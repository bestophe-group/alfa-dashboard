# 🎯 IANA Workflow Create - Guide d'Installation

**Date**: 2026-01-12  
**Workflow**: `iana-workflow-create`  
**Status**: ✅ Créé, ⏳ À importer et configurer

---

## 📋 PRÉREQUIS

### 1. API Key n8n

**Étape 1**: Créer une API Key dans n8n

1. Ouvrir n8n: http://localhost:5678
2. Aller dans: **Settings → API**
3. Cliquer: **Create API Key**
4. Copier le token (format: `n8n_api_XXXXX-rL0`)

**Étape 2**: Configurer la variable d'environnement

**Option A**: Variable d'environnement n8n (recommandé)

Ajouter dans `docker-compose.yml` (section n8n):
```yaml
environment:
  - N8N_API_KEY=n8n_api_XXXXX-rL0
```

**Option B**: Credential n8n

1. Dans n8n: **Settings → Credentials → New**
2. Type: **HTTP Header Auth**
3. Name: `N8N API Key`
4. Header Name: `X-N8N-API-KEY`
5. Header Value: `n8n_api_XXXXX-rL0`

Puis modifier les nodes HTTP dans le workflow pour utiliser cette credential.

---

### 2. Credential PostgreSQL IANA

**Vérifier** que la credential `PostgreSQL IANA` existe dans n8n:

1. **Settings → Credentials**
2. Chercher: `PostgreSQL IANA`
3. Si absent, créer:
   - Type: **Postgres**
   - Name: `PostgreSQL IANA`
   - Host: `postgres` (ou `localhost` si test local)
   - Database: `alfa`
   - User: `alfa`
   - Password: `alfapass123`
   - Port: `5432`

---

## 📥 IMPORT DU WORKFLOW

### Méthode 1: Import via Interface n8n

1. Ouvrir n8n: http://localhost:5678
2. **Workflows → Import from File**
3. Sélectionner: `alfa-dashboard/n8n/workflows/iana-workflow-create.json`
4. Cliquer: **Import**

### Méthode 2: Import via API REST

```bash
# Remplacer YOUR_API_KEY par la vraie API key
curl -X POST "http://localhost:5678/api/v1/workflows" \
  -H "X-N8N-API-KEY: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d @alfa-dashboard/n8n/workflows/iana-workflow-create.json
```

---

## ⚙️ CONFIGURATION POST-IMPORT

### 1. Vérifier les Credentials

Dans le workflow importé, vérifier que:
- Node **API Create Workflow** → Credential: `N8N API Key` (ou variable env)
- Node **API Read Workflow** → Credential: `N8N API Key`
- Node **API List Workflows** → Credential: `N8N API Key`
- Node **API Update Workflow** → Credential: `N8N API Key`
- Node **API Delete Workflow** → Credential: `N8N API Key`
- Node **API Activate Workflow** → Credential: `N8N API Key`
- Node **API Test Workflow** → Credential: `N8N API Key`
- Node **Log Operation** → Credential: `PostgreSQL IANA`

### 2. Vérifier les Variables d'Environnement

Si vous utilisez `$env.N8N_API_KEY` dans les nodes HTTP:
- Vérifier que la variable est définie dans n8n
- Ou remplacer par credential HTTP Header Auth

---

## 🧪 TEST DU WORKFLOW

### 1. Activer le Workflow

Dans n8n, activer le workflow `iana-workflow-create`.

### 2. Test Action: list

```bash
curl -X POST "http://localhost:5678/webhook/workflow" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "list",
    "user_id": "test-user",
    "data": {}
  }'
```

**Résultat attendu**:
```json
{
  "success": true,
  "action": "list",
  "data": [...],
  "error": null,
  "meta": {
    "latency_ms": 123,
    "timestamp": "2026-01-12T...",
    "request_id": "test-user-..."
  }
}
```

### 3. Test Action: create

```bash
curl -X POST "http://localhost:5678/webhook/workflow" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "create",
    "user_id": "test-user",
    "data": {
      "name": "Test Workflow",
      "nodes": [],
      "connections": {}
    }
  }'
```

### 4. Vérifier Logging

```sql
SELECT * FROM iana.operation_logs 
WHERE workflow_id = 'iana-workflow-create' 
ORDER BY created_at DESC 
LIMIT 5;
```

---

## 📊 ACTIONS DISPONIBLES

| Action | Description | Paramètres requis |
|--------|-------------|-------------------|
| `create` | Créer un workflow | `data.name` (requis), `data.nodes`, `data.connections` |
| `read` | Lire un workflow | `data.workflowId` |
| `update` | Modifier un workflow | `data.workflowId`, `data.name`, `data.nodes`, etc. |
| `delete` | Supprimer un workflow | `data.workflowId` |
| `list` | Lister tous les workflows | Aucun |
| `activate` | Activer/désactiver | `data.workflowId`, `data.active` (optionnel) |
| `test` | Tester un workflow | `data.workflowId`, `data.inputData` (optionnel) |

---

## 🔧 TROUBLESHOOTING

### Erreur: "X-N8N-API-KEY header required"

**Cause**: API key non configurée ou invalide

**Solution**:
1. Vérifier que l'API key est créée dans n8n Settings
2. Vérifier que la variable `N8N_API_KEY` est définie (ou credential configurée)
3. Vérifier que les nodes HTTP utilisent la bonne credential/variable

### Erreur: "PostgreSQL IANA credential not found"

**Cause**: Credential PostgreSQL non créée

**Solution**:
1. Créer credential `PostgreSQL IANA` dans n8n
2. Configurer avec les bons paramètres de connexion

### Erreur: "function iana.log_operation does not exist"

**Cause**: Migration SQL non exécutée

**Solution**:
```bash
docker exec alfa-postgres psql -U alfa -d alfa -f /path/to/migrations/00-iana-core.sql
```

---

## ✅ CHECKLIST FINALE

- [ ] API Key n8n créée
- [ ] Variable `N8N_API_KEY` configurée (ou credential HTTP Header Auth)
- [ ] Credential `PostgreSQL IANA` créée
- [ ] Migration `00-iana-core.sql` exécutée
- [ ] Workflow importé dans n8n
- [ ] Credentials vérifiées dans le workflow
- [ ] Workflow activé
- [ ] Test `list` réussi
- [ ] Test `create` réussi
- [ ] Logging vérifié dans `iana.operation_logs`

---

**Fiabilité**: 95%  
**Maintenu par**: Cursor (Auto)  
**Dernière mise à jour**: 2026-01-12
