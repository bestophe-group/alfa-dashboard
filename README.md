# ALFA Dashboard

> Plateforme unifiée de gestion de projets avec Huly, Infisical, n8n, et Uptime Kuma

## 🎯 Vue d'ensemble

ALFA Dashboard est une stack Docker complète pour la gestion de projets, comprenant:

- **Huly** (port 3000) - Gestion de projets et Kanban
- **Infisical** (port 8080) - Gestion des secrets et API keys
- **n8n** (port 5678) - Automatisation de workflows
- **Uptime Kuma** (port 3001) - Monitoring et alertes
- **Traefik** (ports 80/443) - Reverse proxy avec SSL automatique
- **PostgreSQL** (port 5432) - Base de données partagée
- **Redis** (port 6379) - Cache et sessions
- **MongoDB** - Base de données pour Huly

## 📋 Prérequis

- Docker Engine 20.10+
- Docker Compose v2.0+
- 4GB RAM minimum
- 20GB d'espace disque

## 🚀 Installation rapide

### 1. Configuration

```bash
# Copier le fichier d'environnement
cp .env.example .env

# Éditer les variables (IMPORTANT!)
nano .env
```

### 2. Démarrage automatique

```bash
./scripts/setup.sh
```

### 3. Démarrage manuel

```bash
# Valider la configuration
docker compose config

# Démarrer les services
docker compose up -d

# Vérifier le statut
docker compose ps
```

## 🌐 Accès aux services

### Développement local (localhost)

- **Traefik Dashboard**: http://localhost:8080
- **Huly**: http://localhost:3000
- **Infisical**: http://localhost:8080
- **n8n**: http://localhost:5678
- **Uptime Kuma**: http://localhost:3001

### Production (avec domaine)

- **Huly**: https://huly.votredomaine.com
- **Infisical**: https://infisical.votredomaine.com
- **n8n**: https://n8n.votredomaine.com
- **Uptime Kuma**: https://uptime.votredomaine.com

## 🔧 Scripts utiles

### Setup

```bash
./scripts/setup.sh
```

Configure et démarre tous les services.

### Health Check

```bash
./scripts/health-check.sh
```

Vérifie l'état de tous les services et endpoints.

### Backup

```bash
./scripts/backup.sh
```

Crée une sauvegarde complète:
- PostgreSQL dump
- Redis dump
- Volumes Docker (Huly, n8n, Uptime Kuma)
- Fichiers de configuration

Les backups sont stockés dans `./backups/`

## 🧪 Tests

### Tests de structure

```bash
cd tests
./test-stack.sh
```

Vérifie:
- Syntaxe Docker Compose
- Présence des fichiers de configuration
- Définition des volumes et networks
- Présence des healthchecks

### Tests d'endpoints

```bash
cd tests
./test-endpoints.sh
```

Teste:
- Accessibilité des services
- Santé des endpoints
- Connexions aux bases de données

## 📁 Structure du projet

```
alfa-dashboard/
├── docker-compose.yml          # Configuration principale
├── .env                        # Variables d'environnement (à créer)
├── .env.example               # Template de configuration
├── .gitignore                 # Fichiers ignorés par git
├── traefik/
│   └── traefik.yml           # Configuration Traefik
├── scripts/
│   ├── setup.sh              # Installation automatique
│   ├── backup.sh             # Sauvegarde
│   └── health-check.sh       # Vérification santé
├── tests/
│   ├── test-stack.sh         # Tests structure
│   └── test-endpoints.sh     # Tests endpoints
└── README.md                  # Ce fichier
```

## 🔐 Sécurité

### Variables sensibles

Modifiez OBLIGATOIREMENT dans `.env`:

```env
POSTGRES_PASSWORD=changeme          # ⚠️ À changer
REDIS_PASSWORD=changeme             # ⚠️ À changer
N8N_BASIC_AUTH_PASSWORD=changeme    # ⚠️ À changer
N8N_ENCRYPTION_KEY=changeme...      # ⚠️ À changer (32+ chars)
INFISICAL_TOKEN=changeme            # ⚠️ À changer
HULY_SECRET=changeme                # ⚠️ À changer
```

### SSL en production

Traefik gère automatiquement les certificats Let's Encrypt.

Configurez dans `.env`:

```env
DOMAIN=votredomaine.com
ACME_EMAIL=admin@votredomaine.com
```

## 🛠️ Maintenance

### Voir les logs

```bash
# Tous les services
docker compose logs -f

# Un service spécifique
docker compose logs -f huly
docker compose logs -f n8n
```

### Redémarrer un service

```bash
docker compose restart huly
```

### Mettre à jour les images

```bash
docker compose pull
docker compose up -d
```

### Arrêter la stack

```bash
docker compose down
```

### Arrêter et supprimer les volumes

```bash
docker compose down -v  # ⚠️ Supprime les données!
```

## 🔄 Restauration

```bash
# Restaurer PostgreSQL
docker compose exec -T postgres psql -U ${POSTGRES_USER} < backup/postgres.sql

# Restaurer Redis
docker compose cp backup/redis_dump.rdb redis:/data/dump.rdb
docker compose restart redis
```

## 📊 Monitoring

Uptime Kuma permet de monitorer:

1. Tous les services internes
2. Sites web externes
3. Ports TCP
4. APIs

Configurez les alertes via:
- Email
- Slack
- Discord
- Telegram
- etc.

## 🐛 Troubleshooting

### Les services ne démarrent pas

```bash
# Vérifier les logs
docker compose logs

# Vérifier la config
docker compose config

# Vérifier les ressources
docker system df
```

### Port déjà utilisé

Modifiez les ports dans `.env` ou arrêtez le service conflictuel.

### Problème de permissions

```bash
# Traefik acme.json
chmod 600 traefik/letsencrypt/acme.json
```

## 📚 Documentation

- [Huly](https://huly.io/docs)
- [Infisical](https://infisical.com/docs)
- [n8n](https://docs.n8n.io)
- [Uptime Kuma](https://github.com/louislam/uptime-kuma)
- [Traefik](https://doc.traefik.io/traefik/)

## 🤝 Support

Pour toute question ou problème:

1. Vérifiez les logs: `docker compose logs`
2. Lancez le health check: `./scripts/health-check.sh`
3. Consultez la documentation des services

## 📝 License

MIT

---

**Généré avec ALFA-Agent-Method v2.0**
