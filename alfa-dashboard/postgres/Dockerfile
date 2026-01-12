# PostgreSQL 16 with pgvector extension
# Using official pgvector image (Debian-based, pre-compiled)
FROM pgvector/pgvector:pg16

LABEL maintainer="ALFA Team"
LABEL description="PostgreSQL 16 with pgvector extension for RAG implementation"
LABEL version="1.0.0"

# Health check to verify PostgreSQL is ready
HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
    CMD pg_isready -U ${POSTGRES_USER:-postgres}
