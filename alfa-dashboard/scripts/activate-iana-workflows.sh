#!/bin/bash
# Script d'activation des workflows IANA
# Usage: ./activate-iana-workflows.sh [API_KEY]

set -e

N8N_URL="${N8N_URL:-http://localhost:5678}"

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

echo "🔄 Activation workflows IANA"
echo "============================="
echo ""

# Liste des IDs (à mettre à jour après chaque import)
WORKFLOW_IDS=(
  "Fowjj0lqqwb1Abbi"  # iana-router
  "trJusOUdAeLNy2fO"  # iana-l1-handler
  "P64Ew7gj8WWW0N2D"  # iana-l2-handler
  "Jn18X8vRu3EMRAfB"  # iana-l3-handler
)

# Activer d'abord les handlers (sub-workflows)
echo "📦 Activation des handlers (sub-workflows)..."
for wf_id in "${WORKFLOW_IDS[@]:1}"; do
  echo "  Activation $wf_id..."
  RESPONSE=$(curl -s -X POST "$N8N_URL/api/v1/workflows/$wf_id/activate" \
    -H "X-N8N-API-KEY: $API_KEY" 2>&1)
  
  if echo "$RESPONSE" | jq -e '.active == true' > /dev/null 2>&1; then
    echo "  ✅ Activé"
  elif echo "$RESPONSE" | grep -q "not published"; then
    echo "  ⚠️  Erreur: $RESPONSE"
  else
    echo "  ⚠️  Réponse: $RESPONSE"
  fi
done

echo ""
echo "📦 Activation du router (dépend des handlers)..."
# Activer le router en dernier
ROUTER_ID="${WORKFLOW_IDS[0]}"
echo "  Activation $ROUTER_ID..."
RESPONSE=$(curl -s -X POST "$N8N_URL/api/v1/workflows/$ROUTER_ID/activate" \
  -H "X-N8N-API-KEY: $API_KEY" 2>&1)

if echo "$RESPONSE" | jq -e '.active == true' > /dev/null 2>&1; then
  echo "  ✅ Router activé"
elif echo "$RESPONSE" | grep -q "not published"; then
  echo "  ⚠️  Erreur: $RESPONSE"
  echo "  💡 Les handlers doivent être activés d'abord"
else
  echo "  ⚠️  Réponse: $RESPONSE"
fi

echo ""
echo "✅ Activation terminée"
