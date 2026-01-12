# 🚀 ALFA Slack - Démarrage Rapide

**Date**: 2026-01-07
**Status**: ✅ Bot installé dans #bct

---

## ✅ Configuration Actuelle

- **Bot**: `@ALFA` ajouté dans #bct
- **Token**: Validé et opérationnel
- **Workspace**: LifeOS (lifeosgroupe.slack.com)

---

## 🎯 Tester Maintenant

### Étape 1: Démarrer le Webhook Server

```bash
cd /Users/arnaud/Documents/ALFA-Agent-Method/.mcp
node slack-webhook.js
```

**Sortie attendue**:
```
🚀 ALFA Slack Webhook Server running on port 3333
📍 Webhook URL: http://localhost:3333/slack/command
🏥 Health check: http://localhost:3333/health
```

### Étape 2: Exposer avec Ngrok

**Dans un autre terminal**:
```bash
ngrok http 3333
```

**Copiez l'URL** qui s'affiche (ex: `https://abc123.ngrok.io`)

### Étape 3: Configurer le Slash Command

1. Ouvrir: https://api.slack.com/apps/A0A73J9107P/slash-commands
2. Créer ou modifier `/alfa`
3. **Request URL**: `https://abc123.ngrok.io/slack/command`
4. **Short Description**: Execute ALFA MCP tools
5. **Usage Hint**: `status | grafana_create_dashboard title="Dashboard"`
6. Sauvegarder

### Étape 4: Tester dans Slack

**Dans le channel #bct**, taper:

```
/alfa status
```

**Résultat attendu**:
```
⚡ ALFA executing: `/alfa status`...

✅ ALFA Result
[Status des services ALFA Docker]
```

---

## 📝 Commandes de Test Rapides

### Test 1: Status ALFA
```
/alfa status
```
Affiche le status de tous les services ALFA (Grafana, Prometheus, n8n, etc.)

### Test 2: Envoyer un Message
```
/alfa slack_send_message channel="bct" text="✅ ALFA Bot fonctionne!"
```
Le bot envoie un message dans #bct

### Test 3: Health Check ALFA
```
/alfa health
```
Vérifie la santé de tous les conteneurs Docker

### Test 4: Lister les Workflows
```
/alfa workflows
```
Liste tous les workflows n8n disponibles

### Test 5: Créer Note Obsidian
```
/alfa obsidian_create_note title="Test ALFA" content="Note créée depuis Slack"
```
Crée une note dans votre vault Obsidian

---

## 🎨 Exemples par Domaine

### 📊 Grafana
```
/alfa grafana_create_dashboard title="Production Monitoring"
/alfa grafana_query_prometheus query="up"
```

### 🔍 OSINT
```
/alfa osint_company_research company="Acme Corp"
/alfa osint_domain_reconnaissance domain="example.com"
```

### 🎨 Design
```
/alfa design_brand_identity company="My Startup"
/alfa design_social_media_pack theme="Technology"
```

### 💻 GitHub
```
/alfa github_repo_management action=list
/alfa github_issues_management action=list repo=alfa-dashboard
```

### ☁️ Infrastructure
```
/alfa aws_s3_management action=list_buckets
/alfa vercel_deploy project_path=/path/to/app
```

### 📱 Social Media
```
/alfa instagram_post caption="New product!" image_url="https://..."
/alfa youtube_upload title="Demo" file_path="/path/video.mp4"
```

---

## 🐛 Dépannage

### Problème: "invalid_auth"
**Solution**: Vérifier que le token est bien configuré dans le code du webhook

### Problème: "channel_not_found"
**Solution**: S'assurer que le bot est invité dans le channel cible
```
/invite @ALFA
```

### Problème: "missing_scope"
**Solution**: Ajouter les scopes OAuth manquants
1. Aller sur: https://api.slack.com/apps/A0A73J9107P/oauth
2. Ajouter les scopes (voir SLACK-TROUBLESHOOTING.md)
3. Réinstaller l'app

### Problème: Timeout après 3 secondes
**Solution**: Le webhook répond déjà en < 3s, mais vérifier:
- Que ngrok est bien actif
- Que l'URL dans Slack correspond à l'URL ngrok
- Vérifier les logs du webhook server

### Problème: Commande pas reconnue
**Solution**: Vérifier la configuration du slash command
- Request URL doit être: `https://your-ngrok.ngrok.io/slack/command`
- Pas `https://your-ngrok.ngrok.io` seul

---

## 🔍 Logs et Debugging

### Voir les logs du webhook
Le webhook affiche en temps réel:
```
Received command: /alfa status from arnaud
Executing tool: alfa_status
Result sent to Slack
```

### Tester le webhook directement
```bash
curl -X POST http://localhost:3333/slack/command \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "command=/alfa&text=status&user_name=test&response_url=http://example.com"
```

### Vérifier ngrok
Interface web ngrok: http://localhost:4040
- Voir toutes les requêtes
- Inspecter les payloads
- Débugger les erreurs

---

## 📚 Référence Complète

**129 outils disponibles** répartis en **14 domaines**:

1. **Core ALFA** (7) - Gestion stack Docker
2. **Grafana** (5) - Monitoring & dashboards
3. **Power BI** (8) - Business Intelligence
4. **OSINT** (8) - Recherche d'informations
5. **ETL** (10) - Transformations de données
6. **Communication** (9) - Design & marketing
7. **Agents** (10) - Orchestration AI
8. **Claude Code** (9) - Développement
9. **Collaboration** (11) - Slack, M365, Google
10. **Infrastructure** (9) - Cloud & DNS
11. **Business SaaS** (11) - PayFit, PennyLane, Social
12. **CMS** (9) - Wix, WordPress
13. **Developer** (8) - GitHub, Browser
14. **Azure SSO** (7) - Enterprise SSO
15. **Productivity** (8) - Obsidian

**Documentation complète**: `.mcp/TOOLS-LIST-COMPLETE.md`

---

## 🎯 Next Steps

1. ✅ Bot ajouté dans #bct
2. ⏳ Démarrer webhook server
3. ⏳ Exposer avec ngrok
4. ⏳ Configurer slash command
5. ⏳ Tester `/alfa status`
6. ⏳ Explorer les 129 outils

---

## 🔐 Sécurité Production

Pour la production, ne pas utiliser ngrok mais:

### Option 1: VPS avec domaine
```bash
# Sur VPS
pm2 start slack-webhook.js --name alfa-webhook
# Configurer nginx reverse proxy
# Ajouter SSL Let's Encrypt
```
Request URL: `https://alfa.votredomaine.com/slack/command`

### Option 2: AWS Lambda
Déployer `slack-webhook.js` comme fonction Lambda + API Gateway

### Option 3: Vercel Serverless
Convertir en fonction Vercel serverless

---

**🤖 ALFA Bot v2.0.0**
129 outils MCP | 14 domaines | Prêt pour Slack ✅

---

**Aide**: `.mcp/SLACK-TROUBLESHOOTING.md`
**Liste outils**: `.mcp/TOOLS-LIST-COMPLETE.md`
**Validation**: `.mcp/VALIDATION-REPORT.md`
