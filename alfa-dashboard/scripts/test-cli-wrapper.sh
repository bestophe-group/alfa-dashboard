#!/bin/bash
# Script de test pour llm-cli-wrapper.js
# Usage: ./test-cli-wrapper.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WRAPPER="$SCRIPT_DIR/llm-cli-wrapper.js"

echo "🧪 Test du wrapper CLI LLM"
echo "=========================="
echo ""

# Test 1: Claude Code CLI avec prompt simple
echo "Test 1: Claude Code CLI (prompt simple)"
echo "---------------------------------------"
if node "$WRAPPER" claude-code "Bonjour, comment ça va?" claude-3-haiku; then
  echo "✅ Test 1 réussi"
else
  echo "❌ Test 1 échoué"
  exit 1
fi
echo ""

# Test 2: Cursor Agent avec prompt simple
echo "Test 2: Cursor Agent (prompt simple)"
echo "-------------------------------------"
if node "$WRAPPER" cursor-agent "Qu'est-ce que l'ALFA?" claude-3-5-sonnet; then
  echo "✅ Test 2 réussi"
else
  echo "❌ Test 2 échoué"
  exit 1
fi
echo ""

# Test 3: Prompt avec caractères spéciaux
echo "Test 3: Prompt avec caractères spéciaux"
echo "----------------------------------------"
if node "$WRAPPER" claude-code "Test avec \"guillemets\" et \$variables" claude-3-haiku; then
  echo "✅ Test 3 réussi"
else
  echo "❌ Test 3 échoué"
  exit 1
fi
echo ""

# Test 4: Vérifier format JSON
echo "Test 4: Vérification format JSON"
echo "---------------------------------"
RESPONSE=$(node "$WRAPPER" claude-code "test" claude-3-haiku)
if echo "$RESPONSE" | jq . > /dev/null 2>&1; then
  echo "✅ Format JSON valide"
  echo "$RESPONSE" | jq .
else
  echo "❌ Format JSON invalide"
  echo "Réponse: $RESPONSE"
  exit 1
fi
echo ""

# Test 5: Vérifier champs requis
echo "Test 5: Vérification champs requis"
echo "-----------------------------------"
RESPONSE=$(node "$WRAPPER" claude-code "test" claude-3-haiku)
if echo "$RESPONSE" | jq -e '.response' > /dev/null 2>&1 && \
   echo "$RESPONSE" | jq -e '.model' > /dev/null 2>&1 && \
   echo "$RESPONSE" | jq -e '.provider' > /dev/null 2>&1; then
  echo "✅ Tous les champs requis présents"
else
  echo "❌ Champs manquants"
  echo "$RESPONSE" | jq .
  exit 1
fi
echo ""

echo "=========================="
echo "✅ Tous les tests passés !"
echo ""
echo "⚠️  Note: Le wrapper utilise actuellement des réponses simulées."
echo "   Adaptez llm-cli-wrapper.js pour utiliser votre CLI réel."
