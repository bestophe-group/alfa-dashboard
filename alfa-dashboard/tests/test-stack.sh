#!/bin/bash
# ========================================
# ALFA Dashboard - Stack Tests (TDD)
# ========================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🧪 ALFA Dashboard Stack Tests"
echo "=============================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

PASS=0
FAIL=0

# Test function
test_case() {
    local name=$1
    local command=$2

    echo -n "Testing: $name... "

    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        ((FAIL++))
        return 1
    fi
}

echo -e "${YELLOW}=== Static Tests ===${NC}"

# Test 1: Docker Compose syntax
test_case "Docker Compose syntax" "docker compose -f $PROJECT_DIR/docker-compose.yml config"

# Test 2: Environment variables
test_case ".env.example exists" "[ -f $PROJECT_DIR/.env.example ]"

# Test 3: Monitoring configs
test_case "Prometheus config exists" "[ -f $PROJECT_DIR/prometheus/prometheus.yml ]"
test_case "Loki config exists" "[ -f $PROJECT_DIR/loki/loki-config.yml ]"
test_case "Promtail config exists" "[ -f $PROJECT_DIR/promtail/promtail-config.yml ]"
test_case "Alertmanager config exists" "[ -f $PROJECT_DIR/alertmanager/alertmanager.yml ]"
test_case "Falco config exists" "[ -f $PROJECT_DIR/falco/falco.yaml ]"

# Test 4: Grafana dashboards
test_case "Security dashboard exists" "[ -f $PROJECT_DIR/grafana/dashboards/security-dashboard.json ]"
test_case "Executive dashboard exists" "[ -f $PROJECT_DIR/grafana/dashboards/executive-dashboard.json ]"
test_case "Operations dashboard exists" "[ -f $PROJECT_DIR/grafana/dashboards/operations-dashboard.json ]"

# Test 5: n8n workflows
test_case "P0 workflows exist (5)" "[ $(find $PROJECT_DIR/n8n/workflows/p0 -name '*.json' 2>/dev/null | wc -l) -ge 5 ]"
test_case "P1 workflows exist (5)" "[ $(find $PROJECT_DIR/n8n/workflows/p1 -name '*.json' 2>/dev/null | wc -l) -ge 5 ]"
test_case "P2 workflows exist (3)" "[ $(find $PROJECT_DIR/n8n/workflows/p2 -name '*.json' 2>/dev/null | wc -l) -ge 3 ]"

# Test 6: PostgreSQL init scripts
test_case "Service Desk schema exists" "[ -f $PROJECT_DIR/postgres/init/03-service-desk-schema.sql ]"
test_case "Backstage schema exists" "[ -f $PROJECT_DIR/postgres/init/04-backstage-schema.sql ]"

# Test 7: Traefik config
test_case "Traefik config exists" "[ -f $PROJECT_DIR/traefik/traefik.yml ]"

# Test 4: Scripts exist
test_case "setup.sh exists" "[ -f $PROJECT_DIR/scripts/setup.sh ]"
test_case "backup.sh exists" "[ -f $PROJECT_DIR/scripts/backup.sh ]"
test_case "health-check.sh exists" "[ -f $PROJECT_DIR/scripts/health-check.sh ]"

# Test 5: Scripts are executable
test_case "setup.sh is executable" "[ -x $PROJECT_DIR/scripts/setup.sh ]"
test_case "backup.sh is executable" "[ -x $PROJECT_DIR/scripts/backup.sh ]"
test_case "health-check.sh is executable" "[ -x $PROJECT_DIR/scripts/health-check.sh ]"

# Test 6: Required volumes defined
test_case "PostgreSQL volume defined" "docker compose -f $PROJECT_DIR/docker-compose.yml config | grep -q 'alfa-postgres-data'"
test_case "Redis volume defined" "docker compose -f $PROJECT_DIR/docker-compose.yml config | grep -q 'alfa-redis-data'"
test_case "n8n volume defined" "docker compose -f $PROJECT_DIR/docker-compose.yml config | grep -q 'alfa-n8n-data'"

# Test 7: Required networks defined
test_case "Frontend network defined" "docker compose -f $PROJECT_DIR/docker-compose.yml config | grep -q 'alfa-frontend'"
test_case "Backend network defined" "docker compose -f $PROJECT_DIR/docker-compose.yml config | grep -q 'alfa-backend'"

