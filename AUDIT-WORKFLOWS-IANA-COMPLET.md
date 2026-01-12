# AUDIT COMPLET : Workflows IANA existants

**Date**: 2026-01-12  
**Phase**: Phase 1 - Audit des workflows IANA existants  
**Status**: ✅ Terminé

---

## Résumé exécutif

**Workflows IANA identifiés**: 8 workflows  
**Workflows avec structure CRUD complète**: 3 (iana-conversation, iana-workflow-create, iana-rag)  
**Workflows avec logging standardisé**: 2 (iana-conversation, iana-workflow-create)  
**Workflows manquants**: 11 workflows

---

## Détails par workflow

### ✅ 1. iana-conversation.json

**Status**: ✅ Existe et conforme  
**Endpoint**: `/webhook/conversation`  
**Structure**: 
- Webhook → Validate Input → Switch Action → Actions (create, read, update, delete, list, close) → DB Operations → Merge → Log → Format Response → Respond
- ✅ Structure CRUD complète (Switch avec toutes actions)
- ✅ Format response standardisé (Format Response node)
- ✅ Logging dans `iana.operation_logs` (via fonction `iana.log_operation()`)
- ✅ Toutes opérations dans workflow (PostgreSQL nodes)

**Actions**: `create`, `read`, `update`, `delete`, `list`, `close`

**Gaps mineurs**:
- ⚠️ Credential ID hardcodé : `postgres-iana` (devrait utiliser credential réel : `5zFMgYDljFx593WZ`)
- ⚠️ Node "Respond to Webhook" a paramètres vides (nécessite configuration manuelle : `respondWith: "json"`, `responseBody: "={{ JSON.stringify($json) }}"`)
- ⚠️ Table `iana.conversations` dans SQL ne correspond pas exactement (colonnes : session_id, started_at, last_message_at, message_count, total_tokens, total_cost_usd - non présentes dans migration)

**Verdict**: ✅ Conforme au plan, gaps mineurs à corriger

---

### ⚠️ 2. iana-message.json

**Status**: ✅ Existe mais actions différentes  
**Endpoint**: `/webhook/message`  
**Structure**:
- Webhook → Validate Input → Switch Action → Actions (log, context, search) → Merge → Log → Format Response → Respond
- ✅ Structure Switch
- ✅ Format response standardisé
- ✅ Logging dans `iana.operation_logs`
- ✅ Utilise Execute Workflow pour sub-workflows (iana-log, iana-context)

**Actions**: `log`, `context`, `search` (différent de plan : `create`, `read`, `list`, `search`)

**Gaps**:
- ⚠️ Actions ne correspondent pas au plan (log, context vs create, read, list)
- ⚠️ Dépend de sub-workflows (iana-log, iana-context) qui doivent exister
- ⚠️ Credential ID hardcodé : `postgres-iana`
- ⚠️ Node "Respond to Webhook" a paramètres vides

**Verdict**: ⚠️ Actions différentes du plan, à vérifier si besoin d'ajouter CRUD standard

---

### ✅ 3. iana-workflow-create.json

**Status**: ✅ Existe et conforme  
**Endpoint**: `/webhook/workflow` (selon code)  
**Structure**:
- Webhook → Validate Input → Switch Action → Actions (create, read, update, delete, list, activate, test) → API n8n (HTTP Request) → Merge → Log → Format Response → Respond
- ✅ Structure CRUD complète (Switch avec actions)
- ✅ Format response standardisé
- ✅ Logging dans `iana.operation_logs`
- ✅ Toutes opérations dans workflow (HTTP Request nodes pour API n8n)

**Actions**: `create`, `read`, `update`, `delete`, `list`, `activate`, `test`

**Gaps**:
- ⚠️ Manque actions : `deactivate`, `execute` (selon plan)
- ⚠️ Token API n8n hardcodé (devrait être dans credential ou variable env)
- ⚠️ À unifier avec `iana-workflow-factory.json` pour créer `iana-workflow.json`

**Verdict**: ✅ Conforme au plan, manque quelques actions, à unifier avec factory

---

### ⚠️ 4. iana-rag.json

**Status**: ✅ Existe mais actions différentes  
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

**Verdict**: ⚠️ Actions différentes, manque logging, à restructurer pour iana-rag-document

---

### ❌ 5. iana-llm.json

**Status**: ✅ Existe mais non conforme  
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

**Verdict**: ❌ Non conforme (pas de logging, format response non standardisé)

---

### ⚠️ 6. iana-router.json

**Status**: ✅ Existe  
**Endpoint**: `/webhook/iana`  
**Structure**: 
- Webhook → Parse Request → Get Conversation → Classifier (CLI) → Switch L1/L2/L3 → Handlers → Format Response → Log → Respond
- ❌ Pas de structure CRUD standard (routing LLM, pas CRUD)
- ✅ Logging partiel (mais pas dans `iana.operation_logs` standardisé)
- ✅ Toutes opérations dans workflow (Code nodes avec child_process)

**Actions**: Classification L1/L2/L3, routing

**Gaps**:
- ❌ Pas de structure CRUD standard
- ❌ Logging non standardisé dans `iana.operation_logs`
- ⚠️ Format response non standardisé

**Verdict**: ⚠️ Workflow spécialisé (routing), non CRUD, gaps de logging

---

### ⚠️ 7. iana-bridge.json

