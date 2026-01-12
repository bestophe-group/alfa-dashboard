#!/usr/bin/env python3
"""
Script pour générer le workflow iana-documentation.json
Workflow pour générer documentation complète des workflows IANA
Actions: 'generate', 'update', 'list'
"""

import json

VALID_ACTIONS = ['generate', 'update', 'list']
N8N_WEBHOOK_BASE = 'http://localhost:5678/webhook'

# Configuration des workflows à documenter
WORKFLOWS_CONFIG = {
    'iana-rag-document': {
        'endpoint': 'rag/document',
        'actions': ['create', 'read', 'update', 'delete', 'list', 'search', 'chunk'],
        'description': 'Gestion des documents RAG (CRUD complet)'
    },
    'iana-tool': {
        'endpoint': 'tool',
        'actions': ['create', 'read', 'update', 'delete', 'list', 'search', 'execute'],
        'description': 'Gestion des outils MCP (CRUD + exécution)'
    },
    'iana-credential': {
        'endpoint': 'credential',
        'actions': ['create', 'read', 'update', 'delete', 'list', 'test'],
        'description': 'Gestion des credentials n8n (CRUD + test)'
    },
    'iana-workflow': {
        'endpoint': 'workflow',
        'actions': ['create', 'read', 'update', 'delete', 'list', 'activate', 'deactivate', 'test', 'execute'],
        'description': 'Gestion des workflows n8n (CRUD + activation + exécution)'
    },
    'iana-docker': {
        'endpoint': 'docker',
        'actions': ['status', 'start', 'stop', 'restart', 'logs', 'inspect', 'cleanup'],
        'description': 'Gestion des conteneurs Docker'
    },
    'iana-postgres': {
        'endpoint': 'postgres',
        'actions': ['query', 'backup', 'restore', 'vacuum', 'analyze', 'status'],
        'description': 'Gestion de PostgreSQL (queries, backup, maintenance)'
    },
    'iana-backup': {
        'endpoint': 'backup',
        'actions': ['create', 'list', 'restore', 'delete', 'schedule'],
        'description': 'Gestion des sauvegardes (CRUD + planification)'
    },
    'iana-security': {
        'endpoint': 'security',
        'actions': ['audit', 'scan', 'report', 'alert'],
        'description': 'Sécurité (audit, scan, alertes)'
    },
    'iana-redis': {
        'endpoint': 'redis',
        'actions': ['get', 'set', 'delete', 'list', 'flush', 'info', 'status'],
        'description': 'Gestion de Redis (cache, données)'
    },
    'iana-monitoring': {
        'endpoint': 'monitoring',
        'actions': ['query', 'alert', 'dashboard', 'status'],
        'description': 'Monitoring (Prometheus, Grafana)'
    }
}

