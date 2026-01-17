#!/bin/bash
set -e

echo "Install dependencies"
dnf update -y
dnf install -y wget

# Directories
echo "Creating directories"
mkdir -p /etc/prometheus
mkdir -p /var/lib/prometheus

# Download Prometheus
echo "Downloading Prometheus"
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-amd64.tar.gz
tar xzf prometheus-2.52.0.linux-amd64.tar.gz

echo "Copying binaries"
cp prometheus-2.52.0.linux-amd64/prometheus /usr/local/bin/
cp prometheus-2.52.0.linux-amd64/promtool /usr/local/bin/
chmod +x /usr/local/bin/prometheus /usr/local/bin/promtool

echo "Creating config"
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

echo "Creating service"
cat <<'EOF' > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
After=network-online.target
Wants=network-online.target

[Service]
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

echo "Starting service"
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus

echo "=== Prometheus started ==="