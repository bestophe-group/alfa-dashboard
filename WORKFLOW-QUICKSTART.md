# 🚀 ALFA WORKFLOWS - QUICK START

> Guide rapide pour démarrer avec les workflows n8n IANA/ALFA

---

## ✅ PHASE 1 COMPLÉTÉE

### Sub-Workflows créés (Niveau 2)

| Workflow | Fichier | Fonction | Status |
|----------|---------|----------|--------|
| `iana-log` | `workflows/iana-log.json` | Logging centralisé PostgreSQL | ✅ Fait |
| `iana-context` | `workflows/iana-context.json` | Récupération historique conversations | ✅ Fait |
| `iana-error-handler` | `workflows/iana-error-handler.json` | Gestion erreurs + alertes Slack | ✅ Fait |
| `iana-rag-query` | `workflows/iana-rag-query.json` | Consultation RAG vector search | ✅ Fait |
| `alfa-slack-send` | `workflows/alfa-slack-send.json` | Notifications Slack | ✅ Fait |

---

## 📋 PRÉREQUIS

### 1. Base de Données PostgreSQL

```bash
# Se connecter à PostgreSQL
psql -U postgres

# Créer la base IANA si elle n'existe pas
CREATE DATABASE iana;

# Se connecter à la base
\c iana

# Exécuter la migration core
\i /path/to/ALFA-Agent-Method/migrations/00-iana-core.sql

# Vérifier que les tables sont créées
\dt iana.*
\dt rag.*
```

**Tables créées:**
- `iana.conversations`
- `iana.messages`
- `iana.operation_logs`
- `iana.error_logs`
- `iana.notification_logs`
- `rag.documents`
- `rag.document_chunks`

### 2. n8n Configuration

**Créer credential PostgreSQL:**
1. Aller dans n8n → Credentials
2. Créer nouvelle credential "PostgreSQL"
3. Nom: `PostgreSQL IANA`
4. Host: `localhost` (ou votre host PostgreSQL)
5. Port: `5432`
6. Database: `iana`
7. User: `postgres` (ou votre user)
8. Password: `[votre password]`
9. Tester la connexion → Sauvegarder

**Variables d'environnement (optionnel):**
```bash
# Dans votre .env ou docker-compose.yml
ANTHROPIC_API_KEY=sk-ant-xxxxx
GROQ_API_KEY=gsk_xxxxx  # Optionnel
```

---

## 📦 INSTALLATION DES WORKFLOWS

### Méthode 1: Import Manuel (Interface n8n)

1. Ouvrir n8n dans le navigateur
2. Aller dans "Workflows" → "Add workflow"
3. Cliquer sur "..." → "Import from File"
4. Sélectionner le fichier workflow (ex: `iana-log.json`)
5. Répéter pour chaque workflow

### Méthode 2: CLI n8n (Recommandé)

```bash
# Se positionner dans le dossier workflows
cd /Users/arnaud/Documents/ALFA-Agent-Method/mcp-server/workflows

# Importer tous les workflows Phase 1
n8n import:workflow --input=iana-log.json
n8n import:workflow --input=iana-context.json
n8n import:workflow --input=iana-error-handler.json
n8n import:workflow --input=iana-rag-query.json
n8n import:workflow --input=alfa-slack-send.json
```

### Méthode 3: API n8n

```bash
# Exemple pour iana-log
curl -X POST http://localhost:5678/rest/workflows \
  -H "Content-Type: application/json" \
  -d @iana-log.json
```

---

## 🔧 ACTIVATION DES WORKFLOWS

**Tous les workflows sont créés avec `active: false`.**

Pour activer:

### Via Interface
1. Ouvrir le workflow dans n8n
2. Cliquer sur le toggle "Active" en haut à droite

### Via CLI
```bash
# Activer un workflow spécifique
n8n workflow:activate --id=<workflow-id>
```

### Via API
```bash
curl -X PATCH http://localhost:5678/rest/workflows/<workflow-id> \
  -H "Content-Type: application/json" \
  -d '{"active": true}'
```

---

## ✅ TESTS DE VALIDATION

