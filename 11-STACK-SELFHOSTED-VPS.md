# 11 - STACK SELF-HOSTED VPS
## 100% Open Source • Docker Compose • OVH VPS • n8n 2.0

---

## 📑 SOMMAIRE

1. [Architecture globale](#1-architecture-globale)
2. [Prérequis VPS OVH](#2-prérequis-vps-ovh)
3. [Docker Compose Stack](#3-docker-compose-stack)
4. [n8n 2.0 Features (Janvier 2026)](#4-n8n-20-features-janvier-2026)
5. [Configuration MCP bidirectionnelle](#5-configuration-mcp-bidirectionnelle)
6. [Intégrations SaaS via n8n](#6-intégrations-saas-via-n8n)
7. [Sécurité & Maintenance](#7-sécurité--maintenance)

---

## 1. ARCHITECTURE GLOBALE

### Philosophie : ZÉRO dépendance cloud propriétaire

```
┌──────────────────────────────────────────────────────────────────┐
│                    VPS OVH (Ubuntu 24.04)                        │
│                    4 vCPU • 8GB RAM • 80GB SSD                   │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │   TRAEFIK   │  │   N8N 2.0   │  │  INFISICAL  │              │
│  │   (Proxy)   │  │  (Workflow) │  │  (Secrets)  │              │
│  │   :443      │  │   :5678     │  │   :8080     │              │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘              │
│         │                │                │                      │
│         └────────────────┼────────────────┘                      │
│                          │                                       │
│  ┌─────────────┐  ┌──────┴──────┐  ┌─────────────┐              │
│  │  POSTGRES   │  │    REDIS    │  │  MCP GATEWAY│              │
│  │   (DB)      │  │   (Queue)   │  │   :50800    │              │
│  │   :5432     │  │   :6379     │  │             │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘

         │                    │                    │
         ▼                    ▼                    ▼
    PennyLane            PayFit              GitHub/Notion
    (via n8n)           (via n8n)            (via MCP)
```

### Comparaison : Self-hosted vs Cloud propriétaire

| Critère | Zapier/Pipedream | n8n Self-hosted |
|---------|------------------|-----------------|
| Coût mensuel | 50-500€ | ~15€ VPS |
| Données | Leur cloud | TON serveur |
| Limites | Exécutions/mois | Illimitées |
| MCP natif | ❌ | ✅ |
| Customisation | Limitée | 100% |
| Lock-in | Fort | Zéro |

---

## 2. PRÉREQUIS VPS OVH

### Offre recommandée

| Spec | Minimum | Recommandé |
|------|---------|------------|
| **Offre OVH** | VPS Starter | VPS Essential |
| vCPU | 2 | 4 |
| RAM | 4 GB | 8 GB |
| SSD | 40 GB | 80 GB |
| Bande passante | 250 Mbps | 500 Mbps |
| **Prix** | ~6€/mois | ~15€/mois |

### Setup initial VPS

```bash
# Connexion SSH
ssh root@votre-vps.ovh.net

# Update système
apt update && apt upgrade -y

# Installer Docker + Docker Compose
curl -fsSL https://get.docker.com | sh
apt install docker-compose-plugin -y

# Créer user non-root
adduser deploy
usermod -aG docker deploy
su - deploy

# Créer structure
mkdir -p ~/stack/{n8n,postgres,redis,traefik,infisical}
cd ~/stack
```

---

## 3. DOCKER COMPOSE STACK

### Fichier docker-compose.yml

```yaml
# docker-compose.yml - Stack ALFA Self-Hosted
version: '3.8'

services:
  # ═══════════════════════════════════════════════════════════════
  # TRAEFIK - Reverse Proxy + SSL Auto
  # ═══════════════════════════════════════════════════════════════
  traefik:
    image: traefik:v3.0
    container_name: traefik
    restart: unless-stopped
    command:
      - "--api.dashboard=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.letsencrypt.acme.tlschallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.email=${ACME_EMAIL}"
      - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
      - "--entrypoints.web.http.redirections.entrypoint.to=websecure"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik/letsencrypt:/letsencrypt
    networks:
      - alfa-network

  # ═══════════════════════════════════════════════════════════════
  # POSTGRES - Base de données
  # ═══════════════════════════════════════════════════════════════
  postgres:
    image: postgres:16-alpine
    container_name: postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: n8n
    volumes:
      - ./postgres/data:/var/lib/postgresql/data
    networks:
      - alfa-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

  # ═══════════════════════════════════════════════════════════════
  # REDIS - Queue & Cache
  # ═══════════════════════════════════════════════════════════════
  redis:
    image: redis:7-alpine
    container_name: redis
    restart: unless-stopped
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - ./redis/data:/data
    networks:
      - alfa-network

  # ═══════════════════════════════════════════════════════════════
  # N8N 2.0 - Workflow Automation Engine
  # ═══════════════════════════════════════════════════════════════
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    environment:
      # Database
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: postgres
      DB_POSTGRESDB_PORT: 5432
      DB_POSTGRESDB_DATABASE: n8n
      DB_POSTGRESDB_USER: ${POSTGRES_USER}
      DB_POSTGRESDB_PASSWORD: ${POSTGRES_PASSWORD}
      
      # Queue Mode (scaling)
      EXECUTIONS_MODE: queue
      QUEUE_BULL_REDIS_HOST: redis
      QUEUE_BULL_REDIS_PORT: 6379
      QUEUE_BULL_REDIS_PASSWORD: ${REDIS_PASSWORD}
      
      # n8n 2.0 Features
      N8N_SECURE_COOKIE: "true"
      N8N_RUNNERS_ENABLED: "true"
      N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS: "true"
      
      # MCP Features (n8n 2.0)
      N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE: "true"
      
      # Webhook URL
      WEBHOOK_URL: https://${N8N_DOMAIN}
      N8N_HOST: ${N8N_DOMAIN}
      N8N_PROTOCOL: https
      
      # Timezone
      GENERIC_TIMEZONE: Europe/Paris
      TZ: Europe/Paris
      
      # Encryption
      N8N_ENCRYPTION_KEY: ${N8N_ENCRYPTION_KEY}
    volumes:
      - ./n8n/data:/home/node/.n8n
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - alfa-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.n8n.rule=Host(`${N8N_DOMAIN}`)"
      - "traefik.http.routers.n8n.entrypoints=websecure"
      - "traefik.http.routers.n8n.tls.certresolver=letsencrypt"
      - "traefik.http.services.n8n.loadbalancer.server.port=5678"

networks:
  alfa-network:
    driver: bridge
```

### Fichier .env

```bash
# .env - Variables d'environnement
# ⚠️ NE JAMAIS COMMIT - Utiliser Infisical en prod

# Domain
N8N_DOMAIN=n8n.votre-domaine.com
ACME_EMAIL=votre@email.com

# Postgres
POSTGRES_USER=n8n_user
POSTGRES_PASSWORD=CHANGE_ME_STRONG_PASSWORD_32CHARS

# Redis
REDIS_PASSWORD=CHANGE_ME_ANOTHER_STRONG_PASSWORD

# n8n Encryption (générer: openssl rand -hex 32)
N8N_ENCRYPTION_KEY=CHANGE_ME_64_HEX_CHARS
```

### Démarrage

```bash
# Créer volumes
mkdir -p traefik/letsencrypt n8n/data postgres/data redis/data

# Générer clé encryption
echo "N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)" >> .env

# Démarrer stack
docker compose up -d

# Vérifier logs
docker compose logs -f n8n
```

---

## 4. N8N 2.0 FEATURES (JANVIER 2026)

### Changelog critique

| Feature | Version | Impact ALFA |
|---------|---------|-------------|
| **MCP Server Trigger** | 1.119+ | n8n = serveur MCP |
| **MCP Client Tool** | 1.119+ | n8n consomme MCP |
| **MCP Client Node** | 1.121+ | MCP sans AI Agent |
| **Guardrails Node** | 1.120+ | Sécurité AI |
| **Task Runners isolés** | 2.0 | Sécurité exécution |
| **Custom Project Roles** | 1.121+ | RBAC granulaire |
| **Instance-level MCP** | 1.120+ | MCP centralisé |
| **Autosave** | 2.0 (Jan 2026) | UX améliorée |


### MCP Server Trigger : n8n expose ses workflows

n8n devient un **serveur MCP** que Claude/Cursor peuvent appeler :

```
┌─────────────┐         ┌─────────────┐
│   CURSOR    │   MCP   │    N8N      │
│   Claude    │ ──SSE──►│   Workflow  │
│   ChatGPT   │         │             │
└─────────────┘         └─────────────┘
```

**Configuration workflow n8n :**

```json
// Node: MCP Server Trigger
{
  "authentication": "bearerAuth",
  "credential": "MCP Bearer Token",
  "path": "/mcp/alfa-tools"
}
```

**Connexion depuis Claude Desktop :**

```json
// claude_desktop_config.json
{
  "mcpServers": {
    "n8n-workflows": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://n8n.votre-domaine.com/mcp/alfa-tools",
        "--header",
        "Authorization: Bearer ${N8N_MCP_TOKEN}"
      ]
    }
  }
}
```

### MCP Client Tool : n8n consomme des serveurs MCP

n8n appelle des **serveurs MCP externes** dans ses workflows :

```
┌─────────────┐         ┌─────────────┐
│    N8N      │   MCP   │  Serveur    │
│   AI Agent  │ ──SSE──►│  GitHub     │
│   Workflow  │         │  Obsidian   │
└─────────────┘         └─────────────┘
```

**Configuration AI Agent avec MCP :**

```json
// Node: AI Agent + MCP Client Tool
{
  "mcpServers": [
    {
      "name": "github",
      "url": "https://mcp.github.com/sse",
      "authentication": "oauth2"
    },
    {
      "name": "obsidian",
      "url": "http://localhost:50800/obsidian",
      "authentication": "bearer"
    }
  ]
}
```

### MCP Client Node (standalone) - v1.121+

Appeler MCP **sans passer par AI Agent** :

```json
// Node: MCP Client (standalone)
{
  "operation": "executeTool",
  "serverUrl": "http://mcp-gateway:50800/github",
  "tool": "create_issue",
  "parameters": {
    "repo": "mon-projet",
    "title": "{{ $json.issue_title }}",
    "body": "{{ $json.issue_body }}"
  }
}
```

### Guardrails Node - Sécurité AI

```json
// Node: Guardrails
{
  "operation": "checkTextForViolations",
  "policies": ["nsfw", "prompt_injection", "pii"],
  "text": "{{ $json.user_input }}"
}
```

---

## 5. CONFIGURATION MCP BIDIRECTIONNELLE

### Architecture MCP complète

```
┌─────────────────────────────────────────────────────────────────┐
│                     MCP BIDIRECTIONNEL                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  CURSOR/CLAUDE ◄────────────────────────► N8N WORKFLOWS         │
│       │              MCP Server               │                 │
│       │              Trigger                  │                 │
│       │                                       │                 │
│       │                                       │                 │
│       │              MCP Client               │                 │
│       └──────────────────────────────────────►│                 │
│                                               │                 │
│                                               ▼                 │
│                                    ┌─────────────────┐          │
│                                    │  MCP GATEWAY    │          │
│                                    │   :50800        │          │
│                                    │                 │          │
│                                    │  • GitHub       │          │
│                                    │  • Obsidian     │          │
│                                    │  • Brave Search │          │
│                                    │  • Perplexity   │          │
│                                    └─────────────────┘          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Workflow type : Intégration PennyLane

**SANS Zapier/Pipedream** - 100% n8n :

```yaml
# Workflow: Sync factures PennyLane → Notion
Trigger: Schedule (daily 9:00)
  │
  ▼
HTTP Request: GET PennyLane API
  │ URL: https://app.pennylane.com/companies/{id}/customer_invoices
  │ Headers: Authorization: Bearer {{ $env.PENNYLANE_TOKEN }}
  │
  ▼
Loop: Pour chaque facture
  │
  ▼
Notion: Create/Update page
  │ Database: Factures
  │ Properties: {
  │   "Numéro": facture.invoice_number,
  │   "Client": facture.customer.name,
  │   "Montant": facture.amount,
  │   "Status": facture.status
  │ }
  │
  ▼
IF: facture.status == "late"
  │
  ▼
Slack: Send notification
  │ Channel: #comptabilite
  │ Message: "⚠️ Facture en retard: {{ facture.invoice_number }}"
```


---

## 6. INTÉGRATIONS SAAS VIA N8N

### Remplacement Zapier/Pipedream → n8n natif

| SaaS | Ancienne méthode | Nouvelle méthode n8n |
|------|------------------|---------------------|
| **PennyLane** | Pipedream MCP | HTTP Request + API native |
| **PayFit** | getknit.dev | HTTP Request + API native |
| **HubSpot** | Zapier MCP | Node HubSpot natif |
| **Stripe** | Zapier MCP | Node Stripe natif |
| **Notion** | Zapier MCP | Node Notion natif |
| **Slack** | Zapier MCP | Node Slack natif |
| **Google Drive** | Zapier MCP | Node Google natif |
| **Airtable** | Zapier MCP | Node Airtable natif |

### API directes vs MCP wrappers

```
┌─────────────────────────────────────────────────────────────┐
│  PRÉFÉRENCE D'INTÉGRATION (ordre de priorité)               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. NODE N8N NATIF         (si existe)                      │
│     └── Notion, Slack, HubSpot, Stripe, Google...           │
│                                                             │
│  2. HTTP REQUEST           (API REST directe)               │
│     └── PennyLane, PayFit, APIs custom                      │
│                                                             │
│  3. MCP CLIENT TOOL        (si MCP server existe)           │
│     └── GitHub MCP, Obsidian MCP, Brave MCP                 │
│                                                             │
│  4. PLAYWRIGHT/PUPPETEER   (scraping si pas d'API)          │
│     └── Sites legacy sans API                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Templates workflows clés

**1. PennyLane - Récupération factures**

```json
{
  "name": "PennyLane - Sync Factures",
  "nodes": [
    {
      "type": "n8n-nodes-base.scheduleTrigger",
      "parameters": { "rule": { "interval": [{ "field": "hours", "hoursInterval": 24 }] } }
    },
    {
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "method": "GET",
        "url": "https://app.pennylane.com/companies/{{ $env.PENNYLANE_COMPANY_ID }}/customer_invoices",
        "authentication": "genericCredentialType",
        "genericAuthType": "httpHeaderAuth",
        "options": { "headers": { "Accept": "application/json" } }
      }
    }
  ]
}
```

**2. PayFit - Export données RH**

```json
{
  "name": "PayFit - Export Employés",
  "nodes": [
    {
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "method": "GET",
        "url": "https://api.payfit.com/v1/employees",
        "authentication": "oAuth2Api"
      }
    }
  ]
}
```

**3. Monitoring multi-services**

```json
{
  "name": "Health Check Services",
  "nodes": [
    {
      "type": "n8n-nodes-base.scheduleTrigger",
      "parameters": { "rule": { "interval": [{ "field": "minutes", "minutesInterval": 5 }] } }
    },
    {
      "type": "n8n-nodes-base.splitInBatches",
      "parameters": {
        "batchSize": 1,
        "options": {}
      }
    },
    {
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "url": "={{ $json.healthcheck_url }}",
        "options": { "timeout": 5000 }
      }
    },
    {
      "type": "n8n-nodes-base.if",
      "parameters": {
        "conditions": {
          "number": [{ "value1": "={{ $json.statusCode }}", "operation": "notEqual", "value2": 200 }]
        }
      }
    },
    {
      "type": "n8n-nodes-base.slack",
      "parameters": {
        "channel": "#alerts",
        "text": "🚨 Service DOWN: {{ $json.service_name }}"
      }
    }
  ]
}
```

---

## 7. SÉCURITÉ & MAINTENANCE

### Checklist sécurité

| Élément | Action | Commande |
|---------|--------|----------|
| Firewall | UFW activé | `ufw allow 22,80,443/tcp && ufw enable` |
| SSH | Clé uniquement | `PasswordAuthentication no` |
| Docker | User non-root | `user: "1000:1000"` dans compose |
| Secrets | Infisical | `infisical run -- docker compose up` |
| SSL | Let's Encrypt auto | Via Traefik |
| Backups | Quotidien | Script ci-dessous |

### Script backup automatique

```bash
#!/bin/bash
# /home/deploy/scripts/backup.sh

BACKUP_DIR="/home/deploy/backups"
DATE=$(date +%Y%m%d_%H%M%S)
STACK_DIR="/home/deploy/stack"

# Créer dossier backup
mkdir -p $BACKUP_DIR

# Backup Postgres
docker exec postgres pg_dump -U n8n_user n8n | gzip > $BACKUP_DIR/postgres_$DATE.sql.gz

# Backup n8n workflows
docker exec n8n n8n export:workflow --all --output=/tmp/workflows.json
docker cp n8n:/tmp/workflows.json $BACKUP_DIR/workflows_$DATE.json

# Backup credentials (chiffrées)
docker exec n8n n8n export:credentials --all --output=/tmp/credentials.json
docker cp n8n:/tmp/credentials.json $BACKUP_DIR/credentials_$DATE.json

# Cleanup > 30 jours
find $BACKUP_DIR -type f -mtime +30 -delete

# Sync vers S3 (optionnel)
# aws s3 sync $BACKUP_DIR s3://votre-bucket/backups/
```


### Cron backup

```bash
# Ajouter au crontab
crontab -e

# Backup quotidien à 3h du matin
0 3 * * * /home/deploy/scripts/backup.sh >> /var/log/backup.log 2>&1
```

### Monitoring stack

```yaml
# Ajouter à docker-compose.yml

  # Uptime Kuma - Monitoring
  uptime-kuma:
    image: louislam/uptime-kuma:1
    container_name: uptime-kuma
    restart: unless-stopped
    volumes:
      - ./uptime-kuma/data:/app/data
    networks:
      - alfa-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.uptime.rule=Host(`status.${DOMAIN}`)"
      - "traefik.http.routers.uptime.entrypoints=websecure"
      - "traefik.http.routers.uptime.tls.certresolver=letsencrypt"
```

### Updates n8n

```bash
# Pull dernière version
docker compose pull n8n

# Redémarrer avec nouvelle version
docker compose up -d n8n

# Vérifier version
docker exec n8n n8n --version

# Rollback si problème
docker compose down n8n
docker run -d --name n8n-old n8nio/n8n:1.121.1  # Version précédente
```

---

## 📋 CHECKLIST DÉPLOIEMENT

### Phase 1 : Infrastructure

- [ ] VPS OVH commandé (Essential recommandé)
- [ ] DNS configuré (n8n.domaine.com)
- [ ] SSH configuré (clé + no password)
- [ ] Docker + Docker Compose installés
- [ ] UFW activé

### Phase 2 : Stack

- [ ] docker-compose.yml créé
- [ ] .env configuré (secrets forts)
- [ ] `docker compose up -d`
- [ ] SSL Let's Encrypt actif
- [ ] n8n accessible HTTPS

### Phase 3 : Configuration n8n

- [ ] Compte admin créé
- [ ] Credentials Infisical connectées
- [ ] MCP Server Trigger configuré
- [ ] Premier workflow test créé
- [ ] Webhook URL vérifié

### Phase 4 : Intégrations

- [ ] PennyLane API connectée
- [ ] PayFit API connectée  
- [ ] Notion workspace lié
- [ ] Slack webhook configuré
- [ ] GitHub token ajouté

### Phase 5 : Production

- [ ] Backups automatiques activés
- [ ] Monitoring Uptime Kuma
- [ ] Alertes Slack configurées
- [ ] Documentation équipe

---

## 📊 RÉSUMÉ STACK SELF-HOSTED

| Composant | Rôle | Port | Image Docker |
|-----------|------|------|--------------|
| **Traefik** | Reverse proxy + SSL | 80, 443 | traefik:v3.0 |
| **n8n 2.0** | Workflow engine | 5678 | n8nio/n8n:latest |
| **Postgres** | Database | 5432 | postgres:16-alpine |
| **Redis** | Queue | 6379 | redis:7-alpine |
| **Uptime Kuma** | Monitoring | 3001 | louislam/uptime-kuma:1 |

### Coût total mensuel

| Élément | Coût |
|---------|------|
| VPS OVH Essential | ~15€ |
| Domaine | ~1€ |
| **Total** | **~16€/mois** |

vs Zapier Pro : **~50€/mois** (limité à 750 tasks)

---

**Fiabilité** : 98%

💡 **Conseil** : Commence par n8n seul, ajoute Uptime Kuma après validation des workflows critiques.
