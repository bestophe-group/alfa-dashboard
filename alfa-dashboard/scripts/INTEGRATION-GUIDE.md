# Guide d'Intégration CLI LLM dans n8n

## 🎯 Objectif

Intégrer Claude Code CLI ou Cursor Agent comme LLM gratuit dans les workflows n8n IANA.

## 📋 Prérequis

1. **Claude Code CLI** OU **Cursor Agent** installé et fonctionnel
2. **Node.js** installé (pour le wrapper)
3. **n8n** avec accès aux workflows IANA

## 🔧 Étape 1: Identifier votre CLI

### Option A: Claude Code CLI

Vérifier l'installation :
```bash
which claude-code
# ou
claude-code --version
```

Si installé, tester :
```bash
claude-code chat --prompt "Bonjour"
```

### Option B: Cursor Agent

Vérifier l'installation :
```bash
which cursor-agent
# ou
cursor-agent --version
```

Si installé, tester :
```bash
cursor-agent chat --prompt "Bonjour"
```

### Option C: Ollama (alternative gratuite)

Si aucun des deux n'est disponible, utiliser Ollama :
```bash
# Installer Ollama
brew install ollama  # macOS
# ou
curl -fsSL https://ollama.ai/install.sh | sh  # Linux

# Télécharger un modèle
ollama pull llama2
```

## 🔧 Étape 2: Adapter le wrapper

Modifier `alfa-dashboard/scripts/llm-cli-wrapper.js` :

### Pour Claude Code CLI (commande directe)

```javascript
if (PROVIDER === 'claude-code') {
  const { execSync } = require('child_process');
  
  try {
    const result = execSync(
      `claude-code chat --prompt "${PROMPT}" --model "${MODEL}"`,
      {
        encoding: 'utf8',
        maxBuffer: 10 * 1024 * 1024, // 10MB
        timeout: 30000 // 30 secondes
      }
    );
    
    response = {
      response: result.trim(),
      model: MODEL,
      provider: 'claude-code',
      tokens_used: Math.floor(PROMPT.length / 4) // Estimation
    };
  } catch (error) {
    throw new Error(`Claude Code CLI error: ${error.message}`);
  }
}
```

### Pour Cursor Agent (commande directe)

```javascript
else if (PROVIDER === 'cursor-agent') {
  const { execSync } = require('child_process');
  
  try {
    const result = execSync(
      `cursor-agent chat --prompt "${PROMPT}"`,
      {
        encoding: 'utf8',
        maxBuffer: 10 * 1024 * 1024,
        timeout: 60000 // 60 secondes pour L3
      }
    );
    
    response = {
      response: result.trim(),
      model: MODEL,
      provider: 'cursor-agent',
      tokens_used: Math.floor(PROMPT.length / 4)
    };
  } catch (error) {
    throw new Error(`Cursor Agent error: ${error.message}`);
  }
}
```

### Pour Ollama (alternative)

```javascript
if (PROVIDER === 'ollama') {
  const { execSync } = require('child_process');
  
  // Ollama utilise des modèles locaux
  const ollamaModel = MODEL === 'claude-3-haiku' ? 'llama2' : 'llama2:13b';
  
  try {
    const result = execSync(
      `ollama run ${ollamaModel} "${PROMPT}"`,
      {
        encoding: 'utf8',
        maxBuffer: 10 * 1024 * 1024,
        timeout: 60000
      }
    );
    
    response = {
      response: result.trim(),
      model: ollamaModel,
      provider: 'ollama',
      tokens_used: 0 // Ollama ne retourne pas de tokens
    };
  } catch (error) {
    throw new Error(`Ollama error: ${error.message}`);
  }
}
```

## 🔧 Étape 3: Tester le wrapper

```bash
cd /Users/arnaud/Documents/ALFA-Agent-Method/alfa-dashboard/scripts

# Test simple
node llm-cli-wrapper.js claude-code "Bonjour" claude-3-haiku

# Test avec script automatique
./test-cli-wrapper.sh
```

**Résultat attendu** :
```json
{
  "response": "Bonjour ! Comment puis-je vous aider ?",
  "model": "claude-3-haiku",
  "provider": "claude-code",
  "tokens_used": 25
}
```

## 🔧 Étape 4: Importer les workflows dans n8n

### Méthode 1: Import manuel

1. Ouvrir n8n
2. Aller dans **Workflows**
3. Cliquer sur **Import from File**
4. Importer les workflows suivants :
   - `iana-router.json`
   - `iana-l1-handler.json`
   - `iana-l2-handler.json`
   - `iana-l3-handler.json`

