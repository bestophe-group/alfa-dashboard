# MCP Gateway - Quick Start pour Agents IA

> Démarrez avec les outils MCP en 5 minutes

**Version**: 1.0.0
**Date**: 2026-01-12
**Pour**: Agents IA qui découvrent MCP Gateway Docker

---

## 🎯 C'est Quoi ?

**125 outils** via MCP pour automatiser :
- GitHub (issues, PRs, code)
- Monitoring (Grafana, Prometheus, Loki)
- Browser automation
- Fichiers locaux
- Et plus...

**Prefix**: Tous les outils commencent par `mcp__MCP_DOCKER__`

---

## ⚡ Top 10 Outils Essentiels

### 1. GitHub Issues

```json
// Créer issue
{
  "name": "mcp__MCP_DOCKER__issue_write",
  "parameters": {
    "method": "create",
    "owner": "myorg",
    "repo": "myrepo",
    "title": "Bug: API timeout",
    "body": "Description...",
    "labels": ["bug", "P1"]
  }
}
```

### 2. GitHub Pull Requests

```json
// Créer PR
{
  "name": "mcp__MCP_DOCKER__create_pull_request",
  "parameters": {
    "owner": "myorg",
    "repo": "myrepo",
    "title": "feat: add feature",
    "head": "feature/name",
    "base": "main"
  }
}
```

### 3. Recherche Code

```json
// Chercher dans tous repos GitHub
{
  "name": "mcp__MCP_DOCKER__search_code",
  "parameters": {
    "query": "language:Python pandas org:myorg"
  }
}
```

### 4. Lire Fichier Local

```json
{
  "name": "mcp__MCP_DOCKER__read_file",
  "parameters": {
    "path": "/absolute/path/file.csv",
    "offset": 0,
    "length": 100
  }
}
```

### 5. Écrire Fichier

```json
{
  "name": "mcp__MCP_DOCKER__write_file",
  "parameters": {
    "path": "/absolute/path/output.txt",
    "content": "Hello World",
    "mode": "rewrite"
  }
}
```

### 6. Python REPL

```json
// Démarrer Python
{
  "name": "mcp__MCP_DOCKER__start_process",
  "parameters": {
    "command": "python3 -i",
    "timeout_ms": 5000
  }
}
// Returns: {"pid": 12345}

// Envoyer commandes
{
  "name": "mcp__MCP_DOCKER__interact_with_process",
  "parameters": {
    "pid": 12345,
    "input": "print('Hello')"
  }
}
```

### 7. Logs (Loki)

```json
{
  "name": "mcp__MCP_DOCKER__query_loki_logs",
  "parameters": {
    "datasourceUid": "loki-uid",
    "logql": "{app=\"api\"} |= \"error\"",
    "limit": 50
  }
}
```

### 8. Métriques (Prometheus)

```json
{
  "name": "mcp__MCP_DOCKER__query_prometheus",
  "parameters": {
    "datasourceUid": "prom-uid",
    "expr": "up{job=\"api\"}",
    "startTime": "now-1h",
    "queryType": "instant"
  }
}
```

### 9. Browser Automation

```json
// Naviguer
{
  "name": "mcp__MCP_DOCKER__browser_navigate",
  "parameters": {"url": "https://example.com"}
}

// Snapshot (avant interactions)
{
  "name": "mcp__MCP_DOCKER__browser_snapshot"
}

// Click
{
  "name": "mcp__MCP_DOCKER__browser_click",
  "parameters": {
    "element": "Login button",
    "ref": "ref-from-snapshot"
  }
}
```

### 10. Dashboards Grafana

```json
// Chercher
{
  "name": "mcp__MCP_DOCKER__search_dashboards",
  "parameters": {"query": "production"}
}

// Résumé (léger)
{
  "name": "mcp__MCP_DOCKER__get_dashboard_summary",
  "parameters": {"uid": "dash-uid"}
}
```

---

## 🔄 Workflows Complets

### Workflow 1: Debug Production

