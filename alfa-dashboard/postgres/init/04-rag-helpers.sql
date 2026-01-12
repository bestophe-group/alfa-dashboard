-- ========================================
-- ALFA RAG Helpers - AI Agent Functions
-- ========================================
-- Purpose: Simplified search functions for AI agents
-- Created: 2026-01-12
-- ========================================

-- ========================================
-- FUNCTION: rag.search_alfa()
-- ========================================
-- Purpose: One-stop search function for ALFA agents
-- Combines fulltext search with metadata filtering
-- Returns: chunks with document context
CREATE OR REPLACE FUNCTION rag.search_alfa(
    p_question TEXT,
    p_limit INTEGER DEFAULT 10,
    p_category TEXT DEFAULT NULL,
    p_priority TEXT DEFAULT NULL
)
RETURNS TABLE (
    chunk_id UUID,
    chunk_content TEXT,
    relevance_score FLOAT,
    document_title TEXT,
    document_id UUID,
    document_category TEXT,
    document_priority TEXT,
    source_path TEXT,
    chunk_index INTEGER
)
LANGUAGE sql STABLE
AS $$
    SELECT
        c.id AS chunk_id,
        c.content AS chunk_content,
        ts_rank(to_tsvector('french', c.content), plainto_tsquery('french', p_question)) AS relevance_score,
        d.title AS document_title,
        d.id AS document_id,
        d.category AS document_category,
        d.priority AS document_priority,
        d.source_path,
        c.chunk_index
    FROM rag.chunks c
    JOIN rag.documents d ON d.id = c.document_id
    WHERE to_tsvector('french', c.content) @@ plainto_tsquery('french', p_question)
      AND (p_category IS NULL OR d.category = p_category)
      AND (p_priority IS NULL OR d.priority = p_priority)
    ORDER BY relevance_score DESC
    LIMIT p_limit;
$$;

COMMENT ON FUNCTION rag.search_alfa IS 'Simplified search for AI agents - fulltext search with optional category/priority filters';

