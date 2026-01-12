# PLAN - Workflows Microsoft Tenant Collection

**Date**: 2026-01-12  
**Status**: ⏳ En cours

---

## 📋 OBJECTIF

Créer les workflows nécessaires pour scraper les données d'un tenant Microsoft avec authentification OAuth (utilisateur admin).

---

## 🎯 ARCHITECTURE

### Workflow Principal : `iana-microsoft-collect`

**Endpoint** : `/webhook/microsoft/collect`  
**Method** : POST  
**Authentification** : OAuth2 Microsoft Entra (`microsoftEntraOAuth2Api`)

**Actions** :
- `email` - Collecter emails
- `teams` - Collecter messages Teams
- `users` - Collecter utilisateurs
- `calendar` - Collecter événements calendrier
- `files` - Collecter fichiers (OneDrive/SharePoint)
- `all` - Collecter toutes les sources

**Structure** :
```
Webhook → Validate Input → Switch (actions) → Microsoft Graph API → Format Data → RAG Auto-Save → Log → Response
```

### Workflows Spécifiques (Optionnels)

1. **`iana-microsoft-email`** - Emails uniquement
2. **`iana-microsoft-teams`** - Teams uniquement
3. **`iana-microsoft-users`** - Users uniquement

---

## 🔐 AUTHENTIFICATION OAUTH

### Type : Microsoft Entra OAuth2 API

**Credential Type** : `microsoftEntraOAuth2Api`

**Permissions nécessaires** (Admin) :
- `Mail.Read` - Lire emails personnels
- `Mail.ReadBasic.All` - Lire emails organisation
- `ChannelMessage.Read.All` - Lire messages Teams
- `Chat.Read.All` - Lire chats Teams
- `User.Read.All` - Lire utilisateurs
- `Calendars.Read` - Lire calendrier
- `Files.Read.All` - Lire fichiers

**Configuration OAuth** :
- Client ID : À configurer dans Azure AD
- Client Secret : À configurer dans Azure AD
- Redirect URI : `https://n8n.alfa.local/rest/oauth2-credential/callback`
- Scope : `https://graph.microsoft.com/.default`

---

## 📋 SOURCES DE DONNÉES

### 1. Emails

**Endpoint** : `https://graph.microsoft.com/v1.0/me/messages`

**Filtres** :
- `$filter=isRead eq false` - Non lus
- `$filter=receivedDateTime ge {date}` - Après date
- `$select=id,subject,from,receivedDateTime,bodyPreview,body`

**Format RAG** :
```json
{
  "title": "Email: {subject}",
  "content": "{body}",
  "category": "email",
  "metadata": {
    "source": "microsoft_365",
    "type": "email",
    "from": "{from}",
    "receivedDateTime": "{receivedDateTime}",
    "messageId": "{id}"
  }
}
```

### 2. Teams Messages

**Endpoints** :
- Liste teams : `https://graph.microsoft.com/v1.0/me/joinedTeams`
- Messages channel : `https://graph.microsoft.com/v1.0/teams/{team-id}/channels/{channel-id}/messages`
- Messages chat : `https://graph.microsoft.com/v1.0/chats/{chat-id}/messages`

**Format RAG** :
```json
{
  "title": "Teams: {channel/chat name} - {subject}",
  "content": "{body}",
  "category": "teams",
  "metadata": {
    "source": "microsoft_365",
    "type": "teams_message",
    "teamId": "{team-id}",
    "channelId": "{channel-id}",
    "from": "{from}",
    "createdDateTime": "{createdDateTime}"
  }
}
```

### 3. Users

**Endpoint** : `https://graph.microsoft.com/v1.0/users`

**Format RAG** :
```json
{
  "title": "User: {displayName}",
  "content": "{jobTitle} - {department}",
  "category": "user",
  "metadata": {
    "source": "microsoft_365",
    "type": "user",
    "userId": "{id}",
    "email": "{mail}",
    "department": "{department}"
  }
}
```

### 4. Calendar Events

**Endpoint** : `https://graph.microsoft.com/v1.0/me/calendar/events`

**Format RAG** :
```json
{
  "title": "Event: {subject}",
  "content": "{bodyPreview}",
  "category": "calendar",
  "metadata": {
    "source": "microsoft_365",
    "type": "calendar_event",
    "start": "{start}",
    "end": "{end}",
    "organizer": "{organizer}"
  }
}
```

### 5. Files

**Endpoint** : `https://graph.microsoft.com/v1.0/me/drive/root/children`

**Format RAG** :
```json
{
  "title": "File: {name}",
  "content": "{description}",
  "category": "file",
  "metadata": {
    "source": "microsoft_365",
    "type": "file",
    "fileId": "{id}",
    "webUrl": "{webUrl}",
    "lastModifiedDateTime": "{lastModifiedDateTime}"
  }
}
```

---

## 🔧 IMPLÉMENTATION

### Workflow Principal : `iana-microsoft-collect`

**Structure** :
1. **Webhook** (POST `/webhook/microsoft/collect`)
2. **Validate Input** (Code) - Valider action, user_id
3. **Switch Action** (Switch) - Router par action (email, teams, users, etc.)
4. **Prepare Request** (Code) - Préparer requête Graph API
5. **Call Graph API** (HTTP Request) - Appeler Microsoft Graph API avec OAuth
6. **Format Data** (Code) - Formater pour RAG
7. **Save to RAG** (HTTP Request) - Appeler `iana-rag-auto-save`
8. **Log Operation** (PostgreSQL) - Logger opération
9. **Format Response** (Code) - Formater réponse
10. **Respond to Webhook** (Respond) - Retourner réponse

### Credentials

**Microsoft Entra OAuth2 API** :
- Nom : `Microsoft 365 ALFA`
- Type : `microsoftEntraOAuth2Api`
- Configuration : Client ID, Client Secret, Tenant ID
- Scopes : `https://graph.microsoft.com/.default`

---

## ✅ CRITÈRES DE SUCCÈS

- [ ] Workflow `iana-microsoft-collect` créé
- [ ] Authentification OAuth2 configurée
- [ ] Actions email, teams, users, calendar, files implémentées
- [ ] Intégration avec `iana-rag-auto-save` fonctionnelle
- [ ] Logs traçables dans `iana.operation_logs`
- [ ] Test avec authentification OAuth réussi

---

**Plan créé le**: 2026-01-12  
**Status**: ⏳ En attente d'implémentation
