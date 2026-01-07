#!/bin/bash
# ========================================
# ALFA Dashboard - Watchdog Service
# ========================================
# Monitors all ALFA services and ensures they stay running
# Restarts unhealthy containers automatically

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="${PROJECT_DIR}/logs/watchdog.log"
PID_FILE="/tmp/alfa-watchdog.pid"

# Create logs directory
mkdir -p "${PROJECT_DIR}/logs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Services to monitor
SERVICES=("alfa-traefik" "alfa-postgres" "alfa-redis" "alfa-authentik" "alfa-authentik-worker" "alfa-n8n" "alfa-uptime-kuma")
CRITICAL_SERVICES=("alfa-traefik" "alfa-postgres" "alfa-redis" "alfa-authentik" "alfa-n8n")

# Logging function
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" >> "$LOG_FILE"

    case $level in
        INFO)  echo -e "${BLUE}[INFO]${NC} ${message}" ;;
        WARN)  echo -e "${YELLOW}[WARN]${NC} ${message}" ;;
        ERROR) echo -e "${RED}[ERROR]${NC} ${message}" ;;
        OK)    echo -e "${GREEN}[OK]${NC} ${message}" ;;
    esac
}

# Check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        log ERROR "Docker is not running!"
        return 1
    fi
    return 0
}

# Check container status
check_container() {
    local container=$1
    local status=$(docker inspect --format='{{.State.Status}}' "$container" 2>/dev/null || echo "not_found")
    local health=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}no_healthcheck{{end}}' "$container" 2>/dev/null || echo "unknown")

    echo "${status}:${health}"
}

# Restart container
restart_container() {
    local container=$1
    log WARN "Restarting container: $container"

    if docker restart "$container" >/dev/null 2>&1; then
        log OK "Container $container restarted successfully"
        return 0
    else
        log ERROR "Failed to restart container $container"
        return 1
    fi
}

# Start stack if not running
start_stack() {
    log INFO "Starting ALFA stack..."
    cd "$PROJECT_DIR"

    if docker compose up -d >/dev/null 2>&1; then
        log OK "ALFA stack started"
        return 0
    else
        log ERROR "Failed to start ALFA stack"
        return 1
    fi
}

# Monitor all services
monitor_services() {
    local all_healthy=true
    local critical_down=false

    for container in "${SERVICES[@]}"; do
        local result=$(check_container "$container")
        local status="${result%%:*}"
        local health="${result##*:}"

        if [[ "$status" == "not_found" ]] || [[ "$status" == "exited" ]]; then
            log ERROR "Container $container is DOWN (status: $status)"
            all_healthy=false

            # Check if critical
            if [[ " ${CRITICAL_SERVICES[*]} " =~ " $container " ]]; then
                critical_down=true
            fi

            restart_container "$container"

        elif [[ "$status" == "running" ]] && [[ "$health" == "unhealthy" ]]; then
            log WARN "Container $container is UNHEALTHY"
            all_healthy=false
            restart_container "$container"

        elif [[ "$status" == "restarting" ]]; then
            log WARN "Container $container is in restart loop"
            all_healthy=false

        else
            # Container is healthy
            :
        fi
    done

    if $critical_down; then
        log ERROR "Critical services are down - attempting full stack restart"
        start_stack
    fi

    if $all_healthy; then
        return 0
    else
        return 1
    fi
}

# Health summary
health_summary() {
    echo ""
    echo "========================================="
    echo "   ALFA Dashboard - Health Summary"
    echo "========================================="
    echo ""

    for container in "${SERVICES[@]}"; do
        local result=$(check_container "$container")
        local status="${result%%:*}"
        local health="${result##*:}"

        if [[ "$status" == "running" ]] && [[ "$health" == "healthy" || "$health" == "no_healthcheck" ]]; then
            echo -e "  ${GREEN}✓${NC} $container: ${GREEN}running${NC} ($health)"
        elif [[ "$status" == "running" ]]; then
            echo -e "  ${YELLOW}○${NC} $container: ${YELLOW}$status${NC} ($health)"
        else
            echo -e "  ${RED}✗${NC} $container: ${RED}$status${NC}"
        fi
    done

    echo ""
}

# Daemon mode
daemon_mode() {
    local interval=${1:-60}  # Default 60 seconds

    # Check if already running
    if [[ -f "$PID_FILE" ]]; then
        local old_pid=$(cat "$PID_FILE")
        if kill -0 "$old_pid" 2>/dev/null; then
            log ERROR "Watchdog already running (PID: $old_pid)"
            exit 1
        fi
    fi

    # Write PID
    echo $$ > "$PID_FILE"

    log INFO "Starting ALFA Watchdog daemon (interval: ${interval}s)"

    # Trap signals for cleanup
    trap 'log INFO "Watchdog stopped"; rm -f "$PID_FILE"; exit 0' SIGTERM SIGINT

    while true; do
        if check_docker; then
            monitor_services
        else
            log ERROR "Docker not available - waiting..."
        fi
        sleep "$interval"
    done
}

# Stop daemon
stop_daemon() {
    if [[ -f "$PID_FILE" ]]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            log INFO "Stopping watchdog (PID: $pid)"
            kill "$pid"
            rm -f "$PID_FILE"
            log OK "Watchdog stopped"
        else
            log WARN "Watchdog not running (stale PID file)"
            rm -f "$PID_FILE"
        fi
    else
        log WARN "Watchdog not running"
    fi
}

# Main
main() {
    case "${1:-status}" in
        start)
            start_stack
            ;;
        stop)
            cd "$PROJECT_DIR"
            docker compose down
            ;;
        restart)
            cd "$PROJECT_DIR"
            docker compose restart
            ;;
        status)
            check_docker || exit 1
            health_summary
            ;;
        check)
            check_docker || exit 1
            monitor_services
            health_summary
            ;;
        daemon)
            daemon_mode "${2:-60}"
            ;;
        stop-daemon)
            stop_daemon
            ;;
        logs)
            tail -f "$LOG_FILE"
            ;;
        *)
            echo "ALFA Watchdog - Service Monitor"
            echo ""
            echo "Usage: $0 {start|stop|restart|status|check|daemon|stop-daemon|logs}"
            echo ""
            echo "Commands:"
            echo "  start       - Start the ALFA stack"
            echo "  stop        - Stop the ALFA stack"
            echo "  restart     - Restart the ALFA stack"
            echo "  status      - Show health summary"
            echo "  check       - Check and fix unhealthy services"
            echo "  daemon [N]  - Run as daemon (check every N seconds, default 60)"
            echo "  stop-daemon - Stop the watchdog daemon"
            echo "  logs        - Tail the watchdog logs"
            exit 1
            ;;
    esac
}

main "$@"
