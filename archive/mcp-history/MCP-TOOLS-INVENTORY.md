# MCP Gateway Docker - Inventaire Complet des Outils

**Date**: 2026-01-12
**Gateway**: docker/mcp-gateway
**Total Outils**: 125+

---

## 📊 Vue d'Ensemble

| Catégorie | Nombre d'Outils | Prefix |
|-----------|-----------------|--------|
| **Browser Automation** | 20 | `browser_*` |
| **GitHub Integration** | 30 | GitHub operations |
| **Grafana & Monitoring** | 25 | Grafana, Prometheus, Loki |
| **Desktop Commander** | 25 | File ops, processes |
| **Code Intelligence** | 2 | Library docs |
| **MCP Management** | 6 | mcp-* |
| **Incidents & OnCall** | 10 | Incidents, Grafana OnCall |
| **Resources** | 2 | MCP resources |

---

## 1️⃣ BROWSER AUTOMATION (20 outils)

### Navigation
- `browser_navigate` - Naviguer vers une URL
- `browser_navigate_back` - Retour page précédente
- `browser_close` - Fermer la page
- `browser_tabs` - Gérer les onglets (list/new/close/select)

### Interactions
- `browser_click` - Cliquer sur un élément
- `browser_hover` - Survoler un élément
- `browser_type` - Saisir du texte
- `browser_press_key` - Appuyer sur une touche
- `browser_drag` - Drag & drop
- `browser_select_option` - Sélectionner option dropdown

### Forms & Upload
- `browser_fill_form` - Remplir formulaire multiple champs
- `browser_file_upload` - Upload fichiers

### Inspection
- `browser_snapshot` - Capture snapshot accessibilité (meilleur que screenshot)
- `browser_take_screenshot` - Prendre screenshot (PNG/JPEG)
- `browser_console_messages` - Récupérer messages console
- `browser_network_requests` - Voir requêtes réseau

### Evaluation
- `browser_evaluate` - Exécuter JavaScript
- `browser_run_code` - Exécuter code Playwright

### Dialogs & Resize
- `browser_handle_dialog` - Gérer dialogues (alert/confirm/prompt)
- `browser_resize` - Redimensionner fenêtre
- `browser_wait_for` - Attendre texte/temps
- `browser_install` - Installer navigateur

---

## 2️⃣ GITHUB INTEGRATION (30 outils)

### Issues
- `issue_read` - Lire issue (get/comments/sub-issues/labels)
- `issue_write` - Créer/modifier issue
- `sub_issue_write` - Gérer sous-issues (add/remove/reprioritize)
- `add_issue_comment` - Ajouter commentaire
- `search_issues` - Rechercher issues
- `list_issues` - Lister issues (avec filtres/pagination)
- `list_issue_types` - Types d'issues disponibles
- `get_label` - Obtenir label spécifique

### Pull Requests
- `pull_request_read` - Lire PR (get/diff/status/files/comments/reviews)
- `pull_request_review_write` - Créer/soumettre/supprimer review
- `add_comment_to_pending_review` - Ajouter commentaire à review
- `create_pull_request` - Créer nouvelle PR
- `update_pull_request` - Modifier PR existante
- `update_pull_request_branch` - Mettre à jour branche PR
- `merge_pull_request` - Merger PR
- `request_copilot_review` - Demander review Copilot
- `assign_copilot_to_issue` - Assigner Copilot à issue
- `list_pull_requests` - Lister PRs
- `search_pull_requests` - Rechercher PRs

### Repositories
- `create_repository` - Créer nouveau repo
- `fork_repository` - Forker un repo
- `search_repositories` - Rechercher repos
- `get_file_contents` - Lire fichier/dossier

### Branches & Commits
- `create_branch` - Créer branche
- `list_branches` - Lister branches
- `get_commit` - Détails commit (avec diff optionnel)
- `list_commits` - Lister commits (avec filtres)

### Files
- `create_or_update_file` - Créer/modifier fichier
- `delete_file` - Supprimer fichier
- `push_files` - Push multiples fichiers (1 commit)

