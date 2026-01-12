# AUDIT : Workflows IANA existants

**Date**: 2026-01-12  
**Phase**: Phase 1 - Audit des workflows IANA existants

---

## Objectif

Vérifier la structure CRUD, le format request/response, le logging, et s'assurer que toutes les opérations passent par des workflows.

---

## Workflows IANA identifiés

### 1. iana-router.json

**Status**: ✅ Existe  
**Endpoint**: `/webhook/iana`  
**Structure**: 
- Webhook → Parse Request → Get Conversation → Classifier (CLI) → Switch L1/L2/L3 → Handlers → Format Response → Log → Respond
- ❌ Pas de structure CRUD standard (routing LLM, pas CRUD)
- ✅ Logging partiel (pas dans `iana.operation_logs` standardisé)
- ✅ Toutes opérations dans workflow (Code nodes avec child_process)

**Actions**: Classification L1/L2/L3, routing

**Gaps**:
- Pas de structure CRUD standard
- Logging non standardisé dans `iana.operation_logs`
- Format response non standardisé

---

### 2. iana-bridge.json

**Status**: ✅ Existe  
**Endpoint**: `/webhook/bridge`  
**Structure**:
- Webhook → Parse Bridge Request → Router (Execute Workflow)
- ❌ Pas de structure CRUD standard (bridge vers autres workflows)
- ❌ Pas de logging
- ✅ Toutes opérations dans workflow (Execute Workflow nodes)

**Actions**: Bridge vers autres workflows

**Gaps**:
- Pas de structure CRUD
- Pas de logging
- Pas de format response standardisé

---

### 3. iana-conversation.json

**Status**: ✅ Existe  
**Endpoint**: `/webhook/conversation`  
**Structure**: 
- Webhook → Validate Input → Switch Action → Actions (create, read, update, delete, list, close) → DB Operations → Merge → Log → Format Response → Respond
- ✅ Structure CRUD complète (Switch avec toutes actions)
- ✅ Format response standardisé (Format Response node)
- ✅ Logging dans `iana.operation_logs` (via fonction `iana.log_operation()`)
- ✅ Toutes opérations dans workflow (PostgreSQL nodes)

**Actions**: `create`, `read`, `update`, `delete`, `list`, `close`

**Gaps**: 
- ⚠️ Credential ID hardcodé : `postgres-iana` (devrait utiliser credential réel)
- ⚠️ Node "Respond to Webhook" a paramètres vides (nécessite configuration manuelle)
- ⚠️ Table `iana.conversations` dans SQL ne correspond pas exactement au schéma (colonnes différentes)

---

### 4. iana-message.json

**Status**: ✅ Existe  
**Endpoint**: `/webhook/message`  
**Structure**:
- Webhook → Validate Input → Switch Action → Actions (log, context, search) → Merge → Log → Format Response → Respond
- ✅ Structure Switch (mais actions différentes : log, context, search au lieu de CRUD standard)
- ✅ Format response standardisé
- ✅ Logging dans `iana.operation_logs`
- ✅ Utilise Execute Workflow pour sub-workflows (iana-log, iana-context)

**Actions**: `log`, `context`, `search` (différent de plan : `create`, `read`, `list`, `search`)

**Gaps**:
- ⚠️ Actions ne correspondent pas au plan (log, context vs create, read, list)
- ⚠️ Dépend de sub-workflows (iana-log, iana-context) qui doivent exister
- ⚠️ Credential ID hardcodé : `postgres-iana`
- ⚠️ Node "Respond to Webhook" a paramètres vides

---

### 5. iana-llm.json

**Status**: ✅ Existe  
**Endpoint**: `/webhook/llm`  
**Structure**:
- Webhook → Validate → Switch (chat-l1, action-l2, expert-l3) → Handlers
- ✅ Structure Switch
- ❌ Pas de logging standardisé dans `iana.operation_logs`
- ✅ Toutes opérations dans workflow (Code nodes avec CLI)

**Actions**: `chat-l1`, `action-l2`, `expert-l3`

**Gaps**:
- ❌ Pas de logging dans `iana.operation_logs`
- ⚠️ Format response non standardisé
- ⚠️ Pas de node "Respond to Webhook" visible dans structure

---

### 6. iana-rag.json

