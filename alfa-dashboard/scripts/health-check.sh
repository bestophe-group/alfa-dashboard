#!/bin/bash
# ========================================
# ALFA Dashboard - Health Check Script
# ========================================

set -e

echo "🏥 ALFA Dashboard Health Check"
echo "==============================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check service health
check_service() {
    local service=$1
    local url=$2

    if curl -f -s -o /dev/null -w "%{http_code}" "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $service is healthy"
        return 0
    else
        echo -e "${RED}✗${NC} $service is DOWN"
        return 1
    fi
}

# Check Docker services
echo "📦 Docker Services:"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Health}}"
echo ""

# Check endpoints
echo "🌐 Endpoint Health:"
check_service "Traefik" "http://localhost:8080/ping" || true
check_service "Huly" "http://localhost:3000/health" || true
check_service "n8n" "http://localhost:5678/healthz" || true
check_service "Uptime Kuma" "http://localhost:3001/" || true
echo ""

# Check database connections
echo "💾 Database Health:"
if docker compose exec -T postgres pg_isready -U ${POSTGRES_USER:-alfa} > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} PostgreSQL is ready"
else
    echo -e "${RED}✗${NC} PostgreSQL is not ready"
fi

if docker compose exec -T redis redis-cli --raw ping > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Redis is ready"
else
    echo -e "${RED}✗${NC} Redis is not ready"
fi
echo ""

# Check disk usage
echo "💿 Disk Usage:"
docker system df
echo ""

# Check logs for errors (last 10 lines)
echo "📋 Recent Errors:"
docker compose logs --tail=10 | grep -i error || echo "No recent errors found"
echo ""

echo "✅ Health check completed!"
