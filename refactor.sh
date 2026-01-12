#!/bin/bash
set -e

echo "🚀 Starting ALFA refactoring..."

# Create new structure
echo "📁 Creating directory structure..."
mkdir -p mcp-server/tools mcp-server/tests
mkdir -p docs/method docs/stack docs/guides docs/mcp
mkdir -p archive/analyses archive/reflexions archive/status-reports archive/migrations archive/mcp-history archive/guides

# Move method files
echo "📐 Moving method files..."
git mv 01-METHODE-ALFA.md docs/method/
git mv 03-ANTI-DESALIGNEMENT.md docs/method/
git mv 09-CHECKLIST-PROJET.md docs/method/

# Move stack files
echo "🏗️ Moving stack files..."
git mv 04-STACK-COMPLETE.md docs/stack/01-STACK-COMPLETE.md
git mv 05-CICD-PIPELINES.md docs/stack/02-CICD-PIPELINES.md
git mv 06-WORKFLOWS-N8N.md docs/stack/03-WORKFLOWS-N8N.md
git mv 11-STACK-SELFHOSTED-VPS.md docs/stack/04-SELFHOSTED-VPS.md

# Move guides
echo "📖 Moving guides..."
git mv 02-CURSORRULES.md docs/guides/cursorrules.md
git mv 07-PROMPTS-SYSTEME.md docs/guides/prompts-systeme.md
git mv 08-SPECS-TEMPLATES.md docs/guides/specs-templates.md
git mv 10-GLOSSAIRE.md docs/glossaire.md
git mv 00-LISEZMOI.md docs/00-LISEZMOI.md

# Archive analysis files
echo "🗄️ Archiving analyses..."
git mv ANALYSE-01-SCRIPTS.md archive/analyses/
git mv ANALYSE-02-DEVOPS.md archive/analyses/
git mv ANALYSE-PILOTAGE-CLAUDE-CODE.md archive/analyses/

# Archive reflections
echo "💭 Archiving reflections..."
git mv REFLEXION-COUVERTURE-USECASES.md archive/reflexions/
git mv REPONSE-INTERFACE-UNIFIEE.md archive/reflexions/
git mv SYNTHESE-COUVERTURE-GLOBALE.md archive/reflexions/

# Archive status reports
echo "📊 Archiving status reports..."
git mv IMPLEMENTATION-COMPLETE.md archive/migrations/
git mv MCP-ACCESS.md archive/migrations/
git mv STATUS-ALFA-DASHBOARD.md archive/status-reports/
git mv TODO-ALFA-DASHBOARD.md archive/status-reports/
git mv ACTION-GITHUB-AUTH.md archive/guides/

# Move MCP server code
echo "🔌 Moving MCP server..."
git mv .mcp/alfa-server.js mcp-server/
git mv .mcp/package.json mcp-server/
git mv .mcp/package-lock.json mcp-server/
git mv .mcp/tools/* mcp-server/tools/
git mv .mcp/test-e2e.js mcp-server/tests/
git mv .mcp/test-results.json mcp-server/tests/

# Move MCP documentation
echo "📚 Moving MCP docs..."
git mv .mcp/MCP-LAZY-LOADING-GUIDE.md docs/mcp/lazy-loading-guide.md

# Archive MCP history
echo "🗃️ Archiving MCP history..."
for file in .mcp/*.md; do
  [ -f "$file" ] && git mv "$file" archive/mcp-history/
done

git mv .mcp/configure-slack.sh archive/mcp-history/ 2>/dev/null || true
git mv .mcp/slack-webhook.js archive/mcp-history/ 2>/dev/null || true
git mv .mcp/alfa-manage.sh archive/mcp-history/ 2>/dev/null || true
git mv .mcp/list-tools.js archive/mcp-history/ 2>/dev/null || true
git mv .mcp/tools-list.json archive/mcp-history/ 2>/dev/null || true

# Clean up docs/
echo "🧹 Cleaning docs/..."
git mv docs/00-CORE.md archive/migrations/ 2>/dev/null || true
git mv docs/ALFA-METHOD.md archive/migrations/ 2>/dev/null || true
git mv docs/FAISABILITE-COMPLETE.md archive/reflexions/ 2>/dev/null || true

# Remove node_modules and empty .mcp
echo "🗑️ Cleaning up..."
rm -rf .mcp/node_modules
rmdir .mcp 2>/dev/null || true

echo "✅ Refactoring complete!"
echo ""
echo "📊 Summary:"
echo "  - Root files: $(ls -1 *.md 2>/dev/null | wc -l | xargs)"
echo "  - docs/: organized"
echo "  - mcp-server/: ready"
echo "  - archive/: historical files preserved"
