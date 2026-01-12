# RAG Knowledge Base - ALFA

> Semantic search and document retrieval using PostgreSQL + pgvector

## Table of Contents

1. [Architecture](#architecture)
2. [Database Schema](#database-schema)
3. [Functions](#functions)
4. [Usage Examples](#usage-examples)
5. [Integration with n8n](#integration-with-n8n)
6. [Maintenance](#maintenance)
7. [Performance](#performance)

---

## Architecture

The RAG (Retrieval-Augmented Generation) system is built on PostgreSQL 16 with the pgvector extension, providing hybrid search capabilities combining vector similarity and full-text search.

### Components

```
┌─────────────────────────────────────────────────────────┐
│                    Application Layer                     │
│              (n8n, API, Custom Scripts)                  │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│                PostgreSQL + pgvector                     │
├─────────────────────────────────────────────────────────┤
│  rag.documents     │  Source documents with metadata    │
│  rag.chunks        │  Text chunks (1000 chars + overlap)│
│  rag.embeddings    │  1536-D vectors (OpenAI format)    │
├─────────────────────────────────────────────────────────┤
│  Indexes:                                               │
│  - HNSW (vector similarity)                             │
│  - GIN (French full-text)                               │
│  - B-tree (metadata)                                    │
└─────────────────────────────────────────────────────────┘
```

### Key Features

- **Deduplication** - SHA256 hashing prevents duplicate documents
- **Smart Chunking** - Configurable size with overlap for context preservation
- **Hybrid Search** - Combines semantic + keyword matching
- **French Language** - Optimized full-text search for French
- **Metadata** - JSONB fields for flexible document properties
- **Fast Search** - HNSW index for sub-linear search time

---

## Database Schema

### Tables

#### rag.documents

Stores source documents with metadata.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key (auto-generated) |
| `title` | TEXT | Document title |
| `source_type` | TEXT | Type: markdown, pdf, html, txt, code |
| `source_path` | TEXT | Original file path |
| `source_hash` | TEXT | SHA256 hash for deduplication |
| `content_raw` | TEXT | Full document content |
| `content_length` | INTEGER | Character count |
| `metadata` | JSONB | Custom metadata |
| `project` | TEXT | Project name (default: 'ALFA') |
| `category` | TEXT | Document category |
| `priority` | TEXT | Priority: P0, P1, P2, P3 |
| `created_at` | TIMESTAMPTZ | Creation timestamp |
| `updated_at` | TIMESTAMPTZ | Last update timestamp |
| `indexed_at` | TIMESTAMPTZ | When embeddings were created |
| `status` | TEXT | Status: pending, processing, indexed, failed |

**Indexes**:
- Primary key on `id`
- Unique constraint on `source_hash`
- B-tree on `status`, `project`, `created_at`

#### rag.chunks

Text chunks with overlapping context.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key (auto-generated) |
| `document_id` | UUID | Foreign key to documents |
| `chunk_index` | INTEGER | Order within document (0-based) |
| `start_offset` | INTEGER | Character offset in source |
| `end_offset` | INTEGER | End character offset |
| `content` | TEXT | Chunk text content |
| `content_length` | INTEGER | Character count |
| `metadata` | JSONB | Custom metadata |
| `created_at` | TIMESTAMPTZ | Creation timestamp |

**Indexes**:
- Primary key on `id`
- Unique on `(document_id, chunk_index)`
- B-tree on `document_id`
- GIN full-text on `to_tsvector('french', content)`

#### rag.embeddings

Vector embeddings for semantic search.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key (auto-generated) |
| `chunk_id` | UUID | Foreign key to chunks |
| `embedding` | vector(1536) | 1536-dimensional vector |
| `model` | TEXT | Model name (default: text-embedding-ada-002) |
| `created_at` | TIMESTAMPTZ | Creation timestamp |

**Indexes**:
- Primary key on `id`
- Unique on `(chunk_id, model)`
- HNSW on `embedding` (m=16, ef_construction=64)

---

## Functions

### rag.ingest_document()

Ingest a document with automatic deduplication.

**Signature**:
```sql
rag.ingest_document(
    p_title TEXT,
    p_content TEXT,
    p_source_type TEXT DEFAULT 'markdown',
    p_source_path TEXT DEFAULT NULL,
    p_metadata JSONB DEFAULT '{}'::JSONB,
    p_project TEXT DEFAULT 'ALFA',
    p_category TEXT DEFAULT NULL,
    p_priority TEXT DEFAULT 'P2'
) RETURNS UUID
```

**Example**:
```sql
SELECT rag.ingest_document(
    'ALFA Methodology Guide',
    'The ALFA Method follows 5 phases: INTAKE, AUDIT, PLAN, BUILD, PROVE...',
    'markdown',
    '/docs/01-METHODE-ALFA.md',
    '{"author": "Team ALFA", "version": "2.0"}'::jsonb,
    'ALFA',
    'methodology',
    'P1'
);
```

**Returns**: Document UUID (existing or new)

**Behavior**:
- Generates SHA256 hash of content
- If hash exists: updates existing document
- If hash is new: creates new document
- Status is set to 'pending'

---

### rag.chunk_document()

Split document into chunks with overlap.

**Signature**:
```sql
rag.chunk_document(
    p_document_id UUID,
    p_chunk_size INTEGER DEFAULT 1000,
    p_overlap INTEGER DEFAULT 200
) RETURNS INTEGER
```

**Example**:
```sql
-- Chunk with default settings (1000 chars, 200 overlap)
SELECT rag.chunk_document('53386ef4-708f-430d-a9e0-ae2ed7538c53');

-- Custom chunk size
SELECT rag.chunk_document(
    '53386ef4-708f-430d-a9e0-ae2ed7538c53',
    1500,  -- 1500 character chunks
    300    -- 300 character overlap
);
```

**Returns**: Number of chunks created

**Behavior**:
- Deletes existing chunks for the document
- Splits content into chunks of `p_chunk_size` characters
- Adds `p_overlap` characters from previous chunk for context
- Updates document status to 'processing'

---

### rag.store_embedding()

Store vector embedding for a chunk.

**Signature**:
```sql
rag.store_embedding(
    p_chunk_id UUID,
    p_embedding vector(1536),
    p_model TEXT DEFAULT 'text-embedding-ada-002'
) RETURNS UUID
```

**Example**:
```sql
-- Store embedding (vector from OpenAI API)
SELECT rag.store_embedding(
    'chunk-uuid-here',
    '[0.123, -0.456, 0.789, ...]'::vector(1536),
    'text-embedding-ada-002'
);
```

**Returns**: Embedding UUID

**Behavior**:
- Inserts or updates embedding for chunk
- Updates parent document status to 'indexed'
- Sets `indexed_at` timestamp

---

### rag.search_vector()

Semantic search using cosine similarity.

**Signature**:
```sql
rag.search_vector(
    p_query_embedding vector(1536),
    p_limit INTEGER DEFAULT 10,
    p_threshold FLOAT DEFAULT 0.7
) RETURNS TABLE (
    chunk_id UUID,
    content TEXT,
    similarity FLOAT,
    document_title TEXT,
    document_id UUID,
    chunk_index INTEGER
)
```

**Example**:
```sql
-- Search for chunks similar to query
SELECT * FROM rag.search_vector(
    '[0.234, -0.567, ...]'::vector(1536),  -- Query embedding
    5,     -- Top 5 results
    0.8    -- Minimum 80% similarity
);
```

**Returns**: Ranked chunks with similarity scores (0-1)

**Performance**: Uses HNSW index for fast approximate search

---

### rag.search_fulltext()

Keyword search in French.

**Signature**:
```sql
rag.search_fulltext(
    p_query TEXT,
    p_limit INTEGER DEFAULT 10
) RETURNS TABLE (
    chunk_id UUID,
    content TEXT,
    rank FLOAT,
    document_title TEXT,
    document_id UUID,
    chunk_index INTEGER
)
```

**Example**:
```sql
-- Search for French keywords
SELECT * FROM rag.search_fulltext(
    'méthode agile développement',
    10
);
```

**Returns**: Ranked chunks by relevance

**Features**:
- French stemming and stop words
- Phrase matching
- Ranked by relevance (ts_rank)

---

### rag.search_hybrid()

Combined vector + fulltext search.

**Signature**:
```sql
rag.search_hybrid(
    p_query_embedding vector(1536),
    p_query_text TEXT,
    p_limit INTEGER DEFAULT 10,
    p_vector_weight FLOAT DEFAULT 0.7,
    p_fulltext_weight FLOAT DEFAULT 0.3
) RETURNS TABLE (
    chunk_id UUID,
    content TEXT,
    combined_score FLOAT,
    vector_similarity FLOAT,
    fulltext_rank FLOAT,
    document_title TEXT,
    document_id UUID,
    chunk_index INTEGER
)
```

**Example**:
```sql
-- Best of both worlds
SELECT * FROM rag.search_hybrid(
    '[0.234, -0.567, ...]'::vector(1536),  -- Query embedding
    'méthode ALFA développement',          -- Query keywords
    10,    -- Top 10 results
    0.7,   -- 70% weight to vector search
    0.3    -- 30% weight to fulltext
);
```

**Returns**: Ranked chunks by combined score

**Use Case**: Best for queries that benefit from both semantic understanding and keyword matching

---

## Usage Examples

### Complete Workflow

```sql
-- 1. Ingest document
SELECT rag.ingest_document(
    'Getting Started with ALFA',
    'The ALFA Method is a systematic approach...',
    'markdown',
    '/docs/quickstart.md'
) AS doc_id \gset

-- 2. Chunk the document
SELECT rag.chunk_document(:'doc_id', 1000, 200);

-- 3. Get chunks to embed
SELECT id, content 
FROM rag.chunks 
WHERE document_id = :'doc_id'
ORDER BY chunk_index;

-- 4. (Outside SQL) Generate embeddings via OpenAI API
-- 5. Store embeddings
SELECT rag.store_embedding(
    'chunk-id-1',
    '[embedding-vector-here]'::vector(1536)
);

-- 6. Search
SELECT * FROM rag.search_hybrid(
    '[query-embedding]'::vector(1536),
    'getting started',
    5
);
```

### Bulk Operations

```sql
-- Ingest multiple documents
DO $$
DECLARE
    doc_id UUID;
BEGIN
    -- Document 1
    SELECT rag.ingest_document(
        'Doc 1', 'Content 1...', 'markdown'
    ) INTO doc_id;
    PERFORM rag.chunk_document(doc_id);
    
    -- Document 2
    SELECT rag.ingest_document(
        'Doc 2', 'Content 2...', 'markdown'
    ) INTO doc_id;
    PERFORM rag.chunk_document(doc_id);
END $$;
```

### Monitoring

```sql
-- Check document status
SELECT 
    status, 
    COUNT(*) as count,
    SUM(content_length) as total_chars
FROM rag.documents
GROUP BY status;

-- View recent documents
SELECT 
    title, 
    status, 
    created_at,
    content_length
FROM rag.documents
ORDER BY created_at DESC
LIMIT 10;

-- Chunks per document
SELECT 
    d.title,
    COUNT(c.id) as chunk_count,
    SUM(c.content_length) as total_chunk_chars
FROM rag.documents d
LEFT JOIN rag.chunks c ON c.document_id = d.id
GROUP BY d.id, d.title
ORDER BY chunk_count DESC;
```

---

## Integration with n8n

### Workflow Example

Create an n8n workflow for document ingestion:

1. **HTTP Trigger** - Webhook endpoint `/api/rag/ingest`
2. **PostgreSQL Node** - Call `rag.ingest_document()`
3. **PostgreSQL Node** - Call `rag.chunk_document()`
4. **Loop Over Chunks** - For each chunk:
   - **OpenAI Node** - Generate embedding
   - **PostgreSQL Node** - Call `rag.store_embedding()`
5. **Response** - Return success

### Search Workflow

1. **HTTP Trigger** - Webhook endpoint `/api/rag/search`
2. **OpenAI Node** - Generate query embedding
3. **PostgreSQL Node** - Call `rag.search_hybrid()`
4. **Format Response** - Return JSON results

---

## Maintenance

### Backup

```bash
# Backup RAG schema only
docker exec alfa-postgres pg_dump -U alfa -d alfa -n rag > rag_backup.sql

# Restore
docker exec -i alfa-postgres psql -U alfa -d alfa < rag_backup.sql
```

### Vacuum & Analyze

```sql
-- Update statistics
ANALYZE rag.documents;
ANALYZE rag.chunks;
ANALYZE rag.embeddings;

-- Reclaim space
VACUUM FULL rag.embeddings;
```

### Reindex

```sql
-- Rebuild HNSW index
REINDEX INDEX rag.idx_embeddings_vector;

-- Rebuild GIN index
REINDEX INDEX rag.idx_chunks_content_fts;
```

---

## Performance

### Index Tuning

**HNSW Parameters**:
- `m=16` - Number of connections per node (higher = better recall, more memory)
- `ef_construction=64` - Quality during build (higher = better index, slower build)

**Query-time parameter**:
```sql
-- Increase search quality (slower but more accurate)
SET hnsw.ef_search = 100;

-- Default is 40
SET hnsw.ef_search = 40;
```

### Query Optimization

```sql
-- Use EXPLAIN ANALYZE to check query performance
EXPLAIN ANALYZE
SELECT * FROM rag.search_vector(
    '[...]'::vector(1536),
    10,
    0.7
);
```

### Expected Performance

| Operation | Time (approximate) |
|-----------|-------------------|
| Ingest 1 document | < 10ms |
| Chunk 1000-char document | < 50ms |
| Vector search (HNSW) | < 100ms |
| Fulltext search | < 50ms |
| Hybrid search | < 150ms |

**Dataset Size**:
- 10,000 documents = ~50 MB
- 100,000 chunks = ~500 MB
- 100,000 embeddings = ~600 MB (1536-D vectors)

---

## Troubleshooting

### Extension Not Available

```sql
-- Check if vector extension is installed
SELECT * FROM pg_available_extensions WHERE name = 'vector';

-- If missing, rebuild PostgreSQL with pgvector
```

### Slow Searches

```sql
-- Check if HNSW index exists
SELECT indexname FROM pg_indexes WHERE tablename = 'embeddings';

-- Rebuild index
REINDEX INDEX rag.idx_embeddings_vector;

-- Increase ef_search for better recall
SET hnsw.ef_search = 100;
```

### High Memory Usage

```sql
-- Check index sizes
SELECT 
    schemaname, 
    tablename, 
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_indexes 
WHERE schemaname = 'rag'
ORDER BY pg_relation_size(indexrelid) DESC;
```

---

## References

- [pgvector Documentation](https://github.com/pgvector/pgvector)
- [PostgreSQL Full-Text Search](https://www.postgresql.org/docs/current/textsearch.html)
- [OpenAI Embeddings API](https://platform.openai.com/docs/guides/embeddings)
- [HNSW Algorithm](https://arxiv.org/abs/1603.09320)

---

**Last Updated**: 2026-01-12  
**Version**: 1.0.0  
**Author**: ALFA Team
