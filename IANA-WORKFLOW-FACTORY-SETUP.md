# 🏭 IANA Workflow Factory - Guide d'Installation

**Workflow**: `iana-workflow-factory`  
**Endpoint**: `POST /webhook/workflow-factory`  
**Méthode**: Cursor n8n 100% Fiable (selon PDF)

---

## 📋 DESCRIPTION

Ce workflow automatise la création de workflows n8n selon la méthode éprouvée documentée dans `Méthode Cursor n8n 100% Fiable.pdf`.

**Fonctionnalités** :
- ✅ Validation de la spécification workflow (conception sur papier)
- ✅ Génération automatique du workflow via n8n API
- ✅ Préparation des tests (unitaire, intégration, réel)
- ✅ Activation conditionnelle
- ✅ Création de rapport de monitoring
- ✅ Documentation automatique

---

## 🚀 INSTALLATION

### 1. Prérequis

- n8n self-hosted avec API activée
- API Key n8n configurée
- PostgreSQL avec schéma `iana` et fonction `log_operation`

### 2. Import du Workflow

**Méthode 1 : Via UI n8n**

1. Ouvrir n8n : `http://localhost:5678`
2. Aller dans **Workflows** → **Import from File**
3. Sélectionner : `alfa-dashboard/n8n/workflows/iana-workflow-factory.json`
4. Cliquer **Import**

**Méthode 2 : Via API**

```bash
curl -X POST "http://localhost:5678/api/v1/workflows" \
  -H "X-N8N-API-KEY: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d @alfa-dashboard/n8n/workflows/iana-workflow-factory.json
```

### 3. Configuration Credentials

**PostgreSQL IANA** :
- Node **Log Operation** → Credential: `PostgreSQL IANA`

**n8n API Key** :
- Nodes **API Create Workflow** et **API Activate Workflow** → Header `X-N8N-API-KEY`

---

## 📝 FORMAT DE REQUÊTE

### Structure complète

```json
{
  "workflow_spec": {
    "name": "My New Workflow",
    "description": "Description du workflow",
    "trigger": {
      "type": "webhook",
      "method": "POST",
      "path": "my-endpoint"
    },
    "nodes_sequence": [
      {
        "name": "PARSE_ExtractPayload",
        "type": "PARSE_",
        "code": "const input = $input.first().json;\nreturn { data: input.body };"
      },
      {
        "name": "FETCH_ExternalAPI",
        "type": "FETCH_",
        "url": "https://api.example.com/data",
        "method": "GET",
        "headers": [
          {
            "name": "Authorization",
            "value": "Bearer token"
          }
        ],
        "timeout": 30000
      },
      {
        "name": "SEND_Slack_Notify",
        "type": "SEND_",
        "service": "slack",
        "channel": "#notifications",
        "text": "{{$json.message}}"
      }
    ],
    "test_data": {
      "unit": [
        {
          "node": "PARSE_ExtractPayload",
          "input": { "body": { "test": "data" } }
        }
      ],
      "full": {
        "body": { "test": "full workflow" }
      },
      "real": [
        { "body": { "real": "data 1" } },
        { "body": { "real": "data 2" } }
      ]
    },
    "tags": ["automation", "test"],
    "dependencies": ["Slack API", "External API"],
    "error_handling": {
      "retry": 3,
      "timeout": 30000,
      "alert_channel": "#errors"
    }
  },
  "user_id": "user-123",
  "channel": "api",
  "auto_activate": false
}
```

### Exemple minimal

```json
{
  "workflow_spec": {
    "name": "Simple Webhook",
    "description": "Webhook simple qui répond",
    "trigger": {
      "type": "webhook",
      "method": "POST",
      "path": "simple"
    },
    "nodes_sequence": [
      {
        "name": "LOG_Request",
        "type": "LOG_",
        "code": "return $input.first().json;"
      }
    ]
  },
  "user_id": "test-user"
}
```

---

## 🎯 TYPES DE TRIGGERS SUPPORTÉS

### 1. Webhook

```json
{
  "trigger": {
    "type": "webhook",
    "method": "POST",
    "path": "my-endpoint"
  }
}
```

### 2. Cron/Schedule

```json
{
  "trigger": {
    "type": "cron",
    "cron": "0 */1 * * *"
  }
}
```

### 3. Manual

```json
{
  "trigger": {
    "type": "manual"
  }
}
```

---

## 🔧 TYPES DE NODES SUPPORTÉS

### FETCH_ / HTTP_

Appel HTTP externe :

```json
{
  "name": "FETCH_GitHub_GetRepos",
  "type": "FETCH_",
  "url": "https://api.github.com/repos",
  "method": "GET",
  "headers": [
    { "name": "Authorization", "value": "Bearer token" }
  ],
  "timeout": 30000
}
```

