# 06 - WORKFLOWS N8N
## Automation Anti-Désalignement

---

## 📑 SOMMAIRE

1. [Pourquoi n8n](#1-pourquoi-n8n)
2. [Workflows essentiels](#2-workflows-essentiels)
3. [Schémas SQL](#3-schémas-sql)
4. [Configuration](#4-configuration)
5. [Exemples DO / DON'T](#5-exemples-do--dont)

---

## 1. POURQUOI N8N

### Rôle anti-désalignement

| Problème | Solution n8n |
|----------|--------------|
| Pas de monitoring | Alert automatique |
| Oubli de review | Notification Slack |
| Régression silencieuse | Trigger sur eval fail |
| Budget dépassé | Alert token usage |
| Incident non tracé | Audit log automatique |

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    N8N ANTI-DÉSALIGNEMENT                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Triggers                    Actions                        │
│  ────────                    ───────                        │
│  GitHub Webhook      ──►     Eval Suite                     │
│  Schedule            ──►     Token Check                    │
│  Webhook Agent       ──►     Audit Log                      │
│  Alert               ──►     Slack Notify                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. WORKFLOWS ESSENTIELS

### Workflow 1 : Prompt Change Alert

**But** : Alerter si un prompt système change (risque de régression)

**Livrable** : `n8n/workflows/prompt-change-alert.json`

```json
{
  "name": "Prompt Change Alert",
  "nodes": [
    {
      "name": "GitHub Webhook",
      "type": "n8n-nodes-base.webhookTrigger",
      "parameters": {
        "httpMethod": "POST",
        "path": "github-prompts"
      }
    },
    {
      "name": "Filter Prompt Files",
      "type": "n8n-nodes-base.if",
      "parameters": {
        "conditions": {
          "string": [
            {
              "value1": "={{ $json.commits[0].modified }}",
              "operation": "contains",
              "value2": "prompts/"
            }
          ]
        }
      }
    },
    {
      "name": "Trigger Eval",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "url": "https://api.github.com/repos/{{owner}}/{{repo}}/dispatches",
        "method": "POST",
        "headers": {
          "Authorization": "Bearer {{ $credentials.github.accessToken }}"
        },
        "body": {
          "event_type": "eval-prompts"
        }
      }
    },
    {
      "name": "Slack Alert",
      "type": "n8n-nodes-base.slack",
      "parameters": {
        "channel": "#alerts-llm",
        "text": "⚠️ Prompt modifié: {{ $json.commits[0].message }}\nEval suite triggered."
      }
    }
  ]
}
```

### Workflow 2 : Token Budget Guardian

**But** : Monitorer et alerter sur la consommation tokens

```json
{
  "name": "Token Budget Guardian",
  "nodes": [
    {
      "name": "Schedule",
      "type": "n8n-nodes-base.scheduleTrigger",
      "parameters": {
        "rule": {
          "interval": [{ "field": "hours", "hoursInterval": 1 }]
        }
      }
    },
    {
      "name": "Get Anthropic Usage",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "url": "https://api.anthropic.com/v1/usage",
        "headers": {
          "x-api-key": "{{ $credentials.anthropic.apiKey }}",
          "anthropic-version": "2023-06-01"
        }
      }
    },
    {
      "name": "Calculate Percent",
      "type": "n8n-nodes-base.code",
      "parameters": {
        "jsCode": "const used = $input.first().json.tokens_used || 0;\nconst budget = 1000000;\nconst percent = Math.round(used * 100 / budget);\nreturn [{ json: { used, budget, percent } }];"
      }
    },
    {
      "name": "Check Threshold",
      "type": "n8n-nodes-base.if",
      "parameters": {
        "conditions": {
          "number": [
            {
              "value1": "={{ $json.percent }}",
              "operation": "largerEqual",
              "value2": 80
            }
          ]
        }
      }
    },
    {
      "name": "Alert Slack",
      "type": "n8n-nodes-base.slack",
      "parameters": {
        "channel": "#alerts-budget",
        "text": "🔴 Token Budget Alert\nUsage: {{ $json.used }} / {{ $json.budget }} ({{ $json.percent }}%)"
      }
    },
    {
      "name": "Log to DB",
      "type": "n8n-nodes-base.postgres",
      "parameters": {
        "operation": "insert",
        "table": "token_usage_log",
        "columns": "timestamp,tokens_used,budget,percent",
        "values": "NOW(),{{ $json.used }},{{ $json.budget }},{{ $json.percent }}"
      }
    }
  ]
}
```

### Workflow 3 : Eval Regression Monitor

**But** : Détecter les régressions dans l'eval suite

```json
{
  "name": "Eval Regression Monitor",
  "nodes": [
    {
      "name": "Webhook Results",
      "type": "n8n-nodes-base.webhookTrigger",
      "parameters": {
        "httpMethod": "POST",
        "path": "eval-results"
      }
    },
    {
      "name": "Get Previous Score",
      "type": "n8n-nodes-base.postgres",
      "parameters": {
        "operation": "executeQuery",
        "query": "SELECT score FROM eval_runs WHERE project = '{{ $json.project }}' ORDER BY created_at DESC LIMIT 1"
      }
    },
    {
      "name": "Compare Scores",
      "type": "n8n-nodes-base.code",
      "parameters": {
        "jsCode": "const current = $input.first().json.score;\nconst previous = $('Get Previous Score').first().json.score || current;\nconst diff = current - previous;\nconst regression = diff < -0.05;\nreturn [{ json: { current, previous, diff, regression } }];"
      }
    },
    {
      "name": "Is Regression?",
      "type": "n8n-nodes-base.if",
      "parameters": {
        "conditions": {
          "boolean": [
            {
              "value1": "={{ $json.regression }}",
              "value2": true
            }
          ]
        }
      }
    },
    {
      "name": "Create GitHub Issue",
      "type": "n8n-nodes-base.github",
      "parameters": {
        "operation": "create",
        "resource": "issue",
        "owner": "{{ $json.owner }}",
        "repository": "{{ $json.repo }}",
        "title": "🔴 Eval Regression Detected",
        "body": "Score dropped from {{ $json.previous }} to {{ $json.current }} ({{ $json.diff }})"
      }
    }
  ]
}
```

### Workflow 4 : Agent Audit Trail

**But** : Logger toutes les actions de l'agent pour audit

```json
{
  "name": "Agent Audit Trail",
  "nodes": [
    {
      "name": "Webhook Action",
      "type": "n8n-nodes-base.webhookTrigger",
      "parameters": {
        "httpMethod": "POST",
        "path": "agent-action"
      }
    },
    {
      "name": "Log to DB",
      "type": "n8n-nodes-base.postgres",
      "parameters": {
        "operation": "insert",
        "table": "agent_audit_log",
        "columns": "timestamp,session_id,action_type,action_detail,files_modified,tokens_used",
        "values": "NOW(),'{{ $json.session_id }}','{{ $json.action_type }}','{{ $json.detail }}','{{ $json.files }}',{{ $json.tokens }}"
      }
    },
    {
      "name": "Check Anomaly",
      "type": "n8n-nodes-base.code",
      "parameters": {
        "jsCode": "const action = $input.first().json;\nconst anomalies = [];\n\n// Too many files\nif (action.files && action.files.split(',').length > 5) {\n  anomalies.push('Too many files modified');\n}\n\n// High token usage\nif (action.tokens > 10000) {\n  anomalies.push('High token usage');\n}\n\nreturn [{ json: { ...action, anomalies, hasAnomaly: anomalies.length > 0 } }];"
      }
    },
    {
      "name": "Has Anomaly?",
      "type": "n8n-nodes-base.if",
      "parameters": {
        "conditions": {
          "boolean": [
            {
              "value1": "={{ $json.hasAnomaly }}",
              "value2": true
            }
          ]
        }
      }
    },
    {
      "name": "Alert Anomaly",
      "type": "n8n-nodes-base.slack",
      "parameters": {
        "channel": "#alerts-agent",
        "text": "⚠️ Agent Anomaly\nSession: {{ $json.session_id }}\nIssues: {{ $json.anomalies.join(', ') }}"
      }
    }
  ]
}
```

### Workflow 5 : Désalignement Reporter

**But** : Collecter et reporter les incidents de désalignement

```json
{
  "name": "Désalignement Reporter",
  "nodes": [
    {
      "name": "Webhook Incident",
      "type": "n8n-nodes-base.webhookTrigger",
      "parameters": {
        "httpMethod": "POST",
        "path": "desalignment-report"
      }
    },
    {
      "name": "Save to DB",
      "type": "n8n-nodes-base.postgres",
      "parameters": {
        "operation": "insert",
        "table": "desalignment_incidents",
        "columns": "timestamp,type,description,severity,session_id,time_lost_hours",
        "values": "NOW(),'{{ $json.type }}','{{ $json.description }}','{{ $json.severity }}','{{ $json.session_id }}',{{ $json.time_lost }}"
      }
    },
    {
      "name": "Weekly Summary",
      "type": "n8n-nodes-base.scheduleTrigger",
      "parameters": {
        "rule": { "interval": [{ "field": "weeks", "weeksInterval": 1 }] }
      }
    },
    {
      "name": "Get Week Stats",
      "type": "n8n-nodes-base.postgres",
      "parameters": {
        "operation": "executeQuery",
        "query": "SELECT type, COUNT(*) as count, SUM(time_lost_hours) as hours_lost FROM desalignment_incidents WHERE timestamp > NOW() - INTERVAL '7 days' GROUP BY type"
      }
    },
    {
      "name": "Send Report",
      "type": "n8n-nodes-base.slack",
      "parameters": {
        "channel": "#team-dev",
        "text": "📊 Weekly Désalignement Report\n{{ $json }}"
      }
    }
  ]
}
```

---

## 3. SCHÉMAS SQL

**Livrable** : `sql/init.sql`

```sql
-- Table: Audit des actions agent
CREATE TABLE agent_audit_log (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    session_id VARCHAR(100) NOT NULL,
    action_type VARCHAR(50) NOT NULL,
    action_detail TEXT,
    files_modified TEXT,
    tokens_used INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_audit_session ON agent_audit_log(session_id);
CREATE INDEX idx_audit_timestamp ON agent_audit_log(timestamp);

-- Table: Résultats eval
CREATE TABLE eval_runs (
    id SERIAL PRIMARY KEY,
    project VARCHAR(100) NOT NULL,
    commit_sha VARCHAR(40),
    score DECIMAL(5,4) NOT NULL,
    tests_passed INTEGER,
    tests_total INTEGER,
    duration_seconds INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_eval_project ON eval_runs(project);

-- Table: Usage tokens
CREATE TABLE token_usage_log (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    tokens_used BIGINT NOT NULL,
    budget BIGINT NOT NULL,
    percent INTEGER NOT NULL,
    provider VARCHAR(50) DEFAULT 'anthropic'
);

-- Table: Incidents désalignement
CREATE TABLE desalignment_incidents (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    type VARCHAR(50) NOT NULL,  -- hallucination, drift, contournement, overclaim
    description TEXT,
    severity VARCHAR(20) DEFAULT 'medium',  -- low, medium, high, critical
    session_id VARCHAR(100),
    time_lost_hours DECIMAL(4,2) DEFAULT 0,
    resolved BOOLEAN DEFAULT FALSE,
    resolution_notes TEXT
);

CREATE INDEX idx_desalign_type ON desalignment_incidents(type);
CREATE INDEX idx_desalign_timestamp ON desalignment_incidents(timestamp);

-- Vue: Stats hebdomadaires
CREATE VIEW weekly_desalignment_stats AS
SELECT 
    type,
    COUNT(*) as incident_count,
    SUM(time_lost_hours) as total_hours_lost,
    AVG(time_lost_hours) as avg_hours_lost
FROM desalignment_incidents
WHERE timestamp > NOW() - INTERVAL '7 days'
GROUP BY type;
```

---

## 4. CONFIGURATION

### Variables d'environnement n8n

```bash
# .env.n8n (via Infisical)
N8N_HOST=localhost
N8N_PORT=5678
N8N_PROTOCOL=http

# Database
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=localhost
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n_alfa
DB_POSTGRESDB_USER=n8n
DB_POSTGRESDB_PASSWORD=${N8N_DB_PASSWORD}

# Credentials (stockés dans n8n, injectés via Infisical)
# ANTHROPIC_API_KEY
# GITHUB_TOKEN
# SLACK_WEBHOOK_URL
```

### Credentials n8n à configurer

| Credential | Type | Usage |
|------------|------|-------|
| anthropic | HTTP Header Auth | Token budget |
| github | OAuth2 | Issues, webhooks |
| slack | OAuth2 | Notifications |
| postgres | PostgreSQL | Audit logs |

---

## 5. EXEMPLES DO / DON'T

### Alertes utiles vs spam

| ❌ DON'T | ✅ DO |
|----------|-------|
| Alert chaque commit | Alert si prompt modifié |
| Alert chaque API call | Alert si budget > 80% |
| Alert chaque test | Alert si régression > 5% |
| Flood Slack | 1 récap/jour si normal |

### Données à logger vs à ignorer

| ✅ Logger | ❌ Ne pas logger |
|----------|-----------------|
| Action type | Contenu complet prompt |
| Files modifiés | Secrets |
| Tokens utilisés | Données utilisateur |
| Erreurs | Logs debug verbose |

---

**Fiabilité** : 94%
**💡 Conseil** : Commence par le Token Budget Guardian - c'est le plus utile immédiatement.
