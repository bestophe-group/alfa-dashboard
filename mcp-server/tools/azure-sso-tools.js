/**
 * ALFA MCP - Azure SSO Tools
 * Azure Active Directory SSO integration for any application
 */

import fetch from 'node-fetch';

export const azureSSOTools = [
  {
    name: 'alfa_azure_sso_app_registration',
    description: 'Enregistrer application dans Azure AD pour SSO',
    inputSchema: {
      type: 'object',
      properties: {
        app_name: { type: 'string', description: 'Nom de l\'application' },
        redirect_uris: { type: 'array', items: { type: 'string' }, description: 'URLs de redirection OAuth' },
        logout_url: { type: 'string', description: 'URL de logout' },
        app_type: { type: 'string', enum: ['web', 'spa', 'native'], description: 'Type d\'application' },
        api_permissions: {
          type: 'array',
          items: { type: 'string' },
          description: 'Permissions Microsoft Graph (ex: User.Read, Mail.Send)',
        },
      },
      required: ['app_name', 'redirect_uris'],
    },
  },
  {
    name: 'alfa_azure_sso_configure_saml',
    description: 'Configurer SSO SAML pour application entreprise',
    inputSchema: {
      type: 'object',
      properties: {
        app_id: { type: 'string', description: 'Application ID (Object ID)' },
        identifier: { type: 'string', description: 'Entity ID / Identifier' },
        reply_url: { type: 'string', description: 'Assertion Consumer Service URL' },
        sign_on_url: { type: 'string', description: 'Sign on URL' },
        logout_url: { type: 'string', description: 'Logout URL' },
        attributes: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              name: { type: 'string', description: 'Nom de l\'attribut SAML' },
              value: { type: 'string', description: 'Claim source (ex: user.mail)' },
            },
          },
          description: 'Mapping des attributs SAML',
        },
      },
      required: ['app_id', 'identifier', 'reply_url'],
    },
  },
  {
    name: 'alfa_azure_sso_configure_oidc',
    description: 'Configurer SSO OpenID Connect (OIDC)',
    inputSchema: {
      type: 'object',
      properties: {
        app_id: { type: 'string', description: 'Application (client) ID' },
        tenant_id: { type: 'string', description: 'Directory (tenant) ID' },
        client_secret_description: { type: 'string', description: 'Description du secret client' },
        redirect_uris: { type: 'array', items: { type: 'string' } },
        scopes: {
          type: 'array',
          items: { type: 'string' },
          description: 'Scopes OpenID (openid, profile, email, offline_access)',
        },
      },
      required: ['app_id', 'tenant_id', 'redirect_uris'],
    },
  },
  {
    name: 'alfa_azure_sso_assign_users',
    description: 'Assigner utilisateurs/groupes à application SSO',
    inputSchema: {
      type: 'object',
      properties: {
        app_id: { type: 'string', description: 'Service Principal Object ID' },
        user_emails: { type: 'array', items: { type: 'string' }, description: 'Emails des utilisateurs' },
        group_names: { type: 'array', items: { type: 'string' }, description: 'Noms des groupes Azure AD' },
        app_role_id: { type: 'string', description: 'ID du rôle app (optionnel)' },
      },
      required: ['app_id'],
    },
  },
  {
    name: 'alfa_azure_sso_conditional_access',
    description: 'Configurer stratégies d\'accès conditionnel',
    inputSchema: {
      type: 'object',
      properties: {
        policy_name: { type: 'string', description: 'Nom de la stratégie' },
        app_id: { type: 'string', description: 'Application ID' },
        conditions: {
          type: 'object',
          properties: {
            users: {
              type: 'object',
              properties: {
                include_users: { type: 'array', items: { type: 'string' } },
                exclude_users: { type: 'array', items: { type: 'string' } },
                include_groups: { type: 'array', items: { type: 'string' } },
              },
            },
            locations: {
              type: 'object',
              properties: {
                include_locations: { type: 'array', items: { type: 'string' } },
                exclude_locations: { type: 'array', items: { type: 'string' } },
              },
            },
            device_platforms: { type: 'array', items: { type: 'string', enum: ['windows', 'macOS', 'iOS', 'android', 'linux'] } },
          },
        },
        grant_controls: {
          type: 'object',
          properties: {
            require_mfa: { type: 'boolean', description: 'Exiger MFA' },
            require_compliant_device: { type: 'boolean', description: 'Exiger appareil conforme' },
            require_approved_app: { type: 'boolean', description: 'Exiger app approuvée' },
          },
        },
      },
      required: ['policy_name', 'app_id', 'conditions', 'grant_controls'],
    },
  },
  {
    name: 'alfa_azure_sso_get_metadata',
    description: 'Récupérer métadonnées SSO (SAML/OIDC) pour configuration app',
    inputSchema: {
      type: 'object',
      properties: {
        app_id: { type: 'string', description: 'Application ID' },
        tenant_id: { type: 'string', description: 'Tenant ID' },
        protocol: { type: 'string', enum: ['saml', 'oidc'], description: 'Protocole SSO' },
      },
      required: ['app_id', 'tenant_id', 'protocol'],
    },
  },
  {
    name: 'alfa_azure_sso_test_connection',
    description: 'Tester connexion SSO et authentification',
    inputSchema: {
      type: 'object',
      properties: {
        app_id: { type: 'string', description: 'Application ID' },
        test_user_email: { type: 'string', description: 'Email utilisateur test' },
        protocol: { type: 'string', enum: ['saml', 'oidc'] },
      },
      required: ['app_id', 'test_user_email', 'protocol'],
    },
  },
];

