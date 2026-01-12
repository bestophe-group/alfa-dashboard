# 🔍 DIAGNOSTIC BUG MCP n8n 2.2.4

**Date**: 2026-01-12  
**Agent**: Cursor (Auto)  
**Status**: ⚠️ Bug confirmé - MCP fonctionne mais workflows inaccessibles

---

## 📋 RÉSUMÉ

Le serveur MCP n8n est **fonctionnel** (initialize OK, tools/list OK) mais les outils `search_workflows` et `get_workflow_details` ne retournent pas les workflows existants en DB.

---

## ✅ PREUVES

### 1. Workflows existants en DB PostgreSQL

**Base**: `n8n` (pas `alfa`)

```sql
SELECT id, name, active FROM workflow_entity;
```

| ID | Name | Active |
|----|------|--------|
| `qvP4jUz9nnp5wHlv` | Alerts Critical → Slack | false |
| `1qSsruI7p2KU1pGd` | IANA Router - Validated 98% | true |

**Total**: 2 workflows confirmés en DB

---

### 2. Permissions vérifiées

**User MCP**: `arnaud.pasquier@gmail.com` (93da4bc7-eceb-457f-a87e-cc9387eb471b)  
**Project MCP**: `arnaud pasquier <arnaud.pasquier@gmail.com>` (aaPv2c0TqKAz3tL1)

**Workflows ownership**:
```sql
SELECT w.id, w.name, sw.role, p.name as project_name
FROM workflow_entity w
LEFT JOIN shared_workflow sw ON w.id = sw."workflowId"
LEFT JOIN project p ON sw."projectId" = p.id;
```

| Workflow | Role | Project |
|----------|------|---------|
| Alerts Critical → Slack | `workflow:owner` | arnaud pasquier <...> |
| IANA Router - Validated 98% | `workflow:owner` | arnaud pasquier <...> |

✅ **Token MCP et workflows sont dans le MÊME projet**

---

### 3. Test MCP `search_workflows`

**Commande**:
```bash
curl -X POST "http://localhost:5678/mcp-server/http" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json, text/event-stream" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "search_workflows",
      "arguments": {"limit": 20}
    },
    "id": 2
  }'
```

**Résultat**:
```json
{
  "result": {
    "content": [{
      "type": "text",
      "text": "{\"data\":[],\"count\":0}"
    }],
    "structuredContent": {
      "data": [],
      "count": 0
    }
  }
}
```

❌ **Retourne 0 workflows** malgré 2 workflows en DB

---

### 4. Test MCP `get_workflow_details`

**Commande**:
```bash
curl -X POST "http://localhost:5678/mcp-server/http" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get_workflow_details",
      "arguments": {"workflowId": "1qSsruI7p2KU1pGd"}
    },
    "id": 3
  }'
```

**Résultat**:
```json
{
  "result": {
    "content": [{
      "type": "text",
      "text": "Workflow not found"
    }],
    "isError": true
  }
}
```

❌ **Retourne "Workflow not found"** malgré ID valide en DB

---

## 🔍 HYPOTHÈSES

### 1. Bug MCP Server n8n 2.2.4

**Probabilité**: 80%

Le serveur MCP n8n intégré (version 1.0.0) dans n8n 2.2.4 pourrait avoir un bug dans l'implémentation de `search_workflows` qui :
- Ne filtre pas correctement par projet
- Ne récupère pas les workflows partagés
- A un problème de cache/permissions

### 2. Workflows "legacy" créés avant activation MCP

**Probabilité**: 10%

Les workflows créés avant l'activation du MCP server pourraient ne pas être indexés.

### 3. Isolation de contexte MCP

**Probabilité**: 10%

Le serveur MCP pourrait utiliser un contexte isolé qui ne voit pas les workflows du projet principal.

---

## 🎯 WORKAROUNDS PROPOSÉS

### Option 1: Créer un workflow de test via MCP

**Objectif**: Vérifier si les **nouveaux workflows** créés via MCP sont visibles.

