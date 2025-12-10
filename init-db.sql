-- PostgreSQL initialization script for WordPress via OpenHalo
-- This ensures the database is properly set up

-- Create WordPress database if it doesn't exist
SELECT 'CREATE DATABASE wordpress'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'wordpress')\gexec

-- Grant privileges to WordPress user
GRANT ALL PRIVILEGES ON DATABASE wordpress TO wordpress;

-- Connect to WordPress database
\c wordpress

-- Enable required extensions for WordPress compatibility
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Set proper permissions
GRANT ALL ON SCHEMA public TO wordpress;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO wordpress;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO wordpress;

-- Log initialization
DO $$
BEGIN
    RAISE NOTICE 'WordPress database initialized successfully for OpenHalo';
END $$;
