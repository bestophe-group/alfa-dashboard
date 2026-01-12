#!/bin/bash
# Script de déploiement réel des workflows IANA dans n8n
# Usage: ./deploy-iana-workflows.sh [API_KEY]

set -e

N8N_URL="${N8N_URL:-http://localhost:5678}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORKFLOWS_DIR="$PROJECT_ROOT/alfa-dashboard/n8n/workflows"
MCP_WORKFLOWS_DIR="$PROJECT_ROOT/mcp-server/workflows"

# API Key
if [ -z "$1" ]; then
  if [ -z "$N8N_API_KEY" ]; then
    echo "❌ ERREUR: API Key n8n requise"
    echo ""
    echo "Usage:"
    echo "  export N8N_API_KEY='n8n_api_XXXXX'"
    echo "  ./deploy-iana-workflows.sh"
    echo ""
    echo "OU:"
    echo "  ./deploy-iana-workflows.sh 'n8n_api_XXXXX'"
    echo ""
    echo "Pour créer une API key:"
    echo "  1. Ouvrir n8n: $N8N_URL"
    echo "  2. Settings → API → Create API Key"
    exit 1
  fi
  API_KEY="$N8N_API_KEY"
else
  API_KEY="$1"
fi

echo "🚀 Déploiement workflows IANA dans n8n"
echo "======================================"
echo "URL: $N8N_URL"
echo "API Key: ${API_KEY:0:10}..."
echo ""

# Vérifier que n8n répond
echo "📡 Vérification connexion n8n..."
if ! curl -s -f -H "X-N8N-API-KEY: $API_KEY" "$N8N_URL/api/v1/workflows" > /dev/null; then
  echo "❌ ERREUR: Impossible de se connecter à n8n"
  echo "   Vérifiez que n8n est démarré et que l'API key est correcte"
  exit 1
fi
echo "✅ n8n accessible"
echo ""

# Liste des workflows à importer
WORKFLOWS=(
  "$WORKFLOWS_DIR/iana-router.json"
  "$MCP_WORKFLOWS_DIR/iana-l1-handler.json"
  "$MCP_WORKFLOWS_DIR/iana-l2-handler.json"
  "$MCP_WORKFLOWS_DIR/iana-l3-handler.json"
)

RESULTS_FILE="$PROJECT_ROOT/DEPLOY-RESULTS-$(date +%Y%m%d_%H%M%S).md"
echo "# 🚀 Résultats Déploiement IANA" > "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"
echo "**Date**: $(date -Iseconds)" >> "$RESULTS_FILE"
echo "**URL n8n**: $N8N_URL" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

# Importer chaque workflow
SUCCESS=0
FAILED=0

for workflow in "${WORKFLOWS[@]}"; do
  if [ ! -f "$workflow" ]; then
    echo "⚠️  Fichier non trouvé: $workflow"
    continue
  fi

  WF_NAME=$(basename "$workflow" .json)
  echo "📦 Import: $WF_NAME"
  
  # Importer
  RESPONSE=$(curl -s -X POST "$N8N_URL/api/v1/workflows" \
    -H "X-N8N-API-KEY: $API_KEY" \
    -H "Content-Type: application/json" \
    -d @"$workflow" 2>&1)
  
  if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
    WF_ID=$(echo "$RESPONSE" | jq -r '.id')
    WF_NAME_IMPORTED=$(echo "$RESPONSE" | jq -r '.name')
    ACTIVE=$(echo "$RESPONSE" | jq -r '.active')
    
    echo "  ✅ Importé: ID=$WF_ID, Active=$ACTIVE"
    
    # Activer
    if [ "$ACTIVE" = "false" ]; then
      echo "  🔄 Activation..."
      ACTIVATE_RESPONSE=$(curl -s -X PATCH "$N8N_URL/api/v1/workflows/$WF_ID" \
        -H "X-N8N-API-KEY: $API_KEY" \
        -H "Content-Type: application/json" \
        -d '{"active": true}' 2>&1)
      
      if echo "$ACTIVATE_RESPONSE" | jq -e '.active' > /dev/null 2>&1; then
        echo "  ✅ Activé"
        ACTIVE="true"
      else
        echo "  ⚠️  Activation échouée"
      fi
    fi
    
    echo "" >> "$RESULTS_FILE"
    echo "## ✅ $WF_NAME" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    echo "- **ID**: \`$WF_ID\`" >> "$RESULTS_FILE"
    echo "- **Nom**: $WF_NAME_IMPORTED" >> "$RESULTS_FILE"
    echo "- **Actif**: $ACTIVE" >> "$RESULTS_FILE"
    echo "- **Webhook**: \`$N8N_URL/webhook/iana\`" >> "$RESULTS_FILE"
    
    SUCCESS=$((SUCCESS + 1))
  else
    echo "  ❌ Erreur import"
    echo "  Réponse: $RESPONSE"
    echo "" >> "$RESULTS_FILE"
    echo "## ❌ $WF_NAME" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    echo "**Erreur**: Import échoué" >> "$RESULTS_FILE"
    echo "\`\`\`" >> "$RESULTS_FILE"
    echo "$RESPONSE" >> "$RESULTS_FILE"
    echo "\`\`\`" >> "$RESULTS_FILE"
    FAILED=$((FAILED + 1))
  fi
  echo ""
done

# Résumé
echo "======================================"
echo "📊 Résumé"
echo "  ✅ Succès: $SUCCESS"
echo "  ❌ Échecs: $FAILED"
echo ""

echo "" >> "$RESULTS_FILE"
echo "## 📊 Résumé" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"
echo "| Statut | Nombre |" >> "$RESULTS_FILE"
echo "|--------|--------|" >> "$RESULTS_FILE"
echo "| ✅ Succès | $SUCCESS |" >> "$RESULTS_FILE"
echo "| ❌ Échecs | $FAILED |" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

if [ $SUCCESS -gt 0 ]; then
  echo "✅ Déploiement terminé. Résultats dans: $RESULTS_FILE"
  echo ""
  echo "🧪 Pour tester:"
  echo "  curl -X POST $N8N_URL/webhook/iana \\"
  echo "    -H 'Content-Type: application/json' \\"
  echo "    -d '{\"query\": \"Bonjour\", \"user_id\": \"test\"}'"
fi

cat "$RESULTS_FILE"