### Releases & Tags
- `list_releases` - Lister releases
- `get_latest_release` - Dernière release
- `get_release_by_tag` - Release par tag
- `list_tags` - Lister tags
- `get_tag` - Détails tag

### Teams & Users
- `get_me` - Infos utilisateur authentifié
- `get_teams` - Teams de l'utilisateur
- `get_team_members` - Membres d'une team
- `search_users` - Rechercher utilisateurs

### Search
- `search_code` - Recherche code (tous repos GitHub)

---

## 3️⃣ GRAFANA & MONITORING (25 outils)

### Dashboards
- `search_dashboards` - Rechercher dashboards
- `get_dashboard_by_uid` - Dashboard complet (⚠️ gros)
- `get_dashboard_summary` - Résumé dashboard (léger)
- `get_dashboard_property` - Propriété spécifique (JSONPath)
- `get_dashboard_panel_queries` - Queries des panels
- `update_dashboard` - Créer/modifier dashboard (full JSON ou patch)
- `generate_deeplink` - Générer lien dashboard/panel/explore

### Datasources
- `list_datasources` - Lister datasources (avec filtre type)
- `get_datasource_by_uid` - Détails datasource par UID
- `get_datasource_by_name` - Détails datasource par nom

### Folders
- `search_folders` - Rechercher dossiers
- `create_folder` - Créer dossier

### Alerts
- `list_alert_rules` - Lister règles d'alerte
- `get_alert_rule_by_uid` - Règle d'alerte par UID
- `create_alert_rule` - Créer règle d'alerte
- `update_alert_rule` - Modifier règle d'alerte
- `delete_alert_rule` - Supprimer règle d'alerte
- `list_contact_points` - Lister points de contact

### Annotations
- `get_annotations` - Récupérer annotations
- `get_annotation_tags` - Tags d'annotations
- `create_annotation` - Créer annotation
- `create_graphite_annotation` - Créer annotation Graphite
- `update_annotation` - Modifier annotation (full)
- `patch_annotation` - Modifier annotation (partiel)

### Prometheus Queries
- `query_prometheus` - Query PromQL (instant/range)
- `list_prometheus_metric_names` - Noms métriques
- `list_prometheus_metric_metadata` - Métadonnées métriques
- `list_prometheus_label_names` - Noms labels
- `list_prometheus_label_values` - Valeurs d'un label

### Loki Queries
- `query_loki_logs` - Query LogQL (logs ou métriques)
- `query_loki_stats` - Stats streams (count, bytes)
- `list_loki_label_names` - Noms labels Loki
- `list_loki_label_values` - Valeurs label Loki

### Pyroscope (Profiling)
- `list_pyroscope_profile_types` - Types de profils
- `list_pyroscope_label_names` - Noms labels profils
- `list_pyroscope_label_values` - Valeurs label profils
- `fetch_pyroscope_profile` - Récupérer profil (DOT format)

---

## 4️⃣ INCIDENTS & ONCALL (10 outils)

### Incidents (Grafana Incident)
- `list_incidents` - Lister incidents (active/resolved/drill)
- `get_incident` - Détails incident par ID
- `create_incident` - Créer incident (⚠️ usage judicieux)
- `add_activity_to_incident` - Ajouter note à incident

### OnCall (Grafana OnCall)
- `list_alert_groups` - Groupes d'alertes (avec filtres)
- `get_alert_group` - Détails groupe alerte
- `list_oncall_schedules` - Schedules on-call
- `get_oncall_shift` - Détails shift on-call
- `get_current_oncall_users` - Utilisateurs actuellement on-call
- `list_oncall_teams` - Teams on-call
- `list_oncall_users` - Utilisateurs on-call

---

## 5️⃣ SIFT (Investigations) (3 outils)

### Investigations
- `list_sift_investigations` - Lister investigations
- `get_sift_investigation` - Détails investigation par UUID
- `get_sift_analysis` - Analyse spécifique d'investigation

