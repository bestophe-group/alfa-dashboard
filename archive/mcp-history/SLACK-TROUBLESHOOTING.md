# Dépannage Slack Integration

## 🔴 Problème: Token ne fonctionne pas

**Votre token**: `xoxb-XXXX-XXXX-XXXXXXXXXXXX` (remplacez par votre token réel)

### ✅ Solution: Configurer les OAuth Scopes

Le token Bot Slack nécessite des **permissions OAuth** spécifiques pour fonctionner.

---

## 📋 Étapes de Configuration

### 1. Accéder aux OAuth Scopes

🔗 **URL directe**: https://api.slack.com/apps/A0A73J9107P/oauth

**Ou manuellement**:
1. Aller sur https://api.slack.com/apps
2. Cliquer sur votre app **ALFA**
3. Dans le menu de gauche: **OAuth & Permissions**

### 2. Ajouter les Scopes Requis

Dans la section **Bot Token Scopes**, ajouter:

#### Scopes Essentiels pour ALFA
```
✅ chat:write            - Envoyer messages
✅ chat:write.public     - Poster dans channels publics
✅ channels:read         - Lire channels
✅ channels:manage       - Créer/archiver channels
✅ channels:join         - Rejoindre channels
✅ groups:read          - Lire channels privés
✅ groups:write         - Gérer channels privés
✅ im:write             - Envoyer DMs
✅ users:read           - Lire infos utilisateurs
✅ users:write          - Gérer utilisateurs
✅ files:write          - Upload fichiers
✅ files:read           - Lire fichiers
✅ commands             - Recevoir slash commands
```

#### Scopes Avancés (Optionnels)
```
⭕ admin.users:write     - Gestion admin users
⭕ admin.teams:write     - Gestion admin workspace
⭕ pins:write           - Épingler messages
⭕ reactions:write      - Ajouter réactions
⭕ usergroups:write     - Gérer user groups
```

### 3. Réinstaller l'App

⚠️ **IMPORTANT**: Après avoir ajouté des scopes, vous **DEVEZ** réinstaller l'app!

