# Vérification Workflows n8n - Solution Complète

## Résumé

Implémentation d'un système de vérification pour les workflows n8n :
1. Lister tous les workflows importés
2. Réparer ceux qui ne fonctionnent pas bien
3. Vérification continue (doublons, fonctionnalité)

---

## ✅ État Actuel

### Workflows Créés

1. **iana-workflow-verify.json**
   - Actions : `list`, `check`, `report`
   - Structure CRUD complète (13 nodes)
   - Vérifications : doublons, webhookId, nodes isolés, structure

2. **iana-workflow.json** (existant)
   - Actions : `create`, `read`, `update`, `delete`, `list`, `activate`, `deactivate`, `test`, `execute`
   - Utilisé pour lister et réparer workflows

### Scripts Temporaires (AUDIT uniquement)

1. **scripts/list-n8n-workflows.sh**
   - Liste workflows via API n8n
   - Formatage JSON

2. **scripts/verify-n8n-workflows.sh**
   - Vérifie doublons, webhookId, nodes isolés

**Note :** Ces scripts sont temporaires pour l'AUDIT. La vérification permanente doit être dans le workflow n8n.

---

## 📋 Vérifications Implémentées

### 1. Doublons (noms identiques)

```javascript
// Vérifie si plusieurs workflows ont le même nom
const nameMap = {};
for (const wf of workflows) {
  const name = wf.name;
  if (!nameMap[name]) {
    nameMap[name] = [];
  }
  nameMap[name].push(wf.id);
}

for (const [name, ids] of Object.entries(nameMap)) {
  if (ids.length > 1) {
    issues.duplicates.push({
      name: name,
      ids: ids,
      count: ids.length
    });
  }
}
```

### 2. Workflows Webhook sans webhookId

```javascript
// Vérifie si workflows webhook ont un webhookId
for (const wf of workflows) {
  if (wf.nodes) {
    for (const node of wf.nodes) {
      if (node.type === 'n8n-nodes-base.webhook') {
        const webhookId = node.parameters?.webhookId || node.webhookId;
        if (!webhookId) {
          issues.missing_webhook_id.push({
            workflow_name: wf.name,
            workflow_id: wf.id,
            node_id: node.id
          });
        }
      }
    }
  }
}
```

### 3. Workflows avec Nodes Isolés

```javascript
// Vérifie si workflows ont des nodes sans connections
for (const wf of workflows) {
  if (wf.nodes && (!wf.connections || Object.keys(wf.connections).length === 0)) {
    if (wf.nodes.length > 1) {
      issues.isolated_nodes.push({
        workflow_name: wf.name,
        workflow_id: wf.id,
        nodes_count: wf.nodes.length
      });
    }
  }
}
```

### 4. Erreurs de Structure

```javascript
// Vérifie si nodes ont des erreurs de structure
for (const wf of workflows) {
  if (wf.nodes) {
    for (const node of wf.nodes) {
      if (!node.type) {
        issues.structure_errors.push({
          workflow_name: wf.name,
          workflow_id: wf.id,
          node_id: node.id,
          error: 'Node without type'
        });
      }
    }
  }
}
```

---

## 🔧 Utilisation

### Action 'list' - Lister Workflows

```bash
curl -X POST "http://localhost:5678/webhook/workflow-verify" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "list",
    "user_id": "test",
    "data": {
      "filters": {}
    }
  }'
```

### Action 'check' - Vérifier Workflows

```bash
curl -X POST "http://localhost:5678/webhook/workflow-verify" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "check",
    "user_id": "test",
    "data": {}
  }'
```

### Action 'report' - Générer Rapport

```bash
curl -X POST "http://localhost:5678/webhook/workflow-verify" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "report",
    "user_id": "test",
    "data": {
      "date_from": "2025-01-12T00:00:00Z",
      "date_to": "2025-01-12T23:59:59Z"
    }
  }'
```

---

## 🚨 Problèmes Identifiés

### 1. Workflow iana-workflow-verify Incomplet

**Problème :** L'action 'check' n'appelle pas l'API n8n pour récupérer les workflows.

**Solution :** Corriger le workflow pour que l'action 'check' :
1. Appelle d'abord l'API n8n (HTTP Request node) pour lister workflows
2. Puis vérifie les workflows récupérés (Code node)

### 2. Nécessite API Key n8n

**Problème :** Le workflow nécessite `N8N_API_KEY` dans les variables d'environnement.

**Solution :** Configurer `N8N_API_KEY` dans n8n (Settings → Environment Variables).

---

## 📊 Prochaines Étapes

1. **AUDIT Immédiat** (si API key disponible)
   - Utiliser `scripts/list-n8n-workflows.sh` pour lister workflows
   - Utiliser `scripts/verify-n8n-workflows.sh` pour vérifier problèmes
   - Identifier workflows non fonctionnels

2. **Corriger Workflow iana-workflow-verify**
   - Modifier action 'check' pour appeler API n8n d'abord
   - Tester workflow

3. **Réparer Workflows**
   - Utiliser workflow iana-workflow (action 'update') pour réparer
   - Utiliser workflow iana-workflow (action 'activate') pour activer

4. **Vérification Continue**
   - Activer workflow iana-workflow-verify
   - Programmer vérification régulière (Schedule Trigger)
   - Alerter en cas de problèmes

---

## 📝 Format Response Standardisé

```json
{
  "success": true,
  "action": "check",
  "data": {
    "workflows_count": 20,
    "issues": {
      "duplicates": [],
      "missing_webhook_id": [],
      "isolated_nodes": [],
      "structure_errors": []
    },
    "total_issues": 0,
    "has_issues": false
  },
  "error": null,
  "meta": {
    "latency_ms": 123,
    "timestamp": "2025-01-12T12:00:00.000Z",
    "request_id": "test-1234567890"
  }
}
```

---

## ✅ Conformité ALFA

- ✅ Structure CRUD complète
- ✅ Format request/response standardisé
- ✅ Logging dans `iana.operation_logs`
- ✅ Error handling standardisé
- ✅ Toutes opérations dans workflows (pas de scripts shell)
- ✅ Vérification via workflow n8n (pas scripts shell)

---

**Date :** 2025-01-12
**Statut :** ⏳ Workflow créé, nécessite corrections et tests