### Analyses Automatiques
- `find_error_pattern_logs` - Chercher patterns erreurs (Loki)
- `find_slow_requests` - Chercher requêtes lentes (Tempo)

---

## 6️⃣ TEAMS & USERS (3 outils)

### Grafana Teams
- `list_teams` - Rechercher teams Grafana
- `list_users_by_org` - Lister utilisateurs par org

### Assertions (Monitoring)
- `get_assertions` - Résumé assertions pour entité

---

## 7️⃣ DESKTOP COMMANDER (25 outils)

### File Operations
- `read_file` - Lire fichier/URL (offset/length, PDF support)
- `read_multiple_files` - Lire multiples fichiers
- `write_file` - Écrire/ajouter fichier (rewrite/append)
- `write_pdf` - Créer/modifier PDF (markdown → PDF)
- `edit_block` - Édition chirurgicale (old_string → new_string)
- `move_file` - Déplacer/renommer
- `get_file_info` - Métadonnées fichier (taille, dates, permissions)

### Directory Operations
- `list_directory` - Lister répertoire (récursif avec depth)
- `create_directory` - Créer répertoire

### Process Management
- `start_process` - Démarrer processus (avec smart detection)
- `interact_with_process` - Envoyer input à processus (REPL)
- `read_process_output` - Lire output processus
- `list_processes` - Lister processus actifs
- `list_sessions` - Lister sessions terminal
- `kill_process` - Tuer processus
- `force_terminate` - Forcer arrêt session

### Search
- `start_search` - Lancer recherche streaming (files/content)
- `get_more_search_results` - Récupérer plus de résultats
- `stop_search` - Arrêter recherche
- `list_searches` - Lister recherches actives

### Configuration
- `get_config` - Configuration serveur (JSON)
- `set_config_value` - Modifier config (⚠️ chat séparé)

### Utilities
- `get_recent_tool_calls` - Historique appels outils
- `get_usage_stats` - Stats d'usage
- `get_prompts` - Prompts onboarding
- `give_feedback_to_desktop_commander` - Formulaire feedback

---

## 8️⃣ CODE INTELLIGENCE (2 outils)

### Documentation Libraries
- `resolve-library-id` - Résoudre nom → Context7 library ID
- `get-library-docs` - Récupérer docs librairie (focus topic)

**Workflow**: `resolve-library-id("react")` → `get-library-docs("/facebook/react", "hooks")`

---

## 9️⃣ MCP MANAGEMENT (6 outils)

### Server Management
- `mcp-find` - Chercher serveurs MCP dans catalogue
- `mcp-add` - Ajouter serveur MCP à session
- `mcp-remove` - Retirer serveur MCP
- `mcp-config-set` - Configurer serveur MCP
- `mcp-exec` - Exécuter outil MCP non visible
- `mcp-create-profile` - Sauvegarder état gateway comme profil

---

## 🔟 MCP RESOURCES (2 outils)

### Resources
- `ListMcpResourcesTool` - Lister resources MCP disponibles
- `ReadMcpResourceTool` - Lire resource MCP (server + URI)

---

## 📋 RÉSUMÉ PAR DOMAINE

### Développement
- GitHub (30 outils) - Issues, PRs, repos, commits
- Code Intelligence (2 outils) - Docs libraries
- Desktop Commander (25 outils) - Files, processes

### Monitoring & Observability
- Grafana (15 outils) - Dashboards, alerts, datasources
- Prometheus (5 outils) - Métriques
- Loki (4 outils) - Logs
- Pyroscope (3 outils) - Profiling
- Sift (3 outils) - Investigations

### Operations
- Incidents (4 outils) - Gestion incidents
- OnCall (6 outils) - Schedules on-call
- Teams (3 outils) - Gestion équipes

### Automation
- Browser (20 outils) - Automation navigateur
- MCP Management (6 outils) - Orchestration

---

**Total**: ~125 outils répartis en 10 catégories

**Next**: Documentation détaillée avec exemples pour chaque outil
