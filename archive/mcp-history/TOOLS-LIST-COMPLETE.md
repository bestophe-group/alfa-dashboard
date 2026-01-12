# 🤖 ALFA MCP - Liste Complète des 129 Outils

**Date**: 2026-01-07
**Version**: 2.0.0
**Status**: ✅ Production Ready

---

## 📊 Résumé

| Métrique | Valeur |
|----------|--------|
| **Total Outils** | 129 |
| **Domaines d'Expertise** | 14 |
| **Intégrations API** | 40+ |
| **Slack Bot** | ✅ Opérationnel (`alfa` sur lifeosgroupe.slack.com) |
| **Token Valid** | ✅ Oui (configuré dans .env) |

---

## 🎯 14 Domaines d'Expertise

### 1. Core ALFA (7 outils)
Gestion stack ALFA Docker

| Outil | Description |
|-------|-------------|
| `alfa_status` | Status de tous les services ALFA |
| `alfa_logs` | Logs d'un service ALFA |
| `alfa_restart` | Redémarrer un service ALFA |
| `alfa_health` | Health check services ALFA |
| `alfa_metrics` | Query Prometheus metrics |
| `alfa_workflows` | Lister workflows n8n |
| `alfa_db_query` | Query PostgreSQL ALFA DB |

**Usage Slack**: `/alfa status`

---

### 2. Grafana (5 outils)
Monitoring et dashboards

| Outil | Description |
|-------|-------------|
| `alfa_grafana_create_dashboard` | Créer dashboard Grafana |
| `alfa_grafana_query_prometheus` | Exécuter query PromQL |
| `alfa_grafana_create_alert` | Créer alerte Grafana |
| `alfa_grafana_export_dashboard` | Export dashboard (JSON/PDF) |
| `alfa_grafana_import_dashboard` | Import dashboard |

**Usage Slack**: `/alfa grafana_create_dashboard title="Monitoring Prod"`

---

### 3. Power BI (8 outils)
Business Intelligence Microsoft

| Outil | Description |
|-------|-------------|
| `alfa_powerbi_create_dataset` | Créer dataset Power BI |
| `alfa_powerbi_push_data` | Push data vers dataset |
| `alfa_powerbi_create_report` | Créer report Power BI |
| `alfa_powerbi_refresh_dataset` | Refresh dataset |
| `alfa_powerbi_export_report` | Export report (PDF/PNG/PPTX) |
| `alfa_powerbi_create_dataflow` | Créer dataflow |
| `alfa_powerbi_embed_token` | Token embed pour web |
| `alfa_powerbi_query_dax` | Query DAX sur dataset |

**Usage Slack**: `/alfa powerbi_create_dataset`

---

### 4. OSINT (8 outils)
Recherche d'informations Open Source

| Outil | Description |
|-------|-------------|
| `alfa_osint_company_research` | Recherche entreprise (SIREN, dirigeants, patrimoine) |
| `alfa_osint_person_research` | Recherche personne (réseaux, entreprises) |
| `alfa_osint_dark_web_search` | Recherche dark web (leaks, mentions) |
| `alfa_osint_social_media_scrape` | Scraping réseaux sociaux |
| `alfa_osint_domain_reconnaissance` | Recon domaine (DNS, subdomains) |
| `alfa_osint_executive_team_mapping` | Cartographie équipe dirigeante |
| `alfa_osint_financial_research` | Recherche financière |
| `alfa_osint_data_breach_monitor` | Monitoring data breaches |

**Usage Slack**: `/alfa osint_company_research company="Acme Corp"`

---

### 5. ETL (10 outils)
Transformation et conversion de données

| Outil | Description |
|-------|-------------|
| `alfa_etl_video_to_text` | Transcription vidéo → texte |
| `alfa_etl_audio_to_text` | Transcription audio (Whisper) |
| `alfa_etl_pdf_to_text` | Extraction texte PDF (OCR) |
| `alfa_etl_image_to_text` | OCR sur image |
| `alfa_etl_csv_transform` | Transformation CSV |
| `alfa_etl_json_to_csv` | Conversion JSON → CSV |
| `alfa_etl_excel_to_db` | Import Excel → PostgreSQL |
| `alfa_etl_text_to_speech` | TTS (ElevenLabs) |
| `alfa_etl_web_to_markdown` | Web page → Markdown |
| `alfa_etl_batch_convert` | Conversion par lot |

**Usage Slack**: `/alfa etl_pdf_to_text file_path="/path/doc.pdf"`

---

### 6. Communication (9 outils)
Design et marketing

| Outil | Description |
|-------|-------------|
| `alfa_design_brand_identity` | Charte graphique complète |
| `alfa_design_social_media_pack` | Pack réseaux sociaux |
| `alfa_design_website_mockup` | Maquette site web |
| `alfa_generate_website_code` | Génération code site web |
| `alfa_design_infographic` | Création infographie |
| `alfa_design_presentation` | Présentation PowerPoint/Keynote |
| `alfa_marketing_recommendations` | Recommandations marketing |
| `alfa_content_calendar` | Calendrier éditorial 3 mois |
| `alfa_video_script_generator` | Script vidéo marketing |

