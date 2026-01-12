
# Instructions Configuration OAuth Microsoft 365

## 1. Enregistrer Application Azure AD

1. Accéder à https://portal.azure.com
2. Azure Active Directory > App registrations > New registration
3. Nom: "n8n ALFA Data Collector"
4. Supported account types: "Accounts in this organizational directory only"
5. Redirect URI: `https://n8n.alfa.local/rest/oauth2-credential/callback` (ou URL de votre n8n)
6. Register

## 2. Permissions API (Admin Consent Requis)

1. API permissions > Add a permission > Microsoft Graph
2. Permissions déléguées:
   - Mail.Read
   - Mail.ReadBasic.All
   - ChannelMessage.Read.All
   - Chat.Read.All
   - User.Read.All
   - Calendars.Read
   - Files.Read.All
3. Grant admin consent for [Votre Organisation]

## 3. Créer Client Secret

1. Certificates & secrets > New client secret
2. Description: "n8n ALFA"
3. Expires: 24 months (ou selon préférence)
4. Add > Copier la valeur (affichée une seule fois)

## 4. Configurer Credential dans n8n

1. n8n > Credentials > New credential
2. Type: Microsoft Entra OAuth2 API
3. Nom: "Microsoft 365 ALFA"
4. Client ID: (ID de l'application Azure AD)
5. Client Secret: (Secret créé)
6. Tenant ID: (ID du tenant Azure AD)
7. Scope: `https://graph.microsoft.com/.default`
8. Connect my account (autorisera l'application)

## 5. Workflow Prêt

Le workflow `iana-microsoft-collect` est prêt à être utilisé.
Endpoint: /webhook/microsoft/collect
Actions: email, teams, users, calendar, files, all
