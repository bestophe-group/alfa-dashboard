#!/usr/bin/env python3
"""
Script pour générer le workflow iana-rag-document.json
Basé sur iana-conversation.json mais adapté pour RAG documents
"""

import json
import uuid

# Actions : create, read, update, delete, list, search, chunk
VALID_ACTIONS = ['create', 'read', 'update', 'delete', 'list', 'search', 'chunk']
CREDENTIAL_ID = '5zFMgYDljFx593WZ'

def generate_webhook_node():
    return {
        "parameters": {
            "httpMethod": "POST",
            "path": "rag/document",
            "responseMode": "responseNode",
            "options": {}
        },
        "id": "webhook-rag-document",
        "name": "Webhook RAG Document",
        "type": "n8n-nodes-base.webhook",
        "typeVersion": 2,
        "position": [250, 300],
        "webhookId": "iana-rag-document-crud"
    }

def generate_validate_input_node():
    valid_actions_str = ', '.join([f"'{a}'" for a in VALID_ACTIONS])
    js_code = f"""// Validation commune AVANT Switch
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
    
    return {
        "parameters": {
            "jsCode": js_code
        },
        "id": "validate-input",
        "name": "Validate Input",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [470, 300]
    }

def generate_switch_node():
    rules = []
    for i, action in enumerate(VALID_ACTIONS):
        rules.append({
            "conditions": {
                "string": [{
                    "value1": "={{ $json.action }}",
                    "operation": "equals",
                    "value2": action
                }]
            }
        })
    
    return {
        "parameters": {
            "rules": {
                "rules": rules
            },
            "fallbackOutput": "extra"
        },
        "id": "switch-action",
        "name": "Switch Action",
        "type": "n8n-nodes-base.switch",
        "typeVersion": 3,
        "position": [690, 300]
    }

def generate_action_node(action, y_position):
    """Génère un node Code pour préparer l'action"""
    node_ids = {
        'create': 'action-create',
        'read': 'action-read',
        'update': 'action-update',
        'delete': 'action-delete',
        'list': 'action-list',
        'search': 'action-search',
        'chunk': 'action-chunk'
    }
    
    node_names = {
        'create': 'Create Document',
        'read': 'Read Document',
        'update': 'Update Document',
        'delete': 'Delete Document',
        'list': 'List Documents',
        'search': 'Search Documents',
        'chunk': 'Chunk Document'
    }
    
    if action == 'create':
        js_code = """// Action: create
const input = $input.first().json;
const { data, user_id } = input;

// Validation data pour create
if (!data.title) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.title is required for create',
      action: 'create'
    }
  }];
}

if (!data.content) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.content is required for create',
      action: 'create'
    }
  }];
}

// Préparer données pour insertion
const documentData = {
  title: data.title,
  content: data.content,
  source_type: data.source_type || 'markdown',
  source_path: data.source_path || null,
  metadata: data.metadata || {},
  project: data.project || 'ALFA',
  category: data.category || null,
  priority: data.priority || 'P2'
};

return [{
  json: {
    success: true,
    action: 'create',
    documentData: documentData,
    user_id: user_id
  }
}];"""
    elif action == 'read':
        js_code = """// Action: read
const input = $input.first().json;
const { data, user_id } = input;

if (!data.document_id) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.document_id is required for read',
      action: 'read'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'read',
    document_id: data.document_id,
    user_id: user_id
  }
}];"""
    elif action == 'update':
        js_code = """// Action: update
const input = $input.first().json;
const { data, user_id } = input;

if (!data.document_id) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.document_id is required for update',
      action: 'update'
    }
  }];
}

// Préparer données pour update
const updateData = {
  document_id: data.document_id,
  title: data.title || null,
  content: data.content || null,
  metadata: data.metadata || null,
  category: data.category || null,
  status: data.status || null
};

return [{
  json: {
    success: true,
    action: 'update',
    updateData: updateData,
    user_id: user_id
  }
}];"""
    elif action == 'delete':
        js_code = """// Action: delete
const input = $input.first().json;
const { data, user_id } = input;

if (!data.document_id) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.document_id is required for delete',
      action: 'delete'
    }
  }];
}

return [{
  json: {
    success: true,
    action: 'delete',
    document_id: data.document_id,
    user_id: user_id
  }
}];"""
    elif action == 'list':
        js_code = """// Action: list
const input = $input.first().json;
const { data, user_id } = input;

// Préparer filtres pour list
const filters = {
  project: data.project || null,
  category: data.category || null,
  status: data.status || null,
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
}];"""
    elif action == 'search':
        js_code = """// Action: search
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

// Préparer recherche
const searchParams = {
  query: data.query,
  limit: data.limit || 10,
  offset: data.offset || 0
};

return [{
  json: {
    success: true,
    action: 'search',
    searchParams: searchParams,
    user_id: user_id
  }
}];"""
    elif action == 'chunk':
        js_code = """// Action: chunk
const input = $input.first().json;
const { data, user_id } = input;

if (!data.document_id) {
  return [{
    json: {
      success: false,
      errorCode: 'VALIDATION_ERROR',
      errorMessage: 'data.document_id is required for chunk',
      action: 'chunk'
    }
  }];
}

// Préparer paramètres de chunking
const chunkParams = {
  document_id: data.document_id,
  chunk_size: data.chunk_size || 1000,
  overlap: data.overlap || 200
};

return [{
  json: {
    success: true,
    action: 'chunk',
    chunkParams: chunkParams,
    user_id: user_id
  }
}];"""
    
    return {
        "parameters": {
            "jsCode": js_code
        },
        "id": node_ids[action],
        "name": node_names[action],
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [910, y_position]
    }

