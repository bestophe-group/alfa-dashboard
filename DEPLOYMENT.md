# 🚀 ALFA Dashboard - Guide de Déploiement

## 📊 État du Projet

✅ **PROJET FINALISÉ ET DÉPLOYABLE**

### Services Configurés
- ✅ Traefik v2.11 (Reverse proxy + SSL Let's Encrypt)
- ✅ PostgreSQL 16 (Base de données partagée)
- ✅ Redis 7 (Cache et sessions)
- ✅ MongoDB 7 (Base de données Huly)
- ✅ Huly (Gestion de projets Kanban)
- ✅ Infisical (Gestion des secrets)
- ✅ n8n (Automatisation de workflows)
- ✅ Uptime Kuma (Monitoring et alertes)

### Infrastructure
- ✅ Docker Compose configuration complète
- ✅ Tests TDD (structure + endpoints)
- ✅ Scripts d'automatisation (setup, backup, health-check)
- ✅ GitHub Actions CI/CD
- ✅ Documentation complète

---

## 🎯 Déploiement en Production

### Prérequis Serveur

```bash
# Système d'exploitation
Ubuntu 22.04 LTS (recommandé)

# Ressources minimales
- 4GB RAM minimum (8GB recommandé)
- 20GB espace disque
- Docker Engine 20.10+
- Docker Compose v2.0+
- Nom de domaine configuré
```

### 1. Installation sur le Serveur

```bash
# Se connecter au serveur
ssh user@votre-serveur.com

# Installer Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Cloner le repository
cd /opt
sudo git clone https://github.com/bestophe-group/alfa-dashboard.git
cd alfa-dashboard
sudo chown -R $USER:$USER .
```

### 2. Configuration des Variables

```bash
# Copier et éditer .env
cp .env.example .env
nano .env
```

**Variables OBLIGATOIRES à modifier:**

```env
# Domaine
DOMAIN=votredomaine.com
ACME_EMAIL=admin@votredomaine.com

# Sécurité - Générer des mots de passe forts
POSTGRES_PASSWORD=$(openssl rand -base64 32)
REDIS_PASSWORD=$(openssl rand -base64 32)
N8N_BASIC_AUTH_PASSWORD=$(openssl rand -base64 32)
N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)
INFISICAL_TOKEN=$(openssl rand -base64 32)
HULY_SECRET=$(openssl rand -base64 32)
```

### 3. Configuration DNS

Configurez les enregistrements DNS suivants:

```
A    huly.votredomaine.com       → IP_SERVEUR
A    infisical.votredomaine.com  → IP_SERVEUR
A    n8n.votredomaine.com        → IP_SERVEUR
A    uptime.votredomaine.com     → IP_SERVEUR
```

### 4. Déploiement

```bash
# Méthode automatique (recommandée)
./scripts/setup.sh

# OU Méthode manuelle
docker compose pull
docker compose up -d

# Vérifier le statut
docker compose ps
./scripts/health-check.sh
```

### 5. Vérification

```bash
# Voir les logs
docker compose logs -f

# Tester les endpoints
curl https://huly.votredomaine.com
curl https://n8n.votredomaine.com
curl https://infisical.votredomaine.com
curl https://uptime.votredomaine.com
```

---

## 🔄 CI/CD avec GitHub Actions

### Workflows Configurés

**CI Pipeline** (`.github/workflows/ci.yml`)
- ✅ Validation syntaxe Docker Compose
- ✅ Tests de structure
- ✅ Tests de déploiement
- ✅ Scan de sécurité (Trivy)
- ✅ Notifications de résultats

**Deploy Pipeline** (`.github/workflows/deploy.yml`)
- ✅ Déploiement automatique SSH
- ✅ Vérification santé post-déploiement
- ✅ Backup automatique
- ✅ Support production/staging

### Configuration GitHub Actions

Pour activer le déploiement automatique, configurez ces secrets dans GitHub:

```
Repository Settings → Secrets and variables → Actions
```

**Secrets requis:**
- `SSH_PRIVATE_KEY`: Clé SSH privée pour accès serveur
- `SERVER_HOST`: Adresse IP ou domaine du serveur
- `SERVER_USER`: Nom d'utilisateur SSH

**Génération de la clé SSH:**

```bash
# Sur votre machine locale
ssh-keygen -t ed25519 -C "github-actions@alfa-dashboard"

# Copier la clé publique sur le serveur
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@serveur.com

# Copier la clé privée dans GitHub Secrets
cat ~/.ssh/id_ed25519
```

---

## 🧪 Tests

### Tests Locaux

```bash
# Tests de structure
cd tests
./test-stack.sh

# Tests d'endpoints (services doivent être démarrés)
./test-endpoints.sh
```

### Résultats Attendus

```
✅ 17 tests passent dans test-stack.sh
✅ 6 tests passent dans test-endpoints.sh
```

---

## 🔐 Sécurité

### Checklist de Sécurité

- [ ] Tous les mots de passe changés dans `.env`
- [ ] Firewall configuré (ports 80, 443, 22 uniquement)
- [ ] SSH avec clés uniquement (désactiver password auth)
- [ ] Traefik dashboard sécurisé ou désactivé en production
- [ ] Backups automatiques configurés
- [ ] Monitoring actif via Uptime Kuma
- [ ] Certificats SSL configurés (Let's Encrypt)

### Configuration Firewall

```bash
# UFW (Ubuntu)
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

---

## 💾 Sauvegarde et Restauration

### Création d'une Sauvegarde

```bash
# Backup automatique
./scripts/backup.sh

# Backups stockés dans ./backups/YYYY-MM-DD_HH-MM-SS/
```

**Contenu des backups:**
- Dump PostgreSQL
- Dump Redis
- Volumes Docker (Huly, n8n, Uptime Kuma, Infisical)
- Fichiers de configuration

### Restauration

```bash
# Restaurer PostgreSQL
docker compose exec -T postgres psql -U alfa < backups/YYYY-MM-DD/postgres.sql

# Restaurer Redis
docker compose cp backups/YYYY-MM-DD/redis_dump.rdb redis:/data/dump.rdb
docker compose restart redis

# Restaurer volumes
cd backups/YYYY-MM-DD/volumes
docker compose down
sudo cp -r * /var/lib/docker/volumes/
docker compose up -d
```

---

## 🔧 Maintenance

### Commandes Utiles

```bash
# Voir les logs
docker compose logs -f [service]

# Redémarrer un service
docker compose restart [service]

# Mettre à jour les images
docker compose pull
docker compose up -d

# Nettoyer les ressources Docker
docker system prune -a

# Vérifier l'espace disque
df -h
docker system df
```

### Mises à Jour

```bash
# Mettre à jour le code
cd /opt/alfa-dashboard
git pull origin main

# Mettre à jour les services
docker compose pull
docker compose up -d

# Vérifier la santé
./scripts/health-check.sh
```

---

## 📊 Monitoring avec Uptime Kuma

### Configuration Initiale

1. Accéder à `https://uptime.votredomaine.com`
2. Créer un compte admin
3. Ajouter les moniteurs:
   - Huly: `https://huly.votredomaine.com`
   - Infisical: `https://infisical.votredomaine.com/api/status/health`
   - n8n: `https://n8n.votredomaine.com/healthz`
   - Traefik: `http://traefik:8080/ping`

### Configuration des Alertes

Uptime Kuma supporte:
- Email (SMTP)
- Slack
- Discord
- Telegram
- Webhook personnalisé
- Et 90+ autres services

---

## 🆘 Troubleshooting

### Les services ne démarrent pas

```bash
# Vérifier les logs
docker compose logs

# Vérifier la configuration
docker compose config

# Vérifier les ressources
docker stats
df -h
```

### Erreur SSL/Certificats

```bash
# Vérifier les logs Traefik
docker compose logs traefik

# Vérifier les permissions acme.json
ls -l traefik/letsencrypt/acme.json
# Doit être: -rw------- (600)

# Recréer si nécessaire
rm traefik/letsencrypt/acme.json
touch traefik/letsencrypt/acme.json
chmod 600 traefik/letsencrypt/acme.json
docker compose restart traefik
```

### Base de données PostgreSQL

```bash
# Vérifier la connexion
docker compose exec postgres pg_isready -U alfa

# Accéder à la console
docker compose exec postgres psql -U alfa

# Voir les bases de données
\l

# Voir les tables
\dt
```

### Service inaccessible

```bash
# Vérifier que le service est en route
docker compose ps

# Vérifier les healthchecks
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Health}}"

# Vérifier Traefik
curl http://localhost:8080/api/http/routers
```

---

## 📚 Ressources

### Documentation Officielle
- [Huly Docs](https://huly.io/docs)
- [Infisical Docs](https://infisical.com/docs)
- [n8n Docs](https://docs.n8n.io)
- [Uptime Kuma](https://github.com/louislam/uptime-kuma)
- [Traefik v2](https://doc.traefik.io/traefik/)

### Support
- GitHub Issues: https://github.com/bestophe-group/alfa-dashboard/issues
- Documentation: README.md

---

## ✅ Checklist de Déploiement

### Avant le Déploiement
- [ ] Serveur configuré (Docker + Docker Compose)
- [ ] DNS configurés
- [ ] Fichier `.env` créé et sécurisé
- [ ] Firewall configuré
- [ ] GitHub Actions secrets configurés (optionnel)

### Déploiement
- [ ] Repository cloné sur le serveur
- [ ] Services démarrés (`./scripts/setup.sh`)
- [ ] Health check passé (`./scripts/health-check.sh`)
- [ ] Tous les services accessibles via HTTPS

### Post-Déploiement
- [ ] Uptime Kuma configuré avec moniteurs
- [ ] Premier backup créé
- [ ] Cron job backup configuré (optionnel)
- [ ] Documentation serveur mise à jour
- [ ] Accès admin créés pour chaque service

---

**🎉 Déploiement réussi! Votre ALFA Dashboard est opérationnel.**

Généré avec ALFA-Agent-Method v2.0
