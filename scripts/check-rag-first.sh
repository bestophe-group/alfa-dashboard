#!/bin/bash
# Script utilitaire pour vérifier si un token/credential existe dans le RAG
# Usage: ./check-rag-first.sh "n8n API key"

set -e

QUERY="${1:-n8n API key}"
LIMIT="${2:-10}"

echo "🔍 Recherche dans le RAG: '$QUERY'"
echo "=================================="
echo ""

docker exec alfa-postgres psql -U alfa -d alfa << EOF
-- Recherche fulltext dans le RAG
SELECT 
  chunk_id,
  LEFT(content, 200) as content_preview,
  rank,
  document_title,
  document_id
FROM rag.search_fulltext('${QUERY}', ${LIMIT})
ORDER BY rank DESC;
EOF

echo ""
echo "=================================="
echo "✅ Recherche terminée"
echo ""
echo "💡 Si aucun résultat, vérifier aussi:"
echo "   - Fichiers .env"
echo "   - docker-compose.yml"
echo "   - Documentation du projet"