**Status**: ✅ Existe  
**Endpoint**: `/webhook/bridge`  
**Structure**:
- Webhook → Parse Bridge Request → Router (Execute Workflow)
- ❌ Pas de structure CRUD standard (bridge vers autres workflows)
- ❌ Pas de logging
- ✅ Toutes opérations dans workflow (Execute Workflow nodes)

**Actions**: Bridge vers autres workflows

**Gaps**:
- ❌ Pas de structure CRUD
- ❌ Pas de logging
- ❌ Pas de format response standardisé

**Verdict**: ⚠️ Workflow spécialisé (bridge), gaps majeurs (pas de logging, pas de format response)

---

### ⚠️ 8. iana-workflow-factory.json

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

**Verdict**: ⚠️ À unifier avec iana-workflow-create.json

---

## Gaps communs identifiés

### 1. Logging non standardisé
- **Problème**: Seuls `iana-conversation` et `iana-workflow-create` utilisent `iana.log_operation()`
- **Impact**: Traçabilité incomplète
- **Solution**: Ajouter logging dans tous les workflows

### 2. Format response non standardisé
- **Problème**: Tous les workflows n'ont pas de node "Format Response" standardisé
- **Impact**: Inconsistance API
- **Solution**: Ajouter node "Format Response" dans tous les workflows

### 3. Node "Respond to Webhook" non configuré
- **Problème**: Paramètres vides (`{}`) dans plusieurs workflows
- **Impact**: Réponses vides (comme observé avec iana-router)
- **Solution**: Configurer `respondWith: "json"` et `responseBody: "={{ JSON.stringify($json) }}"`

### 4. Credentials hardcodés
- **Problème**: IDs de credentials hardcodés (`postgres-iana` au lieu de `5zFMgYDljFx593WZ`)
- **Impact**: Workflows peuvent ne pas fonctionner si credential ID change
- **Solution**: Utiliser le bon credential ID ou variables d'environnement

### 5. Token API hardcodé
- **Problème**: Token API n8n hardcodé dans `iana-workflow-create.json`
- **Impact**: Sécurité, token peut expirer
- **Solution**: Utiliser credential n8n ou variable d'environnement

---

## Workflows manquants (à créer)

### P0 - Critique (Infrastructure)

1. **iana-docker.json** ⏳ À créer
   - Actions: status, start, stop, restart, logs, inspect, cleanup
   - Implémentation: Code nodes avec `child_process.execSync('docker ...')`

2. **iana-postgres.json** ⏳ À créer
   - Actions: query, backup, restore, vacuum, analyze, status
   - Implémentation: PostgreSQL nodes + Code nodes pour backup/restore

3. **iana-backup.json** ⏳ À créer
   - Actions: create, list, restore, delete, schedule
   - Implémentation: Code nodes + Execute Workflow (iana-postgres, iana-docker)

### P1 - Haute priorité (CRUD entités IANA)

4. **iana-rag-document.json** ⏳ À créer
   - Actions: create, read, update, delete, list, search, chunk
   - Implémentation: PostgreSQL nodes + Code nodes pour chunking

5. **iana-tool.json** ⏳ À créer
   - Actions: create, read, update, delete, list, search, execute
   - Implémentation: PostgreSQL nodes + HTTP Request nodes (si API)

6. **iana-credential.json** ⏳ À créer
   - Actions: create, read, update, delete, list, test
   - Implémentation: HTTP Request nodes (API n8n /api/v1/credentials)

7. **iana-workflow.json** ⏳ À créer (unifier existants)
   - Actions: create, read, update, delete, list, activate, deactivate, test, execute
   - Implémentation: HTTP Request nodes (API n8n /api/v1/workflows)

8. **iana-security.json** ⏳ À créer
   - Actions: audit, scan, report, alert
   - Implémentation: HTTP Request nodes (Falco/Trivy API) + PostgreSQL nodes

9. **iana-test.json** ⏳ À créer
   - Actions: workflow, all, report
   - Implémentation: Execute Workflow nodes + HTTP Request nodes

### P2 - Moyenne priorité (Infrastructure secondaire)

10. **iana-redis.json** ⏳ À créer
    - Actions: get, set, delete, list, flush, info, status
    - Implémentation: Redis node ou Code nodes avec redis-cli

11. **iana-monitoring.json** ⏳ À créer
    - Actions: query, alert, dashboard, status
    - Implémentation: HTTP Request nodes (Prometheus/Grafana API)

---

## Priorités d'implémentation

### Phase 2 : CRUD entités IANA (P1)
1. iana-rag-document (restructurer depuis iana-rag)
2. iana-tool
3. iana-credential
4. iana-workflow (unifier iana-workflow-create + iana-workflow-factory)

### Phase 3 : Infrastructure (P0/P1/P2)
1. iana-docker (P0)
2. iana-postgres (P0)
3. iana-backup (P0)
4. iana-security (P1)
5. iana-redis (P2)
6. iana-monitoring (P2)

### Phase 4 : Tests (P1)
1. iana-test (workflow pour tester les autres workflows)

---

## Conclusion

**Workflows conformes**: 2 (iana-conversation, iana-workflow-create)  
**Workflows à corriger**: 5 (iana-message, iana-rag, iana-llm, iana-router, iana-bridge, iana-workflow-factory)  
**Workflows à créer**: 11 workflows

**Prochaine étape**: Phase 2 - Créer workflows P1 (CRUD entités IANA)
