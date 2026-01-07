#!/bin/bash
# ========================================
# ALFA Dashboard - DNS Setup Script
# ========================================
# Configures local DNS entries for ALFA services
# Run with: sudo ./scripts/setup-dns.sh

set -e

DOMAIN="${ALFA_DOMAIN:-alfa.local}"
IP="${ALFA_IP:-127.0.0.1}"

# DNS entries for ALFA services
DNS_ENTRIES=(
    "n8n.${DOMAIN}"
    "auth.${DOMAIN}"
    "status.${DOMAIN}"
    "traefik.${DOMAIN}"
    "postgres.${DOMAIN}"
    "redis.${DOMAIN}"
    "api.${DOMAIN}"
    "${DOMAIN}"
)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "========================================="
echo "   ALFA Dashboard - DNS Setup"
echo "========================================="
echo ""
echo "Domain: ${DOMAIN}"
echo "IP: ${IP}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root (sudo)${NC}"
    exit 1
fi

# Backup hosts file
BACKUP="/etc/hosts.backup.$(date +%Y%m%d%H%M%S)"
cp /etc/hosts "$BACKUP"
echo -e "${GREEN}✓ Backed up /etc/hosts to ${BACKUP}${NC}"

# Remove old ALFA entries
sed -i '' '/# ALFA Dashboard DNS/,/# END ALFA/d' /etc/hosts 2>/dev/null || true

# Add new entries
echo "" >> /etc/hosts
echo "# ALFA Dashboard DNS - Auto-generated" >> /etc/hosts
for entry in "${DNS_ENTRIES[@]}"; do
    echo "${IP}    ${entry}" >> /etc/hosts
    echo -e "  ${GREEN}✓${NC} Added: ${entry}"
done
echo "# END ALFA Dashboard DNS" >> /etc/hosts

# Flush DNS cache (macOS)
if [[ "$(uname)" == "Darwin" ]]; then
    dscacheutil -flushcache
    killall -HUP mDNSResponder 2>/dev/null || true
    echo -e "${GREEN}✓ DNS cache flushed${NC}"
fi

echo ""
echo -e "${GREEN}DNS setup complete!${NC}"
echo ""
echo "Your ALFA services will be accessible at:"
for entry in "${DNS_ENTRIES[@]}"; do
    echo "  - https://${entry}"
done
echo ""
echo "To use a different domain, set ALFA_DOMAIN environment variable:"
echo "  ALFA_DOMAIN=mycompany.local sudo ./scripts/setup-dns.sh"
