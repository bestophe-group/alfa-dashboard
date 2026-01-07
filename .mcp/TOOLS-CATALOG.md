# ALFA MCP Tools - Catalogue Complet v2.0

> **91 outils d'expertise MCP** pour ALFA Dashboard

Date: 2026-01-07
Version: 2.0.0

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

---

## 🔍 3. OSINT Tools (8 outils)

**Fichier**: `tools/osint-tools.js`

| Outil | Description | Sources |
|-------|-------------|---------|
| `alfa_osint_company_research` | Recherche entreprise complète | Pappers, OpenCorporates |
| `alfa_osint_person_research` | Recherche personne | LinkedIn, Twitter, HIBP |
| `alfa_osint_dark_web_search` | Recherche data leaks | HIBP, DeHashed, IntelX |
| `alfa_osint_social_media_scrape` | Scraping réseaux sociaux | LinkedIn, Twitter, FB, IG |
| `alfa_osint_domain_reconnaissance` | Recon domaine | crt.sh, WHOIS, Shodan |
| `alfa_osint_executive_team_mapping` | Cartographie dirigeants | Pappers, LinkedIn |
| `alfa_osint_financial_research` | Recherche financière | Registres publics |
| `alfa_osint_data_breach_monitor` | Surveillance breaches | APIs multiples |

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
| `alfa_etl_text_to_speech` | TTS | ElevenLabs API |
| `alfa_etl_web_to_markdown` | Web→Markdown | Trafilatura |
| `alfa_etl_batch_convert` | Conversion par lot | FFmpeg, ImageMagick |

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

---

## 💻 7. Claude Code CLI Tools (9 outils)

**Fichier**: `tools/claude-code-tools.js`

| Outil | Description | Cas d'usage |
|-------|-------------|-------------|
| `alfa_claude_create_project` | Créer projet complet | Boilerplate Next.js, FastAPI |
| `alfa_claude_debug_error` | Analyser & débugger erreur | Error analysis + fixes |
| `alfa_claude_generate_tests` | Générer tests unitaires | Jest, Pytest, Vitest |
| `alfa_claude_refactor_code` | Refactoring code | Amélioration qualité |
| `alfa_claude_add_feature` | Ajouter fonctionnalité | Feature development |
| `alfa_claude_document_code` | Générer documentation | JSDoc, README, API docs |
| `alfa_claude_optimize_code` | Optimisation performance | CPU, memory, network |
| `alfa_claude_setup_ci_cd` | Configurer CI/CD | GitHub Actions, GitLab CI |
| `alfa_claude_migrate_code` | Migration code | JS→TS, Python 2→3 |

---

## 💬 8. Collaboration Tools (12 outils)

**Fichier**: `tools/collaboration-tools.js`

| Outil | Description | Plateforme |
|-------|-------------|------------|
| `alfa_slack_send_message` | Envoyer message Slack | Slack |
| `alfa_slack_create_channel` | Créer channel Slack | Slack |
| `alfa_slack_manage_users` | Gérer utilisateurs Slack | Slack |
| `alfa_slack_archive_export` | Exporter historique Slack | Slack |
| `alfa_microsoft365_user_management` | Gestion users Azure AD | Microsoft 365 |
| `alfa_microsoft365_teams_management` | Gestion Teams | Microsoft Teams |
| `alfa_microsoft365_sharepoint` | Gestion SharePoint | SharePoint |
| `alfa_microsoft365_exchange` | Gestion Exchange | Exchange Online |
| `alfa_google_workspace_users` | Gestion users Google | Google Workspace |
| `alfa_google_workspace_groups` | Gestion groupes Google | Google Groups |
| `alfa_google_workspace_drive` | Gestion Google Drive | Google Drive |

---

## ☁️ 9. Infrastructure Tools (9 outils)

**Fichier**: `tools/infrastructure-tools.js`

| Outil | Description | Plateforme |
|-------|-------------|------------|
| `alfa_ovh_domain_management` | Gestion domaines OVH | OVH |
| `alfa_ovh_vps_management` | Gestion VPS OVH | OVH |
| `alfa_hostinger_management` | Gestion Hostinger | Hostinger |
| `alfa_aws_s3_management` | Gestion AWS S3 | AWS |
| `alfa_aws_ec2_management` | Gestion instances EC2 | AWS |
| `alfa_aws_lambda_deploy` | Déployer Lambda | AWS |
| `alfa_vercel_deploy` | Déployer sur Vercel | Vercel |
| `alfa_v0dev_generate` | Générer UI avec v0.dev | v0.dev |
| `alfa_cloudflare_dns` | Gestion DNS Cloudflare | Cloudflare |

---

## 💼 10. Business SaaS Tools (11 outils)

**Fichier**: `tools/business-saas-tools.js`