**Status**: ✅ Existe  
**Endpoint**: `/webhook/rag`  
**Structure**:
- Webhook → Validate Input → Switch Action → Actions (query, create, update, delete, enrich) → Execute Sub-Workflows ou PostgreSQL
- ✅ Structure CRUD standard (Switch avec actions)
- ❌ Pas de logging standardisé dans `iana.operation_logs`
- ✅ Utilise Execute Workflow pour sub-workflows (iana-rag-query)
- ✅ PostgreSQL nodes pour certaines actions

**Actions**: `query`, `create`, `update`, `delete`, `enrich`

**Gaps**:
- ❌ Pas de logging dans `iana.operation_logs`
- ⚠️ Actions ne correspondent pas exactement au plan (enrich vs list, search, chunk)
- ⚠️ Dépend de sub-workflows (iana-rag-query) qui doivent exister
- ⚠️ Manque actions : `list`, `search`, `chunk` (selon plan pour iana-rag-document)

---

### 7. iana-workflow-create.json

**Status**: ✅ Existe  
**Endpoint**: `/webhook/workflow-crud` (selon code)  
**Structure**:
- Webhook → Validate Input → Switch (par action) → Actions (create, read, update, delete, list, activate, test) → Format Response → Log → Respond
- ✅ Structure CRUD standard (Switch avec actions)
- ✅ Format response standardisé
- ✅ Logging (à vérifier si dans `iana.operation_logs`)
- ✅ Toutes opérations dans workflow (HTTP Request pour API n8n)

**Actions**: `create`, `read`, `update`, `delete`, `list`, `activate`, `test`

**Gaps**:
- À unifier avec `iana-workflow-factory.json`
- Manque actions : `deactivate`, `execute`

---

### 8. iana-workflow-factory.json

**Status**: ✅ Existe  
**Endpoint**: `/webhook/workflow-factory-crud` (selon code)  
**Structure**:
- Webhook → Validate → Switch → Factory operations
- ✅ Structure Switch
- ❌ Pas de logging standardisé
- ✅ Utilise API n8n (HTTP Request nodes)

**Actions**: Factory pattern pour créer workflows

**Gaps**:
- ❌ Pas de logging dans `iana.operation_logs`
- ⚠️ À unifier avec `iana-workflow-create.json` pour créer `iana-workflow.json`

---

## Résumé des gaps

### Workflows manquants (à créer)

1. **iana-rag-document.json** (P1)
   - Actions: create, read, update, delete, list, search, chunk
   - Tables: rag.documents, rag.document_chunks

2. **iana-tool.json** (P1)
   - Actions: create, read, update, delete, list, search, execute
   - Table: rag.mcp_tools

3. **iana-credential.json** (P1)
   - Actions: create, read, update, delete, list, test
   - Source: API n8n /api/v1/credentials

4. **iana-workflow.json** (P1 - unifier existants)
   - Actions: create, read, update, delete, list, activate, deactivate, test, execute
   - Source: API n8n /api/v1/workflows

5. **iana-docker.json** (P0)
   - Actions: status, start, stop, restart, logs, inspect, cleanup

6. **iana-postgres.json** (P0)
   - Actions: query, backup, restore, vacuum, analyze, status

7. **iana-backup.json** (P0)
   - Actions: create, list, restore, delete, schedule

8. **iana-redis.json** (P2)
   - Actions: get, set, delete, list, flush, info, status

9. **iana-monitoring.json** (P2)
   - Actions: query, alert, dashboard, status

10. **iana-security.json** (P1)
    - Actions: audit, scan, report, alert

11. **iana-test.json** (P1)
    - Actions: workflow, all, report

### Workflows existants (à corriger/vérifier)

1. **iana-conversation.json** - Vérifier structure CRUD complète
2. **iana-message.json** - Vérifier structure CRUD complète
3. **iana-rag.json** - À restructurer ou vérifier structure CRUD
4. **iana-workflow-create.json** + **iana-workflow-factory.json** - À unifier

---

## Priorités

- **P0** (Critique - Infrastructure) : docker, postgres, backup
- **P1** (Haute - CRUD entités IANA) : rag-document, tool, credential, workflow (unifier), security, test
- **P2** (Moyenne - Infrastructure secondaire) : redis, monitoring

---

## Prochaines étapes

1. ✅ Audit complet terminé
2. ⏳ Créer workflows P0 (docker, postgres, backup)
3. ⏳ Créer workflows P1 (rag-document, tool, credential, workflow unifié, security, test)
4. ⏳ Créer workflows P2 (redis, monitoring)
5. ⏳ Vérifier/corriger workflows existants
