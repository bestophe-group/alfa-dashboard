-- ========================================
-- ALFA MCP Tool Discovery - Schema & Functions
-- ========================================
-- Purpose: Index and search MCP tools for AI agents
-- Created: 2026-01-12
-- ========================================

-- ========================================
-- TABLE: rag.mcp_servers
-- ========================================
-- Purpose: Store MCP server metadata
CREATE TABLE IF NOT EXISTS rag.mcp_servers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    version TEXT,
    status TEXT DEFAULT 'active',
    config JSONB DEFAULT '{}'::JSONB,
    last_indexed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE rag.mcp_servers IS 'MCP server registry for tool discovery';
COMMENT ON COLUMN rag.mcp_servers.name IS 'Server name (e.g., slack-mcp, github-mcp)';
COMMENT ON COLUMN rag.mcp_servers.status IS 'active, inactive, deprecated';
COMMENT ON COLUMN rag.mcp_servers.config IS 'Server configuration (endpoints, auth, etc.)';

-- ========================================
-- TABLE: rag.mcp_tools
-- ========================================
-- Purpose: Index all MCP tools with metadata
CREATE TABLE IF NOT EXISTS rag.mcp_tools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    server_id UUID NOT NULL REFERENCES rag.mcp_servers(id) ON DELETE CASCADE,
    tool_name TEXT NOT NULL,
    description_short TEXT,
    description_full TEXT,
    category TEXT,
    parameters JSONB DEFAULT '{}'::JSONB,
    examples JSONB DEFAULT '[]'::JSONB,
    usage_count INTEGER DEFAULT 0,
    last_used_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(server_id, tool_name)
);

COMMENT ON TABLE rag.mcp_tools IS 'MCP tools index for semantic search';
COMMENT ON COLUMN rag.mcp_tools.tool_name IS 'Tool function name (e.g., send_message, create_issue)';
COMMENT ON COLUMN rag.mcp_tools.description_short IS '1-line description for search';
COMMENT ON COLUMN rag.mcp_tools.description_full IS 'Complete documentation';
COMMENT ON COLUMN rag.mcp_tools.category IS 'Tool category (messaging, github, database, etc.)';
COMMENT ON COLUMN rag.mcp_tools.parameters IS 'JSON schema of tool parameters';
COMMENT ON COLUMN rag.mcp_tools.examples IS 'Usage examples as JSON array';
COMMENT ON COLUMN rag.mcp_tools.usage_count IS 'How many times tool was used';

-- ========================================
-- INDEXES: Performance optimization
-- ========================================

-- B-tree index on server_id for joins
CREATE INDEX IF NOT EXISTS idx_mcp_tools_server_id
ON rag.mcp_tools(server_id);

-- B-tree index on category for filtering
CREATE INDEX IF NOT EXISTS idx_mcp_tools_category
ON rag.mcp_tools(category) WHERE category IS NOT NULL;

-- B-tree index on usage_count for ranking
CREATE INDEX IF NOT EXISTS idx_mcp_tools_usage_count
ON rag.mcp_tools(usage_count DESC);

-- GIN index for full-text search on descriptions
CREATE INDEX IF NOT EXISTS idx_mcp_tools_description_fts
ON rag.mcp_tools USING GIN (to_tsvector('english', COALESCE(description_short, '') || ' ' || COALESCE(description_full, '')));

-- GIN index for tool_name search
CREATE INDEX IF NOT EXISTS idx_mcp_tools_name_fts
ON rag.mcp_tools USING GIN (to_tsvector('english', tool_name));

COMMENT ON INDEX idx_mcp_tools_description_fts IS 'Full-text search on tool descriptions';
COMMENT ON INDEX idx_mcp_tools_name_fts IS 'Full-text search on tool names';
