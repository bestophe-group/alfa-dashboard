# Changelog

All notable changes to ALFA Dashboard will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2026-01-12

### Added
- **MCP Gateway Documentation** - Complete guide for AI agents
  - [docs/MCP-GATEWAY.md](../docs/MCP-GATEWAY.md) - Comprehensive reference (922 lines)
    - 125 tools across 10 categories documented
    - 5 complete workflow examples (debugging, development, data analysis, monitoring, browser testing)
    - Troubleshooting guide with 8 common errors
    - Quick reference table by use case
  - [docs/MCP-QUICKSTART.md](../docs/MCP-QUICKSTART.md) - Quick start guide (220 lines)
    - Top 10 essential tools with examples
    - 3 complete workflows
    - Common errors and solutions
    - Quick reference table
  - README.md updated with MCP Gateway section
    - 10 tool categories overview
    - Key capabilities summary
    - Example usage
    - Links to documentation

### Documentation
- **MCP Tool Categories**:
  - Browser Automation (20 tools) - Playwright-based web testing & scraping
  - GitHub Integration (30 tools) - Issues, PRs, commits, code search
  - Grafana & Dashboards (15 tools) - Monitoring, alerts, visualization
  - Prometheus (5 tools) - Metrics queries and exploration
  - Loki (4 tools) - Log search and analysis
  - Desktop Commander (25 tools) - File operations, REPL, PDF generation
  - Incidents & OnCall (10 tools) - Incident management, on-call schedules
  - Pyroscope & Sift (6 tools) - Performance profiling, automated investigations
  - Code Intelligence (2 tools) - Library documentation lookup
  - MCP Management (6 tools) - Dynamic server discovery & configuration

### Technical Details
- Container: docker/mcp-gateway (running)
- Protocol: Model Context Protocol (MCP)
- Tool prefix: `mcp__MCP_DOCKER__`
- Total documented tools: 125
- Documentation size: ~1,140 lines

## [1.1.0] - 2026-01-12

### Added
- **RAG Knowledge Base** - Vector database for semantic search
  - PostgreSQL pgvector extension (v0.8.1)
  - RAG schema with 3 tables: documents, chunks, embeddings
  - 6 SQL functions for document ingestion and search:
    - `rag.ingest_document()` - Document ingestion with SHA256 deduplication
    - `rag.chunk_document()` - Smart text chunking with overlap
    - `rag.store_embedding()` - Store 1536-dimensional vectors
    - `rag.search_vector()` - Semantic search using cosine similarity
    - `rag.search_fulltext()` - Keyword search in French
    - `rag.search_hybrid()` - Combined vector + fulltext (70/30 weighting)
  - HNSW index for fast vector similarity search (m=16, ef_construction=64)
  - GIN index for French full-text search
  - Deduplication via SHA256 hashing (pgcrypto extension)
  - JSONB metadata support for flexible document properties
- Complete RAG documentation (`docs/RAG.md`)
  - Architecture overview
  - Database schema details
  - Function reference with examples
  - n8n integration guide
  - Maintenance and performance tuning

### Changed
- **PostgreSQL image**: `postgres:16-alpine` → `pgvector/pgvector:pg16`
- Updated `docker-compose.yml` to build custom PostgreSQL image
- Database initialization scripts moved to `postgres/init/`
  - `02-rag-schema.sql` - RAG schema and tables
  - `03-rag-functions.sql` - SQL functions

### Technical Details
- Image: pgvector/pgvector:pg16 (Debian-based)
- Extensions: vector (0.8.1), pgcrypto (1.3), uuid-ossp, plpgsql
- Schemas: public, rag
- Indexes: 13 indexes total (4 on documents, 5 on chunks, 4 on embeddings)
- Vector dimensions: 1536 (OpenAI text-embedding-ada-002 compatible)
- Default chunk size: 1000 characters with 200 character overlap

## [1.0.0] - 2026-01-06

### Added
- Complete Docker Compose stack with 8 services:
  - Traefik v2.11 (reverse proxy + SSL)
  - PostgreSQL 16 (shared database)
  - Redis 7 (cache and sessions)
  - MongoDB 7 (Huly database)
  - Huly (project management and Kanban)
  - Infisical (secrets management)
  - n8n (workflow automation)
  - Uptime Kuma (monitoring and alerts)
- Health checks for all services
- Traefik configuration with automatic SSL via Let's Encrypt
- Network isolation (frontend/backend)
- Persistent volumes for all data
- Environment variables configuration (.env.example)
- Automated setup script (scripts/setup.sh)
- Backup script (scripts/backup.sh)
- Health check script (scripts/health-check.sh)
- TDD test suite:
  - Structure tests (tests/test-stack.sh)
  - Endpoint tests (tests/test-endpoints.sh)
- GitHub Actions CI/CD workflows:
  - CI pipeline with validation, tests, and security scanning
  - Deploy pipeline with SSH deployment and backup
- Complete documentation:
  - README.md (user guide)
  - DEPLOYMENT.md (production deployment guide)
  - CHANGELOG.md (this file)

### Fixed
- Redis healthcheck authentication with password
- Test file path for .env.example
- Healthcheck tests to be more reliable using container names

### Security
- All services require authentication
- Passwords configurable via environment variables
- SSL/TLS encryption via Traefik + Let's Encrypt
- Network segmentation (frontend/backend)
- Trivy security scanning in CI pipeline

## [0.1.0] - 2026-01-06

### Added
- Initial project structure
- Basic docker-compose.yml
- Traefik configuration
- Scripts and tests foundation

---

## Release Notes

### Version 1.0.0 - Production Ready

This is the first production-ready release of ALFA Dashboard. The platform is fully functional with:

✅ **8 integrated services** working together seamlessly
✅ **Complete automation** via scripts and CI/CD
✅ **Security-first approach** with SSL, authentication, and scanning
✅ **Comprehensive testing** with TDD methodology
✅ **Production-ready deployment** with detailed guides
✅ **Backup and monitoring** capabilities built-in

**What's Next:**
- User feedback integration
- Performance optimizations
- Additional service integrations
- Enhanced monitoring dashboards
- Multi-environment support (dev/staging/prod)

---

**Repository:** https://github.com/bestophe-group/alfa-dashboard
**Documentation:** See README.md and DEPLOYMENT.md
**Issues:** https://github.com/bestophe-group/alfa-dashboard/issues
