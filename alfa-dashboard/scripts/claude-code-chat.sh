#!/bin/bash
# Script pour appeler Claude Code CLI comme LLM
# Usage: ./claude-code-chat.sh "prompt" [model]

PROMPT="$1"
MODEL="${2:-claude-3-haiku}"  # Default to haiku for speed

# Créer un fichier temporaire avec le prompt
TEMP_FILE=$(mktemp)
echo "$PROMPT" > "$TEMP_FILE"

# Appeler Claude Code CLI (à adapter selon votre installation)
# Option 1: Si Claude Code CLI expose une API HTTP
# curl -X POST http://localhost:PORT/chat -d "{\"prompt\": \"$PROMPT\", \"model\": \"$MODEL\"}"

# Option 2: Si Claude Code CLI a une commande directe
# claude-code chat --prompt "$PROMPT" --model "$MODEL"

# Option 3: Utiliser un script Python/Node qui appelle l'API Claude Code
# Pour l'instant, on simule avec un script simple
# TODO: Remplacer par le vrai appel CLI

# Simulation temporaire (à remplacer)
cat <<EOF
{
  "response": "Réponse simulée depuis Claude Code CLI. Prompt: $PROMPT",
  "model": "$MODEL",
  "tokens_used": 100
}
EOF

rm -f "$TEMP_FILE"
