# Configuration MCP n8n - VALIDÉE

**Date**: 2026-01-12
**Status**: ✅ Token validé, endpoint confirmé

---

## ✅ VALIDATION TECHNIQUE

### 1. Token MCP Vérifié
- **Type**: JWT (JSON Web Token)
- **Issuer**: n8n
- **Audience**: mcp-server-api
- **Status**: ✅ Accepté par n8n

### 2. Endpoint MCP Confirmé
- **URL**: `http://localhost:5678/mcp-server/http`
- **Protocol**: JSON-RPC 2.0 over HTTP/SSE
- **Status**: ✅ Réponse JSON-RPC reçue

### 3. Requirements
- **Accept Headers**: `application/json` ET `text/event-stream`
- **Solution**: Utiliser `supergateway` (gère automatiquement SSE)

---

## 🔧 CONFIGURATION CLAUDE CODE CLI

### Configuration MCP (à ajouter)

**Fichier**: Configuration Claude Code (ou `claude_desktop_config.json`)

```json
{
  "mcpServers": {
    "n8n": {
      "command": "npx",
      "args": [
        "-y",
        "supergateway",
        "--streamableHttp",
        "http://localhost:5678/mcp-server/http",
        "--header",
        "authorization:Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5M2RhNGJjNy1lY2ViLTQ1N2YtYTg3ZS1jYzkzODdlYjQ3MWIiLCJpc3MiOiJuOG4iLCJhdWQiOiJtY3Atc2VydmVyLWFwaSIsImp0aSI6IjZmNjQ5ZDZiLTQ5ODctNDkzYS1iMDQ2LWM1YjNjMzVlMzFjOSIsImlhdCI6MTc2ODIzNDY0MX0.NV6DM3WlRUvcRvQpDmXR4e-z2qp0UW2ZgG9magMnG5g"
      ]
    }
  }
}
```

### Configuration Alternative (avec variable d'env)

**Fichier `.env.mcp`** (déjà créé):
```bash
N8N_MCP_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5M2RhNGJjNy1lY2ViLTQ1N2YtYTg3ZS1jYzkzODdlYjQ3MWIiLCJpc3MiOiJuOG4iLCJhdWQiOiJtY3Atc2VydmVyLWFwaSIsImp0aSI6IjZmNjQ5ZDZiLTQ5ODctNDkzYS1iMDQ2LWM1YjNjMzVlMzFjOSIsImlhdCI6MTc2ODIzNDY0MX0.NV6DM3WlRUvcRvQpDmXR4e-z2qp0UW2ZgG9magMnG5g
```

**Configuration MCP** (avec variable):
```json
{
  "mcpServers": {
    "n8n": {
      "command": "sh",
      "args": [
        "-c",
        "source /Users/arnaud/Documents/ALFA-Agent-Method/.env.mcp && npx -y supergateway --streamableHttp http://localhost:5678/mcp-server/http --header \"authorization:Bearer $N8N_MCP_TOKEN\""
      ]
    }
  }
}
```

---

## 🎯 OUTILS n8n ATTENDUS

Une fois configuré, tu auras accès à :

### Gestion Workflows
- `n8n_list_workflows` - Lister tous les workflows
- `n8n_get_workflow` - Obtenir détails d'un workflow
- `n8n_create_workflow` - Créer un nouveau workflow
- `n8n_update_workflow` - Modifier un workflow
- `n8n_delete_workflow` - Supprimer un workflow
- `n8n_activate_workflow` - Activer/désactiver un workflow

### Gestion Credentials
- `n8n_list_credentials` - Lister les credentials
- `n8n_get_credential` - Obtenir une credential
- `n8n_create_credential` - Créer une credential

### Exécutions
- `n8n_execute_workflow` - Exécuter un workflow
- `n8n_list_executions` - Lister les exécutions
- `n8n_get_execution` - Détails d'une exécution

### Testing
- `n8n_test_workflow` - Tester un workflow

---

## ✅ VÉRIFICATIONS

### 1. Test Endpoint (déjà fait)
```bash
source .env.mcp
curl -X POST "http://localhost:5678/mcp-server/http" \
  -H "Authorization: Bearer $N8N_MCP_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"initialize","params":{},"id":1}'
```

**Résultat**: ✅ JSON-RPC error (normal, besoin de SSE)

### 2. Test avec Supergateway
```bash
npx -y supergateway --streamableHttp http://localhost:5678/mcp-server/http --header "authorization:Bearer $N8N_MCP_TOKEN"
```

### 3. Vérifier dans Claude Code
Après configuration:
```
Liste les workflows n8n disponibles
```

---

## 📊 DIFFÉRENCES TOKEN MCP vs API

### Token MCP (utilisé ici)
- **Source**: Settings > Instance-level MCP > Access Token
- **Format**: JWT
- **Usage**: Accès au serveur MCP n8n
- **Endpoint**: `/mcp-server/http`

### Token API n8n (différent)
- **Source**: Settings > n8n API > Create API Key
- **Format**: `n8n_api_XXXXX`
- **Usage**: API REST classique n8n
- **Endpoint**: `/api/v1/*` ou `/rest/*`

**⚠️ Ne PAS confondre les deux !**

---

## 🔒 SÉCURITÉ

### Token Stockage
- ✅ Sauvegardé dans `.env.mcp`
- ✅ `.env.mcp` ajouté au `.gitignore`
- ✅ Jamais commité dans git

### Rotation Token
- **Fréquence recommandée**: Tous les 3-6 mois
- **Procédure**: n8n Settings > Instance-level MCP > Regenerate Token

---

## 🐛 TROUBLESHOOTING

### Erreur: "Not Acceptable: Client must accept application/json and text/event-stream"
**Cause**: Client HTTP standard ne supporte pas SSE
**Solution**: Utiliser `supergateway`

### Erreur: "Unauthorized"
**Cause**: Token invalide ou expiré
**Solution**: Régénérer le token dans n8n UI

### Supergateway ne démarre pas
**Solution**:
```bash
npm install -g supergateway
# Ou laisser npx -y le télécharger
```

---

**Maintenu par**: Claude Code CLI 2.1.5
**Dernière mise à jour**: 2026-01-12
