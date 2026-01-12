# ALFA Method - Agent-Led Foolproof Automation

> A methodology for developing reliable, self-healing automation workflows with AI agents.

## Overview

The **ALFA Method** (Agent-Led Foolproof Automation) is a systematic approach to building production-ready automation systems that are:

- **Resilient** - Self-healing with automatic restarts and monitoring
- **Observable** - Full visibility into system health and workflow execution
- **Secure** - SSO authentication, secrets management, audit trails
- **Portable** - Works locally and deploys to VPS with minimal changes

## Core Principles

### 1. Anti-Misalignment

Every automation should be **verifiable** and **reversible**:

- Log all actions before execution
- Validate outputs against expected schemas
- Implement rollback mechanisms for destructive operations
- Use checksums and integrity verification

### 2. Progressive Complexity

Build workflows in priority tiers:

| Priority | Description | SLA |
|----------|-------------|-----|
| **P0** | Critical infrastructure (health, monitoring) | Must work 100% |
| **P1** | Core business workflows | 99.9% uptime |
| **P2** | Integration automations | Best effort |
| **P3** | Experimental/Nice-to-have | Optional |

### 3. Defense in Depth

Multiple layers of protection:

```
┌─────────────────────────────────────────────┐
│           Traefik (TLS/Routing)             │
├─────────────────────────────────────────────┤
│           Authentik (SSO/Auth)              │
├─────────────────────────────────────────────┤
│           Application Layer                 │
├─────────────────────────────────────────────┤
│           Database (PostgreSQL)             │
└─────────────────────────────────────────────┘
```

## Architecture

```
alfa-dashboard/
├── docker-compose.yml      # Production stack definition
├── .env.example            # Environment template
├── scripts/
│   ├── setup-dns.sh        # Local DNS configuration
│   ├── alfa-watchdog.sh    # Service monitor daemon
│   ├── install-service.sh  # macOS launchd installer
│   └── backup.sh           # Automated backups
├── postgres/
│   └── init/               # Database initialization
└── n8n/
    └── workflows/          # Automation workflows (P0-P3)
```

## Quick Start

### Prerequisites

- Docker & Docker Compose v2+
- macOS (for launchd) or Linux (for systemd)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/ALFA-Agent-Method.git
cd ALFA-Agent-Method/alfa-dashboard

# 2. Configure environment
cp .env.example .env
# Edit .env with your values (generate secrets with openssl rand -base64 32)

# 3. Setup local DNS (requires sudo)
sudo ./scripts/setup-dns.sh

# 4. Start the stack
docker compose up -d

# 5. Install auto-start service (macOS)
./scripts/install-service.sh install
```

### Access Points

| Service | URL | Description |
|---------|-----|-------------|
| Traefik | `https://traefik.alfa.local` | Reverse proxy dashboard |
| Authentik | `https://auth.alfa.local` | SSO management |
| n8n | `https://n8n.alfa.local` | Workflow automation |
| Grafana | `https://grafana.alfa.local` | Monitoring dashboards |
| Prometheus | `https://prometheus.alfa.local` | Metrics & alerts |
| Alertmanager | `https://alerts.alfa.local` | Alert management |
| Uptime Kuma | `https://status.alfa.local` | Service health |
| Backstage | `https://portal.alfa.local` | Developer portal |

## Services

### Core Infrastructure

- **Traefik** - Reverse proxy with automatic TLS & metrics
- **PostgreSQL** - Primary database with pgvector extension
  - Service Desk & Backstage schemas
  - **RAG Knowledge Base** - Vector embeddings for semantic search
  - HNSW index for fast similarity search
  - Full-text search in French
- **Redis** - Cache and message queue

### Identity & Security

- **Authentik** - SSO identity provider (OIDC, SAML, LDAP)
- **Falco** - Runtime security & intrusion detection
- **Falcosidekick** - Security alert routing to n8n & Slack
- **Trivy** - Daily vulnerability scanning

### Monitoring & Observability

- **Prometheus** - Metrics collection & time-series database
- **Loki** - Log aggregation & querying
- **Promtail** - Log shipper for Docker containers
- **Grafana** - Unified visualization dashboards
  - Security Dashboard (Falco alerts, auth failures)
  - Executive Dashboard (SLA, uptime, incidents)
  - Operations Dashboard (CPU, memory, network, logs)
- **Alertmanager** - Multi-channel alert routing
- **Node Exporter** - Host metrics collection
- **cAdvisor** - Container metrics collection
- **Uptime Kuma** - Service health monitoring
- **ALFA Watchdog** - Container auto-restart daemon

### Automation