### Test 1: iana-log (Logging)

```bash
curl -X POST http://localhost:5678/webhook/iana/log \
  -H "Content-Type: application/json" \
  -d '{
    "conversation_id": 1,
    "user_id": "test_user",
    "role": "user",
    "content": "Hello IANA!",
    "tier": "L1",
    "metadata": {"source": "test"}
  }'
```

**Réponse attendue:**
```json
{
  "success": true,
  "message_id": 123,
  "logged_at": "2025-01-12T16:30:00.000Z"
}
```

**Vérification DB:**
```sql
SELECT * FROM iana.messages ORDER BY created_at DESC LIMIT 1;
```

---

### Test 2: iana-context (Récupération historique)

```bash
curl -X POST http://localhost:5678/webhook/iana/context \
  -H "Content-Type: application/json" \
  -d '{
    "conversation_id": 1,
    "user_id": "test_user",
    "limit": 10
  }'
```

**Réponse attendue:**
```json
{
  "success": true,
  "count": 5,
  "messages": [
    {
      "message_id": 1,
      "conversation_id": 1,
      "role": "user",
      "content": "Hello",
      "tier": "L1",
      "created_at": "..."
    }
  ],
  "retrieved_at": "2025-01-12T16:31:00.000Z"
}
```

---

### Test 3: iana-error-handler (Gestion erreurs)

```bash
curl -X POST http://localhost:5678/webhook/iana/error \
  -H "Content-Type: application/json" \
  -d '{
    "workflow_id": "test-workflow",
    "node_id": "test-node",
    "error": {
      "message": "Division by zero",
      "code": "ERR_DIV_ZERO"
    },
    "severity": "critical"
  }'
```

**Réponse attendue:**
```json
{
  "success": true,
  "error_id": 1,
  "logged": true,
  "alert_sent": true,
  "timestamp": "2025-01-12T16:32:00.000Z"
}
```

**Vérification DB:**
```sql
SELECT * FROM iana.error_logs ORDER BY created_at DESC LIMIT 1;
```

---

### Test 4: iana-rag-query (RAG search)

**Prérequis:** Avoir des documents dans `rag.documents`

```sql
-- Insérer un document de test
INSERT INTO rag.documents (title, content, category, embedding)
VALUES (
  'Test Document',
  'This is a test document for RAG search',
  'test',
  ARRAY(SELECT random() FROM generate_series(1, 1536))::vector(1536)
);
```

```bash
curl -X POST http://localhost:5678/webhook/iana/rag/query \
  -H "Content-Type: application/json" \
  -d '{
    "query": "test document",
    "limit": 5,
    "threshold": 0.7
  }'
```

**Réponse attendue:**
```json
{
  "success": true,
  "query": "test document",
  "results_count": 1,
  "results": [
    {
      "doc_id": 1,
      "title": "Test Document",
      "content": "This is a test document...",
      "category": "test",
      "similarity": 0.85
    }
  ],
  "retrieved_at": "2025-01-12T16:33:00.000Z"
}
```

---

### Test 5: alfa-slack-send (Notifications)

```bash
curl -X POST http://localhost:5678/webhook/alfa/slack/send \
  -H "Content-Type: application/json" \
  -d '{
    "channel": "#general",
    "text": "Test message from ALFA",
    "username": "ALFA Test Bot",
    "icon_emoji": ":robot_face:"
  }'
```

**Réponse attendue:**
```json
{
  "success": true,
  "channel": "#general",
  "message_ts": "1705075200.123456",
  "log_id": 1,
  "sent_at": "2025-01-12T16:34:00.000Z"
}
```

**Note:** Le workflow actuel utilise un mock. Remplacer par un vrai node Slack en production.

---

## 🐛 DEBUGGING

### Vérifier les logs n8n

```bash
# Via Docker
docker logs -f n8n

# Via CLI
n8n logs
```

### Vérifier l'exécution des workflows

**Via Interface:**
1. Ouvrir le workflow
2. Onglet "Executions" (historique)
3. Cliquer sur une exécution pour voir le détail

