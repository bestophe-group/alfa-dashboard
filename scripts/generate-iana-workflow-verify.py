#!/usr/bin/env python3
"""
Script pour générer le workflow iana-workflow-verify.json
Workflow pour vérifier les workflows n8n (doublons, fonctionnalité)
Actions: 'list', 'check', 'report'
"""

import json

VALID_ACTIONS = ['list', 'check', 'report']
N8N_API_BASE = 'http://localhost:5678/api/v1'

def generate_workflow():
    """Génère le workflow complet"""
    
    nodes = []
    
    # 1. Webhook
    nodes.append({
        "parameters": {
            "httpMethod": "POST",
            "path": "workflow-verify",
            "responseMode": "responseNode",
            "options": {}
        },
        "id": "webhook-verify",
        "name": "Webhook Verify",
        "type": "n8n-nodes-base.webhook",
        "typeVersion": 2,
        "position": [250, 300],
        "webhookId": "iana-workflow-verify-crud"
    })
    
    # 2. Validate Input
    valid_actions_str = ', '.join([f"'{a}'" for a in VALID_ACTIONS])
    nodes.append({
        "parameters": {
            "jsCode": f"""// Validation commune AVANT Switch
const body = $input.first().json.body || $input.first().json;
const {{ action, data, user_id, channel }} = body;

// Validation action
if (!action) {{
  throw new Error('VALIDATION_ERROR: action is required');
}}

// Validation user_id
if (!user_id) {{
  throw new Error('VALIDATION_ERROR: user_id is required');
}}

// Validation actions valides
const validActions = [{valid_actions_str}];
if (!validActions.includes(action)) {{
  throw new Error(`VALIDATION_ERROR: action must be one of: ${{validActions.join(', ')}}`);
}}

// Ajouter metadata
return [{{
  json: {{
    action: action,
    data: data || {{}},
    user_id: user_id,
    channel: channel || 'api',
    _meta: {{
      startTime: Date.now(),
      requestId: `${{user_id}}-${{Date.now()}}`
    }}
  }}
}}];"""
        },
        "id": "validate-input",
        "name": "Validate Input",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [470, 300]
    })
    
    # 3. Switch
    rules = []
    for action in VALID_ACTIONS:
        rules.append({
            "conditions": {
                "string": [{
                    "value1": "={{ $json.action }}",
                    "operation": "equals",
                    "value2": action
                }]
            }
        })
    
    nodes.append({
        "parameters": {
            "rules": {"rules": rules},
            "fallbackOutput": "extra"
        },
        "id": "switch-action",
        "name": "Switch Action",
        "type": "n8n-nodes-base.switch",
        "typeVersion": 3,
        "position": [690, 300]
    })
    
    # 4. Action: list (lister workflows via API)
    nodes.append({
        "parameters": {
            "jsCode": """// Action: list - Lister workflows via API n8n
const input = $input.first().json;
const { data, user_id } = input;

// Appel API n8n pour lister workflows
const filters = data.filters || {};
const apiUrl = `${N8N_API_BASE}/workflows`;

return [{
  json: {
    success: true,
    action: 'list',
    api_url: apiUrl,
    filters: filters,
    user_id: user_id
  }
}];"""
        },
        "id": "action-list",
        "name": "Prepare List",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [910, 200]
    })
    
    # 5. HTTP Request: List Workflows
    nodes.append({
        "parameters": {
            "url": f"{N8N_API_BASE}/workflows",
            "method": "GET",
            "sendHeaders": True,
            "headerParameters": {
                "parameters": [{
                    "name": "X-N8N-API-KEY",
                    "value": "={{ $env.N8N_API_KEY || '' }}"
                }, {
                    "name": "Content-Type",
                    "value": "application/json"
                }]
            },
            "options": {}
        },
        "id": "http-list-workflows",
        "name": "List Workflows HTTP",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [1130, 200]
    })
    
    # 6. Action: check (vérifier doublons et problèmes)
    nodes.append({
        "parameters": {
            "jsCode": """// Action: check - Vérifier doublons et problèmes
const input = $input.first().json;

// Récupérer workflows depuis l'API
// Note: Cette action devrait être appelée après action 'list'
// Pour l'instant, préparer les vérifications

const checks = {
  duplicates: [],
  missing_webhook_id: [],
  isolated_nodes: [],
  structure_errors: []
};

return [{
  json: {
    success: true,
    action: 'check',
    checks: checks,
    workflows_count: 0
  }
}];"""
        },
        "id": "action-check",
        "name": "Prepare Check",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [910, 300]
    })
    
    # 7. Check Workflows (Code node pour vérifications)
    nodes.append({
        "parameters": {
            "jsCode": """// Vérifier workflows pour doublons et problèmes
const input = $input.first().json;

// Récupérer workflows depuis API (via action 'list')
const workflows = input.data || [];

const issues = {
  duplicates: [],
  missing_webhook_id: [],
  isolated_nodes: [],
  structure_errors: []
};

// 1. Vérifier doublons (noms identiques)
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

// 2. Vérifier workflows webhook sans webhookId
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

// 3. Vérifier workflows avec nodes isolés (pas de connections)
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

// 4. Vérifier erreurs de structure (nodes sans type, connections invalides)
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

const total_issues = issues.duplicates.length + 
                     issues.missing_webhook_id.length + 
                     issues.isolated_nodes.length + 
                     issues.structure_errors.length;

return [{
  json: {
    success: true,
    action: 'check',
    workflows_count: workflows.length,
    issues: issues,
    total_issues: total_issues,
    has_issues: total_issues > 0
  }
}];"""
        },
        "id": "check-workflows",
        "name": "Check Workflows",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [1130, 300]
    })
    
    # 8. Action: report (générer rapport)
    nodes.append({
        "parameters": {
            "jsCode": """// Action: report - Générer rapport de vérification
const input = $input.first().json;
const { data, user_id } = input;

// Récupérer résultats de vérification depuis la base de données
// Note: Cette action devrait interroger iana.operation_logs pour générer un rapport

return [{
  json: {
    success: true,
    action: 'report',
    message: 'Report generation - query iana.operation_logs for verification results',
    filters: {
      workflow_id: 'iana-workflow-verify',
      user_id: user_id,
      date_from: data.date_from || null,
      date_to: data.date_to || null
    },
    user_id: user_id
  }
}];"""
        },
        "id": "action-report",
        "name": "Prepare Report",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [910, 400]
    })
    
    # 9. PostgreSQL: Get Report
    nodes.append({
        "parameters": {
            "operation": "executeQuery",
            "query": """SELECT 
  workflow_id,
  action,
  COUNT(*) as total_checks,
  COUNT(*) FILTER (WHERE success = true) as passed,
  COUNT(*) FILTER (WHERE success = false) as failed,
  AVG(latency_ms) as avg_latency_ms,
  MIN(created_at) as first_check,
  MAX(created_at) as last_check
FROM iana.operation_logs
WHERE workflow_id = 'iana-workflow-verify'
  AND user_id = $1
  AND ($2::timestamp IS NULL OR created_at >= $2)
  AND ($3::timestamp IS NULL OR created_at <= $3)
GROUP BY workflow_id, action
ORDER BY workflow_id, action""",
            "additionalFields": {
                "queryParameters": "={{ [$json.user_id, $json.filters.date_from || null, $json.filters.date_to || null] }}"
            },
            "options": {}
        },
        "id": "db-get-report",
        "name": "Get Report",
        "type": "n8n-nodes-base.postgres",
        "typeVersion": 2.4,
        "position": [1130, 400],
        "credentials": {
            "postgres": {
                "id": "5zFMgYDljFx593WZ",
                "name": "PostgreSQL IANA"
            }
        }
    })
    
    # 10. Merge Results
    nodes.append({
        "parameters": {
            "mode": "combine",
            "combineBy": "combineAll"
        },
        "id": "merge-results",
        "name": "Merge Results",
        "type": "n8n-nodes-base.merge",
        "typeVersion": 2.1,
        "position": [1350, 300]
    })
    
    # 11. Log Operation
    nodes.append({
        "parameters": {
            "operation": "executeQuery",
            "query": "SELECT iana.log_operation($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) as log_id",
            "additionalFields": {
                "queryParameters": "={{ ['iana-workflow-verify', $('Validate Input').first().json.action, $('Validate Input').first().json.user_id, 'api', JSON.stringify($('Validate Input').first().json.data || {}), JSON.stringify($json), $json.success !== false, $json.errorCode || null, $json.errorMessage || null, Date.now() - ($('Validate Input').first().json._meta?.startTime || Date.now()), $('Validate Input').first().json._meta?.requestId || null] }}"
            },
            "options": {}
        },
        "id": "log-operation",
        "name": "Log Operation",
        "type": "n8n-nodes-base.postgres",
        "typeVersion": 2.4,
        "position": [1570, 300],
        "credentials": {
            "postgres": {
                "id": "5zFMgYDljFx593WZ",
                "name": "PostgreSQL IANA"
            }
        }
    })
    
    # 12. Format Response
    nodes.append({
        "parameters": {
            "jsCode": """// Format Response Standardisée
const input = $input.first().json;
const validation = $('Validate Input').first().json;
const startTime = validation._meta?.startTime || Date.now();

// Success case
if (input.success !== false && !input.isError) {
  return [{
    json: {
      success: true,
      action: validation.action,
      data: input,
      error: null,
      meta: {
        latency_ms: Date.now() - startTime,
        timestamp: new Date().toISOString(),
        request_id: validation._meta?.requestId
      }
    }
  }];
}

// Error case
return [{
  json: {
    success: false,
    action: validation.action,
    data: null,
    error: {
      code: input.errorCode || 'UNKNOWN_ERROR',
      message: input.errorMessage || input.message || 'An error occurred'
    },
    meta: {
      latency_ms: Date.now() - startTime,
      timestamp: new Date().toISOString(),
      request_id: validation._meta?.requestId
    }
  }
}];"""
        },
        "id": "format-response",
        "name": "Format Response",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [1790, 300]
    })
    
    # 13. Respond to Webhook
    nodes.append({
        "parameters": {
            "respondWith": "json",
            "responseBody": "={{ JSON.stringify($json) }}"
        },
        "id": "respond-webhook",
        "name": "Respond to Webhook",
        "type": "n8n-nodes-base.respondToWebhook",
        "typeVersion": 1,
        "position": [2010, 300]
    })
    
    # Connections
    connections = {
        "Webhook Verify": {
            "main": [[{"node": "Validate Input", "type": "main", "index": 0}]]
        },
        "Validate Input": {
            "main": [[{"node": "Switch Action", "type": "main", "index": 0}]]
        },
        "Switch Action": {
            "main": [
                [{"node": "Prepare List", "type": "main", "index": 0}],
                [{"node": "Prepare Check", "type": "main", "index": 0}],
                [{"node": "Prepare Report", "type": "main", "index": 0}]
            ]
        },
        "Prepare List": {
            "main": [[{"node": "List Workflows HTTP", "type": "main", "index": 0}]]
        },
        "List Workflows HTTP": {
            "main": [[{"node": "Check Workflows", "type": "main", "index": 0}]]
        },
        "Prepare Check": {
            "main": [[{"node": "Check Workflows", "type": "main", "index": 0}]]
        },
        "Check Workflows": {
            "main": [[{"node": "Merge Results", "type": "main", "index": 0}]]
        },
        "Prepare Report": {
            "main": [[{"node": "Get Report", "type": "main", "index": 0}]]
        },
        "Get Report": {
            "main": [[{"node": "Merge Results", "type": "main", "index": 0}]]
        },
        "Merge Results": {
            "main": [[{"node": "Log Operation", "type": "main", "index": 0}]]
        },
        "Log Operation": {
            "main": [[{"node": "Format Response", "type": "main", "index": 0}]]
        },
        "Format Response": {
            "main": [[{"node": "Respond to Webhook", "type": "main", "index": 0}]]
        }
    }
    
    workflow = {
        "name": "iana-workflow-verify",
        "nodes": nodes,
        "connections": connections,
        "settings": {
            "executionOrder": "v1"
        },
        "tags": [
            {"name": "IANA"},
            {"name": "Verification"},
            {"name": "P0"}
        ],
        "active": False
    }
    
    return workflow

if __name__ == "__main__":
    workflow = generate_workflow()
    output_file = "alfa-dashboard/n8n/workflows/iana-workflow-verify.json"
    
    with open(output_file, 'w') as f:
        json.dump(workflow, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Workflow généré: {output_file}")
    print(f"   Nodes: {len(workflow['nodes'])}")
    print(f"   Actions: {', '.join(VALID_ACTIONS)}")
