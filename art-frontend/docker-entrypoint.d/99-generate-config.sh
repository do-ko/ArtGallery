#!/usr/bin/env bash
set -e

cat >/tmp/config.template.js <<'EOF'
window.__APP_CONFIG__ = {
  AWS_REGION: "${AWS_REGION}",
  API_BASE: "${API_BASE}",
  KEYCLOAK_CLIENT_ID: "${KEYCLOAK_CLIENT_ID}",
  KEYCLOAK_REALM: "${KEYCLOAK_REALM}"
};
EOF

envsubst < /tmp/config.template.js > /usr/share/nginx/html/config.js
echo "[entrypoint] generated /usr/share/nginx/html/config.js"