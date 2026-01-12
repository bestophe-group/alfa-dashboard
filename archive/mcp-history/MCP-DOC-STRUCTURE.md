# Structure Documentation MCP Gateway - Pour Agents IA

**Date**: 2026-01-12
**Objectif**: Documentation exhaustive et pédagogique

---

## 📚 Structure Proposée : docs/MCP-GATEWAY.md

### 1. Introduction (~ 50 lignes)
**Pour**: Comprendre ce qu'est la MCP Gateway

```markdown
# MCP Gateway Docker - Guide Complet pour Agents IA

## Qu'est-ce que la MCP Gateway ?
- Architecture MCP (Model Context Protocol)
- Rôle de la gateway Docker
- 125 outils disponibles en 10 catégories

## Prérequis
- Container docker/mcp-gateway actif
- Connexion via MCP client

## Convention de Nommage
- Prefix `mcp__MCP_DOCKER__` pour tous les outils
- Format: `mcp__MCP_DOCKER__category_action`
```

### 2. Quick Start pour Agents IA (~ 100 lignes)
**Pour**: Démarrer rapidement sans lire 2000 lignes

```markdown
## 🚀 Quick Start pour Agents IA

### Premier Appel
Comment utiliser un outil MCP :
- Structure d'appel
- Paramètres requis vs optionnels
- Format JSON des paramètres

### Top 10 Outils à Connaître
1. browser_navigate + browser_snapshot (web)
2. issue_read + issue_write (GitHub issues)
3. create_pull_request + pull_request_read (GitHub PRs)
4. read_file + write_file (fichiers locaux)
5. query_prometheus (métriques)
6. query_loki_logs (logs)
7. search_dashboards + get_dashboard_summary (Grafana)
8. start_process + interact_with_process (REPL)
9. search_code (recherche code GitHub)
10. resolve-library-id + get-library-docs (docs libraries)

### Patterns d'Usage Communs
- Workflow GitHub: chercher issue → lire → commenter → créer PR
- Debugging: lire logs → chercher patterns → créer incident
- Analysis: lire fichiers → démarrer REPL Python → analyser données
- Monitoring: query métriques → créer dashboard → setup alertes
```

### 3. Catégories d'Outils (~ 200 lignes)
**Pour**: Vue d'ensemble organisée

```markdown
## 📋 10 Catégories d'Outils

### 1. Browser Automation (20 outils)
**Cas d'usage**: Tests E2E, scraping, automation web
**Outils clés**: navigate, snapshot, click, fill_form

### 2. GitHub Integration (30 outils)
**Cas d'usage**: Gestion issues/PRs, automation dev
**Outils clés**: issue_write, create_pull_request, search_code

### 3. Grafana & Dashboards (15 outils)
**Cas d'usage**: Monitoring, dashboards, visualisation
**Outils clés**: search_dashboards, update_dashboard

### 4. Prometheus (5 outils)
**Cas d'usage**: Métriques, alerting
**Outils clés**: query_prometheus, list_prometheus_metric_names

### 5. Loki (4 outils)
**Cas d'usage**: Logs, troubleshooting
**Outils clés**: query_loki_logs, query_loki_stats

### 6. Desktop Commander (25 outils)
**Cas d'usage**: Fichiers, processes, REPL interactifs
**Outils clés**: read_file, write_file, start_process

### 7. Incidents & OnCall (10 outils)
**Cas d'usage**: Gestion incidents, on-call
**Outils clés**: create_incident, get_current_oncall_users

### 8. Pyroscope & Sift (6 outils)
**Cas d'usage**: Profiling, investigations
**Outils clés**: fetch_pyroscope_profile, find_error_pattern_logs

### 9. Code Intelligence (2 outils)
**Cas d'usage**: Documentation libraries
**Outils clés**: get-library-docs

### 10. MCP Management (6 outils)
**Cas d'usage**: Gestion serveurs MCP
**Outils clés**: mcp-find, mcp-add
```

### 4. Guide Détaillé par Outil (~ 1500 lignes)
**Pour**: Référence complète avec exemples

```markdown
## 📖 Référence Complète des Outils

### Format par Outil

#### `nom_outil`
**Description**: Que fait cet outil en 1 phrase

**Quand l'utiliser**:
- Cas d'usage 1
- Cas d'usage 2

**Paramètres**:
| Nom | Type | Requis | Description | Défaut |
|-----|------|--------|-------------|--------|
| param1 | string | ✅ | Description | - |
| param2 | number | ❌ | Description | 10 |

**Exemple Simple**:
```json
{
  "param1": "valeur",
  "param2": 20
}
```

**Exemple Avancé**:
[Cas d'usage complexe avec contexte]

**Output Attendu**:
[Description du retour]

**Erreurs Communes**:
- Erreur 1: cause + solution
- Erreur 2: cause + solution

**Outils Associés**:
- outil_1 (workflow avant/après)
- outil_2 (alternative)

---
```

