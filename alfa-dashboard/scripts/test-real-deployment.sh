#!/bin/bash
# Test réel de déploiement et fonctionnement
# Usage: ./test-real-deployment.sh [API_KEY]

set -e

N8N_URL="${N8N_URL:-http://localhost:5678}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# API Key
if [ -z "$1" ]; then
  if [ -z "$N8N_API_KEY" ]; then
    echo "❌ ERREUR: API Key n8n requise"
    echo "Usage: export N8N_API_KEY='n8n_api_XXXXX' && ./test-real-deployment.sh"
    exit 1
  fi
  API_KEY="$N8N_API_KEY"
else
  API_KEY="$1"
fi

echo "🧪 TEST RÉEL - Déploiement IANA"
echo "================================"
echo ""

RESULTS_FILE="$PROJECT_ROOT/TEST-REAL-DEPLOYMENT-$(date +%Y%m%d_%H%M%S).md"
echo "# 🧪 Test Réel Déploiement IANA" > "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"
echo "**Date**: $(date -Iseconds)" >> "$RESULTS_FILE"
echo "**URL n8n**: $N8N_URL" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

# Test 1: Wrapper CLI réel
echo "## Test 1: Wrapper CLI Réel" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

echo "📝 Test wrapper avec question factuelle..."
WRAPPER_TEST=$(cd "$PROJECT_ROOT/alfa-dashboard/scripts" && node llm-cli-wrapper.js claude-code "Combien font 2+2?" claude-3-haiku 2>&1)

echo "**Commande**: \`node llm-cli-wrapper.js claude-code \"Combien font 2+2?\" claude-3-haiku\`" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

if echo "$WRAPPER_TEST" | jq -e '.response' > /dev/null 2>&1; then
  SOURCE=$(echo "$WRAPPER_TEST" | jq -r '.source // "unknown"')
  RESPONSE=$(echo "$WRAPPER_TEST" | jq -r '.response')
  
  if [ "$SOURCE" = "real-cli" ]; then
    echo "✅ **Résultat**: VRAI CLI (source: $SOURCE)" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    echo "**Réponse**: $RESPONSE" >> "$RESULTS_FILE"
  else
    echo "⚠️ **Résultat**: MOCK (source: $SOURCE)" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    echo "**Réponse**: $RESPONSE" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    echo "**Note**: Le wrapper utilise un mock car aucun CLI n'est disponible." >> "$RESULTS_FILE"
  fi
else
  echo "❌ **Résultat**: Erreur parsing JSON" >> "$RESULTS_FILE"
  echo "\`\`\`" >> "$RESULTS_FILE"
  echo "$WRAPPER_TEST" >> "$RESULTS_FILE"
  echo "\`\`\`" >> "$RESULTS_FILE"
fi
echo "" >> "$RESULTS_FILE"

# Test 2: Vérifier workflows dans n8n
echo "## Test 2: Workflows dans n8n" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

echo "📡 Vérification workflows IANA dans n8n..."
WORKFLOWS=$(curl -s -H "X-N8N-API-KEY: $API_KEY" "$N8N_URL/api/v1/workflows" | jq -r '.[] | select(.name | startswith("iana-")) | "\(.id)|\(.name)|\(.active)"' 2>/dev/null || echo "")

if [ -z "$WORKFLOWS" ]; then
  echo "❌ **Aucun workflow IANA trouvé dans n8n**" >> "$RESULTS_FILE"
  echo "" >> "$RESULTS_FILE"
  echo "**Action requise**: Exécuter \`./deploy-iana-workflows.sh\`" >> "$RESULTS_FILE"
else
  echo "✅ **Workflows trouvés**:" >> "$RESULTS_FILE"
  echo "" >> "$RESULTS_FILE"
  echo "| ID | Nom | Actif |" >> "$RESULTS_FILE"
  echo "|----|-----|-------|" >> "$RESULTS_FILE"
  echo "$WORKFLOWS" | while IFS='|' read -r id name active; do
    echo "| \`$id\` | $name | $active |" >> "$RESULTS_FILE"
  done
fi
echo "" >> "$RESULTS_FILE"

# Test 3: Test endpoint webhook
echo "## Test 3: Test Endpoint Webhook" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

echo "🌐 Test webhook /webhook/iana..."
WEBHOOK_TEST=$(curl -s -X POST "$N8N_URL/webhook/iana" \
  -H "Content-Type: application/json" \
  -d '{"query": "Quelle heure est-il ?", "user_id": "test"}' 2>&1)

echo "**Commande**: \`curl -X POST $N8N_URL/webhook/iana -d '{\"query\": \"Quelle heure est-il ?\", \"user_id\": \"test\"}'\`" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

if echo "$WEBHOOK_TEST" | jq . > /dev/null 2>&1; then
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$N8N_URL/webhook/iana" \
    -H "Content-Type: application/json" \
    -d '{"query": "test", "user_id": "test"}')
  
  if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ **HTTP 200** - Endpoint fonctionne" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    echo "**Réponse**: \`\`\`json" >> "$RESULTS_FILE"
    echo "$WEBHOOK_TEST" | jq . >> "$RESULTS_FILE"
    echo "\`\`\`" >> "$RESULTS_FILE"
  else
    echo "⚠️ **HTTP $HTTP_CODE** - Endpoint répond mais avec erreur" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    echo "**Réponse**: \`\`\`json" >> "$RESULTS_FILE"
    echo "$WEBHOOK_TEST" | jq . >> "$RESULTS_FILE"
    echo "\`\`\`" >> "$RESULTS_FILE"
  fi
else
  echo "❌ **Erreur** - Endpoint ne répond pas en JSON" >> "$RESULTS_FILE"
  echo "" >> "$RESULTS_FILE"
  echo "**Réponse brute**: \`\`\`" >> "$RESULTS_FILE"
  echo "$WEBHOOK_TEST" >> "$RESULTS_FILE"
  echo "\`\`\`" >> "$RESULTS_FILE"
fi
echo "" >> "$RESULTS_FILE"

# Résumé
echo "## 📊 Résumé" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"
echo "| Test | Statut |" >> "$RESULTS_FILE"
echo "|------|--------|" >> "$RESULTS_FILE"

if echo "$WRAPPER_TEST" | jq -e '.source == "real-cli"' > /dev/null 2>&1; then
  echo "| Wrapper CLI | ✅ Réel |" >> "$RESULTS_FILE"
else
  echo "| Wrapper CLI | ⚠️ Mock |" >> "$RESULTS_FILE"
fi

if [ -n "$WORKFLOWS" ]; then
  WF_COUNT=$(echo "$WORKFLOWS" | wc -l | tr -d ' ')
  echo "| Workflows n8n | ✅ $WF_COUNT trouvés |" >> "$RESULTS_FILE"
else
  echo "| Workflows n8n | ❌ Aucun |" >> "$RESULTS_FILE"
fi

if [ "$HTTP_CODE" = "200" ]; then
  echo "| Endpoint webhook | ✅ Fonctionne |" >> "$RESULTS_FILE"
else
  echo "| Endpoint webhook | ⚠️ Erreur |" >> "$RESULTS_FILE"
fi

echo "" >> "$RESULTS_FILE"
echo "## ✅ Conclusion" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"
echo "**Fiabilité réelle**: À calculer selon résultats ci-dessus" >> "$RESULTS_FILE"

cat "$RESULTS_FILE"
echo ""
echo "📄 Résultats complets dans: $RESULTS_FILE"