### Méthode 2: Via API n8n

```bash
# Exporter les workflows
cd /Users/arnaud/Documents/ALFA-Agent-Method/alfa-dashboard/n8n/workflows

# Importer via API (nécessite API key)
for workflow in *.json; do
  curl -X POST http://localhost:5678/api/v1/workflows \
    -H "X-N8N-API-KEY: YOUR_API_KEY" \
    -H "Content-Type: application/json" \
    -d @$workflow
done
```

## 🔧 Étape 5: Vérifier les chemins

Dans chaque workflow, vérifier que le chemin vers `llm-cli-wrapper.js` est correct :

```javascript
// Dans les nodes "Prepare Command"
command: `node /Users/arnaud/Documents/ALFA-Agent-Method/alfa-dashboard/scripts/llm-cli-wrapper.js claude-code "..."`
```

**Si votre installation est différente**, modifier le chemin dans tous les workflows.

## 🔧 Étape 6: Tester les workflows

### Test L1 (simple)

```bash
curl -X POST http://localhost:5678/webhook/iana \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Bonjour",
    "user_id": "test",
    "channel": "api"
  }'
```

**Résultat attendu** :
```json
{
  "success": true,
  "tier": "L1",
  "response": "...",
  "meta": {
    "latency_ms": 500,
    "timestamp": "..."
  }
}
```

### Test L2 (avec RAG)

```bash
curl -X POST http://localhost:5678/webhook/iana \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Comment créer un workflow n8n ?",
    "user_id": "test",
    "channel": "api"
  }'
```

### Test L3 (expert)

```bash
curl -X POST http://localhost:5678/webhook/iana \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Analyse l architecture ALFA et propose des améliorations",
    "user_id": "test",
    "channel": "api"
  }'
```

## 🐛 Dépannage

### Erreur: "Command not found"

**Cause** : CLI non installé ou non dans PATH

**Solution** :
```bash
# Vérifier l'installation
which claude-code
which cursor-agent

# Ajouter au PATH si nécessaire
export PATH=$PATH:/chemin/vers/cli
```

### Erreur: "Timeout"

**Cause** : Commande CLI trop longue

**Solution** : Augmenter le timeout dans `llm-cli-wrapper.js` :
```javascript
timeout: 120000 // 2 minutes pour L3
```

### Erreur: "JSON parse error"

**Cause** : Réponse CLI non JSON

**Solution** : Vérifier le format de réponse dans le wrapper :
```javascript
// S'assurer que la réponse est bien formatée en JSON
response = {
  response: result.trim(),
  model: MODEL,
  provider: PROVIDER,
  tokens_used: 0
};
```

### Erreur: "Permission denied"

**Cause** : Scripts non exécutables

**Solution** :
```bash
chmod +x alfa-dashboard/scripts/*.sh
chmod +x alfa-dashboard/scripts/*.js
```

## ✅ Checklist finale

- [ ] CLI installé et fonctionnel (Claude Code / Cursor / Ollama)
- [ ] Wrapper adapté pour votre CLI
- [ ] Test direct du wrapper réussi
- [ ] Workflows importés dans n8n
- [ ] Chemins vérifiés dans les workflows
- [ ] Test L1 réussi
- [ ] Test L2 réussi
- [ ] Test L3 réussi
- [ ] Logs n8n sans erreurs

## 📊 Monitoring

Vérifier les logs n8n pour détecter les erreurs :

```bash
# Logs n8n (Docker)
docker logs n8n -f

# Ou logs système
tail -f /var/log/n8n.log
```

## 💡 Optimisations

### Cache des réponses

Pour éviter d'appeler le CLI à chaque fois, implémenter un cache :

```javascript
const cache = new Map();
const cacheKey = `${PROVIDER}-${MODEL}-${PROMPT.substring(0, 100)}`;

if (cache.has(cacheKey)) {
  return cache.get(cacheKey);
}

// ... appel CLI ...

cache.set(cacheKey, response);
```

### Rate limiting

Limiter les appels pour éviter la surcharge :

```javascript
const rateLimiter = {
  lastCall: 0,
  minInterval: 1000 // 1 seconde entre appels
};

const now = Date.now();
if (now - rateLimiter.lastCall < rateLimiter.minInterval) {
  await new Promise(resolve => setTimeout(resolve, rateLimiter.minInterval - (now - rateLimiter.lastCall)));
}
rateLimiter.lastCall = Date.now();
```

---

**Date**: 2025-01-12
**Version**: 1.0
