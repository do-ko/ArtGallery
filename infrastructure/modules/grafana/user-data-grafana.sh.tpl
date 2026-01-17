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

echo "=== Grafana provisioning ==="

mkdir -p /etc/grafana/provisioning/datasources
mkdir -p /etc/grafana/provisioning/dashboards

# Datasource
cat <<'EOF' > /etc/grafana/provisioning/datasources/datasource.yml
apiVersion: 1

datasources:
  - name: Prometheus
    uid: PROMETHEUS_DS
    type: prometheus
    access: proxy
    url: http://${alb_dns}/prometheus
    isDefault: true
EOF

# Dashboard provider
cat <<'EOF' > /etc/grafana/provisioning/dashboards/dashboard.yml
apiVersion: 1

providers:
  - name: ArtGallery
    orgId: 1
    folder: ArtGallery
    folderUid: artgallery
    type: file
    disableDeletion: false
    editable: true
    options:
      path: /etc/grafana/provisioning/dashboards
EOF

# Dashboard JSON
cat <<'EOF' > /etc/grafana/provisioning/dashboards/guestbook-dashboard.json
{
  "uid": "artgallery-backend",
  "title": "ArtGallery",
  "timezone": "browser",
  "schemaVersion": 37,
  "version": 1,
  "refresh": "10s",
  "panels": [
    {
      "datasource": {
        "type": "prometheus",
        "uid": "PROMETHEUS_DS"
      },
      "type": "stat",
      "title": "HTTP Requests (total)",
      "gridPos": { "x": 0, "y": 0, "w": 8, "h": 4 },
      "targets": [
        {
          "expr": "sum(http_server_requests_seconds_count)",
          "refId": "A"
        }
      ]
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "PROMETHEUS_DS"
      },
      "type": "timeseries",
      "title": "JVM Heap Used",
      "gridPos": { "x": 8, "y": 0, "w": 16, "h": 6 },
      "targets": [
        {
          "expr": "jvm_memory_used_bytes{area=\"heap\"}",
          "refId": "A"
        }
      ]
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "PROMETHEUS_DS"
      },
      "type": "timeseries",
      "title": "HTTP Requests per Status",
      "gridPos": { "x": 0, "y": 6, "w": 24, "h": 6 },
      "targets": [
        {
          "expr": "sum by (status) (http_server_requests_seconds_count)",
          "refId": "A"
        }
      ]
    }
  ]
}
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