#!/usr/bin/env python3
"""
Script pour générer le workflow iana-tool.json
Workflow CRUD pour gérer les outils MCP (rag.mcp_tools)
"""

import json

VALID_ACTIONS = ['create', 'read', 'update', 'delete', 'list', 'search', 'execute']
CREDENTIAL_ID = '5zFMgYDljFx593WZ'

def generate_workflow():
    """Génère le workflow complet"""
    
    nodes = []
    y_positions = [100, 200, 300, 400, 500, 600, 700]
    
    # 1. Webhook
    nodes.append({
        "parameters": {
            "httpMethod": "POST",
            "path": "tool",
            "responseMode": "responseNode",
            "options": {}
        },
        "id": "webhook-tool",
        "name": "Webhook Tool",
        "type": "n8n-nodes-base.webhook",
        "typeVersion": 2,
        "position": [250, 300],
        "webhookId": "iana-tool-crud"
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
    
    # 4. Action nodes + DB nodes
    action_configs = {
        'create': {
            'name': 'Create Tool',
            'js_code': """// Action: create
const input = $input.first().json;
const { data, user_id } = input;

// Validation
if (!data.server_name) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.server_name is required for create',
      action: 'create'
    }
  }];
}

if (!data.tool_name) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.tool_name is required for create',
      action: 'create'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'create',
    toolData: {
      server_name: data.server_name,
      tool_name: data.tool_name,
      description_short: data.description_short || null,
      description_full: data.description_full || null,
      category: data.category || null,
      parameters: data.parameters || {},
      examples: data.examples || []
    },
    user_id: user_id
  }
}];""",
            'query': """SELECT rag.index_mcp_tool(
  $1::text,  -- server_name
  $2::text,  -- tool_name
  $3::text,  -- description_short
  $4::text,  -- description_full
  $5::text,  -- category
  $6::jsonb, -- parameters
  $7::jsonb  -- examples
) AS tool_id""",
            'query_params': "={{ [$json.toolData.server_name, $json.toolData.tool_name, $json.toolData.description_short, $json.toolData.description_full, $json.toolData.category, JSON.stringify($json.toolData.parameters), JSON.stringify($json.toolData.examples)] }}"
        },
        'read': {
            'name': 'Read Tool',
            'js_code': """// Action: read
const input = $input.first().json;
const { data, user_id } = input;

if (!data.server_name || !data.tool_name) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.server_name and data.tool_name are required for read',
      action: 'read'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'read',
    server_name: data.server_name,
    tool_name: data.tool_name,
    user_id: user_id
  }
}];""",
            'query': """SELECT * FROM rag.get_mcp_tool_details($1::text, $2::text)""",
            'query_params': "={{ [$json.server_name, $json.tool_name] }}"
        },
        'update': {
            'name': 'Update Tool',
            'js_code': """// Action: update
const input = $input.first().json;
const { data, user_id } = input;

if (!data.server_name || !data.tool_name) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.server_name and data.tool_name are required for update',
      action: 'update'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'update',
    toolData: {
      server_name: data.server_name,
      tool_name: data.tool_name,
      description_short: data.description_short || null,
      description_full: data.description_full || null,
      category: data.category || null,
      parameters: data.parameters || null,
      examples: data.examples || null
    },
    user_id: user_id
  }
}];""",
            'query': """SELECT rag.index_mcp_tool(
  $1::text,
  $2::text,
  $3::text,
  $4::text,
  $5::text,
  COALESCE($6::jsonb, (SELECT parameters FROM rag.mcp_tools t JOIN rag.mcp_servers s ON s.id = t.server_id WHERE s.name = $1 AND t.tool_name = $2)),
  COALESCE($7::jsonb, (SELECT examples FROM rag.mcp_tools t JOIN rag.mcp_servers s ON s.id = t.server_id WHERE s.name = $1 AND t.tool_name = $2))
) AS tool_id""",
            'query_params': "={{ [$json.toolData.server_name, $json.toolData.tool_name, $json.toolData.description_short, $json.toolData.description_full, $json.toolData.category, $json.toolData.parameters ? JSON.stringify($json.toolData.parameters) : null, $json.toolData.examples ? JSON.stringify($json.toolData.examples) : null] }}"
        },
        'delete': {
            'name': 'Delete Tool',
            'js_code': """// Action: delete
const input = $input.first().json;
const { data, user_id } = input;

if (!data.server_name || !data.tool_name) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.server_name and data.tool_name are required for delete',
      action: 'delete'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'delete',
    server_name: data.server_name,
    tool_name: data.tool_name,
    user_id: user_id
  }
}];""",
            'query': """DELETE FROM rag.mcp_tools t
USING rag.mcp_servers s
WHERE t.server_id = s.id
  AND s.name = $1::text
  AND t.tool_name = $2::text
RETURNING t.id AS tool_id""",
            'query_params': "={{ [$json.server_name, $json.tool_name] }}"
        },
        'list': {
            'name': 'List Tools',
            'js_code': """// Action: list
const input = $input.first().json;
const { data, user_id } = input;

const filters = {
  server_name: data.server_name || null,
  category: data.category || null,
  limit: data.limit || 50,
  offset: data.offset || 0
};

return [{
  json: {
    success: true,
    action: 'list',
    filters: filters,
    user_id: user_id
  }
}];""",
            'query': """SELECT t.id, s.name AS server_name, t.tool_name, t.description_short, t.category, t.usage_count, t.created_at
FROM rag.mcp_tools t
JOIN rag.mcp_servers s ON s.id = t.server_id
WHERE ($1::text IS NULL OR s.name = $1)
  AND ($2::text IS NULL OR t.category = $2)
ORDER BY t.usage_count DESC, t.created_at DESC
LIMIT $3 OFFSET $4""",
            'query_params': "={{ [$json.filters.server_name, $json.filters.category, $json.filters.limit, $json.filters.offset] }}"
        },
        'search': {
            'name': 'Search Tools',
            'js_code': """// Action: search
const input = $input.first().json;
const { data, user_id } = input;

if (!data.query) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.query is required for search',
      action: 'search'
    }
  }];
}

const searchParams = {
  query: data.query,
  category: data.category || null,
  limit: data.limit || 10
};

return [{
  json: {
    success: true,
    action: 'search',
    searchParams: searchParams,
    user_id: user_id
  }
}];""",
            'query': """SELECT * FROM rag.search_mcp_tools($1::text, $2::integer, $3::text)""",
            'query_params': "={{ [$json.searchParams.query, $json.searchParams.limit, $json.searchParams.category] }}"
        },
        'execute': {
            'name': 'Execute Tool',
            'js_code': """// Action: execute (track usage)
const input = $input.first().json;
const { data, user_id } = input;

if (!data.server_name || !data.tool_name) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.server_name and data.tool_name are required for execute',
      action: 'execute'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'execute',
    server_name: data.server_name,
    tool_name: data.tool_name,
    user_id: user_id
  }
}];""",
            'query': """SELECT rag.increment_tool_usage($1::text, $2::text) AS usage_count""",
            'query_params': "={{ [$json.server_name, $json.tool_name] }}"
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
        
        # DB node
        nodes.append({
            "parameters": {
                "operation": "executeQuery",
                "query": config['query'],
                "additionalFields": {
                    "queryParameters": config['query_params']
                },
                "options": {}
            },
            "id": f"db-{action}",
            "name": f"DB {config['name']}",
            "type": "n8n-nodes-base.postgres",
            "typeVersion": 2.4,
            "position": [1130, y_pos],
            "credentials": {
                "postgres": {
                    "id": CREDENTIAL_ID,
                    "name": "PostgreSQL IANA"
                }
            }
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
                "queryParameters": "={{ ['iana-tool', $json.action, $json.user_id, $json.channel || 'api', JSON.stringify($json.data || {}), JSON.stringify($json), $json.success !== false, $json.errorCode || null, $json.errorMessage || null, Date.now() - ($json._meta?.startTime || Date.now()), $json._meta?.requestId || null] }}"
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
        "Webhook Tool": {
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
        'create': 'Create Tool',
        'read': 'Read Tool',
        'update': 'Update Tool',
        'delete': 'Delete Tool',
        'list': 'List Tools',
        'search': 'Search Tools',
        'execute': 'Execute Tool'
    }
    
    db_names = {
        'create': 'DB Create Tool',
        'read': 'DB Read Tool',
        'update': 'DB Update Tool',
        'delete': 'DB Delete Tool',
        'list': 'DB List Tools',
        'search': 'DB Search Tools',
        'execute': 'DB Execute Tool'
    }
    
    for i, action in enumerate(VALID_ACTIONS):
        action_name = action_names[action]
        db_name = db_names[action]
        
        connections["Switch Action"]["main"].append([{
            "node": action_name,
            "type": "main",
            "index": 0
        }])
        
        connections[action_name] = {
            "main": [[{"node": db_name, "type": "main", "index": 0}]]
        }
        
        connections[db_name] = {
            "main": [[{"node": "Merge Results", "type": "main", "index": 0}]]
        }
    
    workflow = {
        "name": "iana-tool",
        "nodes": nodes,
        "connections": connections,
        "settings": {"executionOrder": "v1"},
        "tags": [
            {"name": "IANA"},
            {"name": "CRUD"},
            {"name": "MCP"}
        ],
        "active": False
    }
    
    return workflow

if __name__ == "__main__":
    workflow = generate_workflow()
    output_file = "alfa-dashboard/n8n/workflows/iana-tool.json"
    with open(output_file, 'w') as f:
        json.dump(workflow, f, indent=2)
    
    print(f"✅ Workflow généré : {output_file}")
    print(f"   - {len(workflow['nodes'])} nodes")
    print(f"   - {len(VALID_ACTIONS)} actions : {', '.join(VALID_ACTIONS)}")
