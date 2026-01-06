#!/bin/bash
# ========================================
# ALFA Dashboard - Setup Script
# ========================================

set -e

echo "🚀 ALFA Dashboard Setup"
echo "========================"

# Check if .env exists
if [ ! -f .env ]; then
    echo "📋 Creating .env from .env.example..."
    cp .env.example .env
    echo "⚠️  Please edit .env with your configuration before starting!"
    exit 1
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p traefik/letsencrypt
touch traefik/letsencrypt/acme.json
chmod 600 traefik/letsencrypt/acme.json

# Validate docker-compose config
echo "✅ Validating docker-compose configuration..."
docker compose config > /dev/null

# Pull images
echo "📥 Pulling Docker images..."
docker compose pull

# Start services
echo "🔧 Starting services..."
docker compose up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to be ready..."
sleep 10

# Show status
echo "📊 Services status:"
docker compose ps

echo ""
echo "✅ ALFA Dashboard is ready!"
echo ""
echo "🌐 Access points:"
echo "   - Traefik Dashboard: http://localhost:8080"
echo "   - Huly: https://huly.localhost"
echo "   - Infisical: https://infisical.localhost"
echo "   - n8n: https://n8n.localhost"
echo "   - Uptime Kuma: https://uptime.localhost"
echo ""
echo "📝 Check logs: docker compose logs -f [service]"
