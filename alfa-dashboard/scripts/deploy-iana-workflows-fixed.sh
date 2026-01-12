#!/bin/bash
# Script de déploiement FIXÉ - Retire les champs read-only
# Usage: ./deploy-iana-workflows-fixed.sh [API_KEY]

set -e

N8N_URL="${N8N_URL:-http://localhost:5678}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORKFLOWS_DIR="$PROJECT_ROOT/alfa-dashboard/n8n/workflows"
MCP_WORKFLOWS_DIR="$PROJECT_ROOT/mcp-server/workflows"

# API Key
if [ -z "$1" ]; then
  if [ -z "$N8N_API_KEY" ]; then
    echo "❌ ERREUR: API Key n8n requise"
    exit 1
  fi
  API_KEY="$N8N_API_KEY"
else
  API_KEY="$1"
fi

echo "🚀 Déploiement workflows IANA (FIXÉ)"
echo "===================================="
echo "URL: $N8N_URL"
echo ""

# Vérifier n8n
if ! curl -s -f -H "X-N8N-API-KEY: $API_KEY" "$N8N_URL/api/v1/workflows" > /dev/null; then
  echo "❌ ERREUR: Impossible de se connecter à n8n"
  exit 1
fi
echo "✅ n8n accessible"
echo ""

# Liste des workflows
WORKFLOWS=(
  "$WORKFLOWS_DIR/iana-router.json"
  "$MCP_WORKFLOWS_DIR/iana-l1-handler.json"
  "$MCP_WORKFLOWS_DIR/iana-l2-handler.json"
  "$MCP_WORKFLOWS_DIR/iana-l3-handler.json"
)

RESULTS_FILE="$PROJECT_ROOT/DEPLOY-RESULTS-FIXED-$(date +%Y%m%d_%H%M%S).md"
echo "# 🚀 Déploiement IANA (FIXÉ)" > "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"
echo "**Date**: $(date -Iseconds)" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

SUCCESS=0
FAILED=0

for workflow in "${WORKFLOWS[@]}"; do
  if [ ! -f "$workflow" ]; then
    echo "⚠️  Fichier non trouvé: $workflow"
    continue
  fi

  WF_NAME=$(basename "$workflow" .json)
  echo "📦 Import: $WF_NAME"
  
  # Nettoyer le workflow (retirer champs read-only)
  CLEAN_WF="/tmp/${WF_NAME}-clean.json"
  jq 'del(.active, .tags, .settings.executionOrder)' "$workflow" > "$CLEAN_WF"
  
  # Importer
  RESPONSE=$(curl -s -X POST "$N8N_URL/api/v1/workflows" \
    -H "X-N8N-API-KEY: $API_KEY" \
    -H "Content-Type: application/json" \
    -d @"$CLEAN_WF" 2>&1)
  
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
      
      if echo "$ACTIVATE_RESPONSE" | jq -e '.active == true' > /dev/null 2>&1; then
        echo "  ✅ Activé"
        ACTIVE="true"
      else
        echo "  ⚠️  Activation échouée: $ACTIVATE_RESPONSE"
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
    echo "  ❌ Erreur: $RESPONSE"
    echo "" >> "$RESULTS_FILE"
    echo "## ❌ $WF_NAME" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    echo "**Erreur**: $RESPONSE" >> "$RESULTS_FILE"
    FAILED=$((FAILED + 1))
  fi
  echo ""
done

echo "===================================="
echo "📊 Résumé: ✅ $SUCCESS | ❌ $FAILED"
echo ""

echo "" >> "$RESULTS_FILE"
echo "## 📊 Résumé" >> "$RESULTS_FILE"
echo "| ✅ Succès | ❌ Échecs |" >> "$RESULTS_FILE"
echo "|-----------|-----------|" >> "$RESULTS_FILE"
echo "| $SUCCESS | $FAILED |" >> "$RESULTS_FILE"

cat "$RESULTS_FILE"
