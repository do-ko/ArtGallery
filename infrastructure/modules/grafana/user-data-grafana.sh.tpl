#!/bin/bash
set -e

dnf update -y

echo "=== Prepare repo ==="
cat <<EOF > /etc/yum.repos.d/grafana.repo
[grafana]
name=Grafana OSS
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

echo "=== Install Grafana ==="
dnf install -y grafana

cat <<EOF > /etc/grafana/grafana.ini
[server]
http_port = 3000
domain =
root_url = %(protocol)s://%(domain)s/grafana/
serve_from_sub_path = true

[security]
admin_user = admin
admin_password = admin

[auth.anonymous]
enabled = false
EOF


echo "=== Starting grafana ==="
systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server
echo "=== Grafana started ==="