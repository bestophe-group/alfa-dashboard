-- =====================================================
-- ALFA Dashboard - PostgreSQL Schema
-- Version: 1.0.0
-- Description: Complete database schema for n8n workflows
-- =====================================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- CORE TABLES
-- =====================================================

-- Workflow execution logs
CREATE TABLE IF NOT EXISTS workflow_logs (
    id SERIAL PRIMARY KEY,
    workflow_id VARCHAR(255),
    workflow_name VARCHAR(255) NOT NULL,
    execution_id VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'running',
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    finished_at TIMESTAMP WITH TIME ZONE,
    duration_ms INTEGER,
    error_message TEXT,
    metadata JSONB DEFAULT '{}',
    executed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_workflow_logs_status ON workflow_logs(status);
CREATE INDEX idx_workflow_logs_workflow_name ON workflow_logs(workflow_name);
CREATE INDEX idx_workflow_logs_executed_at ON workflow_logs(executed_at);

-- Incidents table
CREATE TABLE IF NOT EXISTS incidents (
    id SERIAL PRIMARY KEY,
    incident_id VARCHAR(255) UNIQUE NOT NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    severity VARCHAR(50) NOT NULL DEFAULT 'medium',
    status VARCHAR(50) NOT NULL DEFAULT 'open',
    source VARCHAR(255),
    affected_services TEXT[],
    assigned_to VARCHAR(255),
    slack_thread_ts VARCHAR(255),
    github_issue_url VARCHAR(500),
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolution_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_incidents_status ON incidents(status);
CREATE INDEX idx_incidents_severity ON incidents(severity);
CREATE INDEX idx_incidents_created_at ON incidents(created_at);

-- Security events / Audit trail
CREATE TABLE IF NOT EXISTS security_events (
    id SERIAL PRIMARY KEY,
    event_id VARCHAR(255) UNIQUE NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    severity VARCHAR(50) NOT NULL DEFAULT 'info',
    source VARCHAR(255),
    user_id VARCHAR(255),
    ip_address VARCHAR(45),
    user_agent TEXT,
    action VARCHAR(255),
    resource VARCHAR(255),
    details JSONB DEFAULT '{}',
    is_suspicious BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_security_events_type ON security_events(event_type);
CREATE INDEX idx_security_events_severity ON security_events(severity);
CREATE INDEX idx_security_events_created_at ON security_events(created_at);
CREATE INDEX idx_security_events_suspicious ON security_events(is_suspicious) WHERE is_suspicious = TRUE;

-- =====================================================
-- MONITORING TABLES
-- =====================================================

-- Health check results
CREATE TABLE IF NOT EXISTS health_checks (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL,
    response_time_ms INTEGER,
    status_code INTEGER,
    error_message TEXT,
    metadata JSONB DEFAULT '{}',
    checked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_health_checks_service ON health_checks(service_name);
CREATE INDEX idx_health_checks_status ON health_checks(status);
CREATE INDEX idx_health_checks_checked_at ON health_checks(checked_at);

-- Container stats
CREATE TABLE IF NOT EXISTS container_stats (
    id SERIAL PRIMARY KEY,
    total_containers INTEGER NOT NULL DEFAULT 0,
    running INTEGER NOT NULL DEFAULT 0,
    stopped INTEGER NOT NULL DEFAULT 0,
    details JSONB DEFAULT '{}',
    monitored_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_container_stats_monitored_at ON container_stats(monitored_at);

-- SSL certificates
CREATE TABLE IF NOT EXISTS ssl_certificates (
    id SERIAL PRIMARY KEY,
    domain VARCHAR(255) NOT NULL,
    issuer VARCHAR(255),
    valid_from TIMESTAMP WITH TIME ZONE,
    valid_until TIMESTAMP WITH TIME ZONE,
    days_until_expiry INTEGER,
    is_valid BOOLEAN DEFAULT TRUE,
    last_checked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_ssl_certificates_domain ON ssl_certificates(domain);
CREATE INDEX idx_ssl_certificates_expiry ON ssl_certificates(days_until_expiry);

-- Backup logs
CREATE TABLE IF NOT EXISTS backup_logs (
    id SERIAL PRIMARY KEY,
    backup_id VARCHAR(255) UNIQUE NOT NULL,
    backup_type VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'running',
    file_path VARCHAR(500),
    file_size_bytes BIGINT,
    duration_seconds INTEGER,
    services_backed_up TEXT[],
    error_message TEXT,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_backup_logs_status ON backup_logs(status);
CREATE INDEX idx_backup_logs_type ON backup_logs(backup_type);
CREATE INDEX idx_backup_logs_started_at ON backup_logs(started_at);

-- =====================================================
-- OSINT TABLES
-- =====================================================

-- OSINT company data
CREATE TABLE IF NOT EXISTS osint_companies (
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(500) NOT NULL,
    legal_name VARCHAR(500),
    siret VARCHAR(20),
    siren VARCHAR(15),
    legal_form VARCHAR(255),
    capital DECIMAL(15, 2),
    creation_date DATE,
    address TEXT,
    city VARCHAR(255),
    postal_code VARCHAR(20),
    naf_code VARCHAR(10),
    naf_label VARCHAR(255),
    revenue DECIMAL(15, 2),
    employees INTEGER,
    raw_data JSONB DEFAULT '{}',
    source VARCHAR(100),
    fetched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_osint_companies_siret ON osint_companies(siret);
CREATE INDEX idx_osint_companies_name ON osint_companies(company_name);

-- OSINT directors
CREATE TABLE IF NOT EXISTS osint_directors (
    id SERIAL PRIMARY KEY,
    company_siret VARCHAR(20),
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    full_name VARCHAR(500),
    role VARCHAR(255),
    birth_date DATE,
    nationality VARCHAR(100),
    linkedin_url VARCHAR(500),
    other_mandates JSONB DEFAULT '[]',
    raw_data JSONB DEFAULT '{}',
    fetched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_osint_directors_siret ON osint_directors(company_siret);
CREATE INDEX idx_osint_directors_name ON osint_directors(full_name);

-- OSINT DNS/WHOIS data
CREATE TABLE IF NOT EXISTS osint_dns (
    id SERIAL PRIMARY KEY,
    domain VARCHAR(255) NOT NULL,
    ip_addresses TEXT[],
    mail_servers TEXT[],
    name_servers TEXT[],
    txt_records TEXT[],
    registrar VARCHAR(255),
    creation_date DATE,
    expiry_date DATE,
    email_security JSONB DEFAULT '{}',
    raw_data JSONB DEFAULT '{}',
    fetched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_osint_dns_domain ON osint_dns(domain);

-- OSINT social media
CREATE TABLE IF NOT EXISTS osint_social (
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(500) NOT NULL,
    linkedin_url VARCHAR(500),
    twitter_url VARCHAR(500),
    facebook_url VARCHAR(500),
    youtube_url VARCHAR(500),
    github_url VARCHAR(500),
    instagram_url VARCHAR(500),
    social_presence_score INTEGER DEFAULT 0,
    raw_data JSONB DEFAULT '{}',
    fetched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_osint_social_company ON osint_social(company_name);

-- OSINT reputation
CREATE TABLE IF NOT EXISTS osint_reputation (
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(500) NOT NULL,
    source VARCHAR(100),
    sentiment VARCHAR(50),
    sentiment_score DECIMAL(5, 4),
    mentions_count INTEGER DEFAULT 0,
    positive_count INTEGER DEFAULT 0,
    negative_count INTEGER DEFAULT 0,
    neutral_count INTEGER DEFAULT 0,
    sample_mentions JSONB DEFAULT '[]',
    monitored_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_osint_reputation_company ON osint_reputation(company_name);
CREATE INDEX idx_osint_reputation_monitored_at ON osint_reputation(monitored_at);

-- OSINT investors
CREATE TABLE IF NOT EXISTS osint_investors (
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(500) NOT NULL,
    shareholders JSONB DEFAULT '[]',
    shareholders_count INTEGER DEFAULT 0,
    funding_news JSONB DEFAULT '[]',
    total_funding DECIMAL(15, 2),
    raw_data JSONB DEFAULT '{}',
    fetched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_osint_investors_company ON osint_investors(company_name);

-- Full OSINT reports
CREATE TABLE IF NOT EXISTS osint_reports (
    id SERIAL PRIMARY KEY,
    report_id VARCHAR(255) UNIQUE NOT NULL,
    company_name VARCHAR(500) NOT NULL,
    directors_count INTEGER DEFAULT 0,
    shareholders_count INTEGER DEFAULT 0,
    social_presence_score INTEGER DEFAULT 0,
    data_completeness INTEGER DEFAULT 0,
    report_data JSONB NOT NULL,
    requested_by VARCHAR(255),
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_osint_reports_company ON osint_reports(company_name);
CREATE INDEX idx_osint_reports_generated_at ON osint_reports(generated_at);

-- =====================================================
-- INTEGRATION TABLES
-- =====================================================

-- PennyLane sync logs
CREATE TABLE IF NOT EXISTS pennylane_sync_logs (
    id SERIAL PRIMARY KEY,
    total_invoices INTEGER DEFAULT 0,
    total_pending INTEGER DEFAULT 0,
    total_late INTEGER DEFAULT 0,
    total_amount DECIMAL(15, 2) DEFAULT 0,
    late_amount DECIMAL(15, 2) DEFAULT 0,
    invoices_data JSONB DEFAULT '[]',
    synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_pennylane_synced_at ON pennylane_sync_logs(synced_at);

-- PayFit employee snapshots
CREATE TABLE IF NOT EXISTS payfit_employee_snapshots (
    id SERIAL PRIMARY KEY,
    total_employees INTEGER DEFAULT 0,
    active_employees INTEGER DEFAULT 0,
    department_breakdown JSONB DEFAULT '{}',
    contract_breakdown JSONB DEFAULT '{}',
    employees_data JSONB DEFAULT '[]',
    exported_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_payfit_exported_at ON payfit_employee_snapshots(exported_at);

-- Veille technologique logs
CREATE TABLE IF NOT EXISTS veille_logs (
    id SERIAL PRIMARY KEY,
    total_articles INTEGER DEFAULT 0,
    by_category JSONB DEFAULT '{}',
    by_source JSONB DEFAULT '{}',
    articles JSONB DEFAULT '[]',
    scanned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_veille_scanned_at ON veille_logs(scanned_at);

-- GitHub webhooks
CREATE TABLE IF NOT EXISTS github_webhooks (
    id SERIAL PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL,
    repository VARCHAR(255),
    sender VARCHAR(255),
    action VARCHAR(100),
    payload JSONB NOT NULL,
    processed BOOLEAN DEFAULT FALSE,
    received_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_github_webhooks_event ON github_webhooks(event_type);
CREATE INDEX idx_github_webhooks_repo ON github_webhooks(repository);
CREATE INDEX idx_github_webhooks_received_at ON github_webhooks(received_at);

-- GitLab pipelines
CREATE TABLE IF NOT EXISTS gitlab_pipelines (
    id SERIAL PRIMARY KEY,
    pipeline_id INTEGER,
    project_name VARCHAR(255),
    ref VARCHAR(255),
    status VARCHAR(50),
    duration INTEGER,
    user_name VARCHAR(255),
    commit_sha VARCHAR(50),
    received_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_gitlab_pipelines_status ON gitlab_pipelines(status);
CREATE INDEX idx_gitlab_pipelines_project ON gitlab_pipelines(project_name);

-- Notion sync logs
CREATE TABLE IF NOT EXISTS notion_sync_logs (
    id SERIAL PRIMARY KEY,
    total_projects INTEGER DEFAULT 0,
    by_status JSONB DEFAULT '{}',
    by_priority JSONB DEFAULT '{}',
    overdue_count INTEGER DEFAULT 0,
    projects_data JSONB DEFAULT '[]',
    synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_notion_synced_at ON notion_sync_logs(synced_at);

-- Linear issues
CREATE TABLE IF NOT EXISTS linear_issues (
    id SERIAL PRIMARY KEY,
    issue_id VARCHAR(255),
    identifier VARCHAR(50),
    title VARCHAR(500),
    state VARCHAR(100),
    priority INTEGER,
    assignee VARCHAR(255),
    team VARCHAR(255),
    action VARCHAR(50),
    received_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_linear_issues_state ON linear_issues(state);
CREATE INDEX idx_linear_issues_team ON linear_issues(team);

-- Sentry errors
CREATE TABLE IF NOT EXISTS sentry_errors (
    id SERIAL PRIMARY KEY,
    event_id VARCHAR(255),
    project VARCHAR(255),
    environment VARCHAR(100),
    level VARCHAR(50),
    title TEXT,
    user_count INTEGER DEFAULT 0,
    event_count INTEGER DEFAULT 0,
    action VARCHAR(50),
    received_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_sentry_errors_project ON sentry_errors(project);
CREATE INDEX idx_sentry_errors_level ON sentry_errors(level);

-- Discord commands
CREATE TABLE IF NOT EXISTS discord_commands (
    id SERIAL PRIMARY KEY,
    interaction_id VARCHAR(255),
    command_name VARCHAR(100),
    user_id VARCHAR(255),
    user_name VARCHAR(255),
    guild_id VARCHAR(255),
    received_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_discord_commands_name ON discord_commands(command_name);

-- Telegram messages
CREATE TABLE IF NOT EXISTS telegram_messages (
    id SERIAL PRIMARY KEY,
    message_id VARCHAR(255),
    chat_id VARCHAR(255),
    type VARCHAR(50),
    title VARCHAR(255),
    priority VARCHAR(50),
    source VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_telegram_messages_type ON telegram_messages(type);

-- =====================================================
-- ANALYTICS & REPORTS TABLES
-- =====================================================

-- Weekly digests
CREATE TABLE IF NOT EXISTS weekly_digests (
    id SERIAL PRIMARY KEY,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    total_executions INTEGER DEFAULT 0,
    success_rate INTEGER DEFAULT 0,
    total_incidents INTEGER DEFAULT 0,
    digest_data JSONB DEFAULT '{}',
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_weekly_digests_period ON weekly_digests(period_start, period_end);

-- API rate limiting
CREATE TABLE IF NOT EXISTS api_requests (
    id SERIAL PRIMARY KEY,
    client_id VARCHAR(255) NOT NULL,
    endpoint VARCHAR(255) NOT NULL,
    method VARCHAR(10),
    status_code INTEGER,
    response_time_ms INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_api_requests_client ON api_requests(client_id);
CREATE INDEX idx_api_requests_endpoint ON api_requests(endpoint);
CREATE INDEX idx_api_requests_created_at ON api_requests(created_at);

-- Rate limit violations
CREATE TABLE IF NOT EXISTS rate_limit_violations (
    id SERIAL PRIMARY KEY,
    client_id VARCHAR(255) NOT NULL,
    endpoint VARCHAR(255),
    current_count INTEGER,
    max_requests INTEGER,
    blocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_rate_limit_violations_client ON rate_limit_violations(client_id);

-- Logs aggregation
CREATE TABLE IF NOT EXISTS logs (
    id SERIAL PRIMARY KEY,
    log_id VARCHAR(255) UNIQUE NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    level VARCHAR(20) NOT NULL,
    service VARCHAR(255) NOT NULL,
    message TEXT,
    context JSONB DEFAULT '{}',
    trace_id VARCHAR(255),
    span_id VARCHAR(255),
    environment VARCHAR(50),
    host VARCHAR(255),
    ingested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_logs_level ON logs(level);
CREATE INDEX idx_logs_service ON logs(service);
CREATE INDEX idx_logs_timestamp ON logs(timestamp);
CREATE INDEX idx_logs_trace_id ON logs(trace_id) WHERE trace_id IS NOT NULL;

-- AI Evaluations
CREATE TABLE IF NOT EXISTS ai_evaluations (
    id SERIAL PRIMARY KEY,
    eval_id VARCHAR(255) UNIQUE NOT NULL,
    model VARCHAR(100),
    test_suite VARCHAR(255),
    total_tests INTEGER DEFAULT 0,
    passed INTEGER DEFAULT 0,
    failed INTEGER DEFAULT 0,
    accuracy DECIMAL(5, 2),
    avg_latency_ms INTEGER,
    results JSONB DEFAULT '{}',
    executed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_ai_evaluations_model ON ai_evaluations(model);
CREATE INDEX idx_ai_evaluations_suite ON ai_evaluations(test_suite);

-- =====================================================
-- TEAM & CULTURE TABLES
-- =====================================================

-- Team members
CREATE TABLE IF NOT EXISTS team_members (
    id SERIAL PRIMARY KEY,
    employee_id VARCHAR(255) UNIQUE,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    slack_id VARCHAR(255),
    department VARCHAR(255),
    job_title VARCHAR(255),
    birthday DATE,
    start_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    coffee_roulette_opted_in BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_team_members_email ON team_members(email);
CREATE INDEX idx_team_members_active ON team_members(is_active);

-- Daily quotes
CREATE TABLE IF NOT EXISTS daily_quotes (
    id SERIAL PRIMARY KEY,
    quote TEXT NOT NULL,
    author VARCHAR(255),
    source VARCHAR(100),
    posted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_daily_quotes_posted_at ON daily_quotes(posted_at);

-- Coffee roulette history
CREATE TABLE IF NOT EXISTS coffee_roulette_history (
    id SERIAL PRIMARY KEY,
    pairs_count INTEGER DEFAULT 0,
    pairs_data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_coffee_roulette_created_at ON coffee_roulette_history(created_at);

-- =====================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to tables with updated_at
CREATE TRIGGER update_incidents_updated_at
    BEFORE UPDATE ON incidents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_team_members_updated_at
    BEFORE UPDATE ON team_members
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- INITIAL DATA
-- =====================================================

-- Insert default workflow tags
INSERT INTO workflow_logs (workflow_name, status, executed_at)
VALUES ('Schema Initialization', 'success', NOW())
ON CONFLICT DO NOTHING;

-- =====================================================
-- GRANTS (adjust user as needed)
-- =====================================================

-- Grant permissions to n8n user (if exists)
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'n8n') THEN
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO n8n;
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO n8n;
    END IF;
END
$$;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'ALFA Dashboard schema created successfully!';
    RAISE NOTICE 'Tables created: %', (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public');
END
$$;
