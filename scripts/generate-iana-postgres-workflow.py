#!/usr/bin/env python3
"""
Script pour générer le workflow iana-postgres.json (P0)
Actions: query, backup, restore, vacuum, analyze, status
PostgreSQL nodes pour queries, Code nodes pour backup/restore/vacuum/analyze
"""

import json

VALID_ACTIONS = ['query', 'backup', 'restore', 'vacuum', 'analyze', 'status']
CREDENTIAL_ID = '5zFMgYDljFx593WZ'

def generate_workflow():
    """Génère le workflow complet"""
    
    nodes = []
    y_positions = [100, 200, 300, 400, 500, 600]
    
    # 1. Webhook
    nodes.append({
        "parameters": {
            "httpMethod": "POST",
            "path": "postgres",
            "responseMode": "responseNode",
            "options": {}
        },
        "id": "webhook-postgres",
        "name": "Webhook Postgres",
        "type": "n8n-nodes-base.webhook",
        "typeVersion": 2,
        "position": [250, 300],
        "webhookId": "iana-postgres-crud"
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
    
    # 4. Action nodes
    # Query: PostgreSQL node direct
    nodes.append({
        "parameters": {
            "jsCode": """// Action: query
const input = $input.first().json;
const { data, user_id } = input;

if (!data.query) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.query is required for query',
      action: 'query'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'query',
    query: data.query,
    queryParameters: data.queryParameters || [],
    user_id: user_id
  }
}];"""
        },
        "id": "action-query",
        "name": "Query SQL",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [910, 100]
    })
    
    nodes.append({
        "parameters": {
            "operation": "executeQuery",
            "query": "={{ $json.query }}",
            "additionalFields": {
                "queryParameters": "={{ $json.queryParameters }}"
            },
            "options": {}
        },
        "id": "db-query",
        "name": "DB Query",
        "type": "n8n-nodes-base.postgres",
        "typeVersion": 2.4,
        "position": [1130, 100],
        "credentials": {
            "postgres": {
                "id": CREDENTIAL_ID,
                "name": "PostgreSQL IANA"
            }
        }
    })
    
    # Backup, restore, vacuum, analyze, status: Code nodes avec pg_dump/pg_restore/vacuumdb
    action_configs = {
        'backup': {
            'name': 'Backup Database',
            'js_code': """// Action: backup
const input = $input.first().json;
const { data, user_id } = input;

const database = data.database || 'alfa';
const outputFile = data.outputFile || `/tmp/backup_${database}_${Date.now()}.sql`;

return [{
  json: {
    success: true,
    action: 'backup',
    database: database,
    outputFile: outputFile,
    user_id: user_id
  }
}];""",
            'command': "PGPASSWORD=$env.POSTGRES_PASSWORD pg_dump -h $env.POSTGRES_HOST -U $env.POSTGRES_USER -d {database} -f {outputFile}"
        },
        'restore': {
            'name': 'Restore Database',
            'js_code': """// Action: restore
const input = $input.first().json;
const { data, user_id } = input;

if (!data.inputFile) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.inputFile is required for restore',
      action: 'restore'
    }
  }];
}

const database = data.database || 'alfa';

return [{
  json: {
    success: true,
    action: 'restore',
    database: database,
    inputFile: data.inputFile,
    user_id: user_id
  }
}];""",
            'command': "PGPASSWORD=$env.POSTGRES_PASSWORD psql -h $env.POSTGRES_HOST -U $env.POSTGRES_USER -d {database} -f {inputFile}"
        },
        'vacuum': {
            'name': 'Vacuum Database',
            'js_code': """// Action: vacuum
const input = $input.first().json;
const { data, user_id } = input;

const database = data.database || 'alfa';
const full = data.full || false;
const analyze = data.analyze || true;

return [{
  json: {
    success: true,
    action: 'vacuum',
    database: database,
    full: full,
    analyze: analyze,
    user_id: user_id
  }
}];""",
            'command': "PGPASSWORD=$env.POSTGRES_PASSWORD vacuumdb -h $env.POSTGRES_HOST -U $env.POSTGRES_USER -d {database} --full --analyze"
        },
        'analyze': {
            'name': 'Analyze Database',
            'js_code': """// Action: analyze
const input = $input.first().json;
const { data, user_id } = input;

const database = data.database || 'alfa';

return [{
  json: {
    success: true,
    action: 'analyze',
    database: database,
    user_id: user_id
  }
}];""",
            'command': "PGPASSWORD=$env.POSTGRES_PASSWORD psql -h $env.POSTGRES_HOST -U $env.POSTGRES_USER -d {database} -c 'ANALYZE;'"
        },
        'status': {
            'name': 'Status Database',
            'js_code': """// Action: status
const input = $input.first().json;
const { data, user_id } = input;

return [{
  json: {
    success: true,
    action: 'status',
    user_id: user_id
  }
}];""",
            'query': "SELECT version(), current_database(), pg_database_size(current_database()) as size_bytes, (SELECT count(*) FROM pg_stat_activity) as active_connections"
        }
    }
    
    y_idx = 1
    for action in ['backup', 'restart', 'restore', 'vacuum', 'analyze', 'status']:
        if action == 'restart':
            continue
        if action == 'status':
            config = action_configs[action]
            # Status: PostgreSQL node
            nodes.append({
                "parameters": {
                    "jsCode": action_configs['status']['js_code']
                },
                "id": f"action-{action}",
                "name": config['name'],
                "type": "n8n-nodes-base.code",
                "typeVersion": 2,
                "position": [910, y_positions[y_idx]]
            })
            
            nodes.append({
                "parameters": {
                    "operation": "executeQuery",
                    "query": config['query'],
                    "options": {}
                },
                "id": f"db-{action}",
                "name": f"DB {config['name']}",
                "type": "n8n-nodes-base.postgres",
                "typeVersion": 2.4,
                "position": [1130, y_positions[y_idx]],
                "credentials": {
                    "postgres": {
                        "id": CREDENTIAL_ID,
                        "name": "PostgreSQL IANA"
                    }
                }
            })
        else:
            config = action_configs[action]
            # Backup, restore, vacuum, analyze: Code nodes avec execSync
            nodes.append({
                "parameters": {
                    "jsCode": config['js_code']
                },
                "id": f"action-{action}",
                "name": config['name'],
                "type": "n8n-nodes-base.code",
                "typeVersion": 2,
                "position": [910, y_positions[y_idx]]
            })
            
            cmd_code = f"""// Execute PostgreSQL Command: {action}
const {{ execSync }} = require('child_process');
const input = $input.first().json;

const dbHost = process.env.POSTGRES_HOST || 'localhost';
const dbUser = process.env.POSTGRES_USER || 'alfa';
const dbPass = process.env.POSTGRES_PASSWORD || '';
const dbName = input.database || 'alfa';

let command;
{'if (action === "backup") {' if action == 'backup' else ''}
  command = `PGPASSWORD=${{dbPass}} pg_dump -h ${{dbHost}} -U ${{dbUser}} -d ${{dbName}} -f ${{input.outputFile}}`;
{'} else if (action === "restore") {' if action == 'restore' else ''}
  command = `PGPASSWORD=${{dbPass}} psql -h ${{dbHost}} -U ${{dbUser}} -d ${{dbName}} -f ${{input.inputFile}}`;
{'} else if (action === "vacuum") {' if action == 'vacuum' else ''}
  const fullFlag = input.full ? '--full' : '';
  command = `PGPASSWORD=${{dbPass}} vacuumdb -h ${{dbHost}} -U ${{dbUser}} -d ${{dbName}} ${{fullFlag}} --analyze`;
{'} else if (action === "analyze") {' if action == 'analyze' else ''}
  command = `PGPASSWORD=${{dbPass}} psql -h ${{dbHost}} -U ${{dbUser}} -d ${{dbName}} -c "ANALYZE;"`;
{'} else {' if action in ['backup', 'restore', 'vacuum', 'analyze'] else ''}
  command = '';
{'}'

try {{
  const result = execSync(command, {{
    encoding: 'utf8',
    maxBuffer: 50 * 1024 * 1024,
    timeout: 300000
  }});
  
  return [{{
    json: {{
      success: true,
      action: input.action,
      output: result.trim(),
      command: command
    }}
  }}];
}} catch (error) {{
  return [{{
    json: {{
      success: false,
      errorCode: 'POSTGRES_ERROR',
      errorMessage: error.message,
      stderr: error.stderr?.toString() || '',
      action: input.action
    }}
  }}];
}}"""
            
            nodes.append({
                "parameters": {
                    "jsCode": cmd_code.replace('{action}', action)
                },
                "id": f"cmd-{action}",
                "name": f"Execute {config['name']}",
                "type": "n8n-nodes-base.code",
                "typeVersion": 2,
                "position": [1130, y_positions[y_idx]]
            })
        y_idx += 1
    
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
                "queryParameters": "={{ ['iana-postgres', $json.action, $json.user_id, $json.channel || 'api', JSON.stringify($json.data || {}), JSON.stringify($json), $json.success !== false, $json.errorCode || null, $json.errorMessage || null, Date.now() - ($json._meta?.startTime || Date.now()), $json._meta?.requestId || null] }}"
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
        "Webhook Postgres": {
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
    
    # Query
    connections["Switch Action"]["main"].append([{"node": "Query SQL", "type": "main", "index": 0}])
    connections["Query SQL"] = {"main": [[{"node": "DB Query", "type": "main", "index": 0}]]}
    connections["DB Query"] = {"main": [[{"node": "Merge Results", "type": "main", "index": 0}]]}
    
    # Backup, restore, vacuum, analyze, status
    for action in ['backup', 'restore', 'vacuum', 'analyze', 'status']:
        action_name = action_configs.get(action, {}).get('name', action.title())
        if action == 'status':
            connections["Switch Action"]["main"].append([{"node": action_name, "type": "main", "index": 0}])
            connections[action_name] = {"main": [[{"node": f"DB {action_name}", "type": "main", "index": 0}]]}
            connections[f"DB {action_name}"] = {"main": [[{"node": "Merge Results", "type": "main", "index": 0}]]}
        else:
            connections["Switch Action"]["main"].append([{"node": action_name, "type": "main", "index": 0}])
            connections[action_name] = {"main": [[{"node": f"Execute {action_name}", "type": "main", "index": 0}]]}
            connections[f"Execute {action_name}"] = {"main": [[{"node": "Merge Results", "type": "main", "index": 0}]]}
    
    workflow = {
        "name": "iana-postgres",
        "nodes": nodes,
        "connections": connections,
        "settings": {"executionOrder": "v1"},
        "tags": [
            {"name": "IANA"},
            {"name": "Infrastructure"},
            {"name": "P0"},
            {"name": "PostgreSQL"}
        ],
        "active": False
    }
    
    return workflow

if __name__ == "__main__":
    # Simplifier: créer workflow avec structure basique, les commandes seront améliorées plus tard
    print("⚠️  Workflow iana-postgres.json nécessite une structure plus complexe")
    print("   Création d'une version simplifiée...")
    workflow = generate_workflow()
    output_file = "alfa-dashboard/n8n/workflows/iana-postgres.json"
    with open(output_file, 'w') as f:
        json.dump(workflow, f, indent=2)
    
    print(f"✅ Workflow généré : {output_file}")
    print(f"   - {len(workflow['nodes'])} nodes")
    print(f"   - {len(VALID_ACTIONS)} actions : {', '.join(VALID_ACTIONS)}")
    print("   ⚠️  Note: Les commandes backup/restore nécessitent ajustement selon environnement")
