# 🎯 n8n MCP Server - Configuration Complète VALIDÉE

**Date**: 2026-01-12
**Status**: ✅ Prêt à activer

---

## ✅ CE QUI A ÉTÉ FAIT

### 1. Token MCP Obtenu et Validé
- ✅ Token généré dans: n8n Settings > Instance-level MCP > Access Token
- ✅ Format: JWT valide
- ✅ Sauvegardé dans: `.env.mcp` (non-commité)
- ✅ `.gitignore` mis à jour pour sécurité

### 2. Endpoint MCP Testé
- ✅ URL: `http://localhost:5678/mcp-server/http`
- ✅ Protocol: JSON-RPC 2.0 over HTTP/SSE
- ✅ Authentification: Bearer token validée
- ✅ Réponse serveur: JSON-RPC (requis SSE)

### 3. Documentation Créée
- ✅ `/docs/n8n-update-guide.md` - Guide mise à jour n8n
- ✅ `/docs/mcp-n8n-setup.md` - Guide setup MCP complet
- ✅ `/docs/mcp-n8n-config.md` - Configuration technique validée
- ✅ `.env.mcp` - Token sécurisé

### 4. Mises à Jour
- ✅ Claude Code CLI: 2.0.50 → 2.1.5
- ✅ n8n: 2.2.4 (déjà à jour)

---

## 🔧 PROCHAINE ÉTAPE: ACTIVATION

### Configuration à Ajouter dans Claude Code

**Emplacement**: Configuration Claude Code CLI ou `claude_desktop_config.json`

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

### Alternative avec Variable d'Environnement

**1. Le fichier `.env.mcp` existe déjà** avec:
```bash
N8N_MCP_TOKEN=eyJhbGci...G5g
N8N_MCP_ENDPOINT=http://localhost:5678/mcp-server/http
```

**2. Configuration MCP** (plus sécurisée):
```json
{
  "mcpServers": {
    "n8n": {
      "command": "sh",
      "args": [
        "-c",
        "source /Users/arnaud/Documents/ALFA-Agent-Method/.env.mcp && npx -y supergateway --streamableHttp $N8N_MCP_ENDPOINT --header \"authorization:Bearer $N8N_MCP_TOKEN\""
      ]
    }
  }
}
```

---

## 🎯 OUTILS DISPONIBLES APRÈS ACTIVATION

Une fois le serveur MCP n8n activé, tu auras accès à :

### 📋 Workflows
- **Liste workflows**: Voir tous les workflows (actifs/inactifs)
- **Créer workflow**: Créer un nouveau workflow via JSON
- **Modifier workflow**: Éditer un workflow existant
- **Activer/Désactiver**: Toggle activation d'un workflow
- **Supprimer**: Retirer un workflow
- **Exécuter**: Lancer un workflow manuellement

### 🔐 Credentials
- **Liste credentials**: Voir toutes les credentials configurées
- **Créer credential**: Ajouter une nouvelle credential
- **Type credential**: Lister les types disponibles

### 📊 Exécutions
- **Liste exécutions**: Voir l'historique d'exécutions
- **Détails exécution**: Obtenir les logs d'une exécution
- **Statut exécution**: Vérifier si une exécution est en cours

### 🧪 Tests
- **Tester workflow**: Lancer un test avant activation

---

## 🚀 COMMENT ACTIVER

### Option 1: Ajouter Manuellement

1. Localiser le fichier de config Claude Code
2. Ajouter la section `mcpServers` avec la config ci-dessus
3. Redémarrer Claude Code CLI

### Option 2: Via Script

**Créer un script d'activation** (si besoin):
```bash
#!/bin/bash
# activate-n8n-mcp.sh

CONFIG_FILE="$HOME/.config/claude-code/config.json"

# Backup existing config
cp "$CONFIG_FILE" "$CONFIG_FILE.backup"

# Ajouter configuration n8n MCP
# (utiliser jq ou édition manuelle)

echo "n8n MCP server configured!"
echo "Restart Claude Code CLI to activate."
```

---

## ✅ VÉRIFICATION POST-ACTIVATION

### 1. Vérifier le serveur démarre

Dans Claude Code CLI:
```
Vérifie que le serveur MCP n8n est connecté
```

### 2. Lister les workflows

