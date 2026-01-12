# MCP Gateway Docker - Guide Complet pour Agents IA

> **125 outils** pour automatiser GitHub, monitoring, browser, fichiers, et plus encore

**Version**: 1.0.0
**Date**: 2026-01-12
**Gateway**: `docker/mcp-gateway`
**Target**: Agents IA (Claude, GPT, etc.)

---

## 📚 Table des Matières

1. [Introduction](#introduction)
2. [Quick Start pour Agents IA](#quick-start-pour-agents-ia)
3. [10 Catégories d'Outils](#10-catégories-doutils)
4. [Référence Complète](#référence-complète)
5. [Workflows & Patterns](#workflows--patterns)
6. [Troubleshooting](#troubleshooting)

---

## Introduction

### Qu'est-ce que la MCP Gateway ?

La **MCP Gateway Docker** est un conteneur qui expose **125 outils** via le protocole MCP (Model Context Protocol). Ces outils permettent aux agents IA d'interagir avec :

- **GitHub** - Issues, PRs, repos, commits
- **Grafana** - Dashboards, alertes, datasources
- **Prometheus** - Métriques et queries PromQL
- **Loki** - Logs et recherche
- **Browser** - Automation navigateur (Playwright)
- **Fichiers Locaux** - Lecture, écriture, édition
- **Processes** - REPL interactifs, scripts
- **Incidents** - Gestion incidents Grafana
- **OnCall** - Schedules et rotations
- **MCP** - Gestion serveurs MCP

### Architecture

```
┌─────────────────────────────────────────────┐
│         Agent IA (Claude, GPT, etc.)        │
└────────────────────┬────────────────────────┘
                     │ MCP Protocol
┌────────────────────▼────────────────────────┐
│          docker/mcp-gateway                 │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │  125 Outils Disponibles              │  │
│  ├──────────────────────────────────────┤  │
│  │  • Browser (20)                      │  │
│  │  • GitHub (30)                       │  │
│  │  • Grafana (15)                      │  │
│  │  • Prometheus (5)                    │  │
│  │  • Loki (4)                          │  │
│  │  • Desktop Commander (25)            │  │
│  │  • Incidents & OnCall (10)           │  │
│  │  • Pyroscope & Sift (6)              │  │
│  │  • Code Intelligence (2)             │  │
│  │  • MCP Management (6)                │  │
│  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

### Convention de Nommage

**Tous les outils** utilisent le préfixe `mcp__MCP_DOCKER__` :

```
mcp__MCP_DOCKER__browser_navigate
mcp__MCP_DOCKER__issue_write
mcp__MCP_DOCKER__query_prometheus
mcp__MCP_DOCKER__read_file
```

### Prérequis

- Container `docker/mcp-gateway` actif et running
- Connexion MCP établie
- Pour Desktop Commander : chemins autorisés dans configuration

---

## 🚀 Quick Start pour Agents IA

### Premier Appel MCP

**Structure générale** :

```json
{
  "name": "mcp__MCP_DOCKER__tool_name",
  "parameters": {
    "param1": "value",
    "param2": 123
  }
}
```

### Top 10 Outils Essentiels

| Outil | Usage Principal | Exemple |
|-------|-----------------|---------|
| `browser_navigate` | Ouvrir page web | `{"url": "https://example.com"}` |
| `browser_snapshot` | Capturer état page | `{}` (pas de params) |
| `issue_read` | Lire GitHub issue | `{"owner": "org", "repo": "repo", "issue_number": 123, "method": "get"}` |
| `issue_write` | Créer/modifier issue | `{"method": "create", "owner": "org", "repo": "repo", "title": "Bug", "body": "..."}` |
| `create_pull_request` | Créer PR | `{"owner": "org", "repo": "repo", "title": "Fix", "head": "feature", "base": "main"}` |
| `read_file` | Lire fichier local | `{"path": "/absolute/path/file.txt"}` |
| `write_file` | Écrire fichier | `{"path": "/path/file.txt", "content": "...", "mode": "rewrite"}` |
| `query_prometheus` | Query métriques | `{"datasourceUid": "uid", "expr": "up", "startTime": "now-1h", "queryType": "instant"}` |
| `query_loki_logs` | Query logs | `{"datasourceUid": "uid", "logql": "{app=\"api\"}", "limit": 10}` |
| `start_process` | Démarrer REPL | `{"command": "python3 -i", "timeout_ms": 5000}` |

### Workflow Typique : Créer une Issue GitHub

```json
// 1. Lire issues existantes
{
  "name": "mcp__MCP_DOCKER__search_issues",
  "parameters": {
    "query": "is:issue is:open label:bug repo:org/repo"
  }
}

// 2. Créer nouvelle issue
{
  "name": "mcp__MCP_DOCKER__issue_write",
  "parameters": {
    "method": "create",
    "owner": "org",
    "repo": "repo",
    "title": "Bug: Login fails",
    "body": "## Description\n\nLogin page throws 500 error\n\n## Steps to Reproduce\n1. Go to /login\n2. Enter credentials\n3. Click submit",
    "labels": ["bug", "P1"]
  }
}

// 3. Ajouter commentaire
{
  "name": "mcp__MCP_DOCKER__add_issue_comment",
  "parameters": {
    "owner": "org",
    "repo": "repo",
    "issue_number": 456,
    "body": "Investigating this issue now"
  }
}
```

### Paramètres : Requis vs Optionnels

Dans ce guide, les paramètres sont indiqués avec :

- ✅ = **Requis** (l'outil échouera sans)
- ❌ = **Optionnel** (valeur par défaut utilisée si omis)

**Exemple** :

| Paramètre | Requis | Type | Description | Défaut |
|-----------|--------|------|-------------|--------|
| `owner` | ✅ | string | Propriétaire repo | - |
| `page` | ❌ | number | Page de résultats | 1 |

### Gestion d'Erreurs

**Erreurs communes** :

```json
// ❌ Paramètre requis manquant
{
  "error": "Required parameter 'owner' is missing"
}

// ❌ Type incorrect
{
  "error": "Parameter 'page' must be a number, got string"
}

// ❌ Outil non trouvé
{
  "error": "Tool 'mcp__MCP_DOCKER__invalid_tool' not found"
}
```

**Solution** : Toujours vérifier la référence de l'outil avant l'appel.

---

## 🔄 Workflows & Patterns Complets

_Exemples de workflows réels combinant plusieurs outils_

### Workflow 1: Debugging Production

**Scénario**: API en erreur, besoin d'investiguer

```json
// 1. Chercher erreurs dans logs
{
  "name": "mcp__MCP_DOCKER__query_loki_logs",
  "parameters": {
    "datasourceUid": "loki-prod",
    "logql": "{app=\"api\", env=\"prod\"} |= \"error\" |= \"500\"",
    "limit": 50,
    "direction": "backward"
  }
}

// 2. Vérifier métriques CPU/memory
{
  "name": "mcp__MCP_DOCKER__query_prometheus",
  "parameters": {
    "datasourceUid": "prometheus-prod",
    "expr": "rate(container_cpu_usage_seconds_total{name=\"api\"}[5m])",
    "startTime": "now-1h",
    "queryType": "range"
  }
}

// 3. Consulter dashboard existant
{
  "name": "mcp__MCP_DOCKER__search_dashboards",
  "parameters": {"query": "API production"}
}

// 4. Si critique, créer incident
{
  "name": "mcp__MCP_DOCKER__create_incident",
  "parameters": {
    "title": "API 500 errors spike",
    "severity": "critical",
    "roomPrefix": "incident"
  }
}
```

---

### Workflow 2: Feature Development Complet

**Scénario**: Nouvelle feature → Code → PR → Review

```json
// 1. Rechercher code similaire pour inspiration
{
  "name": "mcp__MCP_DOCKER__search_code",
  "parameters": {
    "query": "authentication middleware language:TypeScript org:myorg"
  }
}

// 2. Consulter docs library
{
  "name": "mcp__MCP_DOCKER__resolve-library-id",
  "parameters": {"libraryName": "express"}
}
// Puis:
{
  "name": "mcp__MCP_DOCKER__get-library-docs",
  "parameters": {
    "context7CompatibleLibraryID": "/expressjs/express",
    "topic": "middleware"
  }
}

// 3. Créer branche
{
  "name": "mcp__MCP_DOCKER__create_branch",
  "parameters": {
    "owner": "myorg",
    "repo": "api",
    "branch": "feature/auth-middleware",
    "from_branch": "main"
  }
}

// 4. Modifier fichiers
{
  "name": "mcp__MCP_DOCKER__create_or_update_file",
  "parameters": {
    "owner": "myorg",
    "repo": "api",
    "path": "src/middleware/auth.ts",
    "content": "// Code here",
    "message": "feat: add authentication middleware",
    "branch": "feature/auth-middleware"
  }
}

// 5. Créer PR
{
  "name": "mcp__MCP_DOCKER__create_pull_request",
  "parameters": {
    "owner": "myorg",
    "repo": "api",
    "title": "feat: add authentication middleware",
    "head": "feature/auth-middleware",
    "base": "main",
    "body": "## Changes\\n\\n- JWT verification\\n- Rate limiting\\n\\n## Testing\\n\\n- [x] Unit tests\\n- [x] Integration tests"
  }
}

// 6. Demander review Copilot
{
  "name": "mcp__MCP_DOCKER__request_copilot_review",
  "parameters": {
    "owner": "myorg",
    "repo": "api",
    "pullNumber": 123
  }
}
```

---

### Workflow 3: Analyse Données Locales

**Scénario**: CSV → Analyse pandas → Rapport PDF

```json
// 1. Lire CSV pour aperçu
{
  "name": "mcp__MCP_DOCKER__read_file",
  "parameters": {
    "path": "/Users/arnaud/sales_data.csv",
    "offset": 0,
    "length": 10
  }
}

// 2. Démarrer Python REPL
{
  "name": "mcp__MCP_DOCKER__start_process",
  "parameters": {
    "command": "python3 -i",
    "timeout_ms": 5000
  }
}
// Returns: {"pid": 12345}

// 3. Import pandas
{
  "name": "mcp__MCP_DOCKER__interact_with_process",
  "parameters": {
    "pid": 12345,
    "input": "import pandas as pd\\nimport numpy as np"
  }
}

// 4. Charger données
{
  "name": "mcp__MCP_DOCKER__interact_with_process",
  "parameters": {
    "pid": 12345,
    "input": "df = pd.read_csv('/Users/arnaud/sales_data.csv')"
  }
}

// 5. Analyse
{
  "name": "mcp__MCP_DOCKER__interact_with_process",
  "parameters": {
    "pid": 12345,
    "input": "print(df.describe())"
  }
}

// 6. Générer rapport PDF
{
  "name": "mcp__MCP_DOCKER__write_pdf",
  "parameters": {
    "path": "/Users/arnaud/sales_report.pdf",
    "content": "# Sales Analysis Report\\n\\n## Summary\\n\\n- Total sales: $1.2M\\n- Growth: +15%\\n\\n## Insights\\n\\n..."
  }
}
```

---

### Workflow 4: Setup Monitoring Complet

**Scénario**: Nouveau service → Dashboard → Alertes

```json
// 1. Lister datasources disponibles
{
  "name": "mcp__MCP_DOCKER__list_datasources",
  "parameters": {"type": "prometheus"}
}

// 2. Tester query métrique
{
  "name": "mcp__MCP_DOCKER__query_prometheus",
  "parameters": {
    "datasourceUid": "prometheus-uid",
    "expr": "up{job=\"new-service\"}",
    "startTime": "now-5m",
    "queryType": "instant"
  }
}

// 3. Créer dashboard
{
  "name": "mcp__MCP_DOCKER__update_dashboard",
  "parameters": {
    "dashboard": {
      "title": "New Service Monitoring",
      "panels": [
        {
          "title": "Uptime",
          "targets": [{"expr": "up{job=\"new-service\"}"}]
        }
      ]
    },
    "folderUid": "monitoring-folder"
  }
}

// 4. Setup alerte
{
  "name": "mcp__MCP_DOCKER__create_alert_rule",
  "parameters": {
    "title": "Service Down Alert",
    "condition": "A",
    "data": [{
      "refId": "A",
      "queryType": "instant",
      "expr": "up{job=\"new-service\"} == 0"
    }],
    "noDataState": "Alerting",
    "execErrState": "Alerting",
    "for": "5m",
    "folderUID": "alerts-folder",
    "ruleGroup": "production"
  }
}

// 5. Vérifier contact points
{
  "name": "mcp__MCP_DOCKER__list_contact_points"
}
```

---

### Workflow 5: Web Scraping & Testing

**Scénario**: Tester UI → Screenshots → Validation

```json
// 1. Naviguer vers page
{
  "name": "mcp__MCP_DOCKER__browser_navigate",
  "parameters": {"url": "https://app.example.com/login"}
}

// 2. Capturer état page
{
  "name": "mcp__MCP_DOCKER__browser_snapshot"
}
// Returns: refs pour éléments

// 3. Remplir formulaire login
{
  "name": "mcp__MCP_DOCKER__browser_fill_form",
  "parameters": {
    "fields": [
      {"name": "Email", "type": "textbox", "ref": "email-ref", "value": "test@example.com"},
      {"name": "Password", "type": "textbox", "ref": "pass-ref", "value": "TestPass123"}
    ]
  }
}

// 4. Cliquer submit
{
  "name": "mcp__MCP_DOCKER__browser_click",
  "parameters": {
    "element": "Login button",
    "ref": "submit-button-ref"
  }
}

// 5. Attendre redirection
{
  "name": "mcp__MCP_DOCKER__browser_wait_for",
  "parameters": {"text": "Dashboard", "time": 5}
}

// 6. Screenshot résultat
{
  "name": "mcp__MCP_DOCKER__browser_take_screenshot",
  "parameters": {
    "filename": "login-success.png",
    "fullPage": true
  }
}
```

---

## 🔧 Troubleshooting

### Erreur: "Tool not found"

**Message**: `Tool 'mcp__MCP_DOCKER__tool_name' not found`

**Cause**: Nom outil incorrect ou serveur MCP non activé

**Solution**:
1. Vérifier prefix `mcp__MCP_DOCKER__` présent
2. Utiliser `mcp-find` pour chercher l'outil
3. Vérifier que gateway Docker est active: `docker ps --filter name=mcp-gateway`

---

### Erreur: "Required parameter missing"

**Message**: `Required parameter 'owner' is missing`

**Cause**: Paramètre requis (✅) non fourni

**Solution**:
- Consulter tableau paramètres dans référence
- Tous paramètres marqués ✅ sont obligatoires
- Vérifier types (string vs number vs boolean)

---

### Erreur: "Permission denied" (Desktop Commander)

**Message**: `Error: EACCES: permission denied`

**Cause**: Chemin fichier non autorisé dans configuration

**Solution**:
1. Vérifier `allowedDirectories` dans config Desktop Commander
2. Utiliser chemins absolus (pas relatifs)
3. Exemple config: `"allowedDirectories": ["/Users/arnaud/Documents"]`

---

### Erreur: "Element not found" (Browser)

**Message**: `Element with ref 'xyz' not found`

**Cause**:
- Page a changé depuis `browser_snapshot`
- Ref incorrect
- Page pas complètement chargée

**Solution**:
1. Toujours faire `browser_snapshot` avant interaction
2. Utiliser `browser_wait_for` si page charge lentement
3. Vérifier ref exacte depuis snapshot

---

### Performance: Query Prometheus très lente

**Cause**: Time range trop large ou métrique avec beaucoup de séries

**Solution**:
1. Réduire time range: `now-5m` au lieu de `now-24h`
2. Ajouter labels pour filtrer: `{job="api", env="prod"}`
3. Utiliser `queryType: "instant"` au lieu de `range` si possible

---

### Performance: Dashboard énorme

**Cause**: `get_dashboard_by_uid` retourne tout le JSON (peut être > 100KB)

**Solution**:
1. Utiliser `get_dashboard_summary` pour aperçu
2. Utiliser `get_dashboard_property` avec JSONPath pour données spécifiques
3. Exemple: `{"uid": "dash-uid", "jsonPath": "$.panels[*].title"}`

---

### Erreur: "SHA mismatch" (GitHub update file)

**Message**: `409 Conflict: SHA does not match`

**Cause**: Fichier modifié depuis dernière lecture

**Solution**:
1. Utiliser `get_file_contents` pour obtenir SHA actuel
2. Fournir SHA dans `create_or_update_file`
3. Ou utiliser `push_files` pour commits multiples

---

### Erreur: Process REPL bloqué

**Message**: Pas de response après `interact_with_process`

**Cause**: Commande attend input ou prend trop de temps

**Solution**:
1. Vérifier syntaxe commande (parenthèses fermées, etc.)
2. Augmenter `timeout_ms` si calcul long
3. Utiliser `read_process_output` pour check status
4. Si bloqué: `kill_process` et restart

---

## 📊 Résumé Rapide par Cas d'Usage

### Je veux...

| Besoin | Outils à Utiliser |
|--------|-------------------|
| **Créer issue GitHub** | `issue_write` (method: create) |
| **Créer PR** | `create_pull_request` + `request_copilot_review` |
| **Chercher code** | `search_code` (tous repos GitHub) |
| **Lire logs** | `query_loki_logs` |
| **Vérifier métriques** | `query_prometheus` |
| **Créer dashboard** | `update_dashboard` |
| **Tester page web** | `browser_navigate` → `browser_snapshot` → `browser_click` |
| **Analyser CSV local** | `read_file` → `start_process` (Python) → `interact_with_process` |
| **Créer rapport PDF** | `write_pdf` |
| **Setup alertes** | `create_alert_rule` + `list_contact_points` |
| **Gérer incident** | `create_incident` + `add_activity_to_incident` |
| **Chercher docs library** | `resolve-library-id` → `get-library-docs` |

---

## 📋 10 Catégories d'Outils

### 1. Browser Automation (20 outils)

**Cas d'usage** :
- Tests E2E automatisés
- Scraping web
- Validation UI
- Screenshots et snapshots

**Outils clés** :
- `browser_navigate` - Naviguer vers URL
- `browser_snapshot` - Capturer état page (meilleur que screenshot)
- `browser_click` - Cliquer sur élément
- `browser_fill_form` - Remplir formulaire
- `browser_take_screenshot` - Screenshot PNG/JPEG
- `browser_evaluate` - Exécuter JavaScript

**Quick Example** :
```json
{
  "name": "mcp__MCP_DOCKER__browser_navigate",
  "parameters": {"url": "https://github.com/login"}
}
```

---

### 2. GitHub Integration (30 outils)

**Cas d'usage** :
- Gestion issues et PRs
- Automation développement
- Code review automatisé
- Release management

**Outils clés** :
- `issue_read` / `issue_write` - CRUD issues
- `create_pull_request` / `merge_pull_request` - Workflow PRs
- `search_code` - Recherche code dans tous repos GitHub
- `create_or_update_file` - Modifier fichiers
- `list_commits` - Historique commits

**Quick Example** :
```json
{
  "name": "mcp__MCP_DOCKER__create_pull_request",
  "parameters": {
    "owner": "myorg",
    "repo": "myrepo",
    "title": "feat: add login feature",
    "head": "feature/login",
    "base": "main",
    "body": "## Changes\n\n- Add login page\n- Add auth middleware"
  }
}
```

---

### 3. Grafana & Dashboards (15 outils)

**Cas d'usage** :
- Monitoring et observabilité
- Création dashboards
- Gestion alertes
- Exploration métriques

**Outils clés** :
- `search_dashboards` - Rechercher dashboards
- `get_dashboard_summary` - Résumé dashboard (léger)
- `update_dashboard` - Créer/modifier dashboard
- `create_alert_rule` - Setup alertes
- `list_datasources` - Lister sources de données

**Quick Example** :
```json
{
  "name": "mcp__MCP_DOCKER__search_dashboards",
  "parameters": {
    "query": "production"
  }
}
```

---

### 4. Prometheus (5 outils)

**Cas d'usage** :
- Query métriques
- Exploration labels/métriques
- Debugging performance

**Outils clés** :
- `query_prometheus` - Query PromQL (instant/range)
- `list_prometheus_metric_names` - Lister métriques disponibles
- `list_prometheus_label_names` - Lister labels
- `list_prometheus_label_values` - Valeurs d'un label

**Quick Example** :
```json
{
  "name": "mcp__MCP_DOCKER__query_prometheus",
  "parameters": {
    "datasourceUid": "prometheus-uid",
    "expr": "up{job=\"api\"}",
    "startTime": "now-1h",
    "queryType": "instant"
  }
}
```

---

### 5. Loki (4 outils)

**Cas d'usage** :
- Recherche logs
- Troubleshooting
- Pattern detection
- Audit logs

**Outils clés** :
- `query_loki_logs` - Query LogQL
- `query_loki_stats` - Stats streams (count, bytes)
- `list_loki_label_names` - Labels disponibles
- `list_loki_label_values` - Valeurs label

**Quick Example** :
```json
{
  "name": "mcp__MCP_DOCKER__query_loki_logs",
  "parameters": {
    "datasourceUid": "loki-uid",
    "logql": "{app=\"api\"} |= \"error\"",
    "limit": 20,
    "direction": "backward"
  }
}
```

---

### 6. Desktop Commander (25 outils)

**Cas d'usage** :
- Manipulation fichiers locaux
- REPL interactifs (Python, Node, etc.)
- Analyse données CSV/JSON
- Génération rapports PDF

**Outils clés** :
- `read_file` - Lire fichiers (support PDF, offset/length)
- `write_file` - Écrire/ajouter fichiers
- `start_process` - Démarrer processus (REPL)
- `interact_with_process` - Envoyer commandes au REPL
- `write_pdf` - Créer PDF depuis markdown
- `list_directory` - Lister répertoires (récursif)

**Quick Example** :
```json
{
  "name": "mcp__MCP_DOCKER__read_file",
  "parameters": {
    "path": "/Users/arnaud/data.csv",
    "offset": 0,
    "length": 100
  }
}
```

---

### 7. Incidents & OnCall (10 outils)

**Cas d'usage** :
- Gestion incidents Grafana
- Schedules on-call
- Rotations équipes
- Escalations

**Outils clés** :
- `create_incident` - Créer incident (⚠️ usage judicieux)
- `list_incidents` - Lister incidents (active/resolved)
- `list_oncall_schedules` - Schedules on-call
- `get_current_oncall_users` - Qui est on-call maintenant

**Quick Example** :
```json
{
  "name": "mcp__MCP_DOCKER__get_current_oncall_users",
  "parameters": {
    "scheduleId": "schedule-123"
  }
}
```

---

### 8. Pyroscope & Sift (6 outils)

**Cas d'usage** :
- Profiling performance
- Investigations automatiques
- Detection patterns erreurs
- Analyse requêtes lentes

**Outils clés** :
- `fetch_pyroscope_profile` - Récupérer profil CPU/memory
- `find_error_pattern_logs` - Chercher patterns erreurs (Loki)
- `find_slow_requests` - Chercher requêtes lentes (Tempo)
- `list_sift_investigations` - Lister investigations

**Quick Example** :
```json
{
  "name": "mcp__MCP_DOCKER__find_error_pattern_logs",
  "parameters": {
    "name": "API Errors Investigation",
    "labels": {
      "app": "api",
      "env": "prod"
    },
    "start": "2026-01-12T10:00:00Z",
    "end": "2026-01-12T11:00:00Z"
  }
}
```

---

### 9. Code Intelligence (2 outils)

**Cas d'usage** :
- Documentation libraries
- Recherche API
- Exemples d'usage

**Outils clés** :
- `resolve-library-id` - Résoudre nom library → Context7 ID
- `get-library-docs` - Récupérer docs (avec focus topic)

**Quick Example** :
```json
// 1. Résoudre ID
{
  "name": "mcp__MCP_DOCKER__resolve-library-id",
  "parameters": {
    "libraryName": "react"
  }
}
// Returns: {"context7CompatibleLibraryID": "/facebook/react"}

// 2. Récupérer docs
{
  "name": "mcp__MCP_DOCKER__get-library-docs",
  "parameters": {
    "context7CompatibleLibraryID": "/facebook/react",
    "topic": "hooks"
  }
}
```

---

### 10. MCP Management (6 outils)

**Cas d'usage** :
- Découverte serveurs MCP
- Gestion configuration
- Activation outils dynamique

**Outils clés** :
- `mcp-find` - Chercher serveurs MCP dans catalogue
- `mcp-add` - Ajouter serveur à session
- `mcp-config-set` - Configurer serveur
- `mcp-create-profile` - Sauvegarder état gateway

**Quick Example** :
```json
{
  "name": "mcp__MCP_DOCKER__mcp-find",
  "parameters": {
    "query": "slack",
    "limit": 5
  }
}
```

---