**Via API:**
```bash
# Liste des exécutions récentes
curl http://localhost:5678/rest/executions?limit=10

# Détail d'une exécution
curl http://localhost:5678/rest/executions/<execution-id>
```

### Requêtes SQL utiles

```sql
-- Derniers messages loggés
SELECT * FROM iana.messages ORDER BY created_at DESC LIMIT 10;

-- Dernières erreurs
SELECT * FROM iana.error_logs ORDER BY created_at DESC LIMIT 10;

-- Dernières notifications
SELECT * FROM iana.notification_logs ORDER BY sent_at DESC LIMIT 10;

-- Vue résumé opérations (24h)
SELECT * FROM iana.v_operations_summary;

-- Vue erreurs récentes (24h)
SELECT * FROM iana.v_recent_errors;

-- Conversations actives
SELECT * FROM iana.v_active_conversations;
```

---

## 📊 MONITORING

### Endpoints de santé

```bash
# Health check n8n
curl http://localhost:5678/healthz

# Vérifier que tous les workflows sont actifs
curl http://localhost:5678/rest/workflows | jq '.data[] | select(.active == true) | .name'
```

### Métriques PostgreSQL

```sql
-- Nombre de messages par tier (dernières 24h)
SELECT tier, COUNT(*) as count
FROM iana.messages
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY tier;

-- Taux de succès des opérations
SELECT
  workflow_id,
  ROUND(100.0 * SUM(CASE WHEN success THEN 1 ELSE 0 END) / COUNT(*), 2) as success_rate
FROM iana.operation_logs
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY workflow_id;

-- Latence moyenne par workflow
SELECT
  workflow_id,
  ROUND(AVG(latency_ms)) as avg_latency_ms,
  MAX(latency_ms) as max_latency_ms
FROM iana.operation_logs
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY workflow_id;
```

---

## 🎯 PROCHAINES ÉTAPES

### Phase 2: Workflows CRUD (Façades)

À créer selon [CLAUDE.md](./CLAUDE.md):

1. **iana-message** (`/webhook/message`)
   - Actions: log, context, search
   - Appelle: `iana-log`, `iana-context`

2. **iana-rag** (`/webhook/rag`)
   - Actions: query, create, update, delete, enrich
   - Appelle: `iana-rag-query`, `iana-rag-create`, etc.

3. **iana-llm** (`/webhook/llm`)
   - Actions: chat-l1, action-l2, expert-l3
   - Appelle: `iana-chat-l1`, `iana-action-l2`, `iana-expert-l3`

4. **alfa-notify** (`/webhook/notify`)
   - Actions: slack, email, sms
   - Appelle: `alfa-slack-send`, etc.

---

## 📚 RESSOURCES

| Document | Description |
|----------|-------------|
| [CLAUDE.md](./CLAUDE.md) | Règles architecture workflows (à suivre par Claude CLI) |
| [migrations/00-iana-core.sql](./migrations/00-iana-core.sql) | Migration SQL base |
| [mcp-server/workflows/](./mcp-server/workflows/) | Dossier workflows JSON |

---

## ❓ FAQ

### Pourquoi les workflows sont-ils inactive par défaut ?

**Sécurité.** Permet de vérifier la configuration (credentials, DB) avant exposition des endpoints.

### Dois-je créer les tables manuellement ?

**Oui.** Exécuter `migrations/00-iana-core.sql` avant d'activer les workflows.

### Comment changer les endpoints ?

Modifier le paramètre `path` dans le node Webhook du workflow JSON.

### Les sub-workflows comptent-ils dans les limites n8n ?

**Non.** Selon la [documentation n8n](https://docs.n8n.io/flow-logic/subworkflows), les sub-workflows ne comptent pas dans les limites d'exécution.

### Puis-je utiliser un autre LLM que Claude/Groq ?

**Oui.** Remplacer les nodes `@n8n/n8n-nodes-langchain.lmChatAnthropic` par votre LLM préféré (OpenAI, Ollama, etc.).

---

**Créé par:** Claude Code CLI
**Version:** 1.0 (2025-01-12)
