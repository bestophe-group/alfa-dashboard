# ALFA MCP Tools - Catalogue Complet

> **51 outils d'expertise MCP** pour ALFA Dashboard

Date: 2026-01-07
Version: 1.0.0

---

## 📊 1. Grafana Tools (5 outils)

**Fichier**: `tools/grafana-tools.js`

| Outil | Description | Cas d'usage |
|-------|-------------|-------------|
| `alfa_grafana_create_dashboard` | Créer dashboard avec panels et queries | Monitoring personnalisé |
| `alfa_grafana_query_prometheus` | Exécuter requêtes PromQL | Métriques temps réel |
| `alfa_grafana_create_alert` | Créer règles d'alerte | Notifications automatiques |
| `alfa_grafana_export_dashboard` | Exporter dashboard (JSON/PDF) | Backup, sharing |
| `alfa_grafana_import_dashboard` | Importer dashboard | Migration, templates |

**Exemple d'usage**:
```javascript
alfa_grafana_create_dashboard({
  title: "Service Health Dashboard",
  panels: [
    { title: "CPU Usage", query: "rate(container_cpu_usage[5m])", type: "graph" },
    { title: "Memory", query: "container_memory_usage_bytes" }
  ],
  tags: ["infrastructure", "monitoring"]
})
```

---

## 💼 2. Power BI Tools (8 outils)

**Fichier**: `tools/powerbi-tools.js`

| Outil | Description | Cas d'usage |
|-------|-------------|-------------|
| `alfa_powerbi_create_dataset` | Créer dataset avec schema | Data modeling |
| `alfa_powerbi_push_data` | Pusher données vers table | Real-time updates |
| `alfa_powerbi_create_report` | Créer rapport depuis dataset | Visualizations |
| `alfa_powerbi_refresh_dataset` | Trigger refresh dataset | Data sync |
| `alfa_powerbi_export_report` | Exporter PDF/PNG/PPTX | Partage, archivage |
| `alfa_powerbi_create_dataflow` | Créer dataflow ETL | Transformations |
| `alfa_powerbi_embed_token` | Générer token embed | Web integration |
| `alfa_powerbi_query_dax` | Exécuter requête DAX | Analytics avancés |

**Exemple d'usage**:
```javascript
alfa_powerbi_create_dataset({
  name: "Sales Analytics",
  tables: [
    {
      name: "Sales",
      columns: [
        { name: "Date", type: "DateTime" },
        { name: "Amount", type: "Decimal" },
        { name: "Product", type: "String" }
      ]
    }
  ]
})
```

---

## 🔍 3. OSINT Tools (8 outils)

**Fichier**: `tools/osint-tools.js`

| Outil | Description | Sources |
|-------|-------------|---------|
| `alfa_osint_company_research` | Recherche entreprise complète | Pappers, OpenCorporates, Infogreffe |
| `alfa_osint_person_research` | Recherche personne (social, dark web) | LinkedIn, Twitter, HIBP |
| `alfa_osint_dark_web_search` | Recherche data leaks | HIBP, DeHashed, IntelX |
| `alfa_osint_social_media_scrape` | Scraping réseaux sociaux | LinkedIn, Twitter, FB, IG |
| `alfa_osint_domain_reconnaissance` | Recon domaine (DNS, subdomains) | crt.sh, WHOIS, Shodan |
| `alfa_osint_executive_team_mapping` | Cartographie dirigeants | Pappers, LinkedIn |
| `alfa_osint_financial_research` | Recherche financière & patrimoine | Registres publics |
| `alfa_osint_data_breach_monitor` | Surveillance breaches | APIs multiples |

**Variables d'environnement**:
```bash
PAPPERS_API_KEY=xxx
DEHASHED_API_KEY=xxx
DEHASHED_EMAIL=xxx
INTELX_API_KEY=xxx
```

**Exemple d'usage**:
```javascript
alfa_osint_company_research({
  company_name: "Bestophe Group",
  search_depth: "deep",
  include_subsidiaries: true
})
```

---

## 🔄 4. ETL Tools (10 outils)

**Fichier**: `tools/etl-tools.js`

| Outil | Description | Technologies |
|-------|-------------|--------------|
| `alfa_etl_video_to_text` | Transcription vidéo | FFmpeg + Whisper |
| `alfa_etl_audio_to_text` | Transcription audio | Whisper AI |
| `alfa_etl_pdf_to_text` | Extraction PDF (OCR) | pdftotext, Tesseract |
| `alfa_etl_image_to_text` | OCR image | Tesseract |
| `alfa_etl_csv_transform` | Transformation CSV | Pandas |
| `alfa_etl_json_to_csv` | Conversion JSON→CSV | Pandas |
| `alfa_etl_excel_to_db` | Import Excel→PostgreSQL | SQLAlchemy |
| `alfa_etl_text_to_speech` | TTS (ElevenLabs/Azure) | ElevenLabs API |
| `alfa_etl_web_to_markdown` | Web→Markdown | Trafilatura |
| `alfa_etl_batch_convert` | Conversion par lot | FFmpeg, ImageMagick |