**Usage Slack**: `/alfa design_brand_identity company="Acme Corp"`

---

### 7. Agents (10 outils)
Orchestration d'agents AI

| Outil | Description |
|-------|-------------|
| `alfa_manus_task` | Tâche Manus.im (browser automation) |
| `alfa_chatgpt_task` | Analyse/génération ChatGPT |
| `alfa_perplexity_research` | Recherche Perplexity AI |
| `alfa_grok_analysis` | Analyse Grok (X.ai) |
| `alfa_notebooklm_synthesize` | Synthèse NotebookLM |
| `alfa_elevenlabs_voice_agent` | Agent vocal ElevenLabs |
| `alfa_opendata_import` | Import OpenData |
| `alfa_multi_agent_chain` | Orchestration multi-agents |
| `alfa_comet_assistant_task` | Tâche Comet Assistant |
| `alfa_nano_banana_task` | Tâche Nano Banana |

**Usage Slack**: `/alfa chatgpt_task prompt="Analyze sales data"`

---

### 8. Claude Code (9 outils)
Développement avec Claude

| Outil | Description |
|-------|-------------|
| `alfa_claude_create_project` | Créer projet complet |
| `alfa_claude_debug_error` | Debug code avec fixes |
| `alfa_claude_generate_tests` | Générer tests unitaires |
| `alfa_claude_refactor_code` | Refactoring code |
| `alfa_claude_add_feature` | Ajouter feature |
| `alfa_claude_document_code` | Générer documentation |
| `alfa_claude_optimize_code` | Optimisation performance |
| `alfa_claude_setup_ci_cd` | Setup CI/CD pipeline |
| `alfa_claude_migrate_code` | Migration code |

**Usage Slack**: `/alfa claude_create_project type="nextjs" name="MyApp"`

---

### 9. Collaboration (11 outils)
Slack, Microsoft 365, Google Workspace

| Outil | Description |
|-------|-------------|
| `alfa_slack_send_message` | Envoyer message Slack |
| `alfa_slack_create_channel` | Créer channel Slack |
| `alfa_slack_manage_users` | Gérer users Slack |
| `alfa_slack_archive_export` | Export/archive Slack |
| `alfa_microsoft365_user_management` | Gestion users Azure AD |
| `alfa_microsoft365_teams_management` | Gestion Teams |
| `alfa_microsoft365_sharepoint` | Gestion SharePoint |
| `alfa_microsoft365_exchange` | Gestion Exchange |
| `alfa_google_workspace_users` | Gestion users Google |
| `alfa_google_workspace_groups` | Gestion groupes Google |
| `alfa_google_workspace_drive` | Gestion Google Drive |

**Usage Slack**: `/alfa slack_send_message channel="general" text="Hello!"`

---

### 10. Infrastructure (9 outils)
OVH, AWS, Vercel, Cloudflare

| Outil | Description |
|-------|-------------|
| `alfa_ovh_domain_management` | Gestion domaines OVH |
| `alfa_ovh_vps_management` | Gestion VPS OVH |
| `alfa_hostinger_management` | Gestion Hostinger |
| `alfa_aws_s3_management` | Gestion S3 buckets |
| `alfa_aws_ec2_management` | Gestion instances EC2 |
| `alfa_aws_lambda_deploy` | Deploy Lambda AWS |
| `alfa_vercel_deploy` | Deploy Vercel |
| `alfa_v0dev_generate` | Générer UI v0.dev |
| `alfa_cloudflare_dns` | Gestion DNS Cloudflare |

**Usage Slack**: `/alfa vercel_deploy project_path="/path/app"`

---

### 11. Business SaaS (11 outils)
PayFit, PennyLane, Social Media

| Outil | Description |
|-------|-------------|
| `alfa_payfit_employees` | Gestion employés PayFit |
| `alfa_payfit_time_off` | Gestion congés PayFit |
| `alfa_pennylane_invoices` | Gestion factures PennyLane |
| `alfa_pennylane_expenses` | Gestion notes de frais |
| `alfa_pennylane_accounting_export` | Export compta PennyLane |
| `alfa_bitwarden_vault` | Gestion coffre Bitwarden |
| `alfa_instagram_post` | Post Instagram |
| `alfa_facebook_page_post` | Post Facebook |
| `alfa_tiktok_post` | Post TikTok |
| `alfa_youtube_upload` | Upload YouTube |
| `alfa_canva_design` | Design Canva |

**Usage Slack**: `/alfa instagram_post caption="New product!" image_url="..."`

---

### 12. CMS (9 outils)
Wix, WordPress, WooCommerce

