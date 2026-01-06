# SPEC - ALFA DASHBOARD

## 🎯 OBJECTIF
Créer une plateforme de gestion unifiée self-hosted en Docker.

## 📦 STACK TECHNIQUE
- **Huly** : Gestion projets/Kanban (port 3000)
- **Infisical** : Gestion secrets/API keys (port 8080)
- **n8n** : Workflows automation (port 5678)
- **Uptime Kuma** : Monitoring (port 3001)
- **Traefik** : Reverse proxy + SSL (ports 80, 443)
- **PostgreSQL** : Base de données
- **Redis** : Cache/Queue

## 🏗️ STRUCTURE

```
alfa-dashboard/
├── docker-compose.yml
├── docker-compose.override.yml (dev)
├── .env.example
├── traefik/
│   └── traefik.yml
├── scripts/
│   ├── setup.sh
│   ├── backup.sh
│   └── health-check.sh
├── docs/
│   └── README.md
└── tests/
    └── docker-compose.test.yml
```

## 🌐 DOMAINES (Local)
- huly.localhost
- infisical.localhost
- n8n.localhost
- status.localhost

## ✅ CRITÈRES D'ACCEPTATION
1. `docker compose up -d` fonctionne sans erreur
2. Tous les services accessibles via navigateur
3. Health checks passent
4. Scripts de backup fonctionnels

## 🔐 GITHUB
- Org: bestophe-group
- Repo: alfa-dashboard (à créer)
- Branch strategy: main + feature branches
- Commits conventionnels (feat:, fix:, docs:)