**Variables d'environnement**:
```bash
ELEVENLABS_API_KEY=xxx
```

**Exemple d'usage**:
```javascript
alfa_etl_video_to_text({
  video_path: "/path/to/meeting.mp4",
  output_format: "srt",
  language: "fr",
  whisper_model: "medium"
})
```

---

## 🎨 5. Communication Agency Tools (9 outils)

**Fichier**: `tools/communication-agency-tools.js`

| Outil | Description | Livrable |
|-------|-------------|----------|
| `alfa_design_brand_identity` | Charte graphique complète | Brand guide JSON |
| `alfa_design_social_media_pack` | Pack réseaux sociaux | Posts, stories, covers |
| `alfa_design_website_mockup` | Maquette site web | Wireframes, mockups |
| `alfa_generate_website_code` | Génération code site | Next.js, React, HTML |
| `alfa_design_infographic` | Création infographie | SVG, PNG, PDF |
| `alfa_design_presentation` | Présentation pro | PPTX |
| `alfa_marketing_recommendations` | Recommandations marketing | Stratégie complète |
| `alfa_content_calendar` | Calendrier éditorial 3 mois | CSV |
| `alfa_video_script_generator` | Script vidéo marketing | Structure + visuals |

**Exemple d'usage**:
```javascript
alfa_design_brand_identity({
  company_name: "Bestophe Group",
  industry: "Finance & Investment",
  values: ["Excellence", "Innovation", "Trust"],
  style: "luxury",
  color_preferences: ["#1F2937", "#B45309"]
})
```

---

## 🤖 6. Agent Orchestration Tools (10 outils)

**Fichier**: `tools/agent-orchestration-tools.js`

| Outil | Description | Agent/Service |
|-------|-------------|---------------|
| `alfa_manus_task` | Délégation à Manus.im | Browser automation |
| `alfa_chatgpt_task` | Délégation à ChatGPT | GPT-4 Turbo |
| `alfa_perplexity_research` | Recherche Perplexity | Web search + citations |
| `alfa_grok_analysis` | Analyse via Grok | X/Twitter access |
| `alfa_notebooklm_synthesize` | Synthèse NotebookLM | Document analysis |
| `alfa_elevenlabs_voice_agent` | Agent vocal ElevenLabs | Conversational AI |
| `alfa_opendata_import` | Import OpenData | data.gouv.fr, Eurostat |
| `alfa_multi_agent_chain` | Orchestration multi-agents | Chain execution |
| `alfa_comet_assistant_task` | Comet Assistant | Chrome automation |
| `alfa_nano_banana_task` | Nano Banana | No-code workflows |

**Variables d'environnement**:
```bash
OPENAI_API_KEY=xxx
PERPLEXITY_API_KEY=xxx
ELEVENLABS_API_KEY=xxx
```

**Exemple d'usage**:
```javascript
alfa_multi_agent_chain({
  task_description: "Analyser tendances marché + créer rapport",
  agents: [
    { agent: "perplexity", task: "Rechercher tendances FinTech 2026", pass_to_next: true },
    { agent: "chatgpt", task: "Synthétiser en 5 insights clés", pass_to_next: true },
    { agent: "chatgpt", task: "Créer rapport exécutif PowerPoint", pass_to_next: false }
  ],
  final_output_format: "pdf"
})
```

---

## 💻 7. Claude Code CLI Tools (9 outils)

**Fichier**: `tools/claude-code-tools.js`

| Outil | Description | Cas d'usage |
|-------|-------------|-------------|
| `alfa_claude_create_project` | Créer projet complet | Boilerplate Next.js, FastAPI, etc. |
| `alfa_claude_debug_error` | Analyser & débugger erreur | Error analysis + fixes |
| `alfa_claude_generate_tests` | Générer tests unitaires | Jest, Pytest, Vitest |
| `alfa_claude_refactor_code` | Refactoring code | Amélioration qualité |
| `alfa_claude_add_feature` | Ajouter fonctionnalité | Feature development |
| `alfa_claude_document_code` | Générer documentation | JSDoc, README, API docs |
| `alfa_claude_optimize_code` | Optimisation performance | CPU, memory, network |
| `alfa_claude_setup_ci_cd` | Configurer CI/CD | GitHub Actions, GitLab CI |
| `alfa_claude_migrate_code` | Migration code | JS→TS, Python 2→3 |

