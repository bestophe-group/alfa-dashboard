#!/bin/bash
# ALFA Management Script
# Gestion rapide du webhook ALFA

set -e

TUNNEL_URL="https://aviation-audit-adjacent-alternative.trycloudflare.com"

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions
show_status() {
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║          ALFA Status Dashboard                 ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""

    # PM2 Status
    echo -e "${GREEN}📊 PM2 Process Status:${NC}"
    pm2 status
    echo ""

    # Webhook Health
    echo -e "${GREEN}🏥 Webhook Health Check:${NC}"
    if curl -s http://localhost:3333/health > /dev/null 2>&1; then
        HEALTH=$(curl -s http://localhost:3333/health)
        echo -e "${GREEN}✅ Local: $HEALTH${NC}"
    else
        echo -e "${RED}❌ Local: DOWN${NC}"
    fi

    # Tunnel Health
    echo -e "${GREEN}🌐 Tunnel Health Check:${NC}"
    if curl -s "$TUNNEL_URL/health" > /dev/null 2>&1; then
        HEALTH=$(curl -s "$TUNNEL_URL/health")
        echo -e "${GREEN}✅ Tunnel: $HEALTH${NC}"
    else
        echo -e "${RED}❌ Tunnel: DOWN${NC}"
    fi

    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Request URL:${NC} ${TUNNEL_URL}/slack/command"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

show_logs() {
    echo -e "${BLUE}📋 ALFA Webhook Logs (dernières 50 lignes):${NC}"
    pm2 logs alfa-webhook --lines 50 --nostream
}

restart_webhook() {
    echo -e "${YELLOW}🔄 Redémarrage du webhook...${NC}"
    pm2 restart alfa-webhook
    sleep 2
    show_status
}

stop_webhook() {
    echo -e "${RED}⚠️  ATTENTION: Le webhook ne doit jamais s'arrêter!${NC}"
    read -p "Êtes-vous sûr de vouloir arrêter? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        echo -e "${YELLOW}Arrêt du webhook...${NC}"
        pm2 stop alfa-webhook
    else
        echo -e "${GREEN}Opération annulée.${NC}"
    fi
}

start_webhook() {
    echo -e "${GREEN}🚀 Démarrage du webhook...${NC}"
    pm2 start alfa-webhook
    sleep 2
    show_status
}

show_help() {
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║          ALFA Management Tool                  ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Usage: ./alfa-manage.sh [COMMAND]"
    echo ""
    echo "Commandes disponibles:"
    echo ""
    echo -e "  ${GREEN}status${NC}     - Afficher le statut complet"
    echo -e "  ${GREEN}logs${NC}       - Afficher les logs"
    echo -e "  ${GREEN}restart${NC}    - Redémarrer le webhook"
    echo -e "  ${GREEN}start${NC}      - Démarrer le webhook"
    echo -e "  ${GREEN}stop${NC}       - Arrêter le webhook (⚠️  déconseillé)"
    echo -e "  ${GREEN}test${NC}       - Tester les endpoints"
    echo -e "  ${GREEN}config${NC}     - Afficher URL de configuration Slack"
    echo -e "  ${GREEN}help${NC}       - Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  ./alfa-manage.sh status"
    echo "  ./alfa-manage.sh logs"
    echo ""
}

test_endpoints() {
    echo -e "${BLUE}🧪 Test des endpoints ALFA...${NC}"
    echo ""

    echo -e "${GREEN}Test 1: Health check local${NC}"
    curl -s http://localhost:3333/health | jq . || echo "Failed"
    echo ""

    echo -e "${GREEN}Test 2: Health check tunnel${NC}"
    curl -s "$TUNNEL_URL/health" | jq . || echo "Failed"
    echo ""

    echo -e "${GREEN}Test 3: Webhook endpoint (simulation)${NC}"
    curl -X POST http://localhost:3333/slack/command \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "command=/alfa&text=status&user_name=test&response_url=http://example.com" \
        2>/dev/null || echo "Failed"
    echo ""
}

show_config() {
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║      Configuration Slack Command              ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}1. Ouvrez cette URL:${NC}"
    echo -e "   👉 https://api.slack.com/apps/A0A73J9107P/slash-commands"
    echo ""
    echo -e "${YELLOW}2. Créez ou modifiez /alfa avec ces valeurs:${NC}"
    echo ""
    echo -e "   ${GREEN}Command:${NC}          /alfa"
    echo -e "   ${GREEN}Request URL:${NC}      ${TUNNEL_URL}/slack/command"
    echo -e "   ${GREEN}Short Desc.:${NC}      Execute ALFA MCP tools"
    echo -e "   ${GREEN}Usage Hint:${NC}       status | grafana | slack_send_message"
    echo ""
    echo -e "${YELLOW}3. ✅ Cochez:${NC} Escape channels, users, and links"
    echo ""
    echo -e "${YELLOW}4. Cliquez Save${NC}"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Request URL à copier:${NC}"
    echo "${TUNNEL_URL}/slack/command"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Main
case "$1" in
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    restart)
        restart_webhook
        ;;
    start)
        start_webhook
        ;;
    stop)
        stop_webhook
        ;;
    test)
        test_endpoints
        ;;
    config)
        show_config
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        echo -e "${RED}Commande inconnue: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