```json
// 1. Logs erreurs
{"name": "mcp__MCP_DOCKER__query_loki_logs", "parameters": {...}}

// 2. Métriques CPU
{"name": "mcp__MCP_DOCKER__query_prometheus", "parameters": {...}}

// 3. Si critique, incident
{"name": "mcp__MCP_DOCKER__create_incident", "parameters": {...}}
```

### Workflow 2: Analyse CSV

```json
// 1. Lire CSV
{"name": "mcp__MCP_DOCKER__read_file", "parameters": {"path": "/data.csv", "length": 10}}

// 2. Start Python
{"name": "mcp__MCP_DOCKER__start_process", "parameters": {"command": "python3 -i", "timeout_ms": 5000}}

// 3. Load pandas
{"name": "mcp__MCP_DOCKER__interact_with_process", "parameters": {"pid": 12345, "input": "import pandas as pd"}}

// 4. Read CSV
{"name": "mcp__MCP_DOCKER__interact_with_process", "parameters": {"pid": 12345, "input": "df = pd.read_csv('/data.csv')"}}

// 5. Analyze
{"name": "mcp__MCP_DOCKER__interact_with_process", "parameters": {"pid": 12345, "input": "print(df.describe())"}}
```

### Workflow 3: Créer Feature + PR

```json
// 1. Search code examples
{"name": "mcp__MCP_DOCKER__search_code", "parameters": {"query": "auth middleware"}}

// 2. Create branch
{"name": "mcp__MCP_DOCKER__create_branch", "parameters": {...}}

// 3. Update files
{"name": "mcp__MCP_DOCKER__create_or_update_file", "parameters": {...}}

// 4. Create PR
{"name": "mcp__MCP_DOCKER__create_pull_request", "parameters": {...}}

// 5. Request review
{"name": "mcp__MCP_DOCKER__request_copilot_review", "parameters": {...}}
```

---

## 🚨 Erreurs Communes

| Erreur | Solution |
|--------|----------|
| "Tool not found" | Vérifier prefix `mcp__MCP_DOCKER__` |
| "Required parameter missing" | Vérifier paramètres requis (✅) |
| "Permission denied" | Vérifier `allowedDirectories` config |
| "Element not found" (browser) | Faire `browser_snapshot` avant interaction |
| Query Prometheus lente | Réduire time range (`now-5m` vs `now-24h`) |

---

## 📚 10 Catégories d'Outils

| Catégorie | Nombre | Exemples |
|-----------|--------|----------|
| **Browser** | 20 | navigate, click, snapshot, screenshot |
| **GitHub** | 30 | issues, PRs, commits, search_code |
| **Grafana** | 15 | dashboards, alerts, datasources |
| **Prometheus** | 5 | query, metrics, labels |
| **Loki** | 4 | logs, stats, labels |
| **Desktop Commander** | 25 | files, processes, REPL, PDF |
| **Incidents/OnCall** | 10 | create_incident, schedules |
| **Pyroscope/Sift** | 6 | profiling, investigations |
| **Code Intelligence** | 2 | library docs |
| **MCP Management** | 6 | find, add, configure servers |

---

## 📖 Documentation Complète

**Pour plus de détails**, consulter [MCP-GATEWAY.md](./MCP-GATEWAY.md) :
- Référence complète des 125 outils
- Exemples avancés
- Troubleshooting détaillé
- Workflows complexes

---

## 🎯 Résumé : Je veux...

| Besoin | Outil |
|--------|-------|
| Créer issue | `issue_write` (method: create) |
| Créer PR | `create_pull_request` |
| Chercher code | `search_code` |
| Lire logs | `query_loki_logs` |
| Métriques | `query_prometheus` |
| Analyser CSV | `start_process` + `interact_with_process` |
| Test browser | `browser_navigate` + `browser_snapshot` |
| Créer PDF | `write_pdf` |

---

**🚀 Prêt à démarrer !** Consultez [MCP-GATEWAY.md](./MCP-GATEWAY.md) pour la référence complète.