def generate_db_node(action, y_position):
    """Génère un node PostgreSQL pour l'action"""
    node_ids = {
        'create': 'db-create',
        'read': 'db-read',
        'update': 'db-update',
        'delete': 'db-delete',
        'list': 'db-list',
        'search': 'db-search',
        'chunk': 'db-chunk'
    }
    
    node_names = {
        'create': 'DB Create',
        'read': 'DB Read',
        'update': 'DB Update',
        'delete': 'DB Delete',
        'list': 'DB List',
        'search': 'DB Search',
        'chunk': 'DB Chunk'
    }
    
    if action == 'create':
        query = """SELECT rag.ingest_document(
  $1::text,  -- title
  $2::text,  -- content
  $3::text,  -- source_type
  $4::text,  -- source_path
  $5::jsonb, -- metadata
  $6::text,  -- project
  $7::text,  -- category
  $8::text   -- priority
) AS document_id"""
        query_params = "={{ [$json.documentData.title, $json.documentData.content, $json.documentData.source_type, $json.documentData.source_path, JSON.stringify($json.documentData.metadata), $json.documentData.project, $json.documentData.category, $json.documentData.priority] }}"
    elif action == 'read':
        query = """SELECT id, title, source_type, source_path, content_raw, content_length, metadata, project, category, priority, status, created_at, updated_at, indexed_at
FROM rag.documents
WHERE id = $1::uuid"""
        query_params = "={{ [$json.document_id] }}"
    elif action == 'update':
        query = """UPDATE rag.documents
SET 
  title = COALESCE($1::text, title),
  content_raw = COALESCE($2::text, content_raw),
  content_length = CASE WHEN $2::text IS NOT NULL THEN length($2::text) ELSE content_length END,
  metadata = COALESCE($3::jsonb, metadata),
  category = COALESCE($4::text, category),
  status = COALESCE($5::text, status),
  updated_at = NOW()
WHERE id = $6::uuid
RETURNING id, title, updated_at"""
        query_params = "={{ [$json.updateData.title, $json.updateData.content, $json.updateData.metadata ? JSON.stringify($json.updateData.metadata) : null, $json.updateData.category, $json.updateData.status, $json.updateData.document_id] }}"
    elif action == 'delete':
        query = """DELETE FROM rag.documents WHERE id = $1::uuid RETURNING id"""
        query_params = "={{ [$json.document_id] }}"
    elif action == 'list':
        query = """SELECT id, title, source_type, source_path, content_length, metadata, project, category, priority, status, created_at, updated_at
FROM rag.documents
WHERE ($1::text IS NULL OR project = $1)
  AND ($2::text IS NULL OR category = $2)
  AND ($3::text IS NULL OR status = $3)
ORDER BY created_at DESC
LIMIT $4 OFFSET $5"""
        query_params = "={{ [$json.filters.project, $json.filters.category, $json.filters.status, $json.filters.limit, $json.filters.offset] }}"
    elif action == 'search':
        query = """SELECT c.id AS chunk_id, c.content, c.chunk_index, d.id AS document_id, d.title AS document_title
FROM rag.chunks c
JOIN rag.documents d ON d.id = c.document_id
WHERE to_tsvector('french', c.content) @@ plainto_tsquery('french', $1::text)
ORDER BY ts_rank(to_tsvector('french', c.content), plainto_tsquery('french', $1::text)) DESC
LIMIT $2 OFFSET $3"""
        query_params = "={{ [$json.searchParams.query, $json.searchParams.limit, $json.searchParams.offset] }}"
    elif action == 'chunk':
        query = """SELECT rag.chunk_document(
  $1::uuid,  -- document_id
  $2::integer,  -- chunk_size
  $3::integer   -- overlap
) AS chunk_count"""
        query_params = "={{ [$json.chunkParams.document_id, $json.chunkParams.chunk_size, $json.chunkParams.overlap] }}"
    
    return {
        "parameters": {
            "operation": "executeQuery",
            "query": query,
            "additionalFields": {
                "queryParameters": query_params
            },
            "options": {}
        },
        "id": node_ids[action],
        "name": node_names[action],
        "type": "n8n-nodes-base.postgres",
        "typeVersion": 2.4,
        "position": [1130, y_position],
        "credentials": {
            "postgres": {
                "id": CREDENTIAL_ID,
                "name": "PostgreSQL IANA"
            }
        }
    }

