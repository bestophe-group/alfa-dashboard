#!/bin/bash
# ========================================
# ALFA Dashboard - Endpoint Tests (TDD)
# ========================================

set -e

echo "🌐 ALFA Dashboard Endpoint Tests"
echo "=================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

# Test function
test_endpoint() {
    local name=$1
    local url=$2
    local expected_code=${3:-200}

    echo -n "Testing: $name... "

    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")

    if [ "$response" == "$expected_code" ] || [ "$response" == "200" ] || [ "$response" == "302" ]; then
        echo -e "${GREEN}PASS${NC} (HTTP $response)"
        ((PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC} (HTTP $response, expected $expected_code)"
        ((FAIL++))
        return 1
    fi
}

# Wait for services to be ready
echo -e "${YELLOW}⏳ Waiting for services to be ready (30s)...${NC}"
sleep 30
echo ""

# Test Traefik
test_endpoint "Traefik ping" "http://localhost:8080/ping"

# Test Huly (might return 302 redirect)
test_endpoint "Huly health" "http://localhost:3000/health"

# Test n8n
test_endpoint "n8n health" "http://localhost:5678/healthz"

# Test Uptime Kuma
test_endpoint "Uptime Kuma" "http://localhost:3001/"

# Test PostgreSQL (via docker exec)
echo -n "Testing: PostgreSQL connection... "
if docker compose exec -T postgres pg_isready -U ${POSTGRES_USER:-alfa} > /dev/null 2>&1; then
    echo -e "${GREEN}PASS${NC}"
    ((PASS++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAIL++))
fi

# Test Redis (via docker exec)
echo -n "Testing: Redis connection... "
if docker compose exec -T redis redis-cli --raw ping > /dev/null 2>&1; then
    echo -e "${GREEN}PASS${NC}"
    ((PASS++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAIL++))
fi

echo ""
echo "=================================="
echo "Results: ${GREEN}${PASS} PASSED${NC} | ${RED}${FAIL} FAILED${NC}"
echo "=================================="

if [ $FAIL -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Some endpoints are not responding. Services might still be starting up.${NC}"
    exit 1
fi

exit 0