| Outil | Description | Plateforme |
|-------|-------------|------------|
| `alfa_payfit_employees` | Gestion employés PayFit | PayFit |
| `alfa_payfit_time_off` | Gestion congés PayFit | PayFit |
| `alfa_pennylane_invoices` | Gestion factures PennyLane | PennyLane |
| `alfa_pennylane_expenses` | Gestion dépenses PennyLane | PennyLane |
| `alfa_pennylane_accounting` | Export comptable PennyLane | PennyLane |
| `alfa_bitwarden_vault` | Gestion vault Bitwarden | Bitwarden |
| `alfa_instagram_publish` | Publier sur Instagram | Instagram |
| `alfa_facebook_publish` | Publier sur Facebook | Facebook |
| `alfa_tiktok_publish` | Publier sur TikTok | TikTok |
| `alfa_youtube_upload` | Upload vidéo YouTube | YouTube |
| `alfa_canva_design` | Créer design Canva | Canva |

---

## 🌐 11. CMS Tools (9 outils)

**Fichier**: `tools/cms-tools.js`

| Outil | Description | CMS |
|-------|-------------|-----|
| `alfa_wix_site_management` | Gestion sites Wix | Wix |
| `alfa_wix_page_management` | Gestion pages Wix | Wix |
| `alfa_wix_store_management` | Gestion boutique Wix | Wix |
| `alfa_wordpress_site_management` | Gestion sites WordPress | WordPress |
| `alfa_wordpress_content_management` | Gestion contenu WordPress | WordPress |
| `alfa_wordpress_plugin_management` | Gestion plugins WordPress | WordPress |
| `alfa_wordpress_theme_management` | Gestion thèmes WordPress | WordPress |
| `alfa_wordpress_user_management` | Gestion users WordPress | WordPress |
| `alfa_wordpress_woocommerce` | Gestion WooCommerce | WooCommerce |

---

## 👨‍💻 12. Developer Tools (8 outils)

**Fichier**: `tools/developer-tools.js`

| Outil | Description | Plateforme |
|-------|-------------|------------|
| `alfa_github_repo_management` | Gestion repos GitHub | GitHub |
| `alfa_github_issues_management` | Gestion issues GitHub | GitHub |
| `alfa_github_pr_management` | Gestion Pull Requests | GitHub |
| `alfa_github_actions_management` | Gestion GitHub Actions | GitHub |
| `alfa_github_release_management` | Gestion releases GitHub | GitHub |
| `alfa_browser_navigate` | Navigation web automatisée | Browser |
| `alfa_browser_scrape` | Web scraping avancé | Browser |
| `alfa_browser_authenticate` | Authentification web auto | Browser |

---

## 🔐 13. Azure SSO Tools (7 outils)

**Fichier**: `tools/azure-sso-tools.js`

| Outil | Description | Protocole |
|-------|-------------|-----------|
| `alfa_azure_sso_app_registration` | Enregistrer app Azure AD | OAuth/OIDC |
| `alfa_azure_sso_configure_saml` | Configurer SSO SAML | SAML |
| `alfa_azure_sso_configure_oidc` | Configurer SSO OIDC | OIDC |
| `alfa_azure_sso_assign_users` | Assigner users/groupes | Azure AD |
| `alfa_azure_sso_conditional_access` | Stratégies accès conditionnel | Azure AD |
| `alfa_azure_sso_get_metadata` | Récupérer métadonnées SSO | SAML/OIDC |
| `alfa_azure_sso_test_connection` | Tester connexion SSO | Test |

---

## 📝 14. Productivity Tools (8 outils)

**Fichier**: `tools/productivity-tools.js`

| Outil | Description | Plateforme |
|-------|-------------|------------|
| `alfa_obsidian_create_note` | Créer note Obsidian | Obsidian |
| `alfa_obsidian_search_notes` | Rechercher dans vault | Obsidian |
| `alfa_obsidian_update_note` | Modifier note | Obsidian |
| `alfa_obsidian_graph_analysis` | Analyser graphe connaissances | Obsidian |
| `alfa_obsidian_daily_note` | Créer daily note | Obsidian |
| `alfa_obsidian_export_vault` | Exporter vault | Obsidian |
| `alfa_obsidian_template_apply` | Appliquer template | Obsidian |
| `alfa_obsidian_sync_status` | Vérifier status sync | Obsidian |

---

## 📈 Statistiques Globales v2.0

| Catégorie | Nombre d'outils | Technologies clés |
|-----------|-----------------|-------------------|
| Grafana | 5 | Prometheus, Loki, Alertmanager |
| Power BI | 8 | DAX, M queries, REST API |
| OSINT | 8 | APIs publiques, scraping, dark web |
| ETL | 10 | Whisper, Pandas, FFmpeg, Tesseract |
| Communication | 9 | Design, marketing, web dev |
| Agent Orchestration | 10 | Multi-agent AI, APIs |
| Claude Code | 9 | Development, testing, CI/CD |
| Collaboration | 12 | Slack, M365, Google Workspace |
| Infrastructure | 9 | OVH, AWS, Vercel, Cloudflare |
| Business SaaS | 11 | PayFit, PennyLane, Social Media |
| CMS | 9 | Wix, WordPress, WooCommerce |
| Developer | 8 | GitHub, Browser Automation |
| Azure SSO | 7 | SAML, OIDC, Azure AD |
| Productivity | 8 | Obsidian, Knowledge Management |
| **TOTAL** | **91 outils** | **40+ intégrations** |

