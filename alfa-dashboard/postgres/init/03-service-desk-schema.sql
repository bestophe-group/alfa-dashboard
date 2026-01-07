-- ========================================
-- ALFA Service Desk Schema
-- ========================================

-- Create service_catalog table
CREATE TABLE IF NOT EXISTS service_catalog (
    id SERIAL PRIMARY KEY,
    slug VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    auto_executable BOOLEAN DEFAULT FALSE,
    sla_hours INTEGER DEFAULT 24,
    workflow_id VARCHAR(255),
    required_permissions TEXT[],
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create service_requests table
CREATE TABLE IF NOT EXISTS service_requests (
    id SERIAL PRIMARY KEY,
    ticket_id VARCHAR(20) UNIQUE NOT NULL,
    requester_email VARCHAR(255) NOT NULL,
    requester_name VARCHAR(255),
    service_slug VARCHAR(100) REFERENCES service_catalog(slug),
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    status VARCHAR(50) DEFAULT 'new' CHECK (status IN ('new', 'in_progress', 'waiting', 'resolved', 'closed')),
    title VARCHAR(500) NOT NULL,
    description TEXT,
    metadata JSONB DEFAULT '{}',
    auto_resolution BOOLEAN DEFAULT FALSE,
    assigned_to VARCHAR(255),
    resolved_at TIMESTAMP,
    resolution_notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create service_actions table
CREATE TABLE IF NOT EXISTS service_actions (
    id SERIAL PRIMARY KEY,
    request_id INTEGER REFERENCES service_requests(id) ON DELETE CASCADE,
    action_type VARCHAR(100) NOT NULL,
    action_data JSONB,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'running', 'completed', 'failed')),
    executed_by VARCHAR(255),
    executed_at TIMESTAMP,
    result JSONB,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create security_events table (for Falco)
CREATE TABLE IF NOT EXISTS security_events (
    id SERIAL PRIMARY KEY,
    severity VARCHAR(20) NOT NULL,
    rule VARCHAR(255) NOT NULL,
    description TEXT,
    container_name VARCHAR(255),
    event_data JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create vulnerability_scans table (for Trivy)
CREATE TABLE IF NOT EXISTS vulnerability_scans (
    id SERIAL PRIMARY KEY,
    image_name VARCHAR(255) NOT NULL,
    scan_date TIMESTAMP DEFAULT NOW(),
    critical_count INTEGER DEFAULT 0,
    high_count INTEGER DEFAULT 0,
    total_count INTEGER DEFAULT 0,
    scan_data JSONB
);

-- Create incidents table
CREATE TABLE IF NOT EXISTS incidents (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    description TEXT,
    status VARCHAR(50) DEFAULT 'open' CHECK (status IN ('open', 'investigating', 'resolved', 'closed')),
    container_name VARCHAR(255),
    triggered_by VARCHAR(255),
    resolved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create isolation_log table
CREATE TABLE IF NOT EXISTS isolation_log (
    id SERIAL PRIMARY KEY,
    container_name VARCHAR(255) NOT NULL,
    action VARCHAR(50) NOT NULL,
    severity VARCHAR(20) NOT NULL,
    reason TEXT,
    isolated_at TIMESTAMP DEFAULT NOW()
);

-- Create critical_alerts table
CREATE TABLE IF NOT EXISTS critical_alerts (
    id SERIAL PRIMARY KEY,
    alert_name VARCHAR(255) NOT NULL,
    description TEXT,
    timestamp TIMESTAMP DEFAULT NOW(),
    notified BOOLEAN DEFAULT TRUE
);

-- ========================================
-- INDEXES for performance
-- ========================================
CREATE INDEX idx_requests_status ON service_requests(status);
CREATE INDEX idx_requests_requester ON service_requests(requester_email);
CREATE INDEX idx_requests_created ON service_requests(created_at);
CREATE INDEX idx_requests_service ON service_requests(service_slug);
CREATE INDEX idx_actions_request ON service_actions(request_id);
CREATE INDEX idx_actions_status ON service_actions(status);
CREATE INDEX idx_security_severity ON security_events(severity);
CREATE INDEX idx_security_container ON security_events(container_name);
CREATE INDEX idx_security_created ON security_events(created_at);
CREATE INDEX idx_vulns_image ON vulnerability_scans(image_name);
CREATE INDEX idx_vulns_scan_date ON vulnerability_scans(scan_date);
CREATE INDEX idx_incidents_status ON incidents(status);
CREATE INDEX idx_incidents_severity ON incidents(severity);

-- ========================================
-- INITIAL DATA - Service Catalog
-- ========================================
INSERT INTO service_catalog (slug, name, category, auto_executable, sla_hours, workflow_id, description) VALUES
('password_reset', 'Reset mot de passe Azure AD', 'IT', true, 1, 'P1-46-password-reset-azure', 'Réinitialisation de mot de passe Microsoft 365/Azure AD'),
('sharepoint_create', 'Création site SharePoint', 'IT', true, 4, 'P1-47-sharepoint-create', 'Création automatique de site SharePoint avec bibliothèques'),
('user_onboarding', 'Onboarding utilisateur', 'RH', false, 24, 'P2-52-user-onboarding', 'Processus complet d''onboarding d''un nouvel employé'),
('user_offboarding', 'Offboarding utilisateur', 'RH', true, 4, 'P2-53-user-offboarding', 'Processus complet d''offboarding d''un employé sortant'),
('access_request', 'Demande accès application', 'IT', false, 8, 'P2-access-request', 'Demande d''accès à une application SaaS'),
('hardware_request', 'Demande matériel', 'IT', false, 48, 'P3-hardware-request', 'Commande de matériel informatique'),
('vpn_access', 'Accès VPN', 'IT', true, 2, 'P1-vpn-access', 'Configuration accès VPN'),
('email_distribution', 'Liste de distribution email', 'IT', true, 4, 'P2-email-distribution', 'Création/modification liste de distribution'),
('teams_channel', 'Création canal Teams', 'IT', true, 2, 'P2-54-teams-channel', 'Création d''un nouveau canal Microsoft Teams'),
('incident_report', 'Déclaration incident', 'IT', true, 1, 'P0-incident-report', 'Signalement d''un incident de sécurité ou technique')
ON CONFLICT (slug) DO NOTHING;

-- ========================================
-- FUNCTIONS & TRIGGERS
-- ========================================

-- Auto-generate ticket_id
CREATE OR REPLACE FUNCTION generate_ticket_id()
RETURNS TRIGGER AS $$
BEGIN
    NEW.ticket_id := 'ALFA-' || LPAD(NEW.id::text, 6, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_ticket_id
    BEFORE INSERT ON service_requests
    FOR EACH ROW
    WHEN (NEW.ticket_id IS NULL)
    EXECUTE FUNCTION generate_ticket_id();

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_service_catalog_timestamp
    BEFORE UPDATE ON service_catalog
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_service_requests_timestamp
    BEFORE UPDATE ON service_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_incidents_timestamp
    BEFORE UPDATE ON incidents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO alfa;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO alfa;
