-- =====================================================
-- ALFA Dashboard - Database Creation
-- =====================================================
-- This script runs FIRST (00-) to create all databases
-- before the schema creation script runs
-- =====================================================

-- Create n8n database
SELECT 'Creating n8n database...' AS status;
CREATE DATABASE n8n WITH OWNER alfa ENCODING 'UTF8';

-- Create authentik database
SELECT 'Creating authentik database...' AS status;
CREATE DATABASE authentik WITH OWNER alfa ENCODING 'UTF8';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE n8n TO alfa;
GRANT ALL PRIVILEGES ON DATABASE authentik TO alfa;

SELECT 'All databases created successfully!' AS status;
