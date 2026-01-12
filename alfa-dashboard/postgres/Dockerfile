# PostgreSQL 16 with pgvector extension
# Base: Official PostgreSQL 16 Alpine image
# Extension: pgvector v0.7.4 for vector similarity search
FROM postgres:16-alpine

LABEL maintainer="ALFA Team"
LABEL description="PostgreSQL 16 with pgvector extension for RAG implementation"
LABEL version="1.0.0"

# pgvector version to install
ARG PGVECTOR_VERSION=0.7.4

# Install build dependencies, compile pgvector, then clean up
# This keeps the final image size small by removing build tools
RUN apk add --no-cache --virtual .build-deps \
        git \
        build-base \
        clang15 \
        llvm15 \
    # Keep runtime dependencies
    && apk add --no-cache \
        clang15 \
        llvm15 \
    # Clone and build pgvector
    && cd /tmp \
    && git clone --branch v${PGVECTOR_VERSION} https://github.com/pgvector/pgvector.git \
    && cd pgvector \
    && make \
    && make install \
    # Cleanup
    && rm -rf /tmp/pgvector \
    && apk del .build-deps

# PostgreSQL port
EXPOSE 5432

# Health check to verify PostgreSQL is ready
HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
    CMD pg_isready -U ${POSTGRES_USER:-postgres}
