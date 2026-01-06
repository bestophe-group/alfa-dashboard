# SPEC : ALFA Dashboard - Plateforme Unifiée

## 🎯 OBJECTIF

Créer une stack Docker Compose self-hosted qui combine :
- **Huly** : Gestion projets/Kanban/Livrables
- **Infisical** : Gestion secrets/API Keys/Credentials
- **n8n 2.0** : Workflows/Automations
- **Uptime Kuma** : Monitoring/Status
- **Traefik** : Reverse proxy + SSL

## 📁 STRUCTURE À CRÉER

```
alfa-dashboard/
├── docker-compose.yml          # Stack principale
├── docker-compose.override.yml # Config dev locale
├── .env.example                # Template variables
├── traefik/
│   ├── traefik.yml            # Config Traefik
│   └── dynamic/
│       └── middlewares.yml    # Auth, headers, etc.
├── huly/
│   └── config/                # Config Huly si nécessaire
├── infisical/
│   └── config/                # Config Infisical
├── n8n/
│   └── config/                # Config n8n
├── uptime-kuma/
│   └── config/                # Config monitoring
└── scripts/
    ├── setup.sh               # Script d'installation
    ├── backup.sh              # Script de backup
    └── update.sh              # Script de mise à jour
```

## 🐳 DOCKER COMPOSE - REQUIREMENTS

### Services requis

| Service | Image | Port interne | Domaine |
|---------|-------|--------------|---------|
| traefik | traefik:v3.3 | 80, 443, 8080 | - |
| huly | huly/huly:latest | 8087 | huly.${DOMAIN} |
| infisical | infisical/infisical:latest | 8080 | secrets.${DOMAIN} |
| n8n | n8nio/n8n:latest | 5678 | n8n.${DOMAIN} |
| uptime-kuma | louislam/uptime-kuma:1 | 3001 | status.${DOMAIN} |
| postgres | postgres:16-alpine | 5432 | - |
| redis | redis:7-alpine | 6379 | - |
| mongo | mongo:7 | 27017 | - (pour Huly) |

### Variables d'environnement (.env.example)

```env
# Domain
DOMAIN=localhost
ACME_EMAIL=admin@example.com

# Postgres
POSTGRES_USER=alfa
POSTGRES_PASSWORD=changeme
POSTGRES_DB=alfa

# n8n
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=changeme
N8N_ENCRYPTION_KEY=changeme
WEBHOOK_URL=https://n8n.${DOMAIN}

# Infisical
INFISICAL_TOKEN=changeme
ENCRYPTION_KEY=changeme

# Huly
HULY_SECRET=changeme
```

### Réseaux Docker

```yaml
networks:
  frontend:    # Traefik + services exposés
  backend:     # Services internes (DB, Redis)
```

### Volumes persistants

```yaml
volumes:
  postgres-data:
  redis-data:
  mongo-data:
  n8n-data:
  huly-data:
  infisical-data:
  uptime-kuma-data:
  traefik-certs:
```

## 🔧 CONFIGURATION TRAEFIK

### traefik.yml

```yaml
api:
  dashboard: true
  insecure: true  # Dev only, disable in prod

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
  websecure:
    address: ":443"

providers:
  docker:
    exposedByDefault: false
  file:
    directory: /etc/traefik/dynamic

certificatesResolvers:
  letsencrypt:
    acme:
      email: ${ACME_EMAIL}
      storage: /certs/acme.json
      httpChallenge:
        entryPoint: web
```

## 📝 LABELS DOCKER POUR CHAQUE SERVICE

### Pattern standard

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.{service}.rule=Host(`{service}.${DOMAIN}`)"
  - "traefik.http.routers.{service}.entrypoints=websecure"
  - "traefik.http.routers.{service}.tls.certresolver=letsencrypt"
  - "traefik.http.services.{service}.loadbalancer.server.port={PORT}"
```

## 🚀 SCRIPTS

### setup.sh

```bash
#!/bin/bash
# Vérifie Docker
# Copie .env.example → .env si pas existant
# Génère des secrets aléatoires
# Lance docker compose up -d
# Affiche les URLs
```

### backup.sh

```bash
#!/bin/bash
# Dump Postgres
# Dump MongoDB
# Archive les volumes
# Rotation des backups (garde 7 jours)
```

## ✅ CRITÈRES DE SUCCÈS

1. `docker compose up -d` démarre tous les services
2. Tous les services accessibles via leur sous-domaine
3. SSL fonctionnel (ou bypass en dev local)
4. Pas d'erreurs dans `docker compose logs`
5. Health checks OK sur tous les containers

## 🚫 CONTRAINTES

- Pas de dépendances cloud (tout self-hosted)
- Images Docker officielles uniquement
- Compatible macOS (Docker Desktop) et Linux (VPS)
- Secrets JAMAIS en dur dans les fichiers

## 📋 ORDRE D'IMPLÉMENTATION

1. docker-compose.yml avec Traefik + Postgres + Redis
2. Ajouter n8n (le plus simple)
3. Ajouter Uptime Kuma
4. Ajouter Infisical
5. Ajouter Huly (le plus complexe)
6. Scripts setup/backup
7. Documentation README

---

**Développeur : Claude Code CLI**
**Chef de projet : Claude Desktop**
**Date : 2026-01-06**
