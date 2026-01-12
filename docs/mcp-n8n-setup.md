# Configuration MCP Server n8n - Guide Complet

**Date**: 2026-01-12
**Objectif**: Connecter Claude Code CLI au serveur MCP n8n intégré

---

## 📋 PRÉREQUIS

### 1. Token n8n API (À GÉNÉRER)

**Étapes**:
1. Ouvrir n8n: http://localhost:5678
2. Aller dans: **Settings → API**
3. Cliquer: **Create API Key**
4. Copier le token (format: `n8n_api_XXXXX-rL0`)

**⚠️ IMPORTANT**: Garde ce token secret ! Ne le committe JAMAIS dans git.

---

## 🔧 CONFIGURATION MCP

### Fichier de Configuration

**Emplacement**: `~/.config/claude-code/config.json` (ou équivalent)

```json
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "npx",
      "args": [
        "-y",
        "supergateway",
        "--streamableHttp",
        "http://localhost:5678/mcp-server/http",
        "--header",
        "authorization:Bearer YOUR_N8N_API_TOKEN_HERE"
      ]
    }
  }
}
```

### Variables d'Environnement (Alternative)

Si tu préfères ne pas mettre le token dans la config:

**1. Créer fichier `.env`** (à la racine du projet):
```bash
N8N_API_TOKEN=n8n_api_XXXXX-rL0
```

**2. Modifier la config pour utiliser la variable**:
```json
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "sh",
      "args": [
        "-c",
        "npx -y supergateway --streamableHttp http://localhost:5678/mcp-server/http --header \"authorization:Bearer $N8N_API_TOKEN\""
      ],
      "env": {
        "N8N_API_TOKEN": "${N8N_API_TOKEN}"
      }
    }
  }
}
```

---

## ✅ ACTIVATION

### Méthode 1: Commande mcp-add (Claude Code CLI)

```bash
# Une fois la config créée
mcp-add n8n-mcp
```

### Méthode 2: Configuration Manuelle

Ajouter directement dans `~/.config/claude-code/config.json`

---

## 🧪 VÉRIFICATION

### 1. Test Connexion HTTP

```bash
# Remplacer YOUR_TOKEN par le vrai token
curl -X GET "http://localhost:5678/mcp-server/http" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

**Réponse attendue**: `200 OK` ou liste des endpoints MCP

### 2. Vérifier les Outils Disponibles

Dans Claude Code CLI:
```
Liste les outils n8n disponibles
```

**Outils attendus**:
- `list_workflows` - Lister les workflows
- `create_workflow` - Créer un workflow
- `activate_workflow` - Activer un workflow
- `execute_workflow` - Exécuter un workflow
- `get_workflow` - Obtenir détails d'un workflow
- Plus d'outils selon version n8n...

---

## 🎯 CAS D'USAGE

### Exemple 1: Lister les Workflows

```javascript
// Via Claude Code CLI
"Liste tous les workflows n8n actifs"

// Réponse attendue:
[
  {
    "id": "7ca466b8...",
    "name": "IANA Log",
    "active": true
  },
  {
    "id": "abc123...",
    "name": "IANA Context",
    "active": false
  }
]
```

### Exemple 2: Activer un Workflow

```javascript
// Via Claude Code CLI
"Active le workflow 'IANA Log'"

// Réponse attendue:
{
  "success": true,
  "workflow_id": "7ca466b8...",
  "name": "IANA Log",
  "active": true
}
```

### Exemple 3: Créer un Workflow

```javascript
// Via Claude Code CLI
"Crée un workflow n8n simple qui log 'Hello World'"

// Claude Code utilisera l'outil create_workflow
```

---

## 🔒 SÉCURITÉ

### Best Practices

1. **Token Storage**:
   - ✅ Utiliser variables d'environnement
   - ✅ Ou fichier `.env` avec `.gitignore`
   - ❌ JAMAIS dans git
   - ❌ JAMAIS en clair dans la config

2. **Permissions Token**:
   - Le token a accès COMPLET à n8n
   - Considérer créer un user dédié pour l'API
   - Limiter les permissions si possible

3. **Rotation Token**:
   - Régénérer le token tous les 3-6 mois
   - Invalider l'ancien token immédiatement

---

## 🐛 TROUBLESHOOTING

### Erreur: "Cannot connect to MCP server"

**Causes possibles**:
1. n8n pas démarré → `docker ps | grep n8n`
2. Port 5678 bloqué → `netstat -an | grep 5678`
3. Token invalide → Régénérer dans n8n UI

**Solution**:
```bash
# Vérifier n8n
docker logs alfa-n8n --tail 20

# Tester endpoint MCP
curl http://localhost:5678/mcp-server/http
```

### Erreur: "Unauthorized"

**Cause**: Token manquant ou invalide

**Solution**:
1. Vérifier le token dans la config
2. Régénérer un nouveau token dans n8n
3. Vérifier le format: `authorization:Bearer n8n_api_XXXXX-rL0`

### Erreur: "supergateway not found"

**Cause**: Package `supergateway` pas installé

**Solution**:
```bash
npm install -g supergateway
# Ou laisser npx -y le télécharger automatiquement
```

---

## 📊 MÉTRIQUES & MONITORING

### Vérifier l'Activité MCP

```bash
# Logs Claude Code
tail -f ~/.config/claude-code/logs/mcp.log

# Logs n8n
docker logs -f alfa-n8n | grep -i mcp
```

### Performance

- **Latence attendue**: < 100ms (local)
- **Timeout**: 30s par défaut
- **Retry**: 3 tentatives automatiques

---

## 🔗 RESSOURCES

- [n8n MCP Documentation](https://docs.n8n.io/integrations/mcp/)
- [supergateway npm](https://www.npmjs.com/package/supergateway)
- [Claude Code MCP Guide](https://docs.anthropic.com/claude-code/mcp)

---

## ✅ CHECKLIST FINALE

- [ ] n8n accessible (http://localhost:5678)
- [ ] Token API généré dans n8n Settings
- [ ] Token sauvegardé dans `.env` ou config
- [ ] Configuration MCP créée
- [ ] `mcp-add n8n-mcp` exécuté
- [ ] Test curl réussi
- [ ] Outils n8n visibles dans Claude Code
- [ ] Test `list_workflows` fonctionne

---

**Maintenu par**: Claude Code CLI 2.1.5
**Dernière mise à jour**: 2026-01-12
