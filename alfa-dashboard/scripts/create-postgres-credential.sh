#!/bin/bash
# Script pour créer la credential PostgreSQL IANA dans n8n
# Usage: ./create-postgres-credential.sh [API_KEY]

set -e

N8N_URL="${N8N_URL:-http://localhost:5678}"

# API Key
if [ -z "$1" ]; then
  if [ -z "$N8N_API_KEY" ]; then
    echo "❌ ERREUR: API Key n8n requise"
    echo "Usage: $0 [API_KEY]"
    echo "   OU: export N8N_API_KEY='...' && $0"
    exit 1
  fi
  API_KEY="$N8N_API_KEY"
else
  API_KEY="$1"
fi

# Récupérer les valeurs depuis Docker
POSTGRES_HOST="postgres"
POSTGRES_PORT="5432"
POSTGRES_DB="alfa"
POSTGRES_USER="alfa"
POSTGRES_PASSWORD="alfapass123"

# Vérifier si .env existe et lire les valeurs
if [ -f ".env" ]; then
  echo "📄 Fichier .env trouvé, lecture des valeurs..."
  if grep -q "POSTGRES_USER" .env; then
    POSTGRES_USER=$(grep "^POSTGRES_USER=" .env | cut -d'=' -f2 | tr -d '"' | tr -d "'")
  fi
  if grep -q "POSTGRES_PASSWORD" .env; then
    POSTGRES_PASSWORD=$(grep "^POSTGRES_PASSWORD=" .env | cut -d'=' -f2 | tr -d '"' | tr -d "'")
  fi
  if grep -q "POSTGRES_DB" .env; then
    POSTGRES_DB=$(grep "^POSTGRES_DB=" .env | cut -d'=' -f2 | tr -d '"' | tr -d "'")
  fi
fi

echo "🔐 Création credential PostgreSQL IANA dans n8n"
echo "================================================"
echo "Host: $POSTGRES_HOST"
echo "Port: $POSTGRES_PORT"
echo "Database: $POSTGRES_DB"
echo "User: $POSTGRES_USER"
echo "Password: ${POSTGRES_PASSWORD:0:3}***"
echo ""

# Note: L'API n8n pour créer des credentials nécessite souvent un format spécifique
# et peut nécessiter des permissions spéciales. Cette méthode peut ne pas fonctionner.
# Il est recommandé d'utiliser l'UI n8n.

echo "⚠️  NOTE: L'API n8n pour créer des credentials peut ne pas être disponible."
echo "   Il est recommandé de créer la credential via l'UI n8n :"
echo ""
echo "   1. Ouvrir: $N8N_URL"
echo "   2. Settings → Credentials → New Credential"
echo "   3. Type: PostgreSQL"
echo "   4. Name: PostgreSQL IANA"
echo "   5. Remplir avec les valeurs ci-dessus"
echo "   6. Test Connection → Save"
echo ""
echo "📋 Valeurs à utiliser :"
echo "   Host: $POSTGRES_HOST"
echo "   Port: $POSTGRES_PORT"
echo "   Database: $POSTGRES_DB"
echo "   User: $POSTGRES_USER"
echo "   Password: $POSTGRES_PASSWORD"
echo "   SSL: Désactivé"
echo ""

# Tentative via API (peut échouer selon la version de n8n)
echo "🔄 Tentative de création via API..."
RESPONSE=$(curl -s -X POST "$N8N_URL/api/v1/credentials" \
  -H "X-N8N-API-KEY: $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"PostgreSQL IANA\",
    \"type\": \"postgres\",
    \"data\": {
      \"host\": \"$POSTGRES_HOST\",
      \"port\": $POSTGRES_PORT,
      \"database\": \"$POSTGRES_DB\",
      \"user\": \"$POSTGRES_USER\",
      \"password\": \"$POSTGRES_PASSWORD\",
      \"ssl\": false
    }
  }" 2>&1)

if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
  CRED_ID=$(echo "$RESPONSE" | jq -r '.id')
  echo "✅ Credential créée avec succès !"
  echo "   ID: $CRED_ID"
  echo "   Name: PostgreSQL IANA"
else
  echo "❌ Échec de la création via API"
  echo "   Réponse: $RESPONSE"
  echo ""
  echo "💡 Utilise l'UI n8n pour créer la credential manuellement."
fi