| Outil | Description |
|-------|-------------|
| `alfa_wix_site_management` | Gestion sites Wix |
| `alfa_wix_page_management` | Gestion pages Wix |
| `alfa_wix_store_management` | Gestion boutique Wix |
| `alfa_wordpress_site_management` | Gestion sites WordPress |
| `alfa_wordpress_content_management` | Gestion contenu WordPress |
| `alfa_wordpress_plugin_management` | Gestion plugins WordPress |
| `alfa_wordpress_theme_management` | Gestion thèmes WordPress |
| `alfa_wordpress_user_management` | Gestion users WordPress |
| `alfa_wordpress_woocommerce` | Gestion WooCommerce |

**Usage Slack**: `/alfa wordpress_content_management action=create_post title="Article"`

---

### 13. Developer (8 outils)
GitHub, Browser Automation

| Outil | Description |
|-------|-------------|
| `alfa_github_repo_management` | Gestion repos GitHub |
| `alfa_github_issues_management` | Gestion issues GitHub |
| `alfa_github_pr_management` | Gestion Pull Requests |
| `alfa_github_actions_management` | Gestion GitHub Actions |
| `alfa_github_release_management` | Gestion releases GitHub |
| `alfa_browser_navigate` | Navigation web auto |
| `alfa_browser_scrape` | Web scraping |
| `alfa_browser_authenticate` | Auth web auto |

**Usage Slack**: `/alfa github_repo_management action=list`

---

### 14. Azure SSO (7 outils)
Single Sign-On Entreprise

| Outil | Description |
|-------|-------------|
| `alfa_azure_sso_app_registration` | Enregistrer app Azure AD |
| `alfa_azure_sso_configure_saml` | Config SSO SAML |
| `alfa_azure_sso_configure_oidc` | Config SSO OIDC |
| `alfa_azure_sso_assign_users` | Assigner users à app SSO |
| `alfa_azure_sso_conditional_access` | Accès conditionnel |
| `alfa_azure_sso_get_metadata` | Métadonnées SSO |
| `alfa_azure_sso_test_connection` | Test connexion SSO |

**Usage Slack**: `/alfa azure_sso_app_registration app_name="MyApp"`

---

### 15. Productivity (8 outils)
Obsidian Vault Management

| Outil | Description |
|-------|-------------|
| `alfa_obsidian_create_note` | Créer note Obsidian |
| `alfa_obsidian_search_notes` | Rechercher dans vault |
| `alfa_obsidian_update_note` | Modifier note |
| `alfa_obsidian_graph_analysis` | Analyser graphe |
| `alfa_obsidian_daily_note` | Daily note |
| `alfa_obsidian_export_vault` | Export vault |
| `alfa_obsidian_template_apply` | Appliquer template |
| `alfa_obsidian_sync_status` | Status sync |

**Usage Slack**: `/alfa obsidian_create_note title="Meeting" content="..."`

---

## 🔧 Configuration Slack

### ✅ Token Validé

**Token**: `xoxb-XXXX-XXXX-XXXXXXXXXXXX` (votre token Slack)
**Bot User**: `alfa`
**Workspace**: LifeOS (lifeosgroupe.slack.com)

### ⚠️ Action Requise

1. **Inviter le bot dans vos channels**:
   ```
   /invite @alfa
   ```

2. **Configurer les slash commands**:
   - URL: https://api.slack.com/apps/A0A73J9107P/slash-commands
   - Ajouter `/alfa` avec webhook URL

3. **Ajouter OAuth Scopes** (si nécessaire):
   - URL: https://api.slack.com/apps/A0A73J9107P/oauth
   - Scopes requis: `chat:write`, `channels:read`, `commands`

---

## 🚀 Utilisation

### Format Général

```
/alfa <tool_name> [key=value] [key=value] ...
```

### Exemples

```bash
# Status ALFA
/alfa status

# Créer dashboard Grafana
/alfa grafana_create_dashboard title="Production Monitoring"

# Envoyer message Slack
/alfa slack_send_message channel="general" text="Hello from ALFA!"

# Lister repos GitHub
/alfa github_repo_management action=list

# Créer note Obsidian
/alfa obsidian_create_note title="Meeting Notes" content="Discussion points..."

# Recherche OSINT
/alfa osint_company_research company="Acme Corp"

# Upload YouTube
/alfa youtube_upload file_path="/path/video.mp4" title="New Video"
```

---

## 📚 Documentation Complète

- **Guide Slack**: `.mcp/SLACK-INTEGRATION.md`
- **Troubleshooting**: `.mcp/SLACK-TROUBLESHOOTING.md`
- **Catalogue Tools**: `.mcp/TOOLS-CATALOG.md`
- **Validation Report**: `.mcp/VALIDATION-REPORT.md`
- **Liste JSON**: `.mcp/tools-list.json`

---

## 🎯 Quick Start

### 1. Démarrer Webhook Server

```bash
cd /Users/arnaud/Documents/ALFA-Agent-Method/.mcp
node slack-webhook.js
```

### 2. Exposer avec Ngrok

```bash
ngrok http 3333
```

### 3. Configurer Slack

URL Slash Command: `https://your-ngrok-url.ngrok.io/slack/command`

### 4. Tester

```
/alfa status
```

---

**🤖 ALFA MCP Server v2.0.0**
129 outils professionnels | 14 domaines | Production Ready ✅