def generate_workflow():
    """Génère le workflow complet"""
    
    nodes = []
    
    # 1. Webhook
    nodes.append({
        "parameters": {
            "httpMethod": "POST",
            "path": "documentation",
            "responseMode": "responseNode",
            "options": {}
        },
        "id": "webhook-documentation",
        "name": "Webhook Documentation",
        "type": "n8n-nodes-base.webhook",
        "typeVersion": 2,
        "position": [250, 300],
        "webhookId": "iana-documentation-crud"
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
    
    # 4. Action: generate (générer documentation)
    workflows_config_json = json.dumps(WORKFLOWS_CONFIG, indent=2)
    nodes.append({
        "parameters": {
            "jsCode": f"""// Action: generate - Générer documentation complète
const input = $input.first().json;
const {{ data, user_id }} = input;

// Configuration des workflows
const workflowsConfig = {json.dumps(WORKFLOWS_CONFIG)};

const workflowName = data.workflow_name || null;
const format = data.format || 'markdown';

let workflowsToDocument = [];
if (workflowName) {{
  if (workflowsConfig[workflowName]) {{
    workflowsToDocument = [{{ name: workflowName, config: workflowsConfig[workflowName] }}];
  }} else {{
    return [{{
      json: {{
        success: false,
        errorCode: 'VALIDATION_ERROR',
        errorMessage: `Workflow ${{workflowName}} not found`,
        action: 'generate'
      }}
    }}];
  }}
}} else {{
  // Tous les workflows
  workflowsToDocument = Object.entries(workflowsConfig).map(([name, config]) => ({{
    name,
    config
  }}));
}}

return [{{
  json: {{
    success: true,
    action: 'generate',
    workflows_to_document: workflowsToDocument,
    format: format,
    user_id: user_id
  }}
}}];"""
        },
        "id": "action-generate",
        "name": "Prepare Documentation",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [910, 200]
    })
    
    # 5. Generate Markdown Documentation
    nodes.append({
        "parameters": {
            "jsCode": f"""// Générer documentation Markdown
const input = $input.first().json;
const {{ workflows_to_document, format, user_id }} = input;

// Configuration des workflows
const workflowsConfig = {json.dumps(WORKFLOWS_CONFIG)};

if (format !== 'markdown') {{
  return [{{
    json: {{
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: `Format ${{format}} not supported (only markdown)`,
      action: 'generate'
    }}
  }}];
}}

let markdown = `# Documentation IANA - Workflows API\\n\\n`;
markdown += `> Documentation générée le ${{new Date().toISOString()}}\\n\\n`;
markdown += `## Vue d'ensemble\\n\\n`;
markdown += `Cette documentation décrit tous les workflows IANA disponibles via leurs endpoints webhook.\\n\\n`;
markdown += `**Total workflows:** ${{workflows_to_document.length}}\\n\\n`;
markdown += `---\\n\\n`;

for (const {{ name, config }} of workflows_to_document) {{
  markdown += `## ${{name}}\\n\\n`;
  markdown += `**Description:** ${{config.description || 'N/A'}}\\n\\n`;
  markdown += `**Endpoint:** \`/webhook/${{config.endpoint}}\`\\n\\n`;
  markdown += `**Actions disponibles:** ${{config.actions.length}}\\n\\n`;
  
  markdown += `### Actions\\n\\n`;
  for (const action of config.actions) {{
    markdown += `#### ${{action}}\\n\\n`;
    markdown += `**Request:**\\n\\n`;
    markdown += `\`\`\`json\\n`;
    markdown += `{{\\n`;
    markdown += `  "action": "${{action}}",\\n`;
    markdown += `  "user_id": "string",\\n`;
    markdown += `  "data": {{}}\\n`;
    markdown += `}}\\n`;
    markdown += `\`\`\`\\n\\n`;
    
    markdown += `**Exemple curl:**\\n\\n`;
    markdown += `\`\`\`bash\\n`;
    markdown += `curl -X POST "http://localhost:5678/webhook/${{config.endpoint}}" \\\\\\n`;
    markdown += `  -H "Content-Type: application/json" \\\\\\n`;
    markdown += `  -d '{{\\n`;
    markdown += `    "action": "${{action}}",\\n`;
    markdown += `    "user_id": "test",\\n`;
    markdown += `    "data": {{}}\\n`;
    markdown += `  }}'\\n`;
    markdown += `\`\`\`\\n\\n`;
    
    markdown += `**Response (success):**\\n\\n`;
    markdown += `\`\`\`json\\n`;
    markdown += `{{\\n`;
    markdown += `  "success": true,\\n`;
    markdown += `  "action": "${{action}}",\\n`;
    markdown += `  "data": {{}},\\n`;
    markdown += `  "error": null,\\n`;
    markdown += `  "meta": {{\\n`;
    markdown += `    "latency_ms": 123,\\n`;
    markdown += `    "timestamp": "2025-01-12T12:00:00.000Z",\\n`;
    markdown += `    "request_id": "test-1234567890"\\n`;
    markdown += `  }}\\n`;
    markdown += `}}\\n`;
    markdown += `\`\`\`\\n\\n`;
    
    markdown += `---\\n\\n`;
  }}
  
  markdown += `\\n`;
}}

return [{{
  json: {{
    success: true,
    action: 'generate',
    documentation: markdown,
    format: format,
    workflows_count: workflows_to_document.length,
    user_id: user_id,
    timestamp: new Date().toISOString()
  }}
}}];"""
        },
        "id": "generate-markdown",
        "name": "Generate Markdown",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [1130, 200]
    })
    
    # 6. Action: update (mettre à jour documentation)
    nodes.append({
        "parameters": {
            "jsCode": """// Action: update - Mettre à jour documentation
const input = $input.first().json;
const { data, user_id } = input;

// Pour l'instant, update = generate (régénération complète)
return [{
  json: {
    success: true,
    action: 'update',
    message: 'Update = regenerate documentation',
    user_id: user_id
  }
}];"""
        },
        "id": "action-update",
        "name": "Prepare Update",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [910, 300]
    })
    
    # 7. Action: list (lister workflows documentés)
    nodes.append({
        "parameters": {
            "jsCode": f"""// Action: list - Lister workflows documentés
const input = $input.first().json;
const {{ user_id }} = input;

// Configuration des workflows
const workflowsConfig = {json.dumps(WORKFLOWS_CONFIG)};

const workflowsList = Object.entries(workflowsConfig).map(([name, config]) => ({{
  name,
  endpoint: config.endpoint,
  description: config.description || 'N/A',
  actions_count: config.actions.length,
  actions: config.actions
}}));

return [{{
  json: {{
    success: true,
    action: 'list',
    workflows: workflowsList,
    total_count: workflowsList.length,
    user_id: user_id
  }}
}}];"""
        },
        "id": "action-list",
        "name": "List Workflows",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [910, 400]
    })
    
    # 8. Merge Results
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
    
    # 9. Log Operation
    nodes.append({
        "parameters": {
            "operation": "executeQuery",
            "query": "SELECT iana.log_operation($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) as log_id",
            "additionalFields": {
                "queryParameters": "={{ ['iana-documentation', $('Validate Input').first().json.action, $('Validate Input').first().json.user_id, 'api', JSON.stringify($('Validate Input').first().json.data || {}), JSON.stringify($json), $json.success !== false, $json.errorCode || null, $json.errorMessage || null, Date.now() - ($('Validate Input').first().json._meta?.startTime || Date.now()), $('Validate Input').first().json._meta?.requestId || null] }}"
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
    
    # 10. Format Response
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
    
    # 11. Respond to Webhook
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
        "Webhook Documentation": {
            "main": [[{"node": "Validate Input", "type": "main", "index": 0}]]
        },
        "Validate Input": {
            "main": [[{"node": "Switch Action", "type": "main", "index": 0}]]
        },
        "Switch Action": {
            "main": [
                [{"node": "Prepare Documentation", "type": "main", "index": 0}],
                [{"node": "Prepare Update", "type": "main", "index": 0}],
                [{"node": "List Workflows", "type": "main", "index": 0}]
            ]
        },
        "Prepare Documentation": {
            "main": [[{"node": "Generate Markdown", "type": "main", "index": 0}]]
        },
        "Generate Markdown": {
            "main": [[{"node": "Merge Results", "type": "main", "index": 0}]]
        },
        "Prepare Update": {
            "main": [[{"node": "Merge Results", "type": "main", "index": 0}]]
        },
        "List Workflows": {
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
        "name": "iana-documentation",
        "nodes": nodes,
        "connections": connections,
        "settings": {
            "executionOrder": "v1"
        },
        "tags": [
            {"name": "IANA"},
            {"name": "Documentation"},
            {"name": "P1"}
        ],
        "active": False
    }
    
    return workflow

if __name__ == "__main__":
    workflow = generate_workflow()
    output_file = "alfa-dashboard/n8n/workflows/iana-documentation.json"
    
    with open(output_file, 'w') as f:
        json.dump(workflow, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Workflow généré: {output_file}")
    print(f"   Nodes: {len(workflow['nodes'])}")
    print(f"   Actions: {', '.join(VALID_ACTIONS)}")
    print(f"   Workflows documentés: {len(WORKFLOWS_CONFIG)}")
