# 🔧 INSTRUCTIONS : Activation du workflow iana-router

**Problème**: Le webhook `/webhook/iana` retourne HTTP 200 mais un body vide car le workflow n'est pas activé.

---

## ✅ ÉTAT ACTUEL

- ✅ Workflow `iana-router` importé dans n8n (ID: `Fowjj0lqqwb1Abbi`)
- ✅ Workflow s'exécute partiellement (création conversation dans PostgreSQL)
- ❌ Workflow **NON activé** → réponse HTTP vide
- ❌ Token API n8n invalide → impossible d'activer via API

---

## 🎯 SOLUTION : Activation manuelle dans n8n UI

### Étape 1 : Ouvrir n8n

1. Ouvrir http://localhost:5678 dans votre navigateur
2. Se connecter à n8n (si nécessaire)

### Étape 2 : Trouver le workflow

1. Cliquer sur **"Workflows"** dans le menu de gauche
2. Chercher **"iana-router"** dans la liste
3. Cliquer sur le workflow pour l'ouvrir

### Étape 3 : Activer le workflow

1. En haut à droite du workflow, trouver le toggle **"Active"** (ou "Inactive")
2. Cliquer sur le toggle pour l'activer
3. Le workflow doit passer en état **"Active"** (couleur verte)

**Visual**:
```
┌─────────────────────────────────────────┐
│ iana-router                    [Active] │ ← Toggle ici
├─────────────────────────────────────────┤
│                                         │
│  [Webhook IANA] → [Parse Request] → ... │
│                                         │
└─────────────────────────────────────────┘
```

### Étape 4 : Vérifier l'activation

1. Retourner à la liste des workflows
2. Le workflow `iana-router` doit avoir un indicateur **vert** ou **"Active"**
3. Le webhook `/webhook/iana` doit être accessible

---

## 🧪 TEST APRÈS ACTIVATION

### Test 1 : Requête simple

```bash
curl -X POST "http://localhost:5678/webhook/iana" \
  -H "Content-Type: application/json" \
  -d '{"query": "Dis bonjour", "user_id": "arnaud"}' \
  -v
```

**Résultat attendu**:
```json
{
  "success": true,
  "tier": "L1",
  "response": "Bonjour ! Comment puis-je vous aider ?",
  "confidence": 0.95,
  "rag_context_used": false,
  "rag_count": 0,
  "meta": {
    "latency_ms": 1234,
    "timestamp": "2026-01-12T19:30:00.000Z",
    "request_id": "arnaud-1705086000000",
    "conversation_id": "0badbb72-b562-45c8-b316-f7718728a9b4"
  }
}
```

### Test 2 : Vérifier les logs

```bash
# Logs Docker n8n
docker logs alfa-n8n --tail 50 | grep -i "iana"

# Vérifier conversation créée
docker exec alfa-postgres psql -U alfa -d alfa -c \
  "SELECT conversation_id, user_id, channel, created_at FROM iana.conversations ORDER BY created_at DESC LIMIT 3;"
```

---

## 🔍 DIAGNOSTIC SI PROBLÈME PERSISTE

### Vérifier le statut du workflow

```bash
curl -s -X GET "http://localhost:5678/api/v1/workflows/Fowjj0lqqwb1Abbi" \
  -H "X-N8N-API-KEY: YOUR_API_KEY" \
  | jq '{name: .name, active: .active, nodes: .nodes | length}'
```

### Vérifier les logs Docker

```bash
docker logs alfa-n8n --tail 100 | grep -E "(ERROR|error|Error|Problem)" | tail -20
```

### Vérifier les credentials PostgreSQL

1. Dans n8n UI, ouvrir **"Credentials"**
2. Chercher la credential PostgreSQL (ID: `5zFMgYDljFx593WZ`)
3. Vérifier qu'elle est bien configurée et testable

---

## ✅ CHECKLIST FINALE

- [ ] Workflow `iana-router` visible dans n8n UI
- [ ] Workflow activé (toggle "Active" ON)
- [ ] Webhook `/webhook/iana` retourne une réponse JSON complète
- [ ] La réponse contient `success: true` et `data.response`
- [ ] Les conversations sont créées dans PostgreSQL
- [ ] Aucune erreur dans les logs Docker n8n

---

## 📝 NOTES

- **Workflow ID**: `Fowjj0lqqwb1Abbi`
- **PostgreSQL Credential ID**: `5zFMgYDljFx593WZ`
- **Webhook URL**: `http://localhost:5678/webhook/iana`
- **n8n UI**: http://localhost:5678

Le workflow est instrumenté avec des logs de debug. Une fois activé, les logs seront visibles dans le serveur ndjson ingest (si actif) ou dans les logs Docker n8n.

---

**Fiabilité attendue après activation**: 90% (si réponse JSON complète retournée)
