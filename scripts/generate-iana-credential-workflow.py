#!/usr/bin/env python3
"""
Script pour générer le workflow iana-credential.json
Workflow CRUD pour gérer les credentials n8n via API
"""

import json

VALID_ACTIONS = ['create', 'read', 'update', 'delete', 'list', 'test']
N8N_API_BASE = 'http://localhost:5678/api/v1'
# Note: API key devrait être dans credential n8n ou variable env, mais pour l'instant on laisse vide
N8N_API_KEY = ''  # À configurer dans le workflow

def generate_workflow():
    """Génère le workflow complet"""
    
    nodes = []
    y_positions = [100, 200, 300, 400, 500, 600]
    
    # 1. Webhook
    nodes.append({
        "parameters": {
            "httpMethod": "POST",
            "path": "credential",
            "responseMode": "responseNode",
            "options": {}
        },
        "id": "webhook-credential",
        "name": "Webhook Credential",
        "type": "n8n-nodes-base.webhook",
        "typeVersion": 2,
        "position": [250, 300],
        "webhookId": "iana-credential-crud"
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
    
    # 4. Action nodes + HTTP Request nodes
    action_configs = {
        'create': {
            'name': 'Create Credential',
            'js_code': """// Action: create
const input = $input.first().json;
const { data, user_id } = input;

// Validation
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

if (!data.type) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.type is required for create',
      action: 'create'
    }
  }];
}

if (!data.data) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.data is required for create',
      action: 'create'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'create',
    credentialData: {
      name: data.name,
      type: data.type,
      data: data.data,
      nodesAccess: data.nodesAccess || []
    },
    user_id: user_id
  }
}];""",
            'http_method': 'POST',
            'url_path': f'{N8N_API_BASE}/credentials'
        },
        'read': {
            'name': 'Read Credential',
            'js_code': """// Action: read
const input = $input.first().json;
const { data, user_id } = input;

if (!data.id) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.id is required for read',
      action: 'read'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'read',
    credentialId: data.id,
    user_id: user_id
  }
}];""",
            'http_method': 'GET',
            'url_path': f'{N8N_API_BASE}/credentials/{{{{ $json.credentialId }}}}'
        },
        'update': {
            'name': 'Update Credential',
            'js_code': """// Action: update
const input = $input.first().json;
const { data, user_id } = input;

if (!data.id) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.id is required for update',
      action: 'update'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'update',
    credentialId: data.id,
    credentialData: {
      name: data.name,
      type: data.type,
      data: data.data,
      nodesAccess: data.nodesAccess
    },
    user_id: user_id
  }
}];""",
            'http_method': 'PUT',
            'url_path': f'{N8N_API_BASE}/credentials/{{{{ $json.credentialId }}}}'
        },
        'delete': {
            'name': 'Delete Credential',
            'js_code': """// Action: delete
const input = $input.first().json;
const { data, user_id } = input;

if (!data.id) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.id is required for delete',
      action: 'delete'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'delete',
    credentialId: data.id,
    user_id: user_id
  }
}];""",
            'http_method': 'DELETE',
            'url_path': f'{N8N_API_BASE}/credentials/{{{{ $json.credentialId }}}}'
        },
        'list': {
            'name': 'List Credentials',
            'js_code': """// Action: list
const input = $input.first().json;
const { data, user_id } = input;

return [{
  json: {
    success: true,
    action: 'list',
    filters: {
      filter: data.filter || null
    },
    user_id: user_id
  }
}];""",
            'http_method': 'GET',
            'url_path': f'{N8N_API_BASE}/credentials'
        },
        'test': {
            'name': 'Test Credential',
            'js_code': """// Action: test
const input = $input.first().json;
const { data, user_id } = input;

if (!data.id) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.id is required for test',
      action: 'test'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'test',
    credentialId: data.id,
    user_id: user_id
  }
}];""",
            'http_method': 'POST',
            'url_path': f'{N8N_API_BASE}/credentials/{{{{ $json.credentialId }}}}/test'
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
                        "value": "={{ $env.N8N_API_KEY || '' }}"
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
                http_params["bodyParametersJson"] = "={{ JSON.stringify($json.credentialData) }}"
            elif action == 'update':
                http_params["bodyParametersJson"] = "={{ JSON.stringify($json.credentialData) }}"
        
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
        "position": [1350, 350]
    })
    
    # 6. Log
    nodes.append({
        "parameters": {
            "operation": "executeQuery",
            "query": "SELECT iana.log_operation($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) as log_id",
            "additionalFields": {
                "queryParameters": "={{ ['iana-credential', $json.action, $json.user_id, $json.channel || 'api', JSON.stringify($json.data || {}), JSON.stringify($json), $json.success !== false, $json.errorCode || null, $json.errorMessage || null, Date.now() - ($json._meta?.startTime || Date.now()), $json._meta?.requestId || null] }}"
            },
            "options": {}
        },
        "id": "log-operation",
        "name": "Log Operation",
        "type": "n8n-nodes-base.postgres",
        "typeVersion": 2.4,
        "position": [1570, 350],
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
        "position": [1790, 350]
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
        "position": [2010, 350]
    })
    
    # Générer les connexions
    connections = {
        "Webhook Credential": {
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
        'create': 'Create Credential',
        'read': 'Read Credential',
        'update': 'Update Credential',
        'delete': 'Delete Credential',
        'list': 'List Credentials',
        'test': 'Test Credential'
    }
    
    api_names = {
        'create': 'API Create Credential',
        'read': 'API Read Credential',
        'update': 'API Update Credential',
        'delete': 'API Delete Credential',
        'list': 'API List Credentials',
        'test': 'API Test Credential'
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
        "name": "iana-credential",
        "nodes": nodes,
        "connections": connections,
        "settings": {"executionOrder": "v1"},
        "tags": [
            {"name": "IANA"},
            {"name": "CRUD"},
            {"name": "Credentials"}
        ],
        "active": False
    }
    
    return workflow

if __name__ == "__main__":
    workflow = generate_workflow()
    output_file = "alfa-dashboard/n8n/workflows/iana-credential.json"
    with open(output_file, 'w') as f:
        json.dump(workflow, f, indent=2)
    
    print(f"✅ Workflow généré : {output_file}")
    print(f"   - {len(workflow['nodes'])} nodes")
    print(f"   - {len(VALID_ACTIONS)} actions : {', '.join(VALID_ACTIONS)}")
