# ALFA Dashboard

> Self-hosted automation platform with SSO, monitoring, and auto-healing

## Quick Start

```bash
# 1. Configure environment
cp .env.example .env
# Edit .env - generate secrets with: openssl rand -base64 32

# 2. Setup local DNS (requires sudo)
sudo ./scripts/setup-dns.sh

# 3. Start stack
docker compose up -d

# 4. Install auto-start service (macOS)
./scripts/install-service.sh install
```

## Services

| Service | URL | Port |
|---------|-----|------|
| n8n | `https://n8n.alfa.local` | 5678 |
| Authentik | `https://auth.alfa.local` | 9000 |
| Uptime Kuma | `https://status.alfa.local` | 3001 |
| Traefik | `https://traefik.alfa.local` | 80/443 |
| PostgreSQL | Internal only | 5432 |
| Redis | Internal only | 6379 |

## Stack Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Internet/Client                      │
└────────────────────────────┬────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────┐
│               Traefik (Reverse Proxy)                    │
│         TLS termination, routing, load balancing         │
└────────────────────────────┬────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────┐
│               Authentik (SSO/Identity)                   │
│           OpenID Connect, SAML, Forward Auth             │
└────────────────────────────┬────────────────────────────┘
                             │
┌─────────────┬──────────────┼──────────────┬─────────────┐
│             │              │              │             │
▼             ▼              ▼              ▼             │
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────────┐       │
│   n8n   │ │ Uptime  │ │ Future  │ │   Future    │       │
│Workflows│ │  Kuma   │ │ Service │ │   Service   │       │
└────┬────┘ └─────────┘ └─────────┘ └─────────────┘       │
     │                                                     │
┌────▼───────────────────────────────────────────────────┐│
│                     PostgreSQL                          ││
│                    (Databases)                          ││
├─────────────────────────────────────────────────────────┤│
│                       Redis                             ││
│                  (Cache/Queue)                          ││
└─────────────────────────────────────────────────────────┘│
```

## Scripts

### DNS Setup

```bash
# Configure /etc/hosts for local development
sudo ./scripts/setup-dns.sh

# Custom domain
sudo ALFA_DOMAIN=mycompany.local ./scripts/setup-dns.sh
```

### Watchdog (Service Monitor)

```bash
# Check status
./scripts/alfa-watchdog.sh status

# Run health check
./scripts/alfa-watchdog.sh check

# Start daemon (runs every 30s)
./scripts/alfa-watchdog.sh daemon 30

# View logs
./scripts/alfa-watchdog.sh logs
```

### Service Management (macOS)

```bash
# Install auto-start
./scripts/install-service.sh install

# Other commands
./scripts/install-service.sh start
./scripts/install-service.sh stop
./scripts/install-service.sh restart
./scripts/install-service.sh status
./scripts/install-service.sh uninstall
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DOMAIN` | Base domain | `alfa.local` |
| `ACME_EMAIL` | Let's Encrypt email | `admin@alfa.local` |
| `POSTGRES_USER` | Database user | `alfa` |
| `POSTGRES_PASSWORD` | Database password | *required* |
| `REDIS_PASSWORD` | Redis password | *required* |
| `AUTHENTIK_SECRET_KEY` | Authentik secret | *required* |
| `N8N_JWT_SECRET` | n8n JWT secret | *required* |

### Generate Secrets

```bash
# Standard secret (32 chars)
openssl rand -base64 32

# Long secret for Authentik (60 chars)
openssl rand -base64 60
```

## Development

### Local Override

Create `docker-compose.override.yml`:

```yaml
services:
  n8n:
    environment:
      - N8N_LOG_LEVEL=debug
    ports:
      - "5678:5678"  # Direct access
```

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f n8n

# Last 100 lines
docker compose logs --tail=100 n8n
```

### Database Access

```bash
# Connect to PostgreSQL
docker exec -it alfa-postgres psql -U alfa

# List databases
docker exec alfa-postgres psql -U alfa -c '\l'

# Run query
docker exec alfa-postgres psql -U alfa -d n8n -c 'SELECT * FROM workflow_entity;'
```

## Initial Setup

### Authentik (SSO)

1. Access `https://auth.alfa.local`
2. Create recovery key:
   ```bash
   docker exec -it alfa-authentik ak create_recovery_key 10 admin
   ```
3. Use recovery key to set admin password
4. Configure applications for SSO

### n8n

1. Access `https://n8n.alfa.local`
2. Create owner account
3. Import workflows from `n8n/workflows/`

### Uptime Kuma

1. Access `https://status.alfa.local`
2. Create admin account
3. Add monitors for all services

## Volumes

| Volume | Purpose | Backup Priority |
|--------|---------|-----------------|
| `alfa-postgres-data` | Database | Critical |
| `alfa-redis-data` | Cache | Low |
| `alfa-n8n-data` | Workflows | High |
| `alfa-uptime-kuma-data` | Monitors | Medium |
| `alfa-traefik-certs` | SSL certs | Medium |
| `alfa-authentik-*` | SSO data | High |

## Troubleshooting

### Service won't start

```bash
# Check logs
docker logs alfa-<service>

# Check dependencies
docker compose ps

# Recreate service
docker compose up -d --force-recreate <service>
```

### Database not found

```bash
# Create missing database
docker exec alfa-postgres psql -U alfa -c 'CREATE DATABASE n8n;'
docker exec alfa-postgres psql -U alfa -c 'CREATE DATABASE authentik;'
```

### SSL issues

For local development, accept self-signed certs or use HTTP.

---

Part of the [ALFA Method](../README.md) for foolproof automation.