-- ========================================
-- FUNCTION: rag.get_document_by_title()
-- ========================================
-- Purpose: Find documents by title pattern
-- Returns: document metadata
CREATE OR REPLACE FUNCTION rag.get_document_by_title(
    p_pattern TEXT
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    category TEXT,
    priority TEXT,
    source_path TEXT,
    content_length INTEGER,
    chunk_count BIGINT,
    status TEXT,
    created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE sql STABLE
AS $$
    SELECT
        d.id,
        d.title,
        d.category,
        d.priority,
        d.source_path,
        d.content_length,
        COUNT(c.id) AS chunk_count,
        d.status,
        d.created_at
    FROM rag.documents d
    LEFT JOIN rag.chunks c ON c.document_id = d.id
    WHERE d.title ILIKE '%' || p_pattern || '%'
    GROUP BY d.id
    ORDER BY d.created_at DESC;
$$;

COMMENT ON FUNCTION rag.get_document_by_title IS 'Find documents by title pattern (case-insensitive)';

-- ========================================
-- FUNCTION: rag.get_document_chunks()
-- ========================================
-- Purpose: Retrieve all chunks from a specific document
-- Returns: ordered chunks with metadata
CREATE OR REPLACE FUNCTION rag.get_document_chunks(
    p_document_id UUID
)
RETURNS TABLE (
    chunk_id UUID,
    chunk_index INTEGER,
    content TEXT,
    content_length INTEGER,
    has_embedding BOOLEAN
)
LANGUAGE sql STABLE
AS $$
    SELECT
        c.id AS chunk_id,
        c.chunk_index,
        c.content,
        c.content_length,
        EXISTS(SELECT 1 FROM rag.embeddings e WHERE e.chunk_id = c.id) AS has_embedding
    FROM rag.chunks c
    WHERE c.document_id = p_document_id
    ORDER BY c.chunk_index;
$$;

COMMENT ON FUNCTION rag.get_document_chunks IS 'Retrieve all chunks from a specific document, ordered by index';

-- ========================================
-- FUNCTION: rag.stats()
-- ========================================
-- Purpose: RAG system statistics
-- Returns: counts and sizes
CREATE OR REPLACE FUNCTION rag.stats()
RETURNS TABLE (
    total_documents BIGINT,
    total_chunks BIGINT,
    total_embeddings BIGINT,
    total_content_kb BIGINT,
    documents_by_category JSONB,
    documents_by_priority JSONB,
    documents_by_status JSONB
)
LANGUAGE sql STABLE
AS $$
    SELECT
        (SELECT COUNT(*) FROM rag.documents) AS total_documents,
        (SELECT COUNT(*) FROM rag.chunks) AS total_chunks,
        (SELECT COUNT(*) FROM rag.embeddings) AS total_embeddings,
        (SELECT COALESCE(SUM(content_length), 0) / 1024 FROM rag.documents) AS total_content_kb,
        (SELECT jsonb_object_agg(category, count)
         FROM (SELECT COALESCE(category, 'uncategorized') as category, COUNT(*) as count
               FROM rag.documents GROUP BY category) cat) AS documents_by_category,
        (SELECT jsonb_object_agg(priority, count)
         FROM (SELECT COALESCE(priority, 'unset') as priority, COUNT(*) as count
               FROM rag.documents GROUP BY priority) pri) AS documents_by_priority,
        (SELECT jsonb_object_agg(status, count)
         FROM (SELECT status, COUNT(*) as count
               FROM rag.documents GROUP BY status) st) AS documents_by_status;
$$;

COMMENT ON FUNCTION rag.stats IS 'RAG system statistics - documents, chunks, embeddings counts and breakdown by category/priority/status';

-- ========================================
-- FUNCTION: rag.recent_documents()
-- ========================================
-- Purpose: List recently ingested/updated documents
-- Returns: recent documents with metadata
CREATE OR REPLACE FUNCTION rag.recent_documents(
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    category TEXT,
    priority TEXT,
    status TEXT,
    content_length INTEGER,
    chunk_count BIGINT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE sql STABLE
AS $$
    SELECT
        d.id,
        d.title,
        d.category,
        d.priority,
        d.status,
        d.content_length,
        COUNT(c.id) AS chunk_count,
        d.created_at,
        d.updated_at
    FROM rag.documents d
    LEFT JOIN rag.chunks c ON c.document_id = d.id
    GROUP BY d.id
    ORDER BY d.updated_at DESC
    LIMIT p_limit;
$$;

COMMENT ON FUNCTION rag.recent_documents IS 'List recently ingested or updated documents';

-- ========================================
-- INDEX: Optimize search_alfa performance
-- ========================================
-- Create index on category + priority for filtered searches
CREATE INDEX IF NOT EXISTS idx_documents_category_priority
ON rag.documents(category, priority)
WHERE category IS NOT NULL AND priority IS NOT NULL;

COMMENT ON INDEX idx_documents_category_priority IS 'Optimize filtered searches by category and priority';

-- ========================================
-- USAGE EXAMPLES (for documentation)
-- ========================================
/*

-- Search for ALFA methodology documentation
SELECT * FROM rag.search_alfa('méthode ALFA phases', 5);

-- Search only in MCP category
SELECT * FROM rag.search_alfa('outils GitHub', 10, 'mcp', NULL);

-- Search P1 priority documents
SELECT * FROM rag.search_alfa('monitoring Grafana', 5, NULL, 'P1');

-- Find document by title
SELECT * FROM rag.get_document_by_title('MCP Gateway');

-- Get all chunks from a document
SELECT * FROM rag.get_document_chunks('ae5e70cf-eb7d-435e-867c-cfff4c7379f6');

-- View RAG statistics
SELECT * FROM rag.stats();

-- List recent documents
SELECT * FROM rag.recent_documents(10);

*/
