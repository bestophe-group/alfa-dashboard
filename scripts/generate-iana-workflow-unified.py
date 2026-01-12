#!/usr/bin/env python3
"""
Script pour générer le workflow iana-workflow.json (unifié)
Unifie iana-workflow-create.json + iana-workflow-factory.json
Actions: create, read, update, delete, list, activate, deactivate, test, execute
"""

import json

VALID_ACTIONS = ['create', 'read', 'update', 'delete', 'list', 'activate', 'deactivate', 'test', 'execute']
N8N_API_BASE = 'http://localhost:5678/api/v1'

def generate_workflow():
    """Génère le workflow complet"""
    
    nodes = []
    y_positions = [100, 200, 300, 400, 500, 600, 700, 800, 900]
    
    # 1. Webhook
    nodes.append({
        "parameters": {
            "httpMethod": "POST",
            "path": "workflow",
            "responseMode": "responseNode",
            "options": {}
        },
        "id": "webhook-workflow",
        "name": "Webhook Workflow",
        "type": "n8n-nodes-base.webhook",
        "typeVersion": 2,
        "position": [250, 300],
        "webhookId": "iana-workflow-crud"
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
    
    # 4. Action nodes + API nodes
    action_configs = {
        'create': {
            'name': 'Create Workflow',
            'js_code': """// Action: create
const input = $input.first().json;
const { data, user_id } = input;

if (!data.name) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.name is required for create',
      action: 'create'
    }
  }];
}

if (!data.nodes) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.nodes is required for create',
      action: 'create'
    }
  }];
}

const workflowData = {
  name: data.name,
  nodes: data.nodes,
  connections: data.connections || {},
  settings: data.settings || { executionOrder: 'v1' },
  staticData: data.staticData || null,
  tags: data.tags || []
};

return [{
  json: {
    success: true,
    action: 'create',
    workflowData: workflowData,
    user_id: user_id
  }
}];""",
            'http_method': 'POST',
            'url_path': f'{N8N_API_BASE}/workflows'
        },
        'read': {
            'name': 'Read Workflow',
            'js_code': """// Action: read
const input = $input.first().json;
const { data, user_id } = input;

if (!data.workflowId) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.workflowId is required for read',
      action: 'read'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'read',
    workflowId: data.workflowId,
    user_id: user_id
  }
}];""",
            'http_method': 'GET',
            'url_path': f'{N8N_API_BASE}/workflows/{{{{ $json.workflowId }}}}'
        },
        'update': {
            'name': 'Update Workflow',
            'js_code': """// Action: update
const input = $input.first().json;
const { data, user_id } = input;

if (!data.workflowId) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.workflowId is required for update',
      action: 'update'
    }
  }];
}

const workflowData = {
  id: data.workflowId,
  name: data.name,
  nodes: data.nodes,
  connections: data.connections,
  settings: data.settings,
  staticData: data.staticData,
  tags: data.tags
};

return [{
  json: {
    success: true,
    action: 'update',
    workflowId: data.workflowId,
    workflowData: workflowData,
    user_id: user_id
  }
}];""",
            'http_method': 'PUT',
            'url_path': f'{N8N_API_BASE}/workflows/{{{{ $json.workflowId }}}}'
        },
        'delete': {
            'name': 'Delete Workflow',
            'js_code': """// Action: delete
const input = $input.first().json;
const { data, user_id } = input;

if (!data.workflowId) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.workflowId is required for delete',
      action: 'delete'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'delete',
    workflowId: data.workflowId,
    user_id: user_id
  }
}];""",
            'http_method': 'DELETE',
            'url_path': f'{N8N_API_BASE}/workflows/{{{{ $json.workflowId }}}}'
        },
        'list': {
            'name': 'List Workflows',
            'js_code': """// Action: list
const input = $input.first().json;
const { data, user_id } = input;

return [{
  json: {
    success: true,
    action: 'list',
    filters: {
      active: data.active
    },
    user_id: user_id
  }
}];""",
            'http_method': 'GET',
            'url_path': f'{N8N_API_BASE}/workflows'
        },
        'activate': {
            'name': 'Activate Workflow',
            'js_code': """// Action: activate
const input = $input.first().json;
const { data, user_id } = input;

if (!data.workflowId) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.workflowId is required for activate',
      action: 'activate'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'activate',
    workflowId: data.workflowId,
    active: true,
    user_id: user_id
  }
}];""",
            'http_method': 'POST',
            'url_path': f'{N8N_API_BASE}/workflows/{{{{ $json.workflowId }}}}/activate'
        },
        'deactivate': {
            'name': 'Deactivate Workflow',
            'js_code': """// Action: deactivate
const input = $input.first().json;
const { data, user_id } = input;

if (!data.workflowId) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.workflowId is required for deactivate',
      action: 'deactivate'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'deactivate',
    workflowId: data.workflowId,
    active: false,
    user_id: user_id
  }
}];""",
            'http_method': 'POST',
            'url_path': f'{N8N_API_BASE}/workflows/{{{{ $json.workflowId }}}}/deactivate'
        },
        'test': {
            'name': 'Test Workflow',
            'js_code': """// Action: test
const input = $input.first().json;
const { data, user_id } = input;

if (!data.workflowId) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.workflowId is required for test',
      action: 'test'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'test',
    workflowId: data.workflowId,
    inputData: data.inputData || {},
    user_id: user_id
  }
}];""",
            'http_method': 'POST',
            'url_path': f'{N8N_API_BASE}/workflows/{{{{ $json.workflowId }}}}/execute'
        },
        'execute': {
            'name': 'Execute Workflow',
            'js_code': """// Action: execute
const input = $input.first().json;
const { data, user_id } = input;

if (!data.workflowId) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.workflowId is required for execute',
      action: 'execute'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'execute',
    workflowId: data.workflowId,
    inputData: data.inputData || {},
    user_id: user_id
  }
}];""",
            'http_method': 'POST',
            'url_path': f'{N8N_API_BASE}/workflows/{{{{ $json.workflowId }}}}/execute'
        }
    }
    
    for i, action in enumerate(VALID_ACTIONS):
        config = action_configs[action]
        y_pos = y_positions[i]
        
        # Action node
        nodes.append({
            "parameters": {
                "jsCode": config['js_code']
            },
            "id": f"action-{action}",
            "name": config['name'],
            "type": "n8n-nodes-base.code",
            "typeVersion": 2,
            "position": [910, y_pos]
        })
        
        # HTTP Request node
        http_params = {
            "url": config['url_path'],
            "method": config['http_method'],
            "authentication": "headerAuth",
            "sendHeaders": True,
            "headerParameters": {
                "parameters": [
                    {
                        "name": "X-N8N-API-KEY",
                        "value": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5M2RhNGJjNy1lY2ViLTQ1N2YtYTg3ZS1jYzkzODdlYjQ3MWIiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzY4MjI5MTEwfQ.E1amsEqAQESuuvc0l2qABKXtIEwbxelnoubM1vh9xnM"
                    },
                    {
                        "name": "Content-Type",
                        "value": "application/json"
                    }
                ]
            },
            "options": {}
        }
        
        if config['http_method'] in ['POST', 'PUT']:
            http_params["sendBody"] = True
            if action == 'create':
                http_params["bodyParametersJson"] = "={{ JSON.stringify($json.workflowData) }}"
            elif action == 'update':
                http_params["bodyParametersJson"] = "={{ JSON.stringify($json.workflowData) }}"
            elif action in ['test', 'execute']:
                http_params["bodyParametersJson"] = "={{ JSON.stringify({data: $json.inputData}) }}"
        
        nodes.append({
            "parameters": http_params,
            "id": f"api-{action}",
            "name": f"API {config['name']}",
            "type": "n8n-nodes-base.httpRequest",
            "typeVersion": 4.2,
            "position": [1130, y_pos]
        })
    
    # 5. Merge
    nodes.append({
        "parameters": {
            "mode": "combine",
            "combineBy": "combineAll"
        },
        "id": "merge-results",
        "name": "Merge Results",
        "type": "n8n-nodes-base.merge",
        "typeVersion": 2.1,
        "position": [1350, 450]
    })
    
    # 6. Log
    nodes.append({
        "parameters": {
            "operation": "executeQuery",
            "query": "SELECT iana.log_operation($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) as log_id",
            "additionalFields": {
                "queryParameters": "={{ ['iana-workflow', $json.action, $json.user_id, $json.channel || 'api', JSON.stringify($json.data || {}), JSON.stringify($json), $json.success !== false, $json.errorCode || null, $json.errorMessage || null, Date.now() - ($json._meta?.startTime || Date.now()), $json._meta?.requestId || null] }}"
            },
            "options": {}
        },
        "id": "log-operation",
        "name": "Log Operation",
        "type": "n8n-nodes-base.postgres",
        "typeVersion": 2.4,
        "position": [1570, 450],
        "credentials": {
            "postgres": {
                "id": "5zFMgYDljFx593WZ",
                "name": "PostgreSQL IANA"
            }
        }
    })
    
    # 7. Format Response
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
      data: input.data || input,
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
        "position": [1790, 450]
    })
    
    # 8. Respond
    nodes.append({
        "parameters": {
            "respondWith": "json",
            "responseBody": "={{ JSON.stringify($json) }}"
        },
        "id": "respond-webhook",
        "name": "Respond to Webhook",
        "type": "n8n-nodes-base.respondToWebhook",
        "typeVersion": 1,
        "position": [2010, 450]
    })
    
    # Générer les connexions
    connections = {
        "Webhook Workflow": {
            "main": [[{"node": "Validate Input", "type": "main", "index": 0}]]
        },
        "Validate Input": {
            "main": [[{"node": "Switch Action", "type": "main", "index": 0}]]
        },
        "Switch Action": {
            "main": []
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
    
    action_names = {
        'create': 'Create Workflow',
        'read': 'Read Workflow',
        'update': 'Update Workflow',
        'delete': 'Delete Workflow',
        'list': 'List Workflows',
        'activate': 'Activate Workflow',
        'deactivate': 'Deactivate Workflow',
        'test': 'Test Workflow',
        'execute': 'Execute Workflow'
    }
    
    api_names = {
        'create': 'API Create Workflow',
        'read': 'API Read Workflow',
        'update': 'API Update Workflow',
        'delete': 'API Delete Workflow',
        'list': 'API List Workflows',
        'activate': 'API Activate Workflow',
        'deactivate': 'API Deactivate Workflow',
        'test': 'API Test Workflow',
        'execute': 'API Execute Workflow'
    }
    
    for i, action in enumerate(VALID_ACTIONS):
        action_name = action_names[action]
        api_name = api_names[action]
        
        connections["Switch Action"]["main"].append([{
            "node": action_name,
            "type": "main",
            "index": 0
        }])
        
        connections[action_name] = {
            "main": [[{"node": api_name, "type": "main", "index": 0}]]
        }
        
        connections[api_name] = {
            "main": [[{"node": "Merge Results", "type": "main", "index": 0}]]
        }
    
    workflow = {
        "name": "iana-workflow",
        "nodes": nodes,
        "connections": connections,
        "settings": {"executionOrder": "v1"},
        "tags": [
            {"name": "IANA"},
            {"name": "CRUD"},
            {"name": "Workflows"}
        ],
        "active": False
    }
    
    return workflow

if __name__ == "__main__":
    workflow = generate_workflow()
    output_file = "alfa-dashboard/n8n/workflows/iana-workflow.json"
    with open(output_file, 'w') as f:
        json.dump(workflow, f, indent=2)
    
    print(f"✅ Workflow généré : {output_file}")
    print(f"   - {len(workflow['nodes'])} nodes")
    print(f"   - {len(VALID_ACTIONS)} actions : {', '.join(VALID_ACTIONS)}")
