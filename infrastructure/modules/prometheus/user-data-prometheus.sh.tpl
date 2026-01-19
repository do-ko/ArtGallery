#!/bin/bash
set -e

echo "===> Instalowanie zależności..."
dnf update -y
dnf install -y wget
echo "===> Zależności zostały zainstalowane."



echo "===> Tworzenie użytkownika prometheus..."
id prometheus &>/dev/null || useradd --system --no-create-home --shell /sbin/nologin prometheus
echo "===> Użytkownik prometheus został przygotowany."



echo "===> Pobieranie Prometheusa..."
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-amd64.tar.gz
tar xzf prometheus-2.52.0.linux-amd64.tar.gz
echo "===> Prometheusa został pobrany i rozpakowany."



echo "===> Instalowanie binarek Prometheusa..."
# 0755 pozwala na automatyczne przyznanie dostępu przy instalacji
install -m 0755 prometheus-2.52.0.linux-amd64/prometheus /usr/local/bin/prometheus
install -m 0755 prometheus-2.52.0.linux-amd64/promtool /usr/local/bin/promtool
echo "===> Binarki Prometheusa (prometheus, promtool) zostały zainstalowane."



echo "===> Tworzenie katalogów dla Prometheusa..."
mkdir -p /etc/prometheus
mkdir -p /var/lib/prometheus
chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
echo "===> Katalogi zostały utworzone."


echo "===> Tworzenie konfiguracji Prometheusa..."
cat <<'EOF' > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "backend"
    metrics_path: /api/actuator/prometheus
    static_configs:
      - targets:
          - ${alb_dns}

  - job_name: prometheus
    metrics_path: /prometheus/metrics
    static_configs:
      - targets: ["localhost:9090"]
EOF
echo "===> Konfiguracja Prometheusa została utworzona."



echo "===> Przygotowanie serwisu dla prometheus..."
cat <<'EOF' > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
After=network-online.target
Wants=network-online.target

[Service]
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.listen-address=:9090 \
  --web.route-prefix=/prometheus \
  --web.external-url=/prometheus
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF
echo "===> Serwis został przygotowany."



echo "===> Uruchomienie serwisu prometheus..."
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus
echo "===> Serwis prometheus został uruchomiony"


echo "===> Skrypt user-data prometheusa został zakońcony."
