#!/bin/bash
set -e

echo "Starting OpenHalo initialization..."

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL at ${POSTGRES_HOST:-postgres}:${POSTGRES_PORT:-5432}..."
until pg_isready -h "${POSTGRES_HOST:-postgres}" -p "${POSTGRES_PORT:-5432}" -U "${POSTGRES_USER:-wordpress}"; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 2
done
echo "PostgreSQL is ready!"

# Initialize OpenHalo data directory if not already initialized
if [ ! -f "$PGDATA/PG_VERSION" ]; then
    echo "Initializing OpenHalo data directory..."
    initdb -D "$PGDATA" --encoding=UTF8 --locale=en_US.UTF-8
    
    # Configure OpenHalo to listen on MySQL port
    cat >> "$PGDATA/postgresql.conf" <<EOF

# OpenHalo MySQL Protocol Configuration
port = ${MYSQL_PORT:-3306}
listen_addresses = '*'
max_connections = 100
shared_buffers = 128MB

# Enable MySQL compatibility
aux_mysql.enabled = on
aux_mysql.port = ${MYSQL_PORT:-3306}
EOF

    # Configure authentication
    cat >> "$PGDATA/pg_hba.conf" <<EOF

# Allow connections from any host for demo purposes
host    all             all             0.0.0.0/0               md5
host    all             all             ::/0                    md5
EOF

    echo "OpenHalo initialization complete!"
fi

# Start OpenHalo
echo "Starting OpenHalo server on port ${MYSQL_PORT:-3306}..."
exec postgres -D "$PGDATA"
