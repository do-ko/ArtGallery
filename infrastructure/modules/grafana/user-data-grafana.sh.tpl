#!/bin/bash
set -e

echo "===> Konfiguracja repozytorium Grafana OSS..."
# konfiguracja repozytorium YUM/DNF dla Grafany, dzięki której system wie skąd pobrać pakiet grafana.
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
echo "===> Repozytorium Grafana OSS zostało skonfigurowane."


echo "===> Instalowanie zależności i grafany..."
dnf update -y
dnf install -y grafana
echo "===> Grafana i zależności zostały zainstalowane."




echo "===> Przygotowanie katalogów provisioning Grafany..."
mkdir -p /etc/grafana/provisioning/datasources
mkdir -p /etc/grafana/provisioning/dashboards
echo "===> Katalogi provisioning Grafany zostały przygotowane."


echo "===> Konfiguracja datasource Prometheus dla Grafany..."
# skąd brać dane
cat <<'EOF' > /etc/grafana/provisioning/datasources/datasource.yml
apiVersion: 1

datasources:
  - name: Prometheus
    uid: PROMETHEUS_DATASOURCE
    type: prometheus
    access: proxy
    url: http://${alb_dns}/prometheus
    isDefault: true
EOF
echo "===> Datasource Prometheus został skonfigurowany."



echo "===> Konfiguracja providerów dashboardów Grafany..."
# skąd brać dashboardy
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
echo "===> Provider dashboardów został skonfigurowany."


echo "===> Instalacja dashboardu ArtGallery..."
# sama konfiguracja dashboardu z providera z poprzedniego configu
cat <<'EOF' > /etc/grafana/provisioning/dashboards/artgallery-dashboard.json
{
  "uid": "artgallery-backend",
  "title": "ArtGallery",
  "timezone": "browser",
  "schemaVersion": 1,
  "version": 1,
  "refresh": "10s",
  "panels": [
    {
      "datasource": {
        "type": "prometheus",
        "uid": "PROMETHEUS_DATASOURCE"
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
        "uid": "PROMETHEUS_DATASOURCE"
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
        "uid": "PROMETHEUS_DATASOURCE"
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
echo "===> Dashboard ArtGallery został zainstalowany."


echo "===> Konfiguracja podstawowych ustawień Grafany..."
# domain = puste bo ma wziąć z nagłówka Host w zapytaniu - pobierze dns alb.
# %(protocol)s - http lub https
# %(domain)s - albo domena z domain= albo Host czyli u mnie z Host
# serve_from_sub_path musi być true żeby uży ścieżki /grafana z root_url
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
echo "===> Konfiguracja Grafany (grafana.ini) została zapisana."



echo "===> Uruchomienie serwisu grafana..."
systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server
echo "===> Serwis grafana został uruchomiony"


echo "===> Skrypt user-data grafana został zakońcony."