export async function executeAzureSSOTool(name, args) {
  const AZURE_TENANT_ID = process.env.AZURE_TENANT_ID;
  const AZURE_CLIENT_ID = process.env.AZURE_CLIENT_ID;
  const AZURE_CLIENT_SECRET = process.env.AZURE_CLIENT_SECRET;
  const MS_GRAPH_TOKEN = process.env.MS_GRAPH_TOKEN;

  // Get access token if not provided
  async function getAccessToken() {
    if (MS_GRAPH_TOKEN) return MS_GRAPH_TOKEN;

    const tokenEndpoint = `https://login.microsoftonline.com/${AZURE_TENANT_ID}/oauth2/v2.0/token`;
    const response = await fetch(tokenEndpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        client_id: AZURE_CLIENT_ID,
        client_secret: AZURE_CLIENT_SECRET,
        scope: 'https://graph.microsoft.com/.default',
        grant_type: 'client_credentials',
      }),
    });

    const data = await response.json();
    return data.access_token;
  }

  switch (name) {
    case 'alfa_azure_sso_app_registration': {
      if (!AZURE_TENANT_ID) throw new Error('AZURE_TENANT_ID not configured');

      const token = await getAccessToken();
      const endpoint = 'https://graph.microsoft.com/v1.0/applications';

      const body = {
        displayName: args.app_name,
        signInAudience: 'AzureADMyOrg',
        web: {
          redirectUris: args.redirect_uris,
          logoutUrl: args.logout_url,
        },
        requiredResourceAccess: args.api_permissions ? [
          {
            resourceAppId: '00000003-0000-0000-c000-000000000000', // Microsoft Graph
            resourceAccess: args.api_permissions.map(perm => ({
              id: perm, // Would need to map permission names to IDs
              type: 'Scope',
            })),
          },
        ] : [],
      };

      const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
      });

      const data = await response.json();

      // Also create service principal
      if (data.id) {
        const spEndpoint = 'https://graph.microsoft.com/v1.0/servicePrincipals';
        await fetch(spEndpoint, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ appId: data.appId }),
        });
      }

      return JSON.stringify({
        ...data,
        configuration_urls: {
          oidc_authority: `https://login.microsoftonline.com/${AZURE_TENANT_ID}/v2.0`,
          oidc_metadata: `https://login.microsoftonline.com/${AZURE_TENANT_ID}/v2.0/.well-known/openid-configuration`,
          saml_metadata: `https://login.microsoftonline.com/${AZURE_TENANT_ID}/federationmetadata/2007-06/federationmetadata.xml`,
        },
      }, null, 2);
    }

    case 'alfa_azure_sso_configure_saml': {
      const token = await getAccessToken();
      const endpoint = `https://graph.microsoft.com/v1.0/servicePrincipals/${args.app_id}`;

      const body = {
        preferredSingleSignOnMode: 'saml',
        replyUrls: [args.reply_url],
        loginUrl: args.sign_on_url,
        logoutUrl: args.logout_url,
      };

      const response = await fetch(endpoint, {
        method: 'PATCH',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
      });

      const data = await response.json();

      return JSON.stringify({
        ...data,
        saml_configuration: {
          entity_id: args.identifier,
          acs_url: args.reply_url,
          sign_on_url: args.sign_on_url,
          logout_url: args.logout_url,
          certificate_download: `https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SingleSignOn/objectId/${args.app_id}`,
        },
      }, null, 2);
    }

    case 'alfa_azure_sso_configure_oidc': {
      const token = await getAccessToken();

      // Create client secret
      const secretEndpoint = `https://graph.microsoft.com/v1.0/applications/${args.app_id}/addPassword`;
      const secretResponse = await fetch(secretEndpoint, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          passwordCredential: {
            displayName: args.client_secret_description || 'SSO Client Secret',
          },
        }),
      });

      const secretData = await secretResponse.json();

      return JSON.stringify({
        client_id: args.app_id,
        tenant_id: args.tenant_id,
        client_secret: secretData.secretText,
        authority: `https://login.microsoftonline.com/${args.tenant_id}`,
        authorization_endpoint: `https://login.microsoftonline.com/${args.tenant_id}/oauth2/v2.0/authorize`,
        token_endpoint: `https://login.microsoftonline.com/${args.tenant_id}/oauth2/v2.0/token`,
        jwks_uri: `https://login.microsoftonline.com/${args.tenant_id}/discovery/v2.0/keys`,
        scopes: args.scopes || ['openid', 'profile', 'email'],
        redirect_uris: args.redirect_uris,
      }, null, 2);
    }

    case 'alfa_azure_sso_assign_users': {
      const token = await getAccessToken();
      const assignments = [];

      // Assign users
      if (args.user_emails && args.user_emails.length > 0) {
        for (const email of args.user_emails) {
          // First get user ID
          const userResponse = await fetch(
            `https://graph.microsoft.com/v1.0/users/${email}`,
            {
              headers: { 'Authorization': `Bearer ${token}` },
            }
          );
          const user = await userResponse.json();

          // Then assign
          const assignEndpoint = `https://graph.microsoft.com/v1.0/servicePrincipals/${args.app_id}/appRoleAssignedTo`;
          const assignResponse = await fetch(assignEndpoint, {
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              principalId: user.id,
              resourceId: args.app_id,
              appRoleId: args.app_role_id || '00000000-0000-0000-0000-000000000000', // Default role
            }),
          });

          const assignData = await assignResponse.json();
          assignments.push({ user: email, ...assignData });
        }
      }

      return JSON.stringify({ assignments }, null, 2);
    }

    case 'alfa_azure_sso_conditional_access': {
      const token = await getAccessToken();
      const endpoint = 'https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies';

      const body = {
        displayName: args.policy_name,
        state: 'enabled',
        conditions: {
          applications: {
            includeApplications: [args.app_id],
          },
          users: args.conditions.users,
          locations: args.conditions.locations,
          platforms: args.conditions.device_platforms ? {
            includePlatforms: args.conditions.device_platforms,
          } : undefined,
        },
        grantControls: {
          operator: 'AND',
          builtInControls: [
            args.grant_controls.require_mfa ? 'mfa' : null,
            args.grant_controls.require_compliant_device ? 'compliantDevice' : null,
            args.grant_controls.require_approved_app ? 'approvedApplication' : null,
          ].filter(Boolean),
        },
      };

      const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
      });

      const data = await response.json();
      return JSON.stringify(data, null, 2);
    }

    case 'alfa_azure_sso_get_metadata': {
      const metadata = {
        tenant_id: args.tenant_id,
        app_id: args.app_id,
      };

      if (args.protocol === 'saml') {
        metadata.saml = {
          metadata_url: `https://login.microsoftonline.com/${args.tenant_id}/federationmetadata/2007-06/federationmetadata.xml`,
          issuer: `https://sts.windows.net/${args.tenant_id}/`,
          sso_url: `https://login.microsoftonline.com/${args.tenant_id}/saml2`,
          slo_url: `https://login.microsoftonline.com/${args.tenant_id}/saml2`,
          certificate_url: `https://login.microsoftonline.com/${args.tenant_id}/federationmetadata/2007-06/federationmetadata.xml`,
        };
      } else if (args.protocol === 'oidc') {
        metadata.oidc = {
          discovery_url: `https://login.microsoftonline.com/${args.tenant_id}/v2.0/.well-known/openid-configuration`,
          issuer: `https://login.microsoftonline.com/${args.tenant_id}/v2.0`,
          authorization_endpoint: `https://login.microsoftonline.com/${args.tenant_id}/oauth2/v2.0/authorize`,
          token_endpoint: `https://login.microsoftonline.com/${args.tenant_id}/oauth2/v2.0/token`,
          jwks_uri: `https://login.microsoftonline.com/${args.tenant_id}/discovery/v2.0/keys`,
          userinfo_endpoint: 'https://graph.microsoft.com/oidc/userinfo',
          end_session_endpoint: `https://login.microsoftonline.com/${args.tenant_id}/oauth2/v2.0/logout`,
        };
      }

      return JSON.stringify(metadata, null, 2);
    }

    case 'alfa_azure_sso_test_connection': {
      return JSON.stringify({
        test: 'SSO Connection Test',
        app_id: args.app_id,
        test_user: args.test_user_email,
        protocol: args.protocol,
        note: 'Use Azure Portal Test SSO feature for interactive testing',
        test_url: `https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SingleSignOn/objectId/${args.app_id}`,
        automated_test: 'Not available via API - use portal',
      }, null, 2);
    }

    default:
      throw new Error(`Unknown Azure SSO tool: ${name}`);
  }
}
