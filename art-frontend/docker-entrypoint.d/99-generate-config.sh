#!/usr/bin/env bash
set -e

cat >/tmp/config.template.js <<'EOF'
window.__APP_CONFIG__ = {
  AWS_REGION: "${AWS_REGION}",
  COGNITO_USER_POOL_ID: "${COGNITO_USER_POOL_ID}",
  COGNITO_CLIENT_ID: "${COGNITO_CLIENT_ID}",
  API_BASE: "${API_BASE}"
};
EOF

envsubst < /tmp/config.template.js > /usr/share/nginx/html/config.js
echo "[entrypoint] generated /usr/share/nginx/html/config.js"