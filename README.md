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
| n8n | `https://n8n.alfa.local` | Workflow automation |
| Authentik | `https://auth.alfa.local` | SSO management |
| Uptime Kuma | `https://status.alfa.local` | Service monitoring |
| Traefik | `https://traefik.alfa.local` | Reverse proxy dashboard |

## Services

### Core Infrastructure

- **Traefik** - Reverse proxy with automatic TLS
- **PostgreSQL** - Primary database
- **Redis** - Cache and message queue

### Identity & Security

- **Authentik** - SSO identity provider (OIDC, SAML, LDAP)

### Automation

- **n8n** - Visual workflow automation engine
- **40+ workflows** organized by priority (P0-P3)

### Monitoring

- **Uptime Kuma** - Service health monitoring
- **ALFA Watchdog** - Container auto-restart daemon

## Workflow Organization

### P0 - Critical (Always Running)

- `P0-001-health-check-ping.json` - System heartbeat
- `P0-002-container-monitoring.json` - Docker health
- `P0-003-ssl-certificate-monitor.json` - TLS expiry alerts
- `P0-004-backup-automation.json` - Automated backups
- `P0-005-incident-management.json` - Alert handling

### P1 - Core Business

- Webhook handlers for GitHub, GitLab
- Slack/Discord notifications
- Invoice monitoring (PennyLane)
- Employee management (PayFit)

### P2 - Integrations

- Linear/Notion project sync
- Sentry error routing
- AI evaluation pipelines
- OSINT automation

### P3 - Experimental

- Coffee roulette matching
- Daily inspiration quotes
- Tech news aggregation

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
