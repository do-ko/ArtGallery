#!/bin/bash
set -e

echo "===> Instalowanie zależności i postgresa..."
dnf update -y
dnf install -y postgresql15-server postgresql15-contrib awscli jq
echo "===> Zależności zostały zainstalowane."



echo "===> Oczekiwanie na dysk..."
while true; do
# pobieram listę pełnych śceiżek dysków z wykluczeniem dysku systemowego nvme0n1 i biorę pierwszy
# (skrypt próbuje znaleźć pierwszy dodatkowy dysk, który nie jest nvme0n1)
  DISK=$(lsblk -dpno NAME | grep -v nvme0n1 | head -n 1)
  if [ -n "$DISK" ]; then
    break
  fi
  sleep 3
done
echo "===> Znaleziono dysk: $DISK"


echo "===> Sprawdzenie czy dysk potrzebuje formatowania..."
if ! blkid "$DISK" >/dev/null 2>&1; then
  echo "===> Formatowanie dysku..."
  mkfs.xfs "$DISK"
fi
echo "===> Dysk jest sformatowany."


echo "===> Montowanie dysku z ebs..."
mkdir -p /data
mountpoint -q /data || mount "$DISK" /data
grep -q "^$DISK /data" /etc/fstab || echo "$DISK /data xfs defaults,nofail 0 2" >> /etc/fstab
echo "===> Dysk został zamontowany."



echo "===> Przygotowanie katalogu danych PostgreSQL (PGDATA) na wolumenie EBS..."
PGDATA="/data/postgres"
mkdir -p "$PGDATA"
chown -R postgres:postgres "$PGDATA"
chmod 700 "$PGDATA" # 700 wymagane przez postgresa (tylko właściciel ma uprawnienia read,write,execute)
echo "===> PGDATA został przygotowany."



echo "===> Konfiguracja override systemd: PGDATA na EBS (/data/postgres)"
mkdir -p /etc/systemd/system/postgresql.service.d
cat <<EOF > /etc/systemd/system/postgresql.service.d/override.conf
[Service]
Environment=PGDATA=/data/postgres
EOF
systemctl daemon-reload
echo "===> Systemd postgresql.service został nadpisany."



echo "===> Inicjowanie bazy danych..."
if [ ! -f "$PGDATA/PG_VERSION" ]; then
  echo "===> Inicjowanie nowego klastra PostgreSQL..."
  sudo -u postgres initdb -D "$PGDATA"
  echo "===> Klaster PostgreSQL został utworzony."
else
  echo "===> Klaster PostgreSQL już istnieje – pomijam initdb."
fi



echo "===> Konfigurowanie adresów..."
# Otwarcie PostgreSQL na sieć:
sed -i "s/^#listen_addresses =.*/listen_addresses = '*'/" "$PGDATA/postgresql.conf"
sed -i "s/^listen_addresses =.*/listen_addresses = '*'/" "$PGDATA/postgresql.conf"

# Wszyscy użytkownicy mogą łączyć się się do wszystkich baz z sieci 10.0.0.0/16, używając bezpiecznego hasła (SCRAM).
# 10.0.0.0/16 - to zakres adresów z mojego vpc.
grep -q "10.0.0.0/16" "$PGDATA/pg_hba.conf" || echo "host all all 10.0.0.0/16 scram-sha-256" >> "$PGDATA/pg_hba.conf"
echo "===> Adresy zostały skonfigurowane."




echo "===> Uruchomienie serwisu postgresql..."
systemctl enable postgresql
systemctl restart postgresql
echo "===> Serwis postgresql został uruchomiony."




echo "===> Tworzenie użytkownika bazy danych..."
sudo -u postgres psql <<SQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${username}') THEN
    CREATE USER ${username} WITH PASSWORD '${password}';
  END IF;
END
\$\$;
SQL
echo "===> Użytkownik bazy danych został utworzony."


echo "===> Tworzenie bazy danych..."
sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='${db_name}'" | grep -q 1 || \
sudo -u postgres createdb -O ${username} ${db_name}
echo "===> Baza danych została utworzona."


echo "===> Skrypt user-data postgres został zakońcony."