### 5. Workflows & Patterns (~ 200 lignes)
**Pour**: Comprendre les usages réels

```markdown
## 🔄 Workflows Complets

### Workflow 1: Débugger une Application
1. `query_loki_logs` - Chercher erreurs dans logs
2. `query_prometheus` - Vérifier métriques (CPU, mémoire)
3. `get_dashboard_summary` - Consulter dashboard existant
4. `create_incident` - Créer incident si nécessaire

### Workflow 2: Créer Feature + PR
1. `search_code` - Trouver code similaire
2. `get-library-docs` - Consulter docs library
3. `create_branch` - Créer branche
4. `create_or_update_file` - Modifier fichiers
5. `create_pull_request` - Créer PR
6. `request_copilot_review` - Demander review

### Workflow 3: Analyser Données Locales
1. `read_file` - Lire CSV/JSON
2. `start_process` - Démarrer Python REPL
3. `interact_with_process` - Charger pandas
4. `interact_with_process` - Analyser données
5. `write_pdf` - Exporter rapport

### Workflow 4: Monitoring Setup
1. `list_datasources` - Lister datasources
2. `query_prometheus` - Tester queries
3. `update_dashboard` - Créer/modifier dashboard
4. `create_alert_rule` - Setup alertes
5. `list_contact_points` - Configurer notifications
```

### 6. Troubleshooting (~ 100 lignes)
**Pour**: Résoudre problèmes courants

```markdown
## 🔧 Troubleshooting

### Erreur: "Tool not found"
**Cause**: Outil non activé ou nom incorrect
**Solution**:
- Vérifier prefix `mcp__MCP_DOCKER__`
- Utiliser `mcp-find` pour chercher l'outil

### Erreur: "Required parameter missing"
**Cause**: Paramètre requis non fourni
**Solution**: Consulter tableau params dans référence

### Erreur: "Permission denied"
**Cause**: Accès fichier refusé (Desktop Commander)
**Solution**: Vérifier `allowedDirectories` dans config

### Performance: Outil très lent
**Cause**: Query trop large ou dashboard trop gros
**Solution**:
- Limiter time range
- Utiliser `get_dashboard_summary` au lieu de `get_dashboard_by_uid`
- Paginer résultats

### Browser: "Element not found"
**Cause**: Sélecteur incorrect ou page pas chargée
**Solution**:
- Utiliser `browser_snapshot` avant interaction
- Ajouter `browser_wait_for` si nécessaire
```

---

## 📏 Taille Estimée Finale

| Section | Lignes | % |
|---------|--------|---|
| Introduction | 50 | 2% |
| Quick Start | 100 | 5% |
| Catégories | 200 | 10% |
| Référence Outils (125 outils × 12 lignes) | 1500 | 75% |
| Workflows | 200 | 10% |
| Troubleshooting | 100 | 5% |
| **TOTAL** | **~2150 lignes** | 100% |

---

## 🎯 Principes de Rédaction

### Pour Agents IA

1. **Clarté > Concision**
   - Être explicite sur ce que fait l'outil
   - Donner des exemples concrets
   - Expliquer QUAND utiliser (pas juste COMMENT)

2. **Exemples JSON Réels**
   - Pas de `"..."` ou placeholders
   - Valeurs réalistes et testables
   - Commentaires inline si nécessaire

3. **Contexte d'Usage**
   - Quand utiliser cet outil vs alternatives
   - Outils à utiliser avant/après (workflows)
   - Erreurs communes et solutions

4. **Pas d'Ambiguïté**
   - Paramètres requis clairement identifiés (✅/❌)
   - Types explicites (string/number/boolean/object/array)
   - Valeurs par défaut indiquées

5. **Apprentissage Progressif**
   - Quick Start = 10 outils essentiels
   - Catégories = vue d'ensemble
   - Référence = détails exhaustifs

---

## 🔄 Fichiers à Créer/Modifier

### Nouveaux Fichiers
1. `docs/MCP-GATEWAY.md` (~2150 lignes)
2. `docs/MCP-QUICKSTART.md` (~300 lignes) - Guide rapide séparé

### Fichiers à Modifier
1. `README.md` - Section MCP (+50 lignes)
2. `alfa-dashboard/CHANGELOG.md` - Version 1.1.1 (+30 lignes)

### Commits
1. `docs(mcp): create comprehensive MCP Gateway guide (125 tools)`
2. `docs(mcp): add quick-start guide for AI agents`
3. `docs(readme): add MCP Gateway section`
4. `docs(changelog): version 1.1.1 - MCP Gateway documentation`

---

**✅ Structure Validée - Prêt pour BUILD**
