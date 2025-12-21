#!/bin/bash
set -e

KEYCLOAK_VERSION="25.0.2"
KEYCLOAK_USER="keycloak"
KEYCLOAK_DIR="/opt/keycloak"
KEYCLOAK_REALM="art-gallery"
KEYCLOAK_ADMIN_USER="admin"
KEYCLOAK_ADMIN_PASSWORD="admin123"
KEYCLOAK_PORT="8180"

echo "=== Install system dependencies ==="
dnf update -y
dnf install -y java-17-amazon-corretto

echo "=== Create keycloak user ==="
id ${KEYCLOAK_USER} &>/dev/null || \
  useradd --system --home ${KEYCLOAK_DIR} --shell /sbin/nologin ${KEYCLOAK_USER}

echo "=== Download Keycloak ==="
cd /opt
if [ ! -d "${KEYCLOAK_DIR}" ]; then
  curl -L -o keycloak.tar.gz \
    https://github.com/keycloak/keycloak/releases/download/${KEYCLOAK_VERSION}/keycloak-${KEYCLOAK_VERSION}.tar.gz

  tar -xzf keycloak.tar.gz
  mv keycloak-${KEYCLOAK_VERSION} keycloak
  chown -R ${KEYCLOAK_USER}:${KEYCLOAK_USER} ${KEYCLOAK_DIR}
fi

echo "=== Create systemd service ==="
cat <<EOF > /etc/systemd/system/keycloak.service
[Unit]
Description=Keycloak
After=network.target

[Service]
Type=simple
User=${KEYCLOAK_USER}
Group=${KEYCLOAK_USER}
Environment=KEYCLOAK_ADMIN=${KEYCLOAK_ADMIN_USER}
Environment=KEYCLOAK_ADMIN_PASSWORD=${KEYCLOAK_ADMIN_PASSWORD}
ExecStart=${KEYCLOAK_DIR}/bin/kc.sh start-dev \
  --http-enabled=true \
  --http-port=${KEYCLOAK_PORT} \
  --http-host=0.0.0.0 \
  --health-enabled=true
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo "=== Start Keycloak ==="
systemctl daemon-reload
systemctl enable keycloak
systemctl restart keycloak

echo "=== Wait for Keycloak to be ready ==="
until curl -sf http://localhost:${KEYCLOAK_PORT}/realms/master > /dev/null; do
  sleep 5
done

echo "=== Login via kcadm ==="
/opt/keycloak/bin/kcadm.sh config credentials \
  --server http://localhost:${KEYCLOAK_PORT} \
  --realm master \
  --user ${KEYCLOAK_ADMIN_USER} \
  --password ${KEYCLOAK_ADMIN_PASSWORD}

echo "=== Create realm (idempotent) ==="
/opt/keycloak/bin/kcadm.sh get realms/${KEYCLOAK_REALM} >/dev/null 2>&1 || \
/opt/keycloak/bin/kcadm.sh create realms \
  -s realm=${KEYCLOAK_REALM} \
  -s enabled=true

echo "=== Keycloak setup complete ==="