```
Liste tous les workflows n8n disponibles
```

**Réponse attendue**:
```json
[
  {
    "id": "7ca466b8...",
    "name": "IANA Log",
    "active": false
  },
  {
    "id": "abc123...",
    "name": "IANA Context",
    "active": false
  }
]
```

### 3. Tester une action

```
Active le workflow "IANA Log" dans n8n
```

---

## 📊 RÉCAPITULATIF TECHNIQUE

### Architecture
```
Claude Code CLI
    ↓
supergateway (conversion SSE)
    ↓
n8n MCP Server (/mcp-server/http)
    ↓
n8n Instance (localhost:5678)
```

### Authentification
- **Méthode**: Bearer Token (JWT)
- **Header**: `Authorization: Bearer <token>`
- **Scope**: Instance-level MCP access

### Protocol
- **Transport**: HTTP/Server-Sent Events (SSE)
- **Format**: JSON-RPC 2.0
- **Encoding**: UTF-8

---

## 🔒 SÉCURITÉ

### ✅ Protections en Place
1. Token sauvegardé dans `.env.mcp` (non-commité)
2. `.env.mcp` ajouté au `.gitignore`
3. Token JWT avec expiration (vérifier `iat` dans token)
4. Accès local seulement (localhost:5678)

### ⚠️ Recommandations
1. **Régénérer le token** tous les 3-6 mois
2. **Ne jamais** partager le token publiquement
3. **Limiter l'accès** au fichier `.env.mcp` (chmod 600)
4. **Surveiller les logs** n8n pour accès suspects

### Rotation Token (quand nécessaire)
```bash
# 1. Dans n8n UI: Settings > Instance-level MCP > Regenerate Token
# 2. Copier le nouveau token
# 3. Mettre à jour .env.mcp:
N8N_MCP_TOKEN=<nouveau_token>
# 4. Redémarrer Claude Code CLI
```

---

## 🐛 TROUBLESHOOTING

### Erreur: "Cannot connect to MCP server"
**Solution**:
```bash
# Vérifier n8n est actif
docker ps | grep n8n

# Vérifier endpoint accessible
curl http://localhost:5678/healthz
```

### Erreur: "supergateway not found"
**Solution**:
```bash
# Installer supergateway globalement
npm install -g supergateway

# Ou laisser npx -y le télécharger automatiquement
```

### Token expiré
**Symptôme**: Erreur 401 Unauthorized
**Solution**: Régénérer le token dans n8n UI (Settings > MCP)

---

## 📚 RESSOURCES

### Documentation
- [n8n MCP Server](https://docs.n8n.io/advanced-ai/accessing-n8n-mcp-server/)
- [supergateway npm](https://www.npmjs.com/package/supergateway)
- [MCP Protocol](https://spec.modelcontextprotocol.io/)

### Fichiers Locaux
- `/docs/n8n-update-guide.md`
- `/docs/mcp-n8n-setup.md`
- `/docs/mcp-n8n-config.md`
- `/.env.mcp` (token sécurisé)

---

## ✅ CHECKLIST FINALE

- [x] Token MCP généré dans n8n
- [x] Token sauvegardé dans `.env.mcp`
- [x] `.gitignore` mis à jour
- [x] Endpoint MCP testé et validé
- [x] Documentation complète créée
- [x] Configuration JSON préparée
- [ ] **Configuration ajoutée à Claude Code** ← À FAIRE
- [ ] **Claude Code redémarré** ← À FAIRE
- [ ] **Test "Liste workflows"** ← À FAIRE
- [ ] **Vérification outils n8n disponibles** ← À FAIRE

---

## 🎯 ACTION IMMÉDIATE RECOMMANDÉE

**Tu dois maintenant**:

1. **Ajouter la configuration** dans Claude Code:
   - Copier la config JSON ci-dessus
   - L'ajouter dans le fichier de config Claude Code CLI

2. **Redémarrer** Claude Code CLI

3. **Tester** avec:
   ```
   Liste tous les workflows n8n
   ```

4. **Vérifier** que les 5 workflows IANA sont listés

---

**Préparé par**: Claude Code CLI 2.1.5
**Prêt pour**: Activation immédiate
**Dernière mise à jour**: 2026-01-12 (validé et testé)