# Test 8: Services have healthchecks
test_case "PostgreSQL healthcheck" "grep -A20 'container_name: alfa-postgres' $PROJECT_DIR/docker-compose.yml | grep -q 'healthcheck'"
test_case "Redis healthcheck" "grep -A20 'container_name: alfa-redis' $PROJECT_DIR/docker-compose.yml | grep -q 'healthcheck'"
test_case "n8n healthcheck" "grep -A50 'container_name: alfa-n8n' $PROJECT_DIR/docker-compose.yml | grep -q 'healthcheck'"
test_case "Traefik healthcheck" "grep -A30 'container_name: alfa-traefik' $PROJECT_DIR/docker-compose.yml | grep -q 'healthcheck'"
test_case "Uptime Kuma healthcheck" "grep -A30 'container_name: alfa-uptime-kuma' $PROJECT_DIR/docker-compose.yml | grep -q 'healthcheck'"
test_case "Infisical healthcheck" "grep -A30 'container_name: alfa-infisical' $PROJECT_DIR/docker-compose.yml | grep -q 'healthcheck'"

echo ""
echo -e "${YELLOW}=== Runtime Tests (requires running stack) ===${NC}"

# Test 9: Containers running
if docker ps --format '{{.Names}}' | grep -q 'alfa-'; then
    # Core infrastructure
    test_case "Traefik container running" "docker ps --format '{{.Names}}' | grep -q 'alfa-traefik'"
    test_case "PostgreSQL container running" "docker ps --format '{{.Names}}' | grep -q 'alfa-postgres'"
    test_case "Redis container running" "docker ps --format '{{.Names}}' | grep -q 'alfa-redis'"

    # Monitoring stack
    test_case "Prometheus container running" "docker ps --format '{{.Names}}' | grep -q 'alfa-prometheus'"
    test_case "Loki container running" "docker ps --format '{{.Names}}' | grep -q 'alfa-loki'"
    test_case "Grafana container running" "docker ps --format '{{.Names}}' | grep -q 'alfa-grafana'"
    test_case "Alertmanager container running" "docker ps --format '{{.Names}}' | grep -q 'alfa-alertmanager'"

    # Security stack
    test_case "Falco container running" "docker ps --format '{{.Names}}' | grep -q 'alfa-falco'"
    test_case "Falcosidekick container running" "docker ps --format '{{.Names}}' | grep -q 'alfa-falcosidekick'"

    # Applications
    test_case "n8n container running" "docker ps --format '{{.Names}}' | grep -q 'alfa-n8n'"
    test_case "Uptime Kuma container running" "docker ps --format '{{.Names}}' | grep -q 'alfa-uptime-kuma'"
    test_case "Backstage container running" "docker ps --format '{{.Names}}' | grep -q 'alfa-backstage'"

    # Test 10: Services healthy
    test_case "Traefik healthy" "docker inspect --format='{{.State.Health.Status}}' alfa-traefik | grep -q 'healthy'"
    test_case "PostgreSQL healthy" "docker inspect --format='{{.State.Health.Status}}' alfa-postgres | grep -q 'healthy'"
    test_case "Redis healthy" "docker inspect --format='{{.State.Health.Status}}' alfa-redis | grep -q 'healthy'"
    test_case "Prometheus healthy" "docker inspect --format='{{.State.Health.Status}}' alfa-prometheus | grep -q 'healthy'"
    test_case "Loki healthy" "docker inspect --format='{{.State.Health.Status}}' alfa-loki | grep -q 'healthy'"
    test_case "Grafana healthy" "docker inspect --format='{{.State.Health.Status}}' alfa-grafana | grep -q 'healthy'"
    test_case "n8n healthy" "docker inspect --format='{{.State.Health.Status}}' alfa-n8n | grep -q 'healthy'"

    # Test 11: Service endpoints respond
    test_case "Traefik API responds" "curl -sf http://localhost:8080/api/version"
    test_case "PostgreSQL accepts connections" "docker exec alfa-postgres pg_isready -U alfa"
    test_case "Redis PONG" "docker exec alfa-redis redis-cli -a redispass123 ping 2>/dev/null | grep -q 'PONG'"
    test_case "Prometheus API responds" "curl -sf http://localhost:9090/-/healthy"
    test_case "Grafana API responds" "curl -sf http://localhost:3000/api/health"
else
    echo -e "${YELLOW}Skipping runtime tests - stack not running${NC}"
fi

echo ""
echo "=============================="
echo -e "Results: ${GREEN}${PASS} PASSED${NC} | ${RED}${FAIL} FAILED${NC}"
echo "=============================="

if [ $FAIL -gt 0 ]; then
    exit 1
fi

exit 0
