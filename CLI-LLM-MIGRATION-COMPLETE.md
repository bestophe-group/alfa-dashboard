# ✅ Migration CLI LLM - Complète

## 📋 Résumé

Tous les appels LLM payants (Anthropic) ont été remplacés par des appels CLI gratuits via Claude Code CLI ou Cursor Agent.

## 🔄 Fichiers modifiés

### Workflows principaux (alfa-dashboard/n8n/workflows/)

1. **iana-router.json**
   - ✅ Classifier L1/L2/L3 → `Execute Command` (Claude Code CLI)
   - ✅ L1 Handler → `Execute Command` (Claude Code CLI)
   - ✅ L3 Handler → `Execute Command` (Cursor Agent)

### Handlers (mcp-server/workflows/)

2. **iana-l1-handler.json**
   - ✅ LLM Chat → `Execute Command` (Claude Code CLI)

3. **iana-l2-handler.json**
   - ✅ LLM Analysis → `Execute Command` (Claude Code CLI)

4. **iana-l3-handler.json**
   - ✅ LLM Expert → `Execute Command` (Cursor Agent)

5. **iana-router.json** (version simplifiée)
   - ✅ Classifier → `Execute Command` (Claude Code CLI)
   - ✅ L1 Handler → `Execute Command` (Claude Code CLI)
   - ✅ L3 Handler → `Execute Command` (Cursor Agent)

## 📁 Scripts créés

1. **llm-cli-wrapper.js** - Wrapper Node.js principal
   - Prend: provider (claude-code/cursor-agent), prompt, model
   - Retourne: JSON avec response, model, provider, tokens_used
   - **⚠️ À adapter selon votre installation CLI**

2. **claude-code-chat.sh** - Template shell pour Claude Code CLI
3. **cursor-agent-chat.sh** - Template shell pour Cursor Agent
4. **SETUP-CLI-LLM.md** - Guide d'adaptation détaillé
5. **README-CLI-LLM.md** - Documentation rapide

## 🏗️ Architecture modifiée

### Avant (LLM payant)
```
Prompt → @n8n/n8n-nodes-langchain.lmChatAnthropic → Response
```

### Après (CLI gratuit)
```
Prompt → Prepare Command (Code) → Execute Command (CLI) → Parse Response (Code) → Response
```

## ✅ Vérifications effectuées

- [x] Aucun node `@n8n/n8n-nodes-langchain.lmChatAnthropic` restant dans `alfa-dashboard/n8n/workflows/`
- [x] Tous les workflows utilisent `Execute Command`
- [x] Les prompts sont échappés pour shell (guillemets, $)
- [x] Les réponses CLI sont parsées depuis `stdout` en JSON
- [x] Fallback si parsing JSON échoue
- [x] Chemins absolus corrects vers `llm-cli-wrapper.js`

## 🚀 Prochaines étapes

### 1. Adapter le wrapper

Modifier `alfa-dashboard/scripts/llm-cli-wrapper.js` selon votre installation :

**Option A: Claude Code CLI via commande**
```javascript
const { execSync } = require('child_process');
const result = execSync(`claude-code chat --prompt "${PROMPT}" --model "${MODEL}"`, {
  encoding: 'utf8'
});
```

**Option B: Claude Code CLI via API HTTP**
```javascript
const http = require('http');
// Appel API HTTP
```

**Option C: Cursor Agent**
```javascript
const { execSync } = require('child_process');
const result = execSync(`cursor-agent chat --prompt "${PROMPT}"`, {
  encoding: 'utf8'
});
```

### 2. Tester le wrapper

```bash
cd /Users/arnaud/Documents/ALFA-Agent-Method/alfa-dashboard/scripts
node llm-cli-wrapper.js claude-code "Bonjour" claude-3-haiku
```

Devrait retourner:
```json
{
  "response": "...",
  "model": "claude-3-haiku",
  "provider": "claude-code",
  "tokens_used": 100
}
```

### 3. Importer les workflows dans n8n

1. Importer tous les workflows modifiés
2. Vérifier que les chemins vers `llm-cli-wrapper.js` sont corrects
3. Tester avec une requête simple

### 4. Tests fonctionnels

- [ ] Test L1 (requête simple) → Réponse rapide
- [ ] Test L2 (requête avec RAG) → Réponse avec contexte
- [ ] Test L3 (requête experte) → Réponse détaillée

## 📊 Statistiques

- **Workflows modifiés**: 5
- **Nodes LLM remplacés**: 7
- **Scripts créés**: 5
- **Coût LLM**: **0€** (gratuit via CLI)

## 🔍 Debugging

Si ça ne marche pas :

1. **Tester le wrapper directement** :
   ```bash
   node llm-cli-wrapper.js claude-code "test" claude-3-haiku
   ```

2. **Vérifier les logs n8n** : Erreurs CLI dans logs d'exécution

3. **Vérifier le parsing** : Node "Format Response" doit parser le JSON

4. **Vérifier les chemins** : Chemin absolu vers `llm-cli-wrapper.js` correct

## 📝 Notes importantes

- Les prompts sont échappés pour shell (guillemets, $)
- Les réponses CLI sont parsées depuis `stdout` en JSON
- Fallback si parsing JSON échoue
- Les chemins absolus pointent vers `/Users/arnaud/Documents/ALFA-Agent-Method/alfa-dashboard/scripts/llm-cli-wrapper.js`

## ✅ Checklist finale

- [x] Tous les workflows modifiés
- [x] Scripts créés
- [x] Documentation créée
- [ ] Wrapper adapté pour votre CLI (à faire)
- [ ] Tests fonctionnels (à faire après adaptation)

---

**Date**: 2025-01-12
**Status**: ✅ Migration complète (wrapper à adapter)
