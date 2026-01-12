#!/bin/bash
# ========================================
# Script pour vérifier les workflows n8n (doublons, fonctionnalité)
# ========================================

set -e

N8N_URL="${N8N_URL:-http://localhost:5678}"
N8N_API_KEY="${N8N_API_KEY:-}"

if [ -z "$N8N_API_KEY" ]; then
    echo "❌ Erreur: N8N_API_KEY non défini"
    echo "Usage: N8N_API_KEY=xxx $0"
    exit 1
fi

echo "🔍 Vérification des workflows n8n"
echo "=================================="
echo ""

# Liste tous les workflows
response=$(curl -s -X GET "${N8N_URL}/api/v1/workflows" \
    -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
    -H "Content-Type: application/json" 2>&1)

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de la récupération des workflows"
    exit 1
fi

# Vérifier si réponse est JSON valide
echo "$response" | jq -e . > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Réponse invalide (pas JSON)"
    exit 1
fi

issues=0

# 1. Vérifier doublons (noms identiques)
echo "🔍 Vérification des doublons (noms identiques)..."
duplicates=$(echo "$response" | jq -r '.data[]? // .[]? | .name' | sort | uniq -d)

if [ -n "$duplicates" ]; then
    echo "⚠️  Doublons trouvés:"
    echo "$duplicates" | while read name; do
        echo "   - $name"
        ids=$(echo "$response" | jq -r --arg name "$name" '.data[]? // .[]? | select(.name == $name) | .id')
        echo "     IDs: $ids"
        ((issues++))
    done
else
    echo "✅ Aucun doublon trouvé"
fi
echo ""

# 2. Vérifier workflows sans webhook (workflows avec webhook mais webhookId manquant)
echo "🔍 Vérification des workflows webhook..."
webhook_issues=$(echo "$response" | jq -r '.data[]? // .[]? | select(.nodes[]?.type == "n8n-nodes-base.webhook" and (.nodes[]?.parameters.webhookId == null or .nodes[]?.parameters.webhookId == "")) | "\(.name) (ID: \(.id))"')

if [ -n "$webhook_issues" ]; then
    echo "⚠️  Workflows webhook avec webhookId manquant:"
    echo "$webhook_issues" | while read issue; do
        echo "   - $issue"
        ((issues++))
    done
else
    echo "✅ Tous les workflows webhook ont un webhookId"
fi
echo ""

# 3. Vérifier workflows avec nodes sans connections
echo "🔍 Vérification des workflows avec nodes isolés..."
isolated_nodes=$(echo "$response" | jq -r '.data[]? // .[]? | select(.nodes | length > 0) | select(.connections == null or (.connections | length) == 0) | "\(.name) (ID: \(.id))"')

if [ -n "$isolated_nodes" ]; then
    echo "⚠️  Workflows avec nodes isolés (pas de connections):"
    echo "$isolated_nodes" | while read issue; do
        echo "   - $issue"
        ((issues++))
    done
else
    echo "✅ Tous les workflows ont des connections"
fi
echo ""

# 4. Résumé
echo "📊 Résumé:"
echo "=========="
if [ $issues -eq 0 ]; then
    echo "✅ Aucun problème détecté"
    exit 0
else
    echo "⚠️  $issues problème(s) détecté(s)"
    exit 1
fi
