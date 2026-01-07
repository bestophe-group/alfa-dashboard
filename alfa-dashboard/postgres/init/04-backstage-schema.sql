-- ========================================
-- Backstage Database Schema
-- ========================================

CREATE DATABASE IF NOT EXISTS backstage;

\c backstage;

-- Backstage catalog entities
CREATE TABLE IF NOT EXISTS catalog_entities (
    id SERIAL PRIMARY KEY,
    api_version VARCHAR(255) NOT NULL,
    kind VARCHAR(100) NOT NULL,
    metadata JSONB NOT NULL,
    spec JSONB,
    status JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Backstage techdocs
CREATE TABLE IF NOT EXISTS techdocs (
    id SERIAL PRIMARY KEY,
    entity_ref VARCHAR(500) NOT NULL,
    docs_path TEXT NOT NULL,
    content TEXT,
    published_at TIMESTAMP DEFAULT NOW()
);

-- Software templates (Golden Paths)
CREATE TABLE IF NOT EXISTS software_templates (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    template_type VARCHAR(100) NOT NULL,
    parameters JSONB,
    steps JSONB NOT NULL,
    output JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Golden Paths initial data
INSERT INTO software_templates (name, description, template_type, parameters, steps) VALUES
('node-microservice', 'Node.js Microservice with PostgreSQL', 'backend',
 '{"name": "text", "description": "text", "database": "boolean"}',
 '[{"action": "fetch:template", "id": "fetch", "name": "Fetch Skeleton"}, {"action": "publish:github", "id": "publish", "name": "Publish to GitHub"}]'
),
('react-frontend', 'React Frontend with TypeScript', 'frontend',
 '{"name": "text", "description": "text", "routing": "boolean"}',
 '[{"action": "fetch:template", "id": "fetch"}, {"action": "publish:github", "id": "publish"}]'
),
('python-service', 'Python FastAPI Service', 'backend',
 '{"name": "text", "description": "text", "async": "boolean"}',
 '[{"action": "fetch:template", "id": "fetch"}, {"action": "publish:github", "id": "publish"}]'
)
ON CONFLICT DO NOTHING;

-- Indexes
CREATE INDEX idx_catalog_kind ON catalog_entities(kind);
CREATE INDEX idx_catalog_metadata ON catalog_entities USING GIN (metadata);
CREATE INDEX idx_techdocs_entity ON techdocs(entity_ref);
CREATE INDEX idx_templates_type ON software_templates(template_type);

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO alfa;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO alfa;
