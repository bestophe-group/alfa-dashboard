#!/bin/bash
# Script pour appeler Cursor Agent comme LLM
# Usage: ./cursor-agent-chat.sh "prompt" [model]

PROMPT="$1"
MODEL="${2:-claude-3-haiku}"

# Créer un fichier temporaire avec le prompt
TEMP_FILE=$(mktemp)
echo "$PROMPT" > "$TEMP_FILE"

# Appeler Cursor Agent (à adapter selon votre installation)
# Option 1: Si Cursor Agent expose une API HTTP
# curl -X POST http://localhost:PORT/chat -d "{\"prompt\": \"$PROMPT\", \"model\": \"$MODEL\"}"

# Option 2: Si Cursor Agent a une commande directe
# cursor-agent chat --prompt "$PROMPT" --model "$MODEL"

# Option 3: Utiliser l'API Cursor si disponible
# Pour l'instant, on simule avec un script simple
# TODO: Remplacer par le vrai appel CLI

# Simulation temporaire (à remplacer)
cat <<EOF
{
  "response": "Réponse simulée depuis Cursor Agent. Prompt: $PROMPT",
  "model": "$MODEL",
  "tokens_used": 100
}
EOF

rm -f "$TEMP_FILE"
