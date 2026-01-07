# ALFA MCP Server - Complete Toolset

> **59 outils d'expertise professionnelle** accessibles via MCP pour Claude Desktop, Claude Code CLI et Cursor

## 🚀 Quick Start

### Installation

```bash
cd /Users/arnaud/Documents/ALFA-Agent-Method/.mcp
npm install
```

### Configuration

Créer un fichier `.env` avec vos API keys :

```bash
# Monitoring
GRAFANA_URL=http://localhost:3000
GRAFANA_API_KEY=admin:admin

# Analytics
POWERBI_ACCESS_TOKEN=your_powerbi_token

# OSINT
PAPPERS_API_KEY=your_pappers_key
DEHASHED_API_KEY=your_dehashed_key
DEHASHED_EMAIL=your_email
INTELX_API_KEY=your_intelx_key

# AI Agents
OPENAI_API_KEY=your_openai_key
PERPLEXITY_API_KEY=your_perplexity_key
ELEVENLABS_API_KEY=your_elevenlabs_key
```

### Test du serveur

```bash
node alfa-server.js
```

Vous devriez voir : `ALFA MCP Server running on stdio`

## 📚 Documentation Complète

Consultez [TOOLS-CATALOG.md](./TOOLS-CATALOG.md) pour :
- Liste exhaustive des 59 outils
- Exemples d'utilisation
- Cas d'usage recommandés
- Variables d'environnement
- Architecture technique

## 🎯 7 Domaines d'Expertise

### 1. 📊 Grafana (5 outils)
Gestion complète de Grafana : dashboards, queries, alerts

### 2. 💼 Power BI (8 outils)
Analytics & BI : datasets, reports, DAX, exports

### 3. 🔍 OSINT (8 outils)
Recherche d'intelligence : entreprises, personnes, dark web

### 4. 🔄 ETL (10 outils)
Transformations : video, audio, PDF, images, data

### 5. 🎨 Communication (9 outils)
Agence complète : design, web, marketing, contenu

### 6. 🤖 Agents (10 outils)
Orchestration IA : ChatGPT, Perplexity, Manus, ElevenLabs

### 7. 💻 Claude Code (9 outils)
Développement : projets, tests, debugging, CI/CD

## 🔧 Utilisation dans Claude

### Claude Desktop

```json
{
  "mcpServers": {
    "alfa-dashboard": {
      "command": "node",
      "args": ["/Users/arnaud/Documents/ALFA-Agent-Method/.mcp/alfa-server.js"],
      "env": {
        "GRAFANA_URL": "http://localhost:3000",
        "OPENAI_API_KEY": "xxx"
      }
    }
  }
}
```

### Cursor

```json
{
  "mcpServers": {
    "alfa-dashboard": {
      "command": "node",
      "args": ["/Users/arnaud/Documents/ALFA-Agent-Method/.mcp/alfa-server.js"]
    }
  }
}
```

### Claude Code CLI

Le serveur est déjà accessible directement dans cette session.

## 💡 Exemples Rapides

### Monitoring Grafana

```
Créer un dashboard Grafana pour surveiller nos services ALFA
→ Utilise alfa_grafana_create_dashboard
```

### OSINT Entreprise

```
Faire une recherche OSINT complète sur l'entreprise "Bestophe Group"
→ Utilise alfa_osint_company_research
```

### Transcription Vidéo

```
Transcrire la vidéo /path/meeting.mp4 en français avec timestamps
→ Utilise alfa_etl_video_to_text
```

### Orchestration Multi-Agents

```
Rechercher tendances FinTech 2026, synthétiser et créer rapport PowerPoint
→ Utilise alfa_multi_agent_chain
```

## 🏗️ Architecture

```
.mcp/
├── alfa-server.js          # Serveur MCP principal
├── tools/
│   ├── grafana-tools.js    # 5 outils Grafana
│   ├── powerbi-tools.js    # 8 outils Power BI
│   ├── osint-tools.js      # 8 outils OSINT
│   ├── etl-tools.js        # 10 outils ETL
│   ├── communication-agency-tools.js  # 9 outils Communication
│   ├── agent-orchestration-tools.js   # 10 outils Agents
│   └── claude-code-tools.js           # 9 outils Dev
├── package.json
├── node_modules/
├── TOOLS-CATALOG.md        # Documentation complète
└── README.md               # Ce fichier
```

## 🔐 Sécurité

- Toutes les API keys en variables d'environnement
- Validation stricte des inputs
- Pas de logging de données sensibles
- Rate limiting respecté
- HTTPS pour toutes les APIs externes

## 🛠️ Dépendances

```json
{
  "@modelcontextprotocol/sdk": "^0.5.0",
  "node-fetch": "^3.3.2"
}
```

### Outils système requis (optionnels selon usage)

- **Whisper**: `pip install openai-whisper`
- **FFmpeg**: `brew install ffmpeg`
- **Tesseract**: `brew install tesseract`
- **Python 3**: avec pandas, sqlalchemy

## 📊 Statistiques

| Métrique | Valeur |
|----------|--------|
| **Outils totaux** | 59 |
| **Domaines d'expertise** | 7 |
| **Intégrations API** | 20+ |
| **Lignes de code** | 3000+ |
| **Cas d'usage** | ∞ |

## 🚦 Status & Health

Pour vérifier le status du serveur MCP :

```bash
# Liste des outils disponibles
node -e "import('./alfa-server.js').then(s => console.log(s.listTools()))"

# Test connexion
node alfa-server.js < /dev/null
```

## 📞 Support & Contribution

### Issues

Rapporter les bugs ou suggestions sur GitHub :
https://github.com/bestophe-group/alfa-dashboard/issues

### Ajout de nouveaux outils

1. Créer fichier dans `tools/`
2. Suivre le pattern existant :
   - Exporter array `tools`
   - Exporter fonction `execute{Category}Tool(name, args)`
3. Documenter dans `TOOLS-CATALOG.md`
4. Tester avec le serveur MCP

## 🎓 Ressources

- [Model Context Protocol Docs](https://modelcontextprotocol.io)
- [Claude Code Documentation](https://claude.ai/claude-code)
- [ALFA Dashboard Repo](https://github.com/bestophe-group/alfa-dashboard)

## 📝 Changelog

### v1.0.0 (2026-01-07)

- ✨ 59 outils MCP initiaux
- 📊 Intégration Grafana complète
- 💼 Support Power BI
- 🔍 Suite OSINT professionnelle
- 🔄 Pipeline ETL multiformat
- 🎨 Agence de communication
- 🤖 Orchestration multi-agents
- 💻 Claude Code development tools

---

🤖 **ALFA MCP Server v1.0.0**

Créé avec Claude Code dans le cadre de la méthode ALFA-Agent
