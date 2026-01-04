#!/bin/bash
set -e

echo "=== Install system dependencies ==="
dnf update -y
dnf install -y postgresql15-server awscli jq

echo "=== Init db ==="
/usr/bin/postgresql-setup --initdb

systemctl enable postgresql
systemctl start postgresql

echo "=== Tworzenie usera ==="
sudo -u postgres psql <<SQL
CREATE USER ${username} WITH PASSWORD '${password}';
CREATE DATABASE ${db_name} OWNER ${username};
SQL