# Configuration CLI LLM - Guide d'Adaptation

## ✅ Modifications effectuées

Tous les workflows ont été modifiés pour utiliser **Execute Command** au lieu de nodes LLM payants.

## 📋 Fichiers modifiés

### Workflows principaux
- `iana-router.json` - Classifier + L1/L3 handlers → CLI
- `iana-l1-handler.json` - LLM Chat → CLI
- `iana-l2-handler.json` - LLM Analysis → CLI
- `iana-l3-handler.json` - LLM Expert → CLI

### Scripts créés
- `llm-cli-wrapper.js` - Wrapper Node.js (à adapter)
- `claude-code-chat.sh` - Template shell (à adapter)
- `cursor-agent-chat.sh` - Template shell (à adapter)

## 🔧 Adaptation du wrapper

### Étape 1: Identifier comment appeler votre CLI

#### Option A: Claude Code CLI via commande directe
```bash
# Si Claude Code CLI a une commande chat
claude-code chat --prompt "Votre prompt" --model "claude-3-haiku"
```

#### Option B: Claude Code CLI via API HTTP
```bash
# Si Claude Code CLI expose une API
curl -X POST http://localhost:PORT/chat \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Votre prompt", "model": "claude-3-haiku"}'
```

#### Option C: Cursor Agent via commande
```bash
# Si Cursor Agent a une commande
cursor-agent chat --prompt "Votre prompt"
```

### Étape 2: Modifier `llm-cli-wrapper.js`

#### Pour Claude Code CLI (Option A - Commande directe)
```javascript
if (PROVIDER === 'claude-code') {
  const { execSync } = require('child_process');
  const result = execSync(`claude-code chat --prompt "${PROMPT}" --model "${MODEL}"`, {
    encoding: 'utf8',
    maxBuffer: 10 * 1024 * 1024 // 10MB
  });
  
  response = {
    response: result.trim(),
    model: MODEL,
    provider: 'claude-code',
    tokens_used: Math.floor(PROMPT.length / 4)
  };
}
```

#### Pour Claude Code CLI (Option B - API HTTP)
```javascript
if (PROVIDER === 'claude-code') {
  const http = require('http');
  const data = JSON.stringify({ prompt: PROMPT, model: MODEL });
  
  const options = {
    hostname: 'localhost',
    port: 8080, // Port de votre API Claude Code CLI
    path: '/chat',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': data.length
    }
  };
  
  const apiResponse = await new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => resolve(JSON.parse(body)));
    });
    req.on('error', reject);
    req.write(data);
    req.end();
  });
  
  response = {
    response: apiResponse.response || apiResponse.text,
    model: MODEL,
    provider: 'claude-code',
    tokens_used: apiResponse.tokens_used || 0
  };
}
```

#### Pour Cursor Agent
```javascript
else if (PROVIDER === 'cursor-agent') {
  const { execSync } = require('child_process');
  const result = execSync(`cursor-agent chat --prompt "${PROMPT}"`, {
    encoding: 'utf8',
    maxBuffer: 10 * 1024 * 1024
  });
  
  response = {
    response: result.trim(),
    model: MODEL,
    provider: 'cursor-agent',
    tokens_used: Math.floor(PROMPT.length / 4)
  };
}
```

### Étape 3: Tester le wrapper

```bash
# Test simple
node llm-cli-wrapper.js claude-code "Bonjour" claude-3-haiku

# Devrait retourner du JSON:
# {"response":"...", "model":"claude-3-haiku", "provider":"claude-code", "tokens_used":...}
```

### Étape 4: Vérifier dans n8n

1. Importer les workflows modifiés
2. Tester avec une requête simple
3. Vérifier que `stdout` contient du JSON valide
4. Vérifier que le parsing fonctionne dans les nodes "Format Response"

## 🚨 Points d'attention

1. **Échappement des prompts** : Les prompts sont échappés pour shell (guillemets, $)
2. **Parsing JSON** : Les workflows parsent `stdout` comme JSON
3. **Timeout** : Les commandes CLI peuvent être longues (L3 surtout)
4. **Erreurs** : Les erreurs CLI sont capturées dans `stderr`

## 📝 Format de réponse attendu

Le wrapper doit retourner du JSON sur stdout :

```json
{
  "response": "Réponse du LLM",
  "model": "claude-3-haiku",
  "provider": "claude-code",
  "tokens_used": 100
}
```

## 🔍 Debugging

Si ça ne marche pas :

1. **Tester le wrapper directement** :
   ```bash
   node llm-cli-wrapper.js claude-code "test" claude-3-haiku
   ```

2. **Vérifier les logs n8n** : Les erreurs CLI apparaissent dans les logs d'exécution

3. **Vérifier le parsing** : Le node "Format Response" doit pouvoir parser le JSON

4. **Vérifier les chemins** : Le chemin absolu vers `llm-cli-wrapper.js` doit être correct

## ✅ Checklist

- [ ] Wrapper adapté pour votre CLI (Claude Code ou Cursor)
- [ ] Test direct du wrapper fonctionne
- [ ] Format JSON de réponse correct
- [ ] Workflows importés dans n8n
- [ ] Test avec requête L1 (simple)
- [ ] Test avec requête L2 (avec RAG)
- [ ] Test avec requête L3 (expert)

## 💡 Alternative : Utiliser Ollama (local, gratuit)

Si Claude Code CLI ou Cursor Agent ne sont pas disponibles, vous pouvez utiliser Ollama :

```javascript
// Dans llm-cli-wrapper.js
const { execSync } = require('child_process');
const result = execSync(`ollama run ${MODEL} "${PROMPT}"`, {
  encoding: 'utf8'
});

response = {
  response: result.trim(),
  model: MODEL,
  provider: 'ollama',
  tokens_used: 0
};
```

Puis modifier les workflows pour utiliser `ollama` comme provider.
