#!/bin/bash
set -e

dnf update -y
dnf install -y wget

# Mount volume
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

mkfs.xfs $${DISK} || true
mkdir -p /data
mount $${DISK} /data
echo "$${DISK} /data xfs defaults,nofail 0 2" >> /etc/fstab

# MinIO binary
echo "Downloading miniIO"
useradd -r minio -s /sbin/nologin || true
wget https://dl.min.io/server/minio/release/linux-amd64/minio -O /usr/local/bin/minio
wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc
chmod +x /usr/local/bin/minio
chmod +x /usr/local/bin/mc

# Env
echo "Filling env"
cat <<EOF > /etc/default/minio
MINIO_ROOT_USER=${access_key}
MINIO_ROOT_PASSWORD=${secret_key}
MINIO_VOLUMES=/data
MINIO_OPTS="--address :9000 --console-address :9001"
EOF

# Systemd
echo "Config server service"
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
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

echo "Starting service"
chown -R minio:minio /data
systemctl daemon-reload
systemctl enable minio
systemctl start minio

# ustawienie aliasu
echo "Ustawienie aliasu"
until mc alias set local http://localhost:9000 \
  "${access_key}" "${secret_key}"; do
  sleep 2
done
echo "Alias został ustawiony"

echo "Tworzenie bucketu"
mc mb --ignore-existing local/bucket
echo "Przyznawanie dostępu"
mc anonymous set download local/bucket

echo "Koniec skryptu."