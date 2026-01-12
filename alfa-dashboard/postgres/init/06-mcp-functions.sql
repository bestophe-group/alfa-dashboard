-- ========================================
-- ALFA MCP Tool Discovery - Search Functions
-- ========================================
-- Purpose: Functions to index and search MCP tools
-- Created: 2026-01-12
-- ========================================

-- ========================================
-- FUNCTION: rag.index_mcp_server()
-- ========================================
-- Purpose: Add or update MCP server in registry
-- Returns: server UUID
CREATE OR REPLACE FUNCTION rag.index_mcp_server(
    p_name TEXT,
    p_description TEXT DEFAULT NULL,
    p_version TEXT DEFAULT NULL,
    p_config JSONB DEFAULT '{}'::JSONB
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_server_id UUID;
BEGIN
    INSERT INTO rag.mcp_servers (name, description, version, config, last_indexed_at)
    VALUES (p_name, p_description, p_version, p_config, NOW())
    ON CONFLICT (name) DO UPDATE
        SET description = COALESCE(EXCLUDED.description, rag.mcp_servers.description),
            version = COALESCE(EXCLUDED.version, rag.mcp_servers.version),
            config = EXCLUDED.config,
            last_indexed_at = NOW(),
            updated_at = NOW()
    RETURNING id INTO v_server_id;

    RETURN v_server_id;
END;
$$;

COMMENT ON FUNCTION rag.index_mcp_server IS 'Add or update MCP server in registry';

-- ========================================
-- FUNCTION: rag.index_mcp_tool()
-- ========================================
-- Purpose: Add or update MCP tool in index
-- Returns: tool UUID
CREATE OR REPLACE FUNCTION rag.index_mcp_tool(
    p_server_name TEXT,
    p_tool_name TEXT,
    p_description_short TEXT DEFAULT NULL,
    p_description_full TEXT DEFAULT NULL,
    p_category TEXT DEFAULT NULL,
    p_parameters JSONB DEFAULT '{}'::JSONB,
    p_examples JSONB DEFAULT '[]'::JSONB
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_server_id UUID;
    v_tool_id UUID;
BEGIN
    -- Get server_id
    SELECT id INTO v_server_id
    FROM rag.mcp_servers
    WHERE name = p_server_name;

    IF v_server_id IS NULL THEN
        RAISE EXCEPTION 'Server % not found. Index server first.', p_server_name;
    END IF;

    -- Insert or update tool
    INSERT INTO rag.mcp_tools (
        server_id, tool_name, description_short, description_full,
        category, parameters, examples
    )
    VALUES (
        v_server_id, p_tool_name, p_description_short, p_description_full,
        p_category, p_parameters, p_examples
    )
    ON CONFLICT (server_id, tool_name) DO UPDATE
        SET description_short = COALESCE(EXCLUDED.description_short, rag.mcp_tools.description_short),
            description_full = COALESCE(EXCLUDED.description_full, rag.mcp_tools.description_full),
            category = COALESCE(EXCLUDED.category, rag.mcp_tools.category),
            parameters = EXCLUDED.parameters,
            examples = EXCLUDED.examples,
            updated_at = NOW()
    RETURNING id INTO v_tool_id;

    RETURN v_tool_id;
END;
$$;

COMMENT ON FUNCTION rag.index_mcp_tool IS 'Add or update MCP tool in index';

-- ========================================
-- FUNCTION: rag.search_mcp_tools()
-- ========================================
-- Purpose: Full-text search for MCP tools
-- Returns: tools ranked by relevance
CREATE OR REPLACE FUNCTION rag.search_mcp_tools(
    p_query TEXT,
    p_limit INTEGER DEFAULT 10,
    p_category TEXT DEFAULT NULL
)
RETURNS TABLE (
    tool_id UUID,
    server_name TEXT,
    tool_name TEXT,
    description_short TEXT,
    category TEXT,
    parameters JSONB,
    examples JSONB,
    usage_count INTEGER,
    relevance_score FLOAT
)
LANGUAGE sql STABLE
AS $$
    SELECT
        t.id AS tool_id,
        s.name AS server_name,
        t.tool_name,
        t.description_short,
        t.category,
        t.parameters,
        t.examples,
        t.usage_count,
        ts_rank(
            to_tsvector('english',
                COALESCE(t.tool_name, '') || ' ' ||
                COALESCE(t.description_short, '') || ' ' ||
                COALESCE(t.description_full, '')
            ),
            plainto_tsquery('english', p_query)
        ) AS relevance_score
    FROM rag.mcp_tools t
    JOIN rag.mcp_servers s ON s.id = t.server_id
    WHERE to_tsvector('english',
            COALESCE(t.tool_name, '') || ' ' ||
            COALESCE(t.description_short, '') || ' ' ||
            COALESCE(t.description_full, '')
        ) @@ plainto_tsquery('english', p_query)
      AND (p_category IS NULL OR t.category = p_category)
      AND s.status = 'active'
    ORDER BY relevance_score DESC, t.usage_count DESC
    LIMIT p_limit;
$$;

COMMENT ON FUNCTION rag.search_mcp_tools IS 'Full-text search for MCP tools with relevance ranking';

-- ========================================
-- FUNCTION: rag.search_mcp_tools_simple()
-- ========================================
-- Purpose: Simplified search for AI agents
-- Returns: top tools with server context
CREATE OR REPLACE FUNCTION rag.search_mcp_tools_simple(
    p_query TEXT,
    p_limit INTEGER DEFAULT 5
)
RETURNS TABLE (
    server_name TEXT,
    tool_name TEXT,
    description_short TEXT,
    score FLOAT
)
LANGUAGE sql STABLE
AS $$
    SELECT
        s.name AS server_name,
        t.tool_name,
        t.description_short,
        ts_rank(
            to_tsvector('english',
                COALESCE(t.tool_name, '') || ' ' ||
                COALESCE(t.description_short, '') || ' ' ||
                COALESCE(t.description_full, '')
            ),
            plainto_tsquery('english', p_query)
        ) AS score
    FROM rag.mcp_tools t
    JOIN rag.mcp_servers s ON s.id = t.server_id
    WHERE to_tsvector('english',
            COALESCE(t.tool_name, '') || ' ' ||
            COALESCE(t.description_short, '') || ' ' ||
            COALESCE(t.description_full, '')
        ) @@ plainto_tsquery('english', p_query)
      AND s.status = 'active'
    ORDER BY score DESC, t.usage_count DESC
    LIMIT p_limit;
$$;

COMMENT ON FUNCTION rag.search_mcp_tools_simple IS 'Simplified search for AI agents - returns top tools only';

-- ========================================
-- FUNCTION: rag.list_mcp_servers()
-- ========================================
-- Purpose: List all registered MCP servers
-- Returns: server summary
CREATE OR REPLACE FUNCTION rag.list_mcp_servers()
RETURNS TABLE (
    server_id UUID,
    name TEXT,
    description TEXT,
    version TEXT,
    status TEXT,
    tool_count BIGINT,
    last_indexed_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE sql STABLE
AS $$
    SELECT
        s.id AS server_id,
        s.name,
        s.description,
        s.version,
        s.status,
        COUNT(t.id) AS tool_count,
        s.last_indexed_at
    FROM rag.mcp_servers s
    LEFT JOIN rag.mcp_tools t ON t.server_id = s.id
    GROUP BY s.id
    ORDER BY s.name;
$$;

COMMENT ON FUNCTION rag.list_mcp_servers IS 'List all MCP servers with tool counts';

-- ========================================
-- FUNCTION: rag.get_mcp_tool_details()
-- ========================================
-- Purpose: Get full details for a specific tool
-- Returns: complete tool information
CREATE OR REPLACE FUNCTION rag.get_mcp_tool_details(
    p_server_name TEXT,
    p_tool_name TEXT
)
RETURNS TABLE (
    server_name TEXT,
    tool_name TEXT,
    description_short TEXT,
    description_full TEXT,
    category TEXT,
    parameters JSONB,
    examples JSONB,
    usage_count INTEGER,
    last_used_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE sql STABLE
AS $$
    SELECT
        s.name AS server_name,
        t.tool_name,
        t.description_short,
        t.description_full,
        t.category,
        t.parameters,
        t.examples,
        t.usage_count,
        t.last_used_at,
        t.created_at
    FROM rag.mcp_tools t
    JOIN rag.mcp_servers s ON s.id = t.server_id
    WHERE s.name = p_server_name
      AND t.tool_name = p_tool_name;
$$;

COMMENT ON FUNCTION rag.get_mcp_tool_details IS 'Get complete information for a specific tool';

-- ========================================
-- FUNCTION: rag.increment_tool_usage()
-- ========================================
-- Purpose: Track tool usage for ranking
-- Returns: new usage count
CREATE OR REPLACE FUNCTION rag.increment_tool_usage(
    p_server_name TEXT,
    p_tool_name TEXT
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_count INTEGER;
BEGIN
    UPDATE rag.mcp_tools t
    SET usage_count = usage_count + 1,
        last_used_at = NOW()
    FROM rag.mcp_servers s
    WHERE t.server_id = s.id
      AND s.name = p_server_name
      AND t.tool_name = p_tool_name
    RETURNING t.usage_count INTO v_new_count;

    RETURN v_new_count;
END;
$$;

COMMENT ON FUNCTION rag.increment_tool_usage IS 'Increment usage counter for tool ranking';
