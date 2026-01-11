#!/bin/bash
set -e

echo "Install dependencies"
dnf update -y
dnf install -y postgresql15-server postgresql15-contrib awscli jq firewalld

echo "Init db"
if [ ! -d /var/lib/pgsql/data/base ]; then
  /usr/bin/postgresql-setup --initdb
fi

echo "Config addresses"
# PostgreSQL config
sed -i "s/^#listen_addresses =.*/listen_addresses = '*'/" /var/lib/pgsql/data/postgresql.conf
sed -i "s/^listen_addresses =.*/listen_addresses = '*'/" /var/lib/pgsql/data/postgresql.conf

# pg_hba
grep -q "10.0.0.0/16" /var/lib/pgsql/data/pg_hba.conf || \
echo "host all all 10.0.0.0/16 scram-sha-256" >> /var/lib/pgsql/data/pg_hba.conf

echo "Config firewall"
# Firewall
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-port=5432/tcp
firewall-cmd --reload

echo "Restart postgres"
# Restart postgres AFTER config
systemctl enable postgresql
systemctl restart postgresql

echo "Create user + db"
# Create user + db
sudo -u postgres psql <<SQL
CREATE USER ${username} WITH PASSWORD '${password}';
CREATE DATABASE ${db_name} OWNER ${username};
SQL
