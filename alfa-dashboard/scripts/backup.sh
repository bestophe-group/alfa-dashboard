#!/bin/bash
# ========================================
# ALFA Dashboard - Backup Script
# ========================================

set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="${BACKUP_DIR}/alfa_backup_${TIMESTAMP}"

echo "💾 ALFA Dashboard Backup"
echo "========================"
echo "Timestamp: ${TIMESTAMP}"

# Create backup directory
mkdir -p "${BACKUP_PATH}"

# Backup PostgreSQL
echo "📦 Backing up PostgreSQL..."
docker compose exec -T postgres pg_dumpall -U ${POSTGRES_USER} > "${BACKUP_PATH}/postgres.sql"

# Backup Redis
echo "📦 Backing up Redis..."
docker compose exec -T redis redis-cli --raw SAVE
docker compose cp redis:/data/dump.rdb "${BACKUP_PATH}/redis_dump.rdb"

# Backup volumes
echo "📦 Backing up volumes..."
docker run --rm -v alfa-dashboard_huly_data:/data -v $(pwd)/${BACKUP_PATH}:/backup alpine tar czf /backup/huly_data.tar.gz -C /data .
docker run --rm -v alfa-dashboard_n8n_data:/data -v $(pwd)/${BACKUP_PATH}:/backup alpine tar czf /backup/n8n_data.tar.gz -C /data .
docker run --rm -v alfa-dashboard_uptime_kuma_data:/data -v $(pwd)/${BACKUP_PATH}:/backup alpine tar czf /backup/uptime_kuma_data.tar.gz -C /data .

# Backup configuration files
echo "📦 Backing up configuration..."
cp .env "${BACKUP_PATH}/.env.backup"
cp docker-compose.yml "${BACKUP_PATH}/docker-compose.yml"

# Create archive
echo "🗜️  Creating archive..."
cd "${BACKUP_DIR}"
tar czf "alfa_backup_${TIMESTAMP}.tar.gz" "alfa_backup_${TIMESTAMP}"
rm -rf "alfa_backup_${TIMESTAMP}"

echo ""
echo "✅ Backup completed: ${BACKUP_DIR}/alfa_backup_${TIMESTAMP}.tar.gz"
echo "📊 Backup size: $(du -h ${BACKUP_DIR}/alfa_backup_${TIMESTAMP}.tar.gz | cut -f1)"
