# n8n Update Guide - Self-Hosted Docker

**Source**: docs.n8n.io - Self-hosted Update Guide
**Saved**: 2026-01-12

---

## 📋 Best Practices

### Update Frequency
- ✅ **Update at least once a month**
- ✅ Avoid jumping multiple versions at once
- ✅ Check [Release notes](https://docs.n8n.io/release-notes/) for breaking changes
- ✅ Use Environments to test updates first

---

## 🔄 Updating n8n with Docker

### Method 1: Docker Desktop (GUI)

1. Navigate to **Images** tab
2. Select n8n image → **Pull** from context menu
3. Downloads latest n8n image

### Method 2: Command Line (Recommended)

```bash
# Pull latest (stable) version
docker pull docker.n8n.io/n8nio/n8n

# Pull specific version
docker pull docker.n8n.io/n8nio/n8n:1.81.0

# Pull next (unstable) version
docker pull docker.n8n.io/n8nio/n8n:next
```

### Restart Container After Update

```bash
# 1. Find your container ID
docker ps -a | grep n8n

# 2. Stop the container
docker stop <container_id>

# 3. Remove the container
docker rm <container_id>

# 4. Start with new image
docker run --name=<container_name> [options] -d docker.n8n.io/n8nio/n8n
```

---

## 🐳 Updating with Docker Compose (ALFA Method)

```bash
# Navigate to docker-compose directory
cd /Users/arnaud/Documents/ALFA-Agent-Method/alfa-dashboard

# Pull latest version
docker compose pull n8n

# Stop and remove older version
docker compose down n8n

# Start with new version
docker compose up -d n8n
```

### ALFA Specific Update Workflow

```bash
# 1. Check current version
docker exec alfa-n8n n8n --version

# 2. Backup n8n data volume
docker run --rm -v alfa-n8n-data:/data -v $(pwd)/backups:/backup \
  alpine tar czf /backup/n8n-data-$(date +%Y%m%d-%H%M%S).tar.gz -C /data .

# 3. Pull latest image
docker compose pull n8n

# 4. Recreate container with new image
docker compose up -d n8n

# 5. Verify health
docker logs alfa-n8n --tail 50
curl http://localhost:5678/healthz
```

---

## ⚠️ Important Notes

### Data Persistence
- n8n data is stored in volume: `alfa-n8n-data`
- Database: PostgreSQL (`n8n` database)
- Workflows, credentials, executions are preserved during update

### Post-Update Checklist
- [ ] Verify n8n health: `curl http://localhost:5678/healthz`
- [ ] Check active workflows: n8n UI → Workflows
- [ ] Test webhook endpoints
- [ ] Review execution logs
- [ ] Verify credentials still work

### Rollback Procedure (if update fails)

```bash
# 1. Stop new container
docker compose down n8n

# 2. Restore data backup
docker run --rm -v alfa-n8n-data:/data -v $(pwd)/backups:/backup \
  alpine sh -c "cd /data && tar xzf /backup/n8n-data-TIMESTAMP.tar.gz"

# 3. Pin specific version in docker-compose.yml
# Change: image: n8nio/n8n:latest
# To:     image: n8nio/n8n:1.XX.X

# 4. Restart with old version
docker compose up -d n8n
```

---

## 🔧 n8n with Tunnel (Development Only)

**⚠️ WARNING**: Use only for local dev/testing. NOT safe for production.

```bash
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -e GENERIC_TIMEZONE="Europe/Paris" \
  -e TZ="Europe/Paris" \
  -e N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
  -e N8N_RUNNERS_ENABLED=true \
  -v n8n_data:/home/node/.n8n \
  docker.n8n.io/n8nio/n8n \
  start --tunnel
```

**ALFA uses**: Reverse proxy (Traefik) instead of tunnel for production webhooks.

---

## 📊 Version Management

### Check Current Version
```bash
docker exec alfa-n8n n8n --version
```

### Available Versions
- **latest** → Stable releases (recommended)
- **next** → Unstable/beta (not recommended for production)
- **1.XX.X** → Specific version pinning

### ALFA Current Config
- Image: `n8nio/n8n:latest` (docker-compose.yml line 174)
- Update strategy: Pull latest monthly
- Test environment: None (TODO: create staging n8n)

---

## 🔗 Resources

- [n8n Release Notes](https://docs.n8n.io/release-notes/)
- [Docker Hub: n8n](https://hub.docker.com/r/n8nio/n8n)
- [n8n Docker README](https://github.com/n8n-io/n8n/blob/master/docker/images/n8n/README.md)
- [ALFA docker-compose.yml](../alfa-dashboard/docker-compose.yml)

---

**Maintenu par**: Claude Code CLI
**Dernière mise à jour**: 2026-01-12