---

## 🔧 Variables d'Environnement

### Monitoring & Analytics
```bash
GRAFANA_URL=http://localhost:3000
GRAFANA_API_KEY=admin:admin
POWERBI_ACCESS_TOKEN=xxx
```

### OSINT
```bash
PAPPERS_API_KEY=xxx
DEHASHED_API_KEY=xxx
DEHASHED_EMAIL=xxx
INTELX_API_KEY=xxx
```

### AI Agents
```bash
OPENAI_API_KEY=xxx
PERPLEXITY_API_KEY=xxx
ELEVENLABS_API_KEY=xxx
```

### Collaboration
```bash
SLACK_BOT_TOKEN=xxx
MS_GRAPH_TOKEN=xxx
GOOGLE_SERVICE_ACCOUNT_KEY=xxx
```

### Infrastructure
```bash
OVH_APP_KEY=xxx
OVH_APP_SECRET=xxx
OVH_CONSUMER_KEY=xxx
AWS_ACCESS_KEY_ID=xxx
AWS_SECRET_ACCESS_KEY=xxx
VERCEL_TOKEN=xxx
CLOUDFLARE_API_TOKEN=xxx
```

### Business & SaaS
```bash
PAYFIT_API_KEY=xxx
PENNYLANE_API_KEY=xxx
BITWARDEN_CLI_SESSION=xxx
INSTAGRAM_ACCESS_TOKEN=xxx
FACEBOOK_ACCESS_TOKEN=xxx
TIKTOK_ACCESS_TOKEN=xxx
YOUTUBE_CLIENT_ID=xxx
YOUTUBE_CLIENT_SECRET=xxx
CANVA_API_KEY=xxx
```

### CMS
```bash
WIX_API_KEY=xxx
WP_APPLICATION_PASSWORD=xxx  # Format: username:password base64
```

### Developer
```bash
GITHUB_TOKEN=xxx  # or GITHUB_PAT
```

### Azure SSO
```bash
AZURE_TENANT_ID=xxx
AZURE_CLIENT_ID=xxx
AZURE_CLIENT_SECRET=xxx
```

---

## 💡 Cas d'Usage Recommandés

### Cas 1: Gestion Complète Microsoft 365
```javascript
// 1. Créer utilisateur
alfa_microsoft365_user_management({
  action: 'create',
  user_email: 'nouveau@company.com',
  display_name: 'Nouveau Collaborateur'
})

// 2. Assigner licence
alfa_microsoft365_user_management({
  action: 'assign_license',
  user_email: 'nouveau@company.com',
  licenses: ['E3']
})

// 3. Ajouter à Teams
alfa_microsoft365_teams_management({
  action: 'add_member',
  team_id: 'xxx',
  members: ['nouveau@company.com']
})

// 4. Configurer SSO Azure
alfa_azure_sso_assign_users({
  app_id: 'xxx',
  user_emails: ['nouveau@company.com']
})
```

### Cas 2: Pipeline Complet Content Marketing
```javascript
// 1. Recherche tendances
alfa_perplexity_research({
  query: 'FinTech trends 2026'
})

// 2. Génération script vidéo
alfa_video_script_generator({
  topic: 'Tendances FinTech',
  duration: 180
})

// 3. Voix off
alfa_etl_text_to_speech({
  text: '...',
  model: 'elevenlabs'
})

// 4. Design thumbnail
alfa_canva_design({
  type: 'youtube-thumbnail',
  template_id: 'xxx',
  customizations: {...}
})

// 5. Upload YouTube
alfa_youtube_upload({
  video_path: '/path/video.mp4',
  title: 'Tendances FinTech 2026'
})

// 6. Partage cross-platform
alfa_instagram_publish({ ... })
alfa_facebook_publish({ ... })
alfa_tiktok_publish({ ... })
```

### Cas 3: Infrastructure as Code avec ALFA
```javascript
// 1. Créer bucket S3
alfa_aws_s3_management({
  action: 'create_bucket',
  bucket_name: 'alfa-assets',
  region: 'eu-west-1'
})

// 2. Déployer Lambda
alfa_aws_lambda_deploy({
  function_name: 'alfa-api',
  runtime: 'nodejs18.x',
  code_path: '/path/to/code'
})

// 3. Déployer frontend Vercel
alfa_vercel_deploy({
  project_path: '/path/to/frontend',
  production: true
})

// 4. Configurer DNS Cloudflare
alfa_cloudflare_dns({
  action: 'add_record',
  record_type: 'CNAME',
  name: 'app',
  content: 'vercel-app.vercel.app'
})

// 5. Monitoring Grafana
alfa_grafana_create_dashboard({
  title: 'ALFA Infrastructure',
  panels: [...]
})
```

---

🤖 **ALFA MCP Tools v2.0.0** - 91 outils professionnels

Créé avec Claude Code dans le cadre de la méthode ALFA-Agent
