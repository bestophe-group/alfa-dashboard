#!/usr/bin/env python3
"""
Script pour générer le workflow iana-test.json
Workflow pour tester tous les workflows IANA créés
Actions: 'workflow', 'all', 'report'
"""

import json

VALID_ACTIONS = ['workflow', 'all', 'report']
N8N_WEBHOOK_BASE = 'http://localhost:5678/webhook'

# Configuration des workflows à tester
WORKFLOWS_CONFIG = {
    'iana-rag-document': {
        'endpoint': 'rag/document',
        'actions': ['create', 'read', 'update', 'delete', 'list', 'search', 'chunk']
    },
    'iana-tool': {
        'endpoint': 'tool',
        'actions': ['create', 'read', 'update', 'delete', 'list', 'search', 'execute']
    },
    'iana-credential': {
        'endpoint': 'credential',
        'actions': ['create', 'read', 'update', 'delete', 'list', 'test']
    },
    'iana-workflow': {
        'endpoint': 'workflow',
        'actions': ['create', 'read', 'update', 'delete', 'list', 'activate', 'deactivate', 'test', 'execute']
    },
    'iana-docker': {
        'endpoint': 'docker',
        'actions': ['status', 'start', 'stop', 'restart', 'logs', 'inspect', 'cleanup']
    },
    'iana-postgres': {
        'endpoint': 'postgres',
        'actions': ['query', 'backup', 'restore', 'vacuum', 'analyze', 'status']
    },
    'iana-backup': {
        'endpoint': 'backup',
        'actions': ['create', 'list', 'restore', 'delete', 'schedule']
    },
    'iana-security': {
        'endpoint': 'security',
        'actions': ['audit', 'scan', 'report', 'alert']
    },
    'iana-redis': {
        'endpoint': 'redis',
        'actions': ['get', 'set', 'delete', 'list', 'flush', 'info', 'status']
    },
    'iana-monitoring': {
        'endpoint': 'monitoring',
        'actions': ['query', 'alert', 'dashboard', 'status']
    }
}