### PARSE_ / TRANSFORM_

Transformation de données :

```json
{
  "name": "PARSE_JSON_ExtractEmails",
  "type": "PARSE_",
  "code": "const input = $input.first().json;\nconst emails = input.data.filter(d => d.email);\nreturn { emails };"
}
```

### CONDITION_ / IF_

Branchement conditionnel :

```json
{
  "name": "CONDITION_ValidateData",
  "type": "CONDITION_",
  "conditions": {
    "boolean": [
      {
        "value1": "={{ $json.email }}",
        "operation": "isNotEmpty"
      }
    ]
  }
}
```

### SEND_

Envoi de notification (Slack, Email, etc.) :

```json
{
  "name": "SEND_Slack_Notify",
  "type": "SEND_",
  "service": "slack",
  "channel": "#notifications",
  "text": "{{$json.message}}"
}
```

### LOG_

Logging :

```json
{
  "name": "LOG_ExecutionSuccess",
  "type": "LOG_",
  "code": "const data = $input.first().json;\nconsole.log('SUCCESS:', JSON.stringify(data));\nreturn data;"
}
```

---

## 📊 RÉPONSE

### Succès

```json
{
  "success": true,
  "action": "create_workflow",
  "data": {
    "workflow_id": "abc123",
    "workflow_name": "My New Workflow",
    "created_at": "2026-01-12T...",
    "created_by": "user-123",
    "method": "cursor-n8n-100-percent",
    "status": "created",
    "test_results": {
      "unit_tests": [...],
      "full_test": {...},
      "real_data_test": {...}
    },
    "activation_status": "pending",
    "monitoring": {
      "enabled": true,
      "retention_days": 30,
      "alert_on_error": true
    },
    "documentation": {...},
    "next_steps": [
      "1. Test each node individually (Execute Step)",
      "2. Test full workflow (Execute Workflow)",
      "3. Test with real data (5-10 examples)",
      "4. Monitor first 24h",
      "5. Activate if tests pass"
    ]
  },
  "error": null,
  "meta": {
    "latency_ms": 1234,
    "timestamp": "2026-01-12T...",
    "request_id": "user-123-...",
    "method": "cursor-n8n-100-percent"
  }
}
```

### Erreur

```json
{
  "success": false,
  "action": "create_workflow",
  "data": null,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "workflow_spec.name is required"
  },
  "meta": {...}
}
```

---

## ✅ CHECKLIST POST-CRÉATION

Selon la méthode PDF, après création du workflow :

- [ ] **Test unitaire** : Exécuter chaque node individuellement (Execute Step)
- [ ] **Test intégration** : Exécuter le workflow complet (Execute Workflow)
- [ ] **Test réel** : Tester avec 5-10 exemples de données réelles
- [ ] **Activation** : Activer le workflow si tous les tests passent
- [ ] **Monitoring 24h** : Surveiller les premières exécutions
- [ ] **Documentation** : Compléter la documentation si nécessaire

---

## 🔍 EXEMPLE COMPLET

### Créer un workflow Webhook → Slack

```bash
curl -X POST "http://localhost:5678/webhook/workflow-factory" \
  -H "Content-Type: application/json" \
  -d '{
    "workflow_spec": {
      "name": "Webhook_to_Slack_Notifier",
      "description": "Reçoit un webhook et envoie une notification Slack",
      "trigger": {
        "type": "webhook",
        "method": "POST",
        "path": "slack-notify"
      },
      "nodes_sequence": [
        {
          "name": "PARSE_ExtractPayload",
          "type": "PARSE_",
          "code": "const body = $input.first().json.body || $input.first().json;\nreturn {\n  message: body.message || \"Notification\",\n  channel: body.channel || \"#general\",\n  severity: body.severity || \"info\"\n};"
        },
        {
          "name": "SEND_Slack_Notify",
          "type": "SEND_",
          "service": "slack",
          "channel": "={{$json.channel}}",
          "text": "={{$json.message}}"
        }
      ],
      "test_data": {
        "full": {
          "body": {
            "message": "Test notification",
            "channel": "#test",
            "severity": "info"
          }
        }
      },
      "tags": ["notification", "slack"],
      "error_handling": {
        "retry": 3,
        "timeout": 30000
      }
    },
    "user_id": "arnaud",
    "auto_activate": false
  }'
```

---

## 📚 RESSOURCES

- **Méthode complète** : `Méthode Cursor n8n 100% Fiable.pdf`
- **Workflow existant** : `iana-workflow-create.json` (CRUD workflows)
- **Documentation n8n** : https://docs.n8n.io/api/

---

**Maintenu par**: IANA Workflow Factory  
**Dernière mise à jour**: 2026-01-12