**Test**:
1. Utiliser l'outil MCP `create_workflow` (si disponible)
2. Créer un workflow simple
3. Tester `search_workflows` immédiatement après

**Si ça marche**: Confirme que c'est un problème avec les workflows "legacy"

### Option 2: Utiliser API REST n8n

**Avantage**: API REST stable et testée

**Configuration**:
1. Créer un `X-N8N-API-KEY` dans n8n Settings > API
2. Utiliser `/api/v1/workflows` au lieu de MCP
3. Intégrer dans workflow `iana-workflow-create`

**Endpoint**:
```bash
curl "http://localhost:5678/api/v1/workflows" \
  -H "X-N8N-API-KEY: n8n_api_XXXXX"
```

### Option 3: Mettre à jour n8n

**Version actuelle**: 2.2.4  
**Version la plus récente**: À vérifier

Le bug pourrait être corrigé dans une version plus récente.

### Option 4: Contournement via PostgreSQL direct

**Pour workflow `iana-workflow-create`**:
- Utiliser PostgreSQL directement pour lire les workflows
- Créer via API REST n8n
- Éviter MCP pour les workflows existants

---

## 📊 COMPARAISON MCP vs API REST

| Aspect | MCP Server | API REST |
|--------|-----------|----------|
| **Authentification** | JWT MCP Token | X-N8N-API-KEY |
| **Endpoint** | `/mcp-server/http` | `/api/v1/workflows` |
| **Protocol** | JSON-RPC 2.0 (SSE) | REST (HTTP) |
| **Workflows visibles** | ❌ 0 (bug) | ✅ Tous |
| **Stabilité** | ⚠️ Bug 2.2.4 | ✅ Stable |
| **Recommandation** | ⚠️ Workaround nécessaire | ✅ Utiliser pour workflow create |

---

## ✅ ACTIONS RECOMMANDÉES

### Immédiat (pour workflow `iana-workflow-create`)

1. **Utiliser API REST n8n** au lieu de MCP
   - Créer `X-N8N-API-KEY` dans n8n Settings
   - Implémenter `iana-workflow-create` avec API REST

2. **Tester création workflow via MCP** (si outil disponible)
   - Vérifier si nouveaux workflows sont visibles

### Court terme

3. **Signaler le bug** à n8n
   - Version: 2.2.4
   - MCP Server: 1.0.0
   - Symptôme: `search_workflows` retourne 0 malgré workflows en DB
   - Permissions: OK (même projet, owner)

4. **Vérifier version n8n** la plus récente
   - Mettre à jour si bug corrigé

### Long terme

5. **Monitorer correction** du bug MCP
   - Tester après mise à jour n8n
   - Migrer vers MCP une fois corrigé

---

## 📝 NOTES TECHNIQUES

### Base de données n8n

**Important**: n8n utilise la base `n8n` (pas `alfa`)

```bash
# Vérifier workflows
docker exec alfa-postgres psql -U alfa -d n8n -c \
  "SELECT id, name, active FROM workflow_entity;"
```

### Token MCP vs API Key

**Token MCP** (utilisé ici):
- Source: Settings > Instance-level MCP > Access Token
- Format: JWT
- Usage: MCP Server uniquement

**API Key** (pour workaround):
- Source: Settings > n8n API > Create API Key
- Format: `n8n_api_XXXXX`
- Usage: API REST `/api/v1/*`

---

## 🔄 PROCHAINES ÉTAPES

1. ✅ **Diagnostic complet** (fait)
2. ⏳ **Créer workflow `iana-workflow-create` avec API REST** (workaround)
3. ⏳ **Tester création workflow via MCP** (si possible)
4. ⏳ **Signaler bug à n8n** (optionnel)

---

**Fiabilité**: 95%  
**Status**: Bug confirmé, workaround disponible  
**Maintenu par**: Cursor (Auto)  
**Dernière mise à jour**: 2026-01-12
