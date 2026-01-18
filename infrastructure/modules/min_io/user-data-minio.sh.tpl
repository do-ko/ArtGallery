#!/bin/bash
set -e

echo "===> Instalowanie zależności..."
dnf update -y
dnf install -y wget
echo "===> Zależności zostały zainstalowane."



echo "===> Tworzenie użytkownika dla minio..."
id minio &>/dev/null || useradd --system --create-home --home /var/lib/minio --shell /sbin/nologin minio
echo "===> Użytkownik minio został utworzony."



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
# automatyczne montowanie dysku przy starcie systemu
grep -q "^$DISK /data" /etc/fstab || echo "$DISK /data xfs defaults,nofail 0 2" >> /etc/fstab
echo "===> Dysk został zamontowany."



echo "===> Przyznanie dostępu do dysku dla użytkownika minio..."
chown -R minio:minio /data
echo "===> Dostęp do dysku został przyznanny."



echo "===> Pobieranie MinIO..."
wget https://dl.min.io/server/minio/release/linux-amd64/minio -O /usr/local/bin/minio
wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc
chmod +x /usr/local/bin/minio
chmod +x /usr/local/bin/mc
echo "===> MinIO zostało pobrane."


echo "===> Uzupełnienie zmiennych środowiskowych dla MinIO..."
cat <<EOF > /etc/default/minio
MINIO_ROOT_USER=${access_key}
MINIO_ROOT_PASSWORD=${secret_key}
MINIO_VOLUMES=/data
MINIO_OPTS="--address :9000 --console-address :9001"
EOF
echo "===> Zmienne środowiskowe MinIO zostały uzupełnione."


echo "===> Przygotowanie serwisu dla MinIO..."
cat <<EOF > /etc/systemd/system/minio.service
[Unit]
Description=MinIO
After=network-online.target
RequiresMountsFor=/data

[Service]
User=minio
Group=minio
EnvironmentFile=/etc/default/minio
ExecStart=/usr/local/bin/minio server \$MINIO_OPTS \$MINIO_VOLUMES
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
echo "===> Serwis został przygotowany."


echo "===> Uruchomienie serwisu MinIO..."
systemctl daemon-reload
systemctl enable minio
systemctl start minio
echo "===> Serwis MinIO został uruchomiony."

echo "===> Ustawianie aliasu..."
until sudo -u minio mc alias set local http://localhost:9000 "${access_key}" "${secret_key}"; do
  sleep 2
done
echo "===> Alias został ustawiony."

echo "===> Tworzenie bucketu..."
sudo -u minio mc mb --ignore-existing local/bucket
echo "===> Bbucketu został utworzony."


echo "===> Przyznawanie dostępu do bucketu..."
sudo -u minio mc anonymous set download local/bucket
echo "===> Dostępu do bucketu został przyznany."


echo "===> Skrypt user-data minio został zakońcony."
