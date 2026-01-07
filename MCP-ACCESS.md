# ALFA MCP Server - Access Configuration

## ✅ Status

ALFA est maintenant accessible via MCP (Model Context Protocol) depuis :

- ✅ **Claude Code CLI** (ce terminal)
- ✅ **Claude Desktop**
- ✅ **Cursor IDE**

## 🔧 Configuration

### Claude Desktop
Fichier: `~/Library/Application Support/Claude/claude_desktop_config.json`

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

### Cursor
Fichier: `~/.cursor/mcp.json`

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
Le serveur MCP est accessible directement via les outils disponibles.

## 🛠️ Outils MCP Disponibles

### 1. `alfa_status`
Affiche le statut de tous les services ALFA

```
Utilisation: alfa_status
```

### 2. `alfa_logs`
Récupère les logs d'un service

```
Paramètres:
- service: nom du service (traefik, postgres, n8n, prometheus, etc.)
- lines: nombre de lignes (défaut: 50)
```

### 3. `alfa_restart`
Redémarre un service

```
Paramètres:
- service: nom du service à redémarrer
```

### 4. `alfa_health`
Vérifie l'état de santé de tous les services

```
Utilisation: alfa_health
```

### 5. `alfa_metrics`
Exécute une requête PromQL sur Prometheus

```
Paramètres:
- query: requête PromQL
Exemple: up{job="traefik"}
```

### 6. `alfa_workflows`
Liste les workflows n8n

```
Paramètres:
- priority: filtre par priorité (p0, p1, p2, p3) - optionnel
```

### 7. `alfa_db_query`
Exécute une requête SQL sur PostgreSQL

```
Paramètres:
- database: nom de la base (alfa, backstage, service_desk)
- query: requête SQL
Exemple: SELECT * FROM service_catalog LIMIT 10;
```

## 📋 Exemples d'Utilisation

### Dans Claude Desktop ou Cursor

```
Quelle est la santé des services ALFA ?
→ Utilise alfa_health

Montre-moi les logs de Prometheus
→ Utilise alfa_logs avec service="prometheus"

Combien de workflows P0 existent ?
→ Utilise alfa_workflows avec priority="p0"

Quel est le CPU usage de Traefik ?
→ Utilise alfa_metrics avec query="rate(container_cpu_usage_seconds_total{name='alfa-traefik'}[5m])"

Quels services sont dans le Service Desk ?
→ Utilise alfa_db_query avec database="alfa", query="SELECT slug, name FROM service_catalog"
```

## 🔄 Redémarrage Requis

**Important:** Après modification des fichiers de configuration MCP :

1. **Claude Desktop**: Quitter et relancer l'application
2. **Cursor**: Redémarrer l'éditeur
3. **Claude Code CLI**: Pas de redémarrage nécessaire

## 🧪 Test de Connexion

Pour tester la connexion MCP :

```bash
# Test direct du serveur
node /Users/arnaud/Documents/ALFA-Agent-Method/.mcp/alfa-server.js
```

Le serveur devrait afficher : `ALFA MCP Server running on stdio`

## 📦 Stack ALFA Actuel

Services en cours d'exécution :
- ✅ Traefik (reverse proxy)
- ✅ PostgreSQL (base de données)
- ✅ Redis (cache)
- ✅ n8n (workflows)
- ✅ Uptime Kuma (monitoring)

À déployer (via `docker compose up -d`):
- Prometheus (métriques)
- Loki (logs)
- Grafana (dashboards)
- Alertmanager (alertes)
- Falco (sécurité runtime)
- Backstage (portail développeur)

## 🚀 Démarrage du Stack Complet

```bash
cd /Users/arnaud/Documents/ALFA-Agent-Method/alfa-dashboard
docker compose up -d
```

## 📚 Documentation

- [README.md](./README.md) - Documentation principale
- [IMPLEMENTATION-COMPLETE.md](./IMPLEMENTATION-COMPLETE.md) - Résumé d'implémentation
- [alfa-dashboard/README.md](./alfa-dashboard/README.md) - Guide du dashboard

---

🤖 ALFA MCP Server v1.0.0
