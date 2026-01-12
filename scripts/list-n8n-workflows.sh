#!/bin/bash
# ========================================
# Script pour lister tous les workflows n8n via API
# ========================================

set -e

N8N_URL="${N8N_URL:-http://localhost:5678}"
N8N_API_KEY="${N8N_API_KEY:-}"

if [ -z "$N8N_API_KEY" ]; then
    echo "❌ Erreur: N8N_API_KEY non défini"
    echo "Usage: N8N_API_KEY=xxx $0"
    exit 1
fi

echo "📊 Liste des workflows n8n"
echo "=========================="
echo "URL: $N8N_URL"
echo ""

# Liste tous les workflows
echo "🔍 Récupération des workflows..."
response=$(curl -s -X GET "${N8N_URL}/api/v1/workflows" \
    -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
    -H "Content-Type: application/json" 2>&1)

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de la récupération des workflows"
    echo "$response"
    exit 1
fi

# Vérifier si réponse est JSON valide
echo "$response" | jq -e . > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Réponse invalide (pas JSON)"
    echo "$response"
    exit 1
fi

# Extraire workflows
workflows=$(echo "$response" | jq -r '.data[]? // .[]?')

if [ -z "$workflows" ]; then
    echo "⚠️  Aucun workflow trouvé"
    echo "Réponse complète:"
    echo "$response" | jq .
    exit 0
fi

# Compter workflows
count=$(echo "$response" | jq -r '.data[]?.id // .[].id' 2>/dev/null | wc -l | tr -d ' ')
echo "✅ Workflows trouvés: $count"
echo ""

# Afficher liste formatée
echo "📋 Liste des workflows:"
echo "======================"
echo "$response" | jq -r '.data[]? // .[]? | "\(.id) | \(.name) | \(.active // false) | \(.updatedAt // "N/A")"' | \
    while IFS='|' read -r id name active updated; do
        active_status=$(echo "$active" | tr -d ' ')
        if [ "$active_status" = "true" ]; then
            status="✅ Actif"
        else
            status="❌ Inactif"
        fi
        printf "%-40s %-20s %-15s %s\n" "$name" "$id" "$status" "$updated"
    done

echo ""
echo "📊 Statistiques:"
echo "==============="
active_count=$(echo "$response" | jq -r '.data[]? // .[]? | select(.active == true) | .id' 2>/dev/null | wc -l | tr -d ' ')
inactive_count=$(echo "$response" | jq -r '.data[]? // .[]? | select(.active == false) | .id' 2>/dev/null | wc -l | tr -d ' ')
echo "Total: $count"
echo "Actifs: $active_count"
echo "Inactifs: $inactive_count"

# Sauvegarder JSON complet
output_file="workflows-list-$(date +%Y%m%d_%H%M%S).json"
echo "$response" > "$output_file"
echo ""
echo "💾 Liste complète sauvegardée: $output_file"
