#!/bin/bash
set -e

KEYCLOAK_VERSION="21.1.2"
KEYCLOAK_USER="keycloak"
KEYCLOAK_DIR="/opt/keycloak"
KEYCLOAK_REALM="art-gallery"
KEYCLOAK_ADMIN_USER="admin"
KEYCLOAK_ADMIN_PASSWORD="admin123"
KEYCLOAK_PORT="8180"
ALB_DNS="${alb_dns}"

SMTP_USER="${smtp_user}"
SMTP_APP_PASSWORD="${smtp_app_password}"



echo "===> Instalowanie zależności..."
dnf update -y
dnf install -y java-17-amazon-corretto
echo "===> Zależności zostały zainstalowane."



echo "===> Tworzenie użytkownika dla keycloaka..."
id $${KEYCLOAK_USER} &>/dev/null || useradd --system --home $${KEYCLOAK_DIR} --shell /sbin/nologin $${KEYCLOAK_USER}
echo "===> Użytkownik keycloak został utworzony."



echo "===> Pobieranie keycloaka..."
cd /opt
if [ ! -d "$${KEYCLOAK_DIR}" ]; then
  curl -L -o keycloak.tar.gz \
    https://github.com/keycloak/keycloak/releases/download/$${KEYCLOAK_VERSION}/keycloak-$${KEYCLOAK_VERSION}.tar.gz

  tar -xzf keycloak.tar.gz
  mv keycloak-$${KEYCLOAK_VERSION} keycloak
  chown -R $${KEYCLOAK_USER}:$${KEYCLOAK_USER} $${KEYCLOAK_DIR}
fi
echo "===> Keycloak został pobrany i rozpakowany."



echo "===> Przygotowanie serwisu dla keycloaka..."
cat <<EOF > /etc/systemd/system/keycloak.service
[Unit]
Description=Keycloak
After=network.target

[Service]
User=$${KEYCLOAK_USER}
Group=$${KEYCLOAK_USER}
Environment=KEYCLOAK_ADMIN=$${KEYCLOAK_ADMIN_USER}
Environment=KEYCLOAK_ADMIN_PASSWORD=$${KEYCLOAK_ADMIN_PASSWORD}
ExecStartPre=$${KEYCLOAK_DIR}/bin/kc.sh build
ExecStart=$${KEYCLOAK_DIR}/bin/kc.sh start-dev \
  --http-enabled=true \
  --http-port=$${KEYCLOAK_PORT} \
  --hostname-strict=false \
  --http-host=0.0.0.0 \
  --hostname=$${ALB_DNS} \
  --health-enabled=true
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
echo "===> Serwis został przygotowany."


echo "===> Uruchomienie serwisu keycloaka..."
systemctl daemon-reload
systemctl enable keycloak
systemctl restart keycloak
echo "===> Serwis keycloak został uruchomiony"


echo "===> Oczekiwanie na gotowość serwisu keycloak..."
until curl -sf http://localhost:$${KEYCLOAK_PORT}/realms/master > /dev/null; do
  sleep 5
done
echo "===> Serwis keycloak jest gotowy do obsługi zapytań."


echo "===> Ustawienie danych logowanie do skryptu kcadm"
$${KEYCLOAK_DIR}/bin/kcadm.sh config credentials \
  --server http://localhost:$${KEYCLOAK_PORT} \
  --realm master \
  --user $${KEYCLOAK_ADMIN_USER} \
  --password $${KEYCLOAK_ADMIN_PASSWORD}
echo "===> Dane logowania do skryptu kcadm zostały ustawione."


echo "===> Tworzenie nowego realmu dla art gallery..."
  $${KEYCLOAK_DIR}/bin/kcadm.sh create realms \
    --server http://localhost:$${KEYCLOAK_PORT} \
    -s realm=$${KEYCLOAK_REALM} \
    -s enabled=true \
    -s registrationAllowed=true \
    -s registrationEmailAsUsername=true \
    -s verifyEmail=true \
    -s resetPasswordAllowed=true \
    -s rememberMe=true \
    -s loginWithEmailAllowed=true \
    -s passwordPolicy="length(12) and upperCase(1) and lowerCase(1) and digits(1) and specialChars(1) and notUsername" \
    -s smtpServer.host="smtp.gmail.com" \
    -s smtpServer.port="587" \
    -s smtpServer.from=$${SMTP_USER} \
    -s smtpServer.auth=true \
    -s smtpServer.user=$${SMTP_USER} \
    -s smtpServer.password="$${SMTP_APP_PASSWORD}" \
    -s smtpServer.starttls=true
echo "===> Nowy realm art gallery został utworzony."



echo "===> Tworzenie nowego klienta dla frontendu..."
$${KEYCLOAK_DIR}/bin/kcadm.sh create clients \
  -r $${KEYCLOAK_REALM} \
  -f - <<EOF
{
  "clientId": "art-gallery-frontend",
  "name": "Art Gallery Frontend",
  "enabled": true,
  "protocol": "openid-connect",

  "publicClient": true,

  "standardFlowEnabled": true,
  "implicitFlowEnabled": false,
  "directAccessGrantsEnabled": false,
  "bearerOnly": false,

  "attributes": {
    "pkce.code.challenge.method": "plain"
  },

  "redirectUris": [
    "http://$${ALB_DNS}/*"
  ],

  "webOrigins": [
    "http://$${ALB_DNS}"
  ]
}
EOF
echo "===> Nowy klient dla frontendu został stworzony."

echo "===> Skrypt user-data keycloaka został zakońcony."