1. Cliquer sur **"Install to Workspace"** en haut de la page OAuth
2. Autoriser les nouvelles permissions
3. Un **nouveau token** sera généré (conservez l'ancien format)

### 4. Configurer les Slash Commands

🔗 **URL directe**: https://api.slack.com/apps/A0A73J9107P/slash-commands

**Configuration**:
```
Command: /alfa
Request URL: http://your-ngrok-url.ngrok.io/slack/command
Short Description: Execute ALFA MCP tools
Usage Hint: status | grafana_create_dashboard | slack_send_message
```

**Options importantes**:
- ✅ Escape channels, users, and links sent to your app

### 5. Activer Interactivity (Optionnel)

🔗 **URL**: https://api.slack.com/apps/A0A73J9107P/interactive-messages

```
Request URL: http://your-ngrok-url.ngrok.io/slack/interactive
```

Permet les boutons, menus déroulants, modals dans les réponses ALFA.

---

## 🧪 Test du Token

### Test 1: Vérifier les Scopes

```bash
curl https://slack.com/api/auth.test \
  -H "Authorization: Bearer YOUR_SLACK_TOKEN"
```

**Réponse attendue**:
```json
{
  "ok": true,
  "url": "https://your-workspace.slack.com/",
  "team": "Your Team",
  "user": "alfa-bot",
  "team_id": "T...",
  "user_id": "U..."
}
```

### Test 2: Envoyer un Message Test

```bash
curl -X POST https://slack.com/api/chat.postMessage \
  -H "Authorization: Bearer YOUR_SLACK_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "channel": "YOUR_CHANNEL_ID",
    "text": "✅ ALFA Bot is working!"
  }'
```

**Si erreur `missing_scope`**:
→ Retourner à l'étape 2 et ajouter le scope manquant

---

## 🚀 Démarrage Webhook avec Ngrok

### Terminal 1: Démarrer Webhook Server

```bash
cd /Users/arnaud/Documents/ALFA-Agent-Method/.mcp
node slack-webhook.js
```

**Output attendu**:
```
🚀 ALFA Slack Webhook Server running on port 3333
📍 Webhook URL: http://localhost:3333/slack/command
🏥 Health check: http://localhost:3333/health
```

### Terminal 2: Exposer avec Ngrok

```bash
ngrok http 3333
```

**Output attendu**:
```
Forwarding  https://abcd-1234-5678.ngrok.io -> http://localhost:3333
```

**⚠️ Copier l'URL ngrok**: `https://abcd-1234-5678.ngrok.io`

### Terminal 3: Configurer Slash Command

1. Aller sur https://api.slack.com/apps/A0A73J9107P/slash-commands
2. Cliquer sur `/alfa` (ou "Create New Command")
3. **Request URL**: `https://abcd-1234-5678.ngrok.io/slack/command`
4. Sauvegarder

---

## 🧪 Test Complet

### Test dans Slack

```
/alfa status
```

**Réponse attendue**:
```
⚡ ALFA executing: `/alfa status`...
✅ ALFA Result
[Status des services ALFA]
```

### Test avec Arguments

```
/alfa slack_send_message channel=general text="Hello from ALFA"
```

---

## 🐛 Erreurs Courantes

### Erreur: `invalid_auth`
**Cause**: Token expiré ou invalide
**Solution**: Réinstaller l'app pour obtenir un nouveau token

### Erreur: `missing_scope`
**Cause**: Scope OAuth manquant
**Solution**: Ajouter le scope dans OAuth & Permissions, puis réinstaller

### Erreur: `channel_not_found`
**Cause**: Bot pas invité dans le channel
**Solution**: Dans Slack: `/invite @ALFA` dans le channel

### Erreur: `not_in_channel`
**Cause**: Bot doit être membre du channel
**Solution**: Ajouter scope `channels:join` ou inviter manuellement

### Erreur: Timeout après 3 secondes
**Cause**: Slack nécessite réponse < 3s
**Solution**: Le webhook répond immédiatement puis exécute en async (déjà implémenté)

### Erreur: `url_verification failed`
**Cause**: Ngrok URL pas configurée dans Slack
**Solution**: Vérifier que l'URL dans Slack matche l'URL ngrok

---

## 📊 Architecture Webhook

```
┌─────────────────┐
│  Slack User     │
│  /alfa status   │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────┐
│  Slack API                  │
│  POST /slack/command        │
└────────┬────────────────────┘
         │
         ▼ (via ngrok)
┌─────────────────────────────┐
│  ALFA Webhook Server        │
│  Port 3333                  │
│  - Parse command            │
│  - Respond < 3s             │
│  - Execute async            │
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│  ALFA MCP Server            │
│  - Execute tool             │
│  - Return result            │
└────────┬────────────────────┘
         │
         ▼ (via response_url)
┌─────────────────────────────┐
│  Slack Channel              │
│  ✅ ALFA Result             │
│  [Tool output]              │
└─────────────────────────────┘
```

---

## 🔐 Sécurité: Webhook Verification

Le webhook vérifie automatiquement les requêtes Slack avec le **Signing Secret**.

### Obtenir le Signing Secret

🔗 **URL**: https://api.slack.com/apps/A0A73J9107P/general

Copier le **Signing Secret** et l'ajouter au `.env`:

```bash
SLACK_SIGNING_SECRET=your_signing_secret_here
```

**⚠️ Sans le signing secret**, le webhook accepte toutes les requêtes (risque sécurité).

---

## ✅ Checklist Complète

- [ ] OAuth Scopes configurés (minimum: `chat:write`, `commands`)
- [ ] App réinstallée après ajout de scopes
- [ ] Nouveau token Bot récupéré
- [ ] Slash command `/alfa` créé
- [ ] Webhook server démarré (`node slack-webhook.js`)
- [ ] Ngrok exposant le port 3333
- [ ] URL ngrok configurée dans Slack slash command
- [ ] Signing secret ajouté au `.env`
- [ ] Test `/alfa status` dans Slack réussi
- [ ] Bot invité dans les channels nécessaires

---

## 📞 Support

Si après toutes ces étapes ça ne fonctionne toujours pas:

1. **Logs Webhook**: Vérifier la console du webhook server
2. **Logs Slack**: https://api.slack.com/apps/A0A73J9107P/event-subscriptions (Request Logs)
3. **Test Token**: Utiliser le test curl ci-dessus
4. **Ngrok Inspector**: http://localhost:4040 (interface web ngrok)

---

🤖 **ALFA Slack Integration**
Version 1.0.0 - 2026-01-07