def generate_merge_node():
    return {
        "parameters": {
            "mode": "combine",
            "combineBy": "combineAll"
        },
        "id": "merge-results",
        "name": "Merge Results",
        "type": "n8n-nodes-base.merge",
        "typeVersion": 2.1,
        "position": [1350, 400]
    }

def generate_log_node():
    return {
        "parameters": {
            "operation": "executeQuery",
            "query": "SELECT iana.log_operation($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) as log_id",
            "additionalFields": {
                "queryParameters": "={{ ['iana-rag-document', $json.action, $json.user_id, $json.channel || 'api', JSON.stringify($json.data || {}), JSON.stringify($json), $json.success !== false, $json.errorCode || null, $json.errorMessage || null, Date.now() - ($json._meta?.startTime || Date.now()), $json._meta?.requestId || null] }}"
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
    }

def generate_format_response_node():
    js_code = """// Format Response Standardisée
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
    
    return {
        "parameters": {
            "jsCode": js_code
        },
        "id": "format-response",
        "name": "Format Response",
        "type": "n8n-nodes-base.code",
        "typeVersion": 2,
        "position": [1790, 400]
    }

def generate_respond_node():
    return {
        "parameters": {
            "respondWith": "json",
            "responseBody": "={{ JSON.stringify($json) }}"
        },
        "id": "respond-webhook",
        "name": "Respond to Webhook",
        "type": "n8n-nodes-base.respondToWebhook",
        "typeVersion": 1,
        "position": [2010, 400]
    }

def generate_connections():
    """Génère les connexions entre les nodes"""
    connections = {
        "Webhook RAG Document": {
            "main": [[{
                "node": "Validate Input",
                "type": "main",
                "index": 0
            }]]
        },
        "Validate Input": {
            "main": [[{
                "node": "Switch Action",
                "type": "main",
                "index": 0
            }]]
        },
        "Switch Action": {
            "main": []
        },
        "Merge Results": {
            "main": [[{
                "node": "Log Operation",
                "type": "main",
                "index": 0
            }]]
        },
        "Log Operation": {
            "main": [[{
                "node": "Format Response",
                "type": "main",
                "index": 0
            }]]
        },
        "Format Response": {
            "main": [[{
                "node": "Respond to Webhook",
                "type": "main",
                "index": 0
            }]]
        }
    }
    
    # Ajouter les connexions du Switch vers les actions
    action_nodes = {
        'create': 'Create Document',
        'read': 'Read Document',
        'update': 'Update Document',
        'delete': 'Delete Document',
        'list': 'List Documents',
        'search': 'Search Documents',
        'chunk': 'Chunk Document'
    }
    
    for i, action in enumerate(VALID_ACTIONS):
        node_name = action_nodes[action]
        db_node_name = {
            'create': 'DB Create',
            'read': 'DB Read',
            'update': 'DB Update',
            'delete': 'DB Delete',
            'list': 'DB List',
            'search': 'DB Search',
            'chunk': 'DB Chunk'
        }[action]
        
        connections["Switch Action"]["main"].append([{
            "node": node_name,
            "type": "main",
            "index": 0
        }])
        
        connections[node_name] = {
            "main": [[{
                "node": db_node_name,
                "type": "main",
                "index": 0
            }]]
        }
        
        connections[db_node_name] = {
            "main": [[{
                "node": "Merge Results",
                "type": "main",
                "index": 0
            }]]
        }
    
    return connections

def main():
    """Génère le workflow complet"""
    nodes = []
    
    # Webhook
    nodes.append(generate_webhook_node())
    
    # Validate Input
    nodes.append(generate_validate_input_node())
    
    # Switch
    nodes.append(generate_switch_node())
    
    # Action nodes + DB nodes
    y_positions = [100, 200, 300, 400, 500, 600, 700]
    for i, action in enumerate(VALID_ACTIONS):
        nodes.append(generate_action_node(action, y_positions[i]))
        nodes.append(generate_db_node(action, y_positions[i]))
    
    # Merge
    nodes.append(generate_merge_node())
    
    # Log
    nodes.append(generate_log_node())
    
    # Format Response
    nodes.append(generate_format_response_node())
    
    # Respond
    nodes.append(generate_respond_node())
    
    # Générer les connexions
    connections = generate_connections()
    
    # Créer le workflow complet
    workflow = {
        "name": "iana-rag-document",
        "nodes": nodes,
        "connections": connections,
        "settings": {
            "executionOrder": "v1"
        },
        "tags": [
            {"name": "IANA"},
            {"name": "CRUD"},
            {"name": "RAG"}
        ],
        "active": False
    }
    
    # Sauvegarder
    output_file = "alfa-dashboard/n8n/workflows/iana-rag-document.json"
    with open(output_file, 'w') as f:
        json.dump(workflow, f, indent=2)
    
    print(f"✅ Workflow généré : {output_file}")
    print(f"   - {len(nodes)} nodes")
    print(f"   - {len(VALID_ACTIONS)} actions : {', '.join(VALID_ACTIONS)}")

if __name__ == "__main__":
    main()
