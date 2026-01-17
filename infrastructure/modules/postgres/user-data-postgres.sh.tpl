#!/bin/bash
set -e

echo "Install dependencies"
dnf update -y
dnf install -y postgresql15-server postgresql15-contrib awscli jq

echo "Mounting storage volume"
echo "Waiting for data disk..."
while true; do
  DISK=$(lsblk -dpno NAME | grep -v nvme0n1 | head -n 1)
  if [ -n "$DISK" ]; then
    break
  fi
  sleep 3
done
echo "Found data disk: $DISK"

# Format ONLY if not formatted
if ! blkid "$DISK" >/dev/null 2>&1; then
  mkfs.xfs "$DISK"
fi

mkdir -p /data
mount "$DISK" /data || true
grep -q "$DISK /data" /etc/fstab || echo "$DISK /data xfs defaults,nofail 0 2" >> /etc/fstab

echo "=== Prepare PGDATA on EBS ==="
PGDATA="/data/postgres"

mkdir -p "$PGDATA"
chown postgres:postgres "$PGDATA"
chmod 700 "$PGDATA"

echo "=== Configure systemd override for PGDATA ==="
mkdir -p /etc/systemd/system/postgresql.service.d

cat <<EOF > /etc/systemd/system/postgresql.service.d/override.conf
[Service]
Environment=PGDATA=/data/postgres
EOF

systemctl daemon-reload


echo "=== Init db ==="
if [ ! -f "$PGDATA/PG_VERSION" ]; then
  sudo -u postgres initdb -D "$PGDATA"
fi

echo "Config addresses"
sed -i "s/^#listen_addresses =.*/listen_addresses = '*'/" "$PGDATA/postgresql.conf"
sed -i "s/^listen_addresses =.*/listen_addresses = '*'/" "$PGDATA/postgresql.conf"

grep -q "10.0.0.0/16" "$PGDATA/pg_hba.conf" || \
echo "host all all 10.0.0.0/16 scram-sha-256" >> "$PGDATA/pg_hba.conf"

echo "=== Start Postgres ==="
systemctl enable postgresql
systemctl restart postgresql

echo "=== Create user (idempotent) ==="
sudo -u postgres psql <<SQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${username}') THEN
    CREATE USER ${username} WITH PASSWORD '${password}';
  END IF;
END
\$\$;
SQL

echo "=== Create database (idempotent) ==="
sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='${db_name}'" | grep -q 1 || \
sudo -u postgres createdb -O ${username} ${db_name}

echo "=== Postgres ready ==="