-- ========================================
-- ALFA RAG Schema - Vector Search & Embeddings
-- ========================================
-- Requires: pgvector extension (vector v0.8.1+)
-- Purpose: Document ingestion, chunking, and semantic search
-- Created: 2026-01-12
-- ========================================

-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create RAG schema
CREATE SCHEMA IF NOT EXISTS rag;

-- ========================================
-- TABLE: rag.documents
-- ========================================
CREATE TABLE IF NOT EXISTS rag.documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    source_type TEXT DEFAULT 'markdown',
    source_path TEXT,
    source_hash TEXT UNIQUE,
    content_raw TEXT,
    content_length INTEGER,
    metadata JSONB DEFAULT '{}',
    project TEXT DEFAULT 'ALFA',
    category TEXT,
    priority TEXT DEFAULT 'P2',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    indexed_at TIMESTAMPTZ,
    status TEXT DEFAULT 'pending'
);

CREATE INDEX IF NOT EXISTS idx_documents_status ON rag.documents(status);
CREATE INDEX IF NOT EXISTS idx_documents_project ON rag.documents(project);
CREATE INDEX IF NOT EXISTS idx_documents_created_at ON rag.documents(created_at DESC);

-- ========================================
-- TABLE: rag.chunks
-- ========================================
CREATE TABLE IF NOT EXISTS rag.chunks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID REFERENCES rag.documents(id) ON DELETE CASCADE,
    chunk_index INTEGER NOT NULL,
    start_offset INTEGER,
    end_offset INTEGER,
    content TEXT NOT NULL,
    content_length INTEGER NOT NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(document_id, chunk_index)
);

CREATE INDEX IF NOT EXISTS idx_chunks_document_id ON rag.chunks(document_id);
CREATE INDEX IF NOT EXISTS idx_chunks_chunk_index ON rag.chunks(document_id, chunk_index);
CREATE INDEX IF NOT EXISTS idx_chunks_content_fts ON rag.chunks USING GIN(to_tsvector('french', content));

-- ========================================
-- TABLE: rag.embeddings
-- ========================================
CREATE TABLE IF NOT EXISTS rag.embeddings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chunk_id UUID REFERENCES rag.chunks(id) ON DELETE CASCADE,
    embedding vector(1536),
    model TEXT DEFAULT 'text-embedding-ada-002',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(chunk_id, model)
);

-- HNSW index for fast cosine similarity search
CREATE INDEX IF NOT EXISTS idx_embeddings_vector ON rag.embeddings 
    USING hnsw (embedding vector_cosine_ops) WITH (m = 16, ef_construction = 64);