- **n8n** - Visual workflow automation engine
- **13+ workflows** organized by priority:
  - **P0** (5): Falco intrusion detection, Trivy scanning, incident response, auto-isolation, critical alerts
  - **P1** (5): Azure AD password reset, SharePoint creation, PennyLane/PayFit sync, service desk handler
  - **P2** (3): User onboarding/offboarding, Teams channel creation
  - **P3**: OSINT, cyber threat watch, morning rituals

### Platform Engineering

- **Backstage** - Developer portal with self-service
  - Service catalog
  - TechDocs documentation
  - Golden Paths templates (Node, React, Python)
  - Software templates for standardized deployments

### RAG Knowledge Base

- **PostgreSQL + pgvector** - Vector database for semantic search
  - **Documents** - Markdown, PDF, HTML, code files
  - **Chunks** - Intelligent text splitting with overlap
  - **Embeddings** - 1536-dimensional vectors (OpenAI compatible)
  - **Search capabilities**:
    - **Vector Search** - Semantic similarity using cosine distance
    - **Fulltext Search** - Keyword matching in French
    - **Hybrid Search** - Combined vector + fulltext (70/30 weighting)
  - **Features**:
    - Deduplication via SHA256 hashing
    - HNSW index for fast similarity search (m=16, ef_construction=64)
    - GIN index for French full-text search
    - JSONB metadata support
    - Automatic chunking with configurable size and overlap

**Available Functions**:
- `rag.ingest_document()` - Ingest documents with deduplication
- `rag.chunk_document()` - Split documents into chunks
- `rag.store_embedding()` - Store vector embeddings
- `rag.search_vector()` - Semantic search with similarity threshold
- `rag.search_fulltext()` - Keyword search with ranking
- `rag.search_hybrid()` - Combined search for best results

**Documentation**: See [docs/RAG.md](docs/RAG.md) for detailed usage and examples.

## Workflow Organization

### P0 - Critical (Security & Infrastructure)

- `41-falco-intrusion-detect.json` - Runtime security events from Falco
- `42-trivy-daily-scan.json` - Daily vulnerability scanning
- `43-incident-response-playbook.json` - Automated incident response
- `44-auto-isolation.json` - Automatic container isolation on compromise
- `45-critical-alert-handler.json` - Multi-channel critical alerts

### P1 - Core Business & Admin

- `46-password-reset-azure.json` - Azure AD password reset automation
- `47-sharepoint-create.json` - SharePoint site & library creation
- `48-pennylane-invoice-sync.json` - PennyLane invoice sync (every 6h)
- `49-payfit-employee-export.json` - PayFit employee export (weekly)
- `50-service-request-handler.json` - Service Desk request router

### P2 - HR & Integrations

- `52-user-onboarding.json` - Automated user onboarding (Azure AD, email, access)
- `53-user-offboarding.json` - Automated user offboarding (disable, revoke sessions)
- `54-teams-channel-create.json` - Microsoft Teams channel creation
- Linear/Notion project sync (planned)
- Sentry error routing (planned)

### P3 - Intelligence & Experimental

- OSINT company/executive scans (planned)
- Cyber threat intelligence watch (planned)
- Morning ritual automations (planned)

## Resilience Features

### Auto-Restart Daemon

The watchdog monitors all services every 30 seconds:

```bash
# Check status
./scripts/alfa-watchdog.sh status

# Run single check
./scripts/alfa-watchdog.sh check

# Start daemon mode
./scripts/alfa-watchdog.sh daemon 30

# View logs
./scripts/alfa-watchdog.sh logs
```

### macOS Auto-Start

```bash
# Install launchd service
./scripts/install-service.sh install

# Service commands
./scripts/install-service.sh start
./scripts/install-service.sh stop
./scripts/install-service.sh status
./scripts/install-service.sh uninstall
```

## VPS Deployment

The stack is VPS-ready. To deploy:

1. Update `.env` with production values:
   ```
   DOMAIN=your-domain.com
   ACME_EMAIL=admin@your-domain.com
   ```

2. Configure DNS records (A records for subdomains)

3. Deploy:
   ```bash
   docker compose up -d
   ```

4. Initial Authentik setup:
   ```bash
   docker exec -it alfa-authentik ak create_recovery_key 10 admin
   ```

## Development

### Local Development Override

Create `docker-compose.override.yml` for local changes:

```yaml
services:
  n8n:
    environment:
      - N8N_LOG_LEVEL=debug
```

### Testing

```bash
# Run stack tests
./tests/test-stack.sh

# Test specific endpoints
./tests/test-endpoints.sh
```

## Contributing

1. Follow the priority system (P0-P3) for new workflows
2. Include error handling and logging in all workflows
3. Test locally before pushing
4. Document webhook endpoints and required credentials

## License

MIT License - See LICENSE file for details.

---

Built with the ALFA Method for reliable, self-healing automation.
