# ALFA MCP Server - Complete Toolset

> **91 outils d'expertise professionnelle** accessibles via MCP pour Claude Desktop, Claude Code CLI et Cursor

## 🚀 Quick Start

### Installation

```bash
cd /Users/arnaud/Documents/ALFA-Agent-Method/.mcp
npm install
```

### Configuration

Créer un fichier `.env` avec vos API keys :

```bash
# Monitoring & Analytics
GRAFANA_URL=http://localhost:3000
GRAFANA_API_KEY=admin:admin
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

# Collaboration
SLACK_BOT_TOKEN=your_slack_token
MS_GRAPH_TOKEN=your_ms_token
GOOGLE_SERVICE_ACCOUNT_KEY=your_google_key

# Infrastructure
OVH_APP_KEY=your_ovh_key
OVH_APP_SECRET=your_ovh_secret
OVH_CONSUMER_KEY=your_ovh_consumer
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
VERCEL_TOKEN=your_vercel_token
CLOUDFLARE_API_TOKEN=your_cloudflare_token

# Business SaaS
PAYFIT_API_KEY=your_payfit_key
PENNYLANE_API_KEY=your_pennylane_key
BITWARDEN_CLI_SESSION=your_bitwarden_session
INSTAGRAM_ACCESS_TOKEN=your_instagram_token
FACEBOOK_ACCESS_TOKEN=your_facebook_token
TIKTOK_ACCESS_TOKEN=your_tiktok_token
YOUTUBE_CLIENT_ID=your_youtube_id
YOUTUBE_CLIENT_SECRET=your_youtube_secret
CANVA_API_KEY=your_canva_key

# CMS
WIX_API_KEY=your_wix_key
WP_APPLICATION_PASSWORD=your_wp_pass

# Developer
GITHUB_TOKEN=your_github_token

# Azure SSO
AZURE_TENANT_ID=your_tenant_id
AZURE_CLIENT_ID=your_client_id
AZURE_CLIENT_SECRET=your_client_secret
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

## 🎯 14 Domaines d'Expertise

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

### 8. 💬 Collaboration (12 outils)
Slack, Microsoft 365, Google Workspace

### 9. ☁️ Infrastructure (9 outils)
OVH, Hostinger, AWS, Vercel, v0.dev, Cloudflare

### 10. 💼 Business SaaS (11 outils)
PayFit, PennyLane, Bitwarden, Social Media, Canva

### 11. 🌐 CMS (9 outils)
Wix, WordPress, WooCommerce

### 12. 👨‍💻 Developer (8 outils)
GitHub, Browser Automation

### 13. 🔐 Azure SSO (7 outils)
SAML, OIDC, Conditional Access

### 14. 📝 Productivity (8 outils)
Obsidian vault management

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
| **Outils totaux** | 91 |
| **Domaines d'expertise** | 14 |
| **Intégrations API** | 40+ |
| **Lignes de code** | 5000+ |
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

### v2.0.0 (2026-01-07)

- ✨ 91 outils MCP (32 nouveaux)
- 💬 Collaboration: Slack, Microsoft 365, Google Workspace
- ☁️ Infrastructure: OVH, AWS, Vercel, Cloudflare
- 💼 Business SaaS: PayFit, PennyLane, Social Media
- 🌐 CMS: Wix, WordPress, WooCommerce
- 👨‍💻 Developer: GitHub, Browser Automation
- 🔐 Azure SSO: SAML, OIDC, Conditional Access
- 📝 Productivity: Obsidian vault management

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

🤖 **ALFA MCP Server v2.0.0**

Créé avec Claude Code dans le cadre de la méthode ALFA-Agent
