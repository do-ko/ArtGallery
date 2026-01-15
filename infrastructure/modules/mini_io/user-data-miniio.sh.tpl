#!/bin/bash
set -e

dnf update -y

# Mount volume
echo "Mounting storage volume"
mkfs.xfs /dev/xvdg || true
mkdir -p /data
mount /dev/xvdg /data
echo "/dev/xvdg /data xfs defaults,nofail 0 2" >> /etc/fstab

# MinIO binary
echo "Downloading miniIO"
useradd -r minio -s /sbin/nologin || true
wget https://dl.min.io/server/minio/release/linux-amd64/minio -O /usr/local/bin/minio
chmod +x /usr/local/bin/minio

# Env
echo "Filling env"
cat <<EOF > /etc/default/minio
MINIO_ROOT_USER=${access_key}
MINIO_ROOT_PASSWORD=${secret_key}
MINIO_VOLUMES=/data
MINIO_OPTS="--console-address :9001"
EOF

# Systemd
echo "Config service"
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