**Exemple d'usage**:
```javascript
alfa_claude_create_project({
  project_name: "alfa-api-gateway",
  project_type: "nextjs",
  features: ["auth", "database", "api", "tests", "docker"],
  output_dir: "/Users/arnaud/Projects"
})
```

---

## 📈 Statistiques Globales

| Catégorie | Nombre d'outils | Technologies clés |
|-----------|-----------------|-------------------|
| Grafana | 5 | Prometheus, Loki, Alertmanager |
| Power BI | 8 | DAX, M queries, REST API |
| OSINT | 8 | APIs publiques, scraping, dark web |
| ETL | 10 | Whisper, Pandas, FFmpeg, Tesseract |
| Communication | 9 | Design, marketing, web dev |
| Agent Orchestration | 10 | Multi-agent AI, APIs |
| Claude Code | 9 | Development, testing, CI/CD |
| **TOTAL** | **59 outils** | **20+ intégrations** |

---

## 🔧 Installation & Configuration

### 1. Installer dépendances

```bash
cd /Users/arnaud/Documents/ALFA-Agent-Method/.mcp
npm install
```

### 2. Configurer variables d'environnement

```bash
# API Keys
export GRAFANA_API_KEY="admin:admin"
export POWERBI_ACCESS_TOKEN="xxx"
export PAPPERS_API_KEY="xxx"
export OPENAI_API_KEY="xxx"
export PERPLEXITY_API_KEY="xxx"
export ELEVENLABS_API_KEY="xxx"
export DEHASHED_API_KEY="xxx"
export INTELX_API_KEY="xxx"

# URLs
export GRAFANA_URL="http://localhost:3000"
```

### 3. Tester le serveur

```bash
node alfa-server.js
```

### 4. Intégration Claude

Les configurations sont déjà en place dans :
- Claude Desktop: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Cursor: `~/.cursor/mcp.json`

---

## 🎯 Cas d'usage Recommandés

### Cas 1: Veille Concurrentielle Complète
```javascript
// 1. OSINT sur concurrent
alfa_osint_company_research({ company_name: "Concurrent X" })

// 2. Analyse réseaux sociaux
alfa_osint_social_media_scrape({ platform: "linkedin", target: "Concurrent X" })

// 3. Recherche tendances
alfa_perplexity_research({ query: "Concurrent X strategy 2026" })

// 4. Génération rapport
alfa_design_presentation({ title: "Competitive Analysis", slides: [...] })
```

### Cas 2: Pipeline Analytics Complet
```javascript
// 1. Import OpenData
alfa_opendata_import({ source: "data.gouv.fr", dataset_id: "xxx" })

// 2. Transformation ETL
alfa_etl_csv_transform({ transformations: [...] })

// 3. Push vers Power BI
alfa_powerbi_push_data({ dataset_id: "xxx", rows: [...] })

// 4. Dashboard Grafana
alfa_grafana_create_dashboard({ panels: [...] })
```

### Cas 3: Génération Contenu Marketing
```javascript
// 1. Recherche insights
alfa_perplexity_research({ query: "FinTech trends 2026" })

// 2. Génération scripts
alfa_video_script_generator({ video_type: "explainer" })

// 3. Voix off
alfa_etl_text_to_speech({ text: "...", model: "elevenlabs" })

// 4. Calendrier éditorial
alfa_content_calendar({ platforms: ["linkedin", "twitter"] })
```

---

## 📚 Documentation Technique

### Architecture MCP

```
alfa-server.js (serveur principal)
├── tools/
│   ├── grafana-tools.js
│   ├── powerbi-tools.js
│   ├── osint-tools.js
│   ├── etl-tools.js
│   ├── communication-agency-tools.js
│   ├── agent-orchestration-tools.js
│   └── claude-code-tools.js
├── package.json
└── node_modules/
```

### Ajout de nouveaux outils

1. Créer fichier dans `tools/`
2. Exporter `tools` array et fonction `execute`
3. Importer dans `alfa-server.js`
4. Redémarrer serveur MCP

---

## 🔐 Sécurité

- **API Keys**: Toutes stockées en variables d'environnement
- **Données sensibles**: Jamais loggées
- **Rate limiting**: Respecté sur toutes les APIs
- **Validation**: Tous les inputs validés

---

## 📞 Support

- **Documentation**: `/MCP-ACCESS.md`
- **Logs**: Stderr du serveur MCP
- **Debugging**: `verbose_timing` parameters disponibles

---

🤖 **ALFA MCP Tools v1.0.0** - Generated with Claude Code
