-- ========================================
-- ALFA RAG Functions - Document Processing & Search
-- ========================================
-- Purpose: Ingest, chunk, embed, and search documents
-- Created: 2026-01-12
-- ========================================

-- ========================================
-- FUNCTION: rag.ingest_document()
-- ========================================
-- Purpose: Ingest a document with deduplication
-- Returns: document UUID
CREATE OR REPLACE FUNCTION rag.ingest_document(
    p_title TEXT,
    p_content TEXT,
    p_source_type TEXT DEFAULT 'markdown',
    p_source_path TEXT DEFAULT NULL,
    p_metadata JSONB DEFAULT '{}'::JSONB,
    p_project TEXT DEFAULT 'ALFA',
    p_category TEXT DEFAULT NULL,
    p_priority TEXT DEFAULT 'P2'
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_hash TEXT;
    v_doc_id UUID;
    v_existing_id UUID;
BEGIN
    -- Generate SHA256 hash for deduplication
    v_hash := encode(digest(p_content, 'sha256'), 'hex');
    
    -- Check if document already exists
    SELECT id INTO v_existing_id
    FROM rag.documents
    WHERE source_hash = v_hash;
    
    IF v_existing_id IS NOT NULL THEN
        -- Update existing document
        UPDATE rag.documents
        SET title = p_title,
            content_raw = p_content,
            content_length = length(p_content),
            metadata = p_metadata,
            updated_at = NOW(),
            status = 'pending'
        WHERE id = v_existing_id;
        
        RETURN v_existing_id;
    ELSE
        -- Insert new document
        INSERT INTO rag.documents (
            title, source_type, source_path, source_hash,
            content_raw, content_length, metadata,
            project, category, priority, status
        )
        VALUES (
            p_title, p_source_type, p_source_path, v_hash,
            p_content, length(p_content), p_metadata,
            p_project, p_category, p_priority, 'pending'
        )
        RETURNING id INTO v_doc_id;
        
        RETURN v_doc_id;
    END IF;
END;
$$;

-- ========================================
-- FUNCTION: rag.chunk_document()
-- ========================================
-- Purpose: Split document into chunks with overlap
-- Returns: number of chunks created
CREATE OR REPLACE FUNCTION rag.chunk_document(
    p_document_id UUID,
    p_chunk_size INTEGER DEFAULT 1000,
    p_overlap INTEGER DEFAULT 200
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_content TEXT;
    v_chunk TEXT;
    v_start_pos INTEGER;
    v_end_pos INTEGER;
    v_chunk_index INTEGER := 0;
    v_chunk_count INTEGER := 0;
BEGIN
    -- Get document content
    SELECT content_raw INTO v_content
    FROM rag.documents
    WHERE id = p_document_id;
    
    IF v_content IS NULL THEN
        RAISE EXCEPTION 'Document % not found', p_document_id;
    END IF;
    
    -- Delete existing chunks
    DELETE FROM rag.chunks WHERE document_id = p_document_id;
    
    -- Split into chunks
    v_start_pos := 1;
    WHILE v_start_pos <= length(v_content) LOOP
        v_end_pos := LEAST(v_start_pos + p_chunk_size - 1, length(v_content));
        v_chunk := substring(v_content FROM v_start_pos FOR p_chunk_size);
        
        -- Insert chunk
        INSERT INTO rag.chunks (
            document_id, chunk_index, start_offset, end_offset,
            content, content_length
        )
        VALUES (
            p_document_id, v_chunk_index, v_start_pos, v_end_pos,
            v_chunk, length(v_chunk)
        );
        
        v_chunk_index := v_chunk_index + 1;
        v_chunk_count := v_chunk_count + 1;
        
        -- Move to next chunk with overlap
        v_start_pos := v_end_pos - p_overlap + 1;
        
        IF v_start_pos >= length(v_content) THEN
            EXIT;
        END IF;
    END LOOP;
    
    -- Update document status
    UPDATE rag.documents
    SET status = 'processing',
        updated_at = NOW()
    WHERE id = p_document_id;
    
    RETURN v_chunk_count;
END;
$$;

-- ========================================
-- FUNCTION: rag.store_embedding()
-- ========================================
-- Purpose: Store vector embedding for a chunk
-- Returns: embedding UUID
CREATE OR REPLACE FUNCTION rag.store_embedding(
    p_chunk_id UUID,
    p_embedding vector(1536),
    p_model TEXT DEFAULT 'text-embedding-ada-002'
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_embedding_id UUID;
BEGIN
    INSERT INTO rag.embeddings (chunk_id, embedding, model)
    VALUES (p_chunk_id, p_embedding, p_model)
    ON CONFLICT (chunk_id, model) DO UPDATE
        SET embedding = EXCLUDED.embedding,
            created_at = NOW()
    RETURNING id INTO v_embedding_id;
    
    -- Update chunk's parent document status
    UPDATE rag.documents d
    SET status = 'indexed',
        indexed_at = NOW(),
        updated_at = NOW()
    FROM rag.chunks c
    WHERE c.id = p_chunk_id
      AND d.id = c.document_id;
    
    RETURN v_embedding_id;
END;
$$;

-- ========================================
-- FUNCTION: rag.search_vector()
-- ========================================
-- Purpose: Vector similarity search using cosine distance
-- Returns: ranked chunks with similarity scores
CREATE OR REPLACE FUNCTION rag.search_vector(
    p_query_embedding vector(1536),
    p_limit INTEGER DEFAULT 10,
    p_threshold FLOAT DEFAULT 0.7
)
RETURNS TABLE (
    chunk_id UUID,
    content TEXT,
    similarity FLOAT,
    document_title TEXT,
    document_id UUID,
    chunk_index INTEGER
)
LANGUAGE sql STABLE
AS $$
    SELECT 
        c.id AS chunk_id,
        c.content,
        1 - (e.embedding <=> p_query_embedding) AS similarity,
        d.title AS document_title,
        d.id AS document_id,
        c.chunk_index
    FROM rag.embeddings e
    JOIN rag.chunks c ON c.id = e.chunk_id
    JOIN rag.documents d ON d.id = c.document_id
    WHERE 1 - (e.embedding <=> p_query_embedding) > p_threshold
    ORDER BY e.embedding <=> p_query_embedding
    LIMIT p_limit;
$$;

-- ========================================
-- FUNCTION: rag.search_fulltext()
-- ========================================
-- Purpose: Full-text search in French
-- Returns: ranked chunks with relevance scores
CREATE OR REPLACE FUNCTION rag.search_fulltext(
    p_query TEXT,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    chunk_id UUID,
    content TEXT,
    rank FLOAT,
    document_title TEXT,
    document_id UUID,
    chunk_index INTEGER
)
LANGUAGE sql STABLE
AS $$
    SELECT 
        c.id AS chunk_id,
        c.content,
        ts_rank(to_tsvector('french', c.content), plainto_tsquery('french', p_query)) AS rank,
        d.title AS document_title,
        d.id AS document_id,
        c.chunk_index
    FROM rag.chunks c
    JOIN rag.documents d ON d.id = c.document_id
    WHERE to_tsvector('french', c.content) @@ plainto_tsquery('french', p_query)
    ORDER BY rank DESC
    LIMIT p_limit;
$$;

-- ========================================
-- FUNCTION: rag.search_hybrid()
-- ========================================
-- Purpose: Hybrid search combining vector + fulltext
-- Returns: ranked chunks with combined scores
CREATE OR REPLACE FUNCTION rag.search_hybrid(
    p_query_embedding vector(1536),
    p_query_text TEXT,
    p_limit INTEGER DEFAULT 10,
    p_vector_weight FLOAT DEFAULT 0.7,
    p_fulltext_weight FLOAT DEFAULT 0.3
)
RETURNS TABLE (
    chunk_id UUID,
    content TEXT,
    combined_score FLOAT,
    vector_similarity FLOAT,
    fulltext_rank FLOAT,
    document_title TEXT,
    document_id UUID,
    chunk_index INTEGER
)
LANGUAGE sql STABLE
AS $$
    WITH vector_results AS (
        SELECT * FROM rag.search_vector(p_query_embedding, p_limit * 2, 0.5)
    ),
    fulltext_results AS (
        SELECT * FROM rag.search_fulltext(p_query_text, p_limit * 2)
    )
    SELECT 
        COALESCE(v.chunk_id, f.chunk_id) AS chunk_id,
        COALESCE(v.content, f.content) AS content,
        (COALESCE(v.similarity, 0) * p_vector_weight + COALESCE(f.rank, 0) * p_fulltext_weight) AS combined_score,
        COALESCE(v.similarity, 0) AS vector_similarity,
        COALESCE(f.rank, 0) AS fulltext_rank,
        COALESCE(v.document_title, f.document_title) AS document_title,
        COALESCE(v.document_id, f.document_id) AS document_id,
        COALESCE(v.chunk_index, f.chunk_index) AS chunk_index
    FROM vector_results v
    FULL OUTER JOIN fulltext_results f ON v.chunk_id = f.chunk_id
    ORDER BY combined_score DESC
    LIMIT p_limit;
$$;
