#!/bin/bash
set -e

echo "Starting OpenHalo initialization..."

# Initialize OpenHalo data directory if not already initialized
if [ ! -f "$PGDATA/PG_VERSION" ]; then
    echo "Initializing OpenHalo data directory..."
    pg_ctl init -D "$PGDATA"
    
    # Configure OpenHalo according to official documentation
    # Reference: https://github.com/HaloTech-Co-Ltd/openHalo
    cat >> "$PGDATA/postgresql.conf" <<EOF

# OpenHalo MySQL Compatibility Configuration
# Based on https://github.com/HaloTech-Co-Ltd/openHalo README

# Database compatibility mode
database_compat_mode = 'mysql'              # mysql mode for MySQL compatibility

# MySQL listener configuration
mysql.listener_on = true                    # enable MySQL listener
mysql.port = ${MYSQL_PORT:-3306}           # port for MySQL protocol

# Connection settings
listen_addresses = '*'                      # listen on all interfaces
max_connections = 100                       # maximum number of connections
port = 5432                                 # PostgreSQL port

# Memory settings
shared_buffers = 128MB                      # memory for shared buffers
work_mem = 4MB                              # memory for query operations
maintenance_work_mem = 64MB                 # memory for maintenance operations

# Logging
log_destination = 'stderr'
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_line_prefix = '%m [%p] '
log_timezone = 'UTC'

# Locale settings
datestyle = 'iso, mdy'
timezone = 'UTC'
lc_messages = 'en_US.UTF-8'
lc_monetary = 'en_US.UTF-8'
lc_numeric = 'en_US.UTF-8'
lc_time = 'en_US.UTF-8'
default_text_search_config = 'pg_catalog.english'
EOF

    # Configure authentication for MySQL protocol
    cat >> "$PGDATA/pg_hba.conf" <<EOF

# MySQL protocol authentication (for demo purposes)
# TYPE  DATABASE        USER            ADDRESS                 METHOD
host    all             all             0.0.0.0/0               md5
host    all             all             ::/0                    md5
EOF

    echo "OpenHalo initialization complete!"
fi

# Start OpenHalo server
echo "Starting OpenHalo server..."
echo "  - PostgreSQL port: 5432"
echo "  - MySQL protocol port: ${MYSQL_PORT:-3306}"
pg_ctl start -D "$PGDATA" -l "$PGDATA/logfile" -w

# Wait for server to start
sleep 5

# Create and enable aux_mysql extension for MySQL compatibility
echo "Enabling aux_mysql extension for MySQL compatibility..."
psql -p 5432 -d postgres << EOF
-- Create aux_mysql extension for MySQL compatibility
CREATE EXTENSION IF NOT EXISTS aux_mysql CASCADE;

-- Create WordPress database user
-- Using MySQL native password for compatibility
SET password_encryption = 'mysql_native_password';
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'halo') THEN
        CREATE USER halo PASSWORD 'halo123';
    END IF;
END
\$\$;

-- Grant necessary privileges
GRANT ALL PRIVILEGES ON DATABASE postgres TO halo;
ALTER DATABASE postgres OWNER TO halo;

-- Show user created
SELECT usename, usecreatedb, usesuper FROM pg_shadow WHERE usename='halo';
EOF

echo ""
echo "======================================"
echo "OpenHalo is ready!"
echo "======================================"
echo "PostgreSQL port: 5432"
echo "MySQL protocol port: ${MYSQL_PORT:-3306}"
echo "Database: postgres"
echo "User: halo"
echo "Password: halo123"
echo "======================================"
echo ""

# Keep the container running and tail the log
tail -f "$PGDATA/logfile"
