#!/bin/bash
# ========================================
# ALFA Dashboard - Service Installer
# ========================================
# Installs launchd service for auto-start on macOS

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PLIST_NAME="com.alfa.dashboard.plist"
PLIST_SOURCE="${SCRIPT_DIR}/${PLIST_NAME}"
PLIST_DEST="${HOME}/Library/LaunchAgents/${PLIST_NAME}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "========================================="
echo "   ALFA Dashboard - Service Installer"
echo "========================================="
echo ""

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${RED}Error: This script is for macOS only${NC}"
    echo "For Linux, use systemd instead"
    exit 1
fi

# Create logs directory
mkdir -p "${PROJECT_DIR}/logs"

case "${1:-install}" in
    install)
        echo -e "${YELLOW}Installing ALFA Dashboard service...${NC}"

        # Create LaunchAgents directory if needed
        mkdir -p "${HOME}/Library/LaunchAgents"

        # Update plist with correct paths
        sed "s|/Users/arnaud/Documents/ALFA-Agent-Method/alfa-dashboard|${PROJECT_DIR}|g" \
            "$PLIST_SOURCE" > "$PLIST_DEST"

        # Unload if already loaded
        launchctl unload "$PLIST_DEST" 2>/dev/null || true

        # Load the service
        launchctl load "$PLIST_DEST"

        echo -e "${GREEN}✓ Service installed and started${NC}"
        echo ""
        echo "The ALFA Dashboard will now:"
        echo "  - Start automatically when you log in"
        echo "  - Monitor all services every 30 seconds"
        echo "  - Auto-restart any failed containers"
        echo ""
        echo "Commands:"
        echo "  Check status:  launchctl list | grep alfa"
        echo "  View logs:     tail -f ${PROJECT_DIR}/logs/watchdog.log"
        echo "  Stop service:  $0 stop"
        echo "  Uninstall:     $0 uninstall"
        ;;

    stop)
        echo -e "${YELLOW}Stopping ALFA Dashboard service...${NC}"
        launchctl unload "$PLIST_DEST" 2>/dev/null || true
        echo -e "${GREEN}✓ Service stopped${NC}"
        ;;

    start)
        echo -e "${YELLOW}Starting ALFA Dashboard service...${NC}"
        launchctl load "$PLIST_DEST" 2>/dev/null || true
        echo -e "${GREEN}✓ Service started${NC}"
        ;;

    restart)
        echo -e "${YELLOW}Restarting ALFA Dashboard service...${NC}"
        launchctl unload "$PLIST_DEST" 2>/dev/null || true
        sleep 2
        launchctl load "$PLIST_DEST"
        echo -e "${GREEN}✓ Service restarted${NC}"
        ;;

    uninstall)
        echo -e "${YELLOW}Uninstalling ALFA Dashboard service...${NC}"

        # Unload service
        launchctl unload "$PLIST_DEST" 2>/dev/null || true

        # Remove plist
        rm -f "$PLIST_DEST"

        echo -e "${GREEN}✓ Service uninstalled${NC}"
        echo "Note: Docker containers are still running. Run 'docker compose down' to stop them."
        ;;

    status)
        echo "Service status:"
        if launchctl list | grep -q "com.alfa.dashboard"; then
            echo -e "  ${GREEN}✓ ALFA Dashboard service is running${NC}"
            launchctl list | grep "com.alfa.dashboard"
        else
            echo -e "  ${RED}✗ ALFA Dashboard service is not running${NC}"
        fi
        echo ""
        echo "Container status:"
        "${SCRIPT_DIR}/alfa-watchdog.sh" status
        ;;

    *)
        echo "Usage: $0 {install|start|stop|restart|uninstall|status}"
        exit 1
        ;;
esac
