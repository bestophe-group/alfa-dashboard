# ALFA MCP Server

Serveur MCP (Model Context Protocol) pour ALFA Dashboard.

## 🎯 Description

Ce serveur expose 125+ outils MCP pour interagir avec :
- PostgreSQL (base ALFA)
- Grafana / Prometheus
- n8n workflows
- Stack Docker complète
- Services externes (Slack, GitHub, Power BI, etc.)

## 🚀 Démarrage

```bash
cd mcp-server
npm install
node alfa-server.js
```

## 📁 Structure

```
mcp-server/
├── alfa-server.js          # Point d'entrée
├── tools/                  # Modules outils
│   ├── grafana-tools.js
│   ├── powerbi-tools.js
│   ├── osint-tools.js
│   └── ... (14 modules)
├── tests/
│   ├── test-e2e.js        # Tests end-to-end
│   └── test-results.json
└── package.json
```

## 🔧 Configuration

Le serveur se configure via Claude Desktop :

```json
{
  "mcpServers": {
    "alfa-dashboard": {
      "command": "node",
      "args": ["/path/to/mcp-server/alfa-server.js"]
    }
  }
}
```

## 📚 Documentation

- **Guide Lazy Loading:** `/docs/mcp/lazy-loading-guide.md`
- **Historique:** `/archive/mcp-history/`

## ✅ Tests

```bash
npm test
```
