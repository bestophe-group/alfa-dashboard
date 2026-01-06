#!/bin/bash
# ========================================
# ALFA Dashboard - Stack Tests (TDD)
# ========================================

set -e

echo "🧪 ALFA Dashboard Stack Tests"
echo "=============================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
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

# Test 1: Docker Compose syntax
test_case "Docker Compose syntax" "docker compose -f ../docker-compose.yml config"

# Test 2: Environment variables
test_case ".env.example exists" "[ -f ../.env.example ]"

# Test 3: Traefik config
test_case "Traefik config exists" "[ -f ../traefik/traefik.yml ]"

# Test 4: Scripts exist
test_case "setup.sh exists" "[ -f ../scripts/setup.sh ]"
test_case "backup.sh exists" "[ -f ../scripts/backup.sh ]"
test_case "health-check.sh exists" "[ -f ../scripts/health-check.sh ]"

# Test 5: Scripts are executable
test_case "setup.sh is executable" "[ -x ../scripts/setup.sh ]"
test_case "backup.sh is executable" "[ -x ../scripts/backup.sh ]"
test_case "health-check.sh is executable" "[ -x ../scripts/health-check.sh ]"

# Test 6: Required volumes defined
test_case "PostgreSQL volume defined" "docker compose -f ../docker-compose.yml config | grep -q 'postgres_data'"
test_case "Redis volume defined" "docker compose -f ../docker-compose.yml config | grep -q 'redis_data'"
test_case "n8n volume defined" "docker compose -f ../docker-compose.yml config | grep -q 'n8n_data'"

# Test 7: Required networks defined
test_case "Frontend network defined" "docker compose -f ../docker-compose.yml config | grep -q 'frontend'"
test_case "Backend network defined" "docker compose -f ../docker-compose.yml config | grep -q 'backend'"

# Test 8: Services have healthchecks
test_case "PostgreSQL healthcheck" "grep -A20 'container_name: alfa-postgres' ../docker-compose.yml | grep -q 'healthcheck'"
test_case "Redis healthcheck" "grep -A20 'container_name: alfa-redis' ../docker-compose.yml | grep -q 'healthcheck'"
test_case "n8n healthcheck" "grep -A50 'container_name: alfa-n8n' ../docker-compose.yml | grep -q 'healthcheck'"

echo ""
echo "=============================="
echo "Results: ${GREEN}${PASS} PASSED${NC} | ${RED}${FAIL} FAILED${NC}"
echo "=============================="

if [ $FAIL -gt 0 ]; then
    exit 1
fi

exit 0