def generate_workflow():
    """Génère le workflow complet"""
    
    nodes = []
    
    # 1. Webhook
    nodes.append({
        "parameters": {
            "httpMethod": "POST",
            "path": "test",
            "responseMode": "responseNode",
            "options": {}
        },
        "id": "webhook-test",
        "name": "Webhook Test",
        "type": "n8n-nodes-base.webhook",
        "typeVersion": 2,
        "position": [250, 300],
        "webhookId": "iana-test-workflow"
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
    
    # 4. Action: workflow (tester un workflow spécifique)
    workflows_config_json = json.dumps(WORKFLOWS_CONFIG, indent=2).replace('"', '\\"')
    nodes.append({
        "parameters": {
            "jsCode": f"""// Action: workflow - Tester un workflow spécifique
const input = $input.first().json;
const {{ data, user_id }} = input;

// Validation
if (!data.workflow_name) {{
  return [{{
    json: {{
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.workflow_name is required for workflow test',
      action: 'workflow'
    }}
  }}];
}}

if (!data.action_name) {{
  return [{{
    json: {{
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.action_name is required for workflow test',
      action: 'workflow'
    }}
  }}];
}}

// Configuration des workflows
const workflowsConfig = {json.dumps(WORKFLOWS_CONFIG)};

const workflowName = data.workflow_name;
const actionName = data.action_name;
const testData = data.test_data || {{}};

if (!workflowsConfig[workflowName]) {{
  return [{{
    json: {{
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: `Workflow ${{workflowName}} not found in config`,
      action: 'workflow'
    }}
  }}];
}}

if (!workflowsConfig[workflowName].actions.includes(actionName)) {{
  return [{{
    json: {{
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: `Action ${{actionName}} not found in workflow ${{workflowName}}`,
      action: 'workflow'
    }}
  }}];
}}

const endpoint = workflowsConfig[workflowName].endpoint;
const webhookUrl = `http://localhost:5678/webhook/${{endpoint}}`;

return [{{
  json: {{
    success: true,
    action: 'workflow',
    workflow_name: workflowName,
    action_name: actionName,
    endpoint: endpoint,
    webhook_url: webhookUrl,
    test_data: {{
      action: actionName,
      data: testData,
      user_id: user_id,
      channel: 'test'
    }},
    user_id: user_id
  }}
}}];"""
        },
        "id": "action-workflow",
        "name": "Prepare Workflow Test",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [910, 200]
    })
    
    # 5. HTTP Request: Test Workflow
    nodes.append({
        "parameters": {
            "url": "={{ $json.webhook_url }}",
            "method": "POST",
            "sendHeaders": True,
            "headerParameters": {
                "parameters": [{
                    "name": "Content-Type",
                    "value": "application/json"
                }]
            },
            "sendBody": True,
            "bodyParametersJson": "={{ JSON.stringify($json.test_data) }}",
            "options": {
                "timeout": 30000
            }
        },
        "id": "http-test-workflow",
        "name": "Test Workflow HTTP",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [1130, 200]
    })
    
    # 6. Action: all (tester tous les workflows)
    nodes.append({
        "parameters": {
            "jsCode": f"""// Action: all - Tester tous les workflows
const input = $input.first().json;
const {{ user_id }} = input;

// Configuration des workflows
const workflowsConfig = {json.dumps(WORKFLOWS_CONFIG)};

const testCases = [];
for (const [workflowName, config] of Object.entries(workflowsConfig)) {{
  for (const actionName of config.actions) {{
    testCases.push({{
      workflow_name: workflowName,
      action_name: actionName,
      endpoint: config.endpoint,
      webhook_url: `http://localhost:5678/webhook/${{config.endpoint}}`,
      test_data: {{
        action: actionName,
        data: {{}},
        user_id: user_id,
        channel: 'test'
      }}
    }});
  }}
}}

return testCases.map(tc => ({{
  json: {{
    success: true,
    action: 'all',
    ...tc,
    user_id: user_id
  }}
}}));"""
        },
        "id": "action-all",
        "name": "Prepare All Tests",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [910, 300]
    })
    
    # 7. HTTP Request: Test All (avec Split In Batches si nécessaire)
    nodes.append({
        "parameters": {
            "url": "={{ $json.webhook_url }}",
            "method": "POST",
            "sendHeaders": True,
            "headerParameters": {
                "parameters": [{
                    "name": "Content-Type",
                    "value": "application/json"
                }]
            },
            "sendBody": True,
            "bodyParametersJson": "={{ JSON.stringify($json.test_data) }}",
            "options": {
                "timeout": 30000
            }
        },
        "id": "http-test-all",
        "name": "Test All HTTP",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [1130, 300]
    })
    
    # 8. Action: report (générer rapport de tests)
    nodes.append({
        "parameters": {
            "jsCode": """// Action: report - Générer rapport de tests
const input = $input.first().json;
const { data, user_id } = input;

// Récupérer les résultats de tests depuis la base de données
// Note: Cette action devrait interroger iana.operation_logs pour générer un rapport
// Pour l'instant, retourner un message indiquant que le rapport doit être généré

return [{
  json: {
    success: true,
    action: 'report',
    message: 'Report generation - query iana.operation_logs for test results',
    filters: {
      workflow_id: 'iana-test',
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
    
    # 9. PostgreSQL: Get Test Results
    nodes.append({
        "parameters": {
            "operation": "executeQuery",
            "query": """SELECT 
  workflow_id,
  action,
  COUNT(*) as total_tests,
  COUNT(*) FILTER (WHERE success = true) as passed,
  COUNT(*) FILTER (WHERE success = false) as failed,
  AVG(latency_ms) as avg_latency_ms,
  MIN(created_at) as first_test,
  MAX(created_at) as last_test
FROM iana.operation_logs
WHERE workflow_id LIKE 'iana-%'
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
        "name": "Get Test Report",
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
    
    # 11. Format Test Result
    nodes.append({
        "parameters": {
            "jsCode": """// Format Test Result
const input = $input.first().json;
const validation = $('Validate Input').first().json;

// Si c'est une réponse HTTP, formater comme résultat de test
if (input.success !== undefined || input.data !== undefined) {
  return [{
    json: {
      test_success: input.success !== false,
      workflow_name: validation.data.workflow_name || null,
      action_name: validation.data.action_name || null,
      response: input,
      timestamp: new Date().toISOString()
    }
  }];
}

// Sinon, retourner tel quel
return [{
  json: {
    ...input,
    timestamp: new Date().toISOString()
  }
}];"""
        },
        "id": "format-test-result",
        "name": "Format Test Result",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [1570, 300]
    })
    
    # 12. Log Operation
    nodes.append({
        "parameters": {
            "operation": "executeQuery",
            "query": "SELECT iana.log_operation($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) as log_id",
            "additionalFields": {
                "queryParameters": "={{ ['iana-test', $('Validate Input').first().json.action, $('Validate Input').first().json.user_id, 'api', JSON.stringify($('Validate Input').first().json.data || {}), JSON.stringify($json), $json.test_success !== false, $json.errorCode || null, $json.errorMessage || null, Date.now() - ($('Validate Input').first().json._meta?.startTime || Date.now()), $('Validate Input').first().json._meta?.requestId || null] }}"
            },
            "options": {}
        },
        "id": "log-operation",
        "name": "Log Operation",
        "type": "n8n-nodes-base.postgres",
        "typeVersion": 2.4,
        "position": [1790, 300],
        "credentials": {
            "postgres": {
                "id": "5zFMgYDljFx593WZ",
                "name": "PostgreSQL IANA"
            }
        }
    })
    
    # 13. Format Response
    nodes.append({
        "parameters": {
            "jsCode": """// Format Response Standardisée
const input = $input.first().json;
const validation = $('Validate Input').first().json;
const startTime = validation._meta?.startTime || Date.now();

// Success case
if (input.test_success !== false && !input.isError) {
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
        "position": [2010, 300]
    })
    
    # 14. Respond to Webhook
    nodes.append({
        "parameters": {
            "respondWith": "json",
            "responseBody": "={{ JSON.stringify($json) }}"
        },
        "id": "respond-webhook",
        "name": "Respond to Webhook",
        "type": "n8n-nodes-base.respondToWebhook",
        "typeVersion": 1,
        "position": [2230, 300]
    })
    
    # Connections
    connections = {
        "Webhook Test": {
            "main": [[{"node": "Validate Input", "type": "main", "index": 0}]]
        },
        "Validate Input": {
            "main": [[{"node": "Switch Action", "type": "main", "index": 0}]]
        },
        "Switch Action": {
            "main": [
                [{"node": "Prepare Workflow Test", "type": "main", "index": 0}],
                [{"node": "Prepare All Tests", "type": "main", "index": 0}],
                [{"node": "Prepare Report", "type": "main", "index": 0}]
            ]
        },
        "Prepare Workflow Test": {
            "main": [[{"node": "Test Workflow HTTP", "type": "main", "index": 0}]]
        },
        "Test Workflow HTTP": {
            "main": [[{"node": "Format Test Result", "type": "main", "index": 0}]]
        },
        "Prepare All Tests": {
            "main": [[{"node": "Test All HTTP", "type": "main", "index": 0}]]
        },
        "Test All HTTP": {
            "main": [[{"node": "Format Test Result", "type": "main", "index": 0}]]
        },
        "Prepare Report": {
            "main": [[{"node": "Get Test Report", "type": "main", "index": 0}]]
        },
        "Get Test Report": {
            "main": [[{"node": "Format Test Result", "type": "main", "index": 0}]]
        },
        "Format Test Result": {
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
        "name": "iana-test",
        "nodes": nodes,
        "connections": connections,
        "settings": {
            "executionOrder": "v1"
        },
        "tags": [
            {"name": "IANA"},
            {"name": "Testing"},
            {"name": "P1"}
        ],
        "active": False
    }
    
    return workflow

if __name__ == "__main__":
    workflow = generate_workflow()
    output_file = "alfa-dashboard/n8n/workflows/iana-test.json"
    
    with open(output_file, 'w') as f:
        json.dump(workflow, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Workflow généré: {output_file}")
    print(f"   Nodes: {len(workflow['nodes'])}")
    print(f"   Actions: {', '.join(VALID_ACTIONS)}")
    print(f"   Workflows à tester: {len(WORKFLOWS_CONFIG)}")
