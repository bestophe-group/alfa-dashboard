# Configuration CLI LLM (Claude Code CLI / Cursor Agent)

## Objectif

Remplacer tous les appels LLM payants (Anthropic) par des appels CLI gratuits via Claude Code CLI ou Cursor Agent.

## Scripts créés

### `llm-cli-wrapper.js`

Wrapper Node.js pour appeler les CLI comme LLM.

**Usage:**
```bash
node llm-cli-wrapper.js <provider> <prompt> [model]
```

**Providers:**
- `claude-code` : Utilise Claude Code CLI
- `cursor-agent` : Utilise Cursor Agent

**Exemple:**
```bash
node llm-cli-wrapper.js claude-code "Bonjour, comment ça va?" claude-3-haiku
```

## Configuration requise

### Option 1: Claude Code CLI

Si Claude Code CLI expose une API HTTP, modifier `llm-cli-wrapper.js` :

```javascript
// Dans la section claude-code
const http = require('http');
const response = await callClaudeCodeAPI(PROMPT, MODEL);
```

### Option 2: Cursor Agent

Si Cursor Agent a une commande CLI, modifier `llm-cli-wrapper.js` :

```javascript
// Dans la section cursor-agent
const { execSync } = require('child_process');
const response = execSync(`cursor-agent chat --prompt "${PROMPT}" --model "${MODEL}"`);
```

### Option 3: Scripts shell

Les scripts `claude-code-chat.sh` et `cursor-agent-chat.sh` sont des templates à adapter selon votre installation.

## Workflows modifiés

Tous les workflows suivants utilisent maintenant `Execute Command` au lieu de `@n8n/n8n-nodes-langchain.lmChatAnthropic` :

1. **iana-router.json**
   - Classifier L1/L2/L3 → CLI
   - L1 Handler → CLI
   - L3 Handler → CLI

2. **iana-l1-handler.json**
   - LLM Chat → CLI

3. **iana-l2-handler.json**
   - LLM Analysis → CLI

4. **iana-l3-handler.json**
   - LLM Expert → CLI

## Prochaines étapes

1. **Adapter `llm-cli-wrapper.js`** selon votre installation Claude Code CLI ou Cursor Agent
2. **Tester** avec une requête simple
3. **Vérifier** que les réponses sont bien parsées depuis stdout

## Notes

- Les prompts sont échappés pour shell (guillemets, $)
- Les réponses CLI sont parsées depuis `stdout` en JSON
- Fallback si le parsing JSON échoue
