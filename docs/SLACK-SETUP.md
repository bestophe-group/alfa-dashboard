# Configuration Slack App ALFA

## Étapes de configuration

### 1. Créer la Slack App

1. Aller sur https://api.slack.com/apps
2. Cliquer "Create New App"
3. Choisir "From scratch"
4. Nom: `ALFA`
5. Workspace: Sélectionner votre workspace

### 2. Configurer le Slash Command

1. Dans la sidebar, cliquer "Slash Commands"
2. Cliquer "Create New Command"
3. Remplir:
   - Command: `/alfa`
   - Request URL: `https://n8n.alfa.local/webhook/slack-command`
   - Short Description: `ALFA - Automatisation IT`
   - Usage Hint: `[help|status|osint|reset|scan|ticket|sharepoint|backup]`
4. Sauvegarder

### 3. Permissions (OAuth & Permissions)

Ajouter ces Bot Token Scopes:
- `commands` - Slash commands
- `chat:write` - Envoyer messages
- `chat:write.public` - Envoyer dans channels publics
- `users:read` - Lire infos utilisateurs
- `users:read.email` - Lire emails

### 4. Installer l'app

1. Cliquer "Install to Workspace"
2. Autoriser les permissions
3. Copier le "Bot User OAuth Token" (commence par `xoxb-`)

### 5. Configurer n8n

Dans n8n, créer un credential Slack:
- Type: Slack API
- Access Token: `xoxb-...` (le token copié)

### 6. Tester

Dans Slack, taper:
```
/alfa help
```

## Commandes disponibles

| Commande | Description |
|----------|-------------|
| `/alfa help` | Affiche l'aide |
| `/alfa status` | État des services |
| `/alfa scan` | Lance scan vulnérabilités |
| `/alfa backup` | Lance backup |
| `/alfa reset <email>` | Reset password Azure AD |
| `/alfa sharepoint <nom>` | Créer site SharePoint |
| `/alfa osint <entreprise>` | Rapport OSINT |
| `/alfa ticket <description>` | Créer ticket support |

## URL du Webhook n8n

```
https://n8n.alfa.local/webhook/slack-command
```

Pour le développement local:
```
https://n8n.alfa.local/webhook-test/slack-command
```

## Troubleshooting

### Erreur "dispatch_failed"
- Vérifier que n8n est accessible depuis Internet
- Vérifier l'URL du webhook

### Erreur "operation_timeout"
- Le workflow doit répondre en moins de 3 secondes
- Utiliser réponse immédiate + traitement async

### Bot ne répond pas
- Vérifier que le workflow est actif dans n8n
- Vérifier les logs n8n
