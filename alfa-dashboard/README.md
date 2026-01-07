# ALFA Dashboard

> Plateforme unifiée de gestion DevOps avec n8n, Infisical, et Uptime Kuma

## 🎯 Vue d'ensemble

ALFA Dashboard est une stack Docker complète pour la gestion DevOps, comprenant:

| Service | Port | Description |
|---------|------|-------------|
| **Traefik** | 80/443/8080 | Reverse proxy avec SSL automatique |
| **PostgreSQL** | 5432 | Base de données principale |
| **Redis** | 6379 | Cache et sessions |
| **n8n** | 5678 | Automatisation de workflows |
| **Infisical** | 8080 | Gestion des secrets et API keys |
| **Uptime Kuma** | 3001 | Monitoring et alertes |

## 📋 Prérequis

- Docker Engine 24.0+
- Docker Compose v2.20+
- 2GB RAM minimum (4GB recommandé)
- 10GB d'espace disque

## 🚀 Installation rapide

### 1. Configuration

```bash
# Copier le fichier d'environnement
cp .env.example .env

# Générer des mots de passe sécurisés
openssl rand -base64 32  # Pour POSTGRES_PASSWORD
openssl rand -base64 32  # Pour REDIS_PASSWORD
openssl rand -hex 32     # Pour N8N_ENCRYPTION_KEY
openssl rand -hex 16     # Pour INFISICAL_ENCRYPTION_KEY (32 chars exactement)
openssl rand -base64 32  # Pour INFISICAL_AUTH_SECRET

# Éditer les variables
nano .env
```

### 2. Démarrage

```bash
# Démarrer les services
docker compose up -d

# Vérifier le statut
docker compose ps

# Lancer les tests
./tests/test-stack.sh
```

## 🌐 Accès aux services

### Développement local

| Service | URL |
|---------|-----|
| Traefik Dashboard | http://localhost:8080 |
| n8n | http://localhost:5678 (via container) |
| Uptime Kuma | http://localhost:3001 (via container) |
| Infisical | http://localhost:8080 (via container) |

### Production (avec domaine)

| Service | URL |
|---------|-----|
| n8n | https://n8n.votredomaine.com |
| Infisical | https://secrets.votredomaine.com |
| Uptime Kuma | https://status.votredomaine.com |
| Traefik | https://traefik.votredomaine.com |

## 🔧 Scripts utiles

```bash
# Setup initial
./scripts/setup.sh

# Vérification santé
./scripts/health-check.sh

# Backup complet
./scripts/backup.sh

# Tests
./tests/test-stack.sh
```

## 📁 Structure du projet

```
alfa-dashboard/
├── docker-compose.yml          # Stack principale (6 services)
├── .env                        # Variables d'environnement
├── .env.example               # Template de configuration
├── traefik/
│   ├── traefik.yml           # Configuration Traefik
│   └── dynamic/              # Config dynamique
├── scripts/
│   ├── setup.sh              # Installation
│   ├── backup.sh             # Sauvegarde
│   └── health-check.sh       # Health check
├── tests/
│   ├── test-stack.sh         # Tests stack (34 tests)
│   └── test-endpoints.sh     # Tests endpoints
└── README.md
```

## 🔐 Sécurité

### Variables sensibles à modifier

```env
POSTGRES_PASSWORD=<générer avec openssl>
REDIS_PASSWORD=<générer avec openssl>
N8N_ENCRYPTION_KEY=<32 caractères hex>
INFISICAL_ENCRYPTION_KEY=<32 caractères exactement>
INFISICAL_AUTH_SECRET=<base64>
```

### SSL en production

Traefik gère automatiquement les certificats Let's Encrypt:

```env
DOMAIN=votredomaine.com
ACME_EMAIL=admin@votredomaine.com
```

## 🛠️ Maintenance

```bash
# Logs
docker compose logs -f [service]

# Redémarrer un service
docker compose restart [service]

# Mise à jour
docker compose pull && docker compose up -d

# Arrêt
docker compose down

# Arrêt + suppression données
docker compose down -v  # ⚠️ Destructif!
```

## 🧪 Tests

```bash
# 34 tests automatisés
./tests/test-stack.sh

# Vérifie:
# - Syntaxe Docker Compose
# - Fichiers de configuration
# - Volumes et networks
# - Healthchecks
# - Containers running
# - Services healthy
# - Endpoints répondent
```

## 📊 Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      TRAEFIK                            │
│              (Reverse Proxy + SSL)                      │
│                   :80 :443 :8080                        │
└───────────────────────┬─────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
   ┌─────────┐    ┌─────────┐    ┌─────────┐
   │   n8n   │    │Infisical│    │ Uptime  │
   │  :5678  │    │  :8080  │    │  Kuma   │
   └────┬────┘    └────┬────┘    │  :3001  │
        │              │         └─────────┘
        │              │
        ▼              ▼
   ┌──────────────────────┐
   │      PostgreSQL      │
   │        :5432         │
   └──────────┬───────────┘
              │
        ┌─────┴─────┐
        │   Redis   │
        │   :6379   │
        └───────────┘
```

## 📚 Documentation

- [n8n](https://docs.n8n.io)
- [Infisical](https://infisical.com/docs)
- [Uptime Kuma](https://github.com/louislam/uptime-kuma)
- [Traefik](https://doc.traefik.io/traefik/)

## 📝 License

MIT

---

**ALFA Dashboard v1.0.0** - Stack fonctionnelle avec 6 services et 34 tests passants.
