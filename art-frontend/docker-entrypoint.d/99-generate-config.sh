#!/usr/bin/env bash
set -e

cat >/tmp/config.template.js <<'EOF'
window.__APP_CONFIG__ = {
  COGNITO_ISSUER_URI: "${COGNITO_ISSUER_URI}",
  COGNITO_DOMAIN_BASE: "${COGNITO_DOMAIN_BASE}",
  COGNITO_CLIENT_ID: "${COGNITO_CLIENT_ID}",
  REDIRECT_URI: "${REDIRECT_URI}",
  LOGOUT_URI: "${LOGOUT_URI}",
  API_BASE: "${API_BASE}"
};
EOF

envsubst < /tmp/config.template.js > /usr/share/nginx/html/config.js
echo "[entrypoint] generated /usr/share/nginx/html/config.js"