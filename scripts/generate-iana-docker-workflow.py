#!/usr/bin/env python3
"""
Script pour générer le workflow iana-docker.json (P0)
Actions: status, start, stop, restart, logs, inspect, cleanup
Toutes commandes via Code nodes avec child_process.execSync
"""

import json

VALID_ACTIONS = ['status', 'start', 'stop', 'restart', 'logs', 'inspect', 'cleanup']
CREDENTIAL_ID = '5zFMgYDljFx593WZ'

def generate_workflow():
    """Génère le workflow complet"""
    
    nodes = []
    y_positions = [100, 200, 300, 400, 500, 600, 700]
    
    # 1. Webhook
    nodes.append({
        "parameters": {
            "httpMethod": "POST",
            "path": "docker",
            "responseMode": "responseNode",
            "options": {}
        },
        "id": "webhook-docker",
        "name": "Webhook Docker",
        "type": "n8n-nodes-base.webhook",
        "typeVersion": 2,
        "position": [250, 300],
        "webhookId": "iana-docker-crud"
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
    
    # 4. Action nodes + Command nodes
    action_configs = {
        'status': {
            'name': 'Status Docker',
            'js_code': """// Action: status
const input = $input.first().json;
const { data, user_id } = input;

const container = data.container || null;

return [{
  json: {
    success: true,
    action: 'status',
    container: container,
    user_id: user_id
  }
}];""",
            'command': "docker ps -a --format 'json' | jq -s '.'"
        },
        'start': {
            'name': 'Start Container',
            'js_code': """// Action: start
const input = $input.first().json;
const { data, user_id } = input;

if (!data.container) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.container is required for start',
      action: 'start'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'start',
    container: data.container,
    user_id: user_id
  }
}];""",
            'command': "docker start {{ $json.container }}"
        },
        'stop': {
            'name': 'Stop Container',
            'js_code': """// Action: stop
const input = $input.first().json;
const { data, user_id } = input;

if (!data.container) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.container is required for stop',
      action: 'stop'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'stop',
    container: data.container,
    user_id: user_id
  }
}];""",
            'command': "docker stop {{ $json.container }}"
        },
        'restart': {
            'name': 'Restart Container',
            'js_code': """// Action: restart
const input = $input.first().json;
const { data, user_id } = input;

if (!data.container) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.container is required for restart',
      action: 'restart'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'restart',
    container: data.container,
    user_id: user_id
  }
}];""",
            'command': "docker restart {{ $json.container }}"
        },
        'logs': {
            'name': 'Get Logs',
            'js_code': """// Action: logs
const input = $input.first().json;
const { data, user_id } = input;

if (!data.container) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.container is required for logs',
      action: 'logs'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'logs',
    container: data.container,
    tail: data.tail || 100,
    user_id: user_id
  }
}];""",
            'command': "docker logs --tail {{ $json.tail || 100 }} {{ $json.container }}"
        },
        'inspect': {
            'name': 'Inspect Container',
            'js_code': """// Action: inspect
const input = $input.first().json;
const { data, user_id } = input;

if (!data.container) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.container is required for inspect',
      action: 'inspect'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'inspect',
    container: data.container,
    user_id: user_id
  }
}];""",
            'command': "docker inspect {{ $json.container }}"
        },
        'cleanup': {
            'name': 'Cleanup Docker',
            'js_code': """// Action: cleanup
const input = $input.first().json;
const { data, user_id } = input;

return [{
  json: {
    success: true,
    action: 'cleanup',
    pruneImages: data.pruneImages || false,
    pruneVolumes: data.pruneVolumes || false,
    pruneContainers: data.pruneContainers || false,
    user_id: user_id
  }
}];""",
            'command': "docker system prune -f"
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
        
        # Command execution node
        cmd_code = f"""// Execute Docker Command: {action}
const {{ execSync }} = require('child_process');
const input = $input.first().json;

let command;
{'if (input.container) {' if action != 'status' and action != 'cleanup' else ''}
  command = `{config['command']}`;
{'}' if action != 'status' and action != 'cleanup' else ''}

try {{
  const result = execSync(command, {{
    encoding: 'utf8',
    maxBuffer: 10 * 1024 * 1024,
    timeout: 30000
  }});
  
  let output;
  try {{
    output = JSON.parse(result.trim());
  }} catch (e) {{
    output = {{ raw: result.trim() }};
  }}
  
  return [{{
    json: {{
      success: true,
      action: input.action,
      output: output,
      command: command
    }}
  }}];
}} catch (error) {{
  return [{{
    json: {{
      success: false,
      errorCode: 'DOCKER_ERROR',
      errorMessage: error.message,
      stderr: error.stderr?.toString() || '',
      action: input.action
    }}
  }}];
}}"""
        
        # Remplacer les templates n8n
        cmd_code = cmd_code.replace('{{ $json.container }}', '${input.container}')
        cmd_code = cmd_code.replace('{{ $json.tail || 100 }}', '${input.tail || 100}')
        
        nodes.append({
            "parameters": {
                "jsCode": cmd_code
            },
            "id": f"cmd-{action}",
            "name": f"Execute {config['name']}",
            "type": "n8n-nodes-base.code",
            "typeVersion": 2,
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
        "position": [1350, 400]
    })
    
    # 6. Log
    nodes.append({
        "parameters": {
            "operation": "executeQuery",
            "query": "SELECT iana.log_operation($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) as log_id",
            "additionalFields": {
                "queryParameters": "={{ ['iana-docker', $json.action, $json.user_id, $json.channel || 'api', JSON.stringify($json.data || {}), JSON.stringify($json), $json.success !== false, $json.errorCode || null, $json.errorMessage || null, Date.now() - ($json._meta?.startTime || Date.now()), $json._meta?.requestId || null] }}"
            },
            "options": {}
        },
        "id": "log-operation",
        "name": "Log Operation",
        "type": "n8n-nodes-base.postgres",
        "typeVersion": 2.4,
        "position": [1570, 400],
        "credentials": {
            "postgres": {
                "id": CREDENTIAL_ID,
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
        "position": [1790, 400]
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
        "position": [2010, 400]
    })
    
    # Générer les connexions
    connections = {
        "Webhook Docker": {
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
        'status': 'Status Docker',
        'start': 'Start Container',
        'stop': 'Stop Container',
        'restart': 'Restart Container',
        'logs': 'Get Logs',
        'inspect': 'Inspect Container',
        'cleanup': 'Cleanup Docker'
    }
    
    cmd_names = {
        'status': 'Execute Status Docker',
        'start': 'Execute Start Container',
        'stop': 'Execute Stop Container',
        'restart': 'Execute Restart Container',
        'logs': 'Execute Get Logs',
        'inspect': 'Execute Inspect Container',
        'cleanup': 'Execute Cleanup Docker'
    }
    
    for i, action in enumerate(VALID_ACTIONS):
        action_name = action_names[action]
        cmd_name = cmd_names[action]
        
        connections["Switch Action"]["main"].append([{
            "node": action_name,
            "type": "main",
            "index": 0
        }])
        
        connections[action_name] = {
            "main": [[{"node": cmd_name, "type": "main", "index": 0}]]
        }
        
        connections[cmd_name] = {
            "main": [[{"node": "Merge Results", "type": "main", "index": 0}]]
        }
    
    workflow = {
        "name": "iana-docker",
        "nodes": nodes,
        "connections": connections,
        "settings": {"executionOrder": "v1"},
        "tags": [
            {"name": "IANA"},
            {"name": "Infrastructure"},
            {"name": "P0"},
            {"name": "Docker"}
        ],
        "active": False
    }
    
    return workflow

if __name__ == "__main__":
    workflow = generate_workflow()
    output_file = "alfa-dashboard/n8n/workflows/iana-docker.json"
    with open(output_file, 'w') as f:
        json.dump(workflow, f, indent=2)
    
    print(f"✅ Workflow généré : {output_file}")
    print(f"   - {len(workflow['nodes'])} nodes")
    print(f"   - {len(VALID_ACTIONS)} actions : {', '.join(VALID_ACTIONS)}")
