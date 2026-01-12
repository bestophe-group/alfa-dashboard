/**
 * ALFA MCP - Collaboration & Communication Tools
 * Slack, Microsoft 365, Google Workspace management
 */

import fetch from 'node-fetch';

export const collaborationTools = [
  {
    name: 'alfa_slack_send_message',
    description: 'Envoyer message Slack sur channel ou DM',
    inputSchema: {
      type: 'object',
      properties: {
        channel: { type: 'string', description: 'Channel ID ou nom (#general, @user)' },
        text: { type: 'string', description: 'Message texte' },
        blocks: { type: 'array', description: 'Blocks Slack pour message riche' },
        thread_ts: { type: 'string', description: 'Thread timestamp pour répondre' },
        attachments: { type: 'array', description: 'Fichiers à attacher' },
      },
      required: ['channel', 'text'],
    },
  },
  {
    name: 'alfa_slack_create_channel',
    description: 'Créer channel Slack (public/private)',
    inputSchema: {
      type: 'object',
      properties: {
        name: { type: 'string', description: 'Nom du channel (sans #)' },
        is_private: { type: 'boolean', description: 'Channel privé' },
        description: { type: 'string', description: 'Description du channel' },
        members: { type: 'array', items: { type: 'string' }, description: 'User IDs initiaux' },
      },
      required: ['name'],
    },
  },
  {
    name: 'alfa_slack_manage_users',
    description: 'Inviter/retirer users, gérer permissions Slack',
    inputSchema: {
      type: 'object',
      properties: {
        action: { type: 'string', enum: ['invite', 'deactivate', 'promote_admin', 'list'] },
        email: { type: 'string', description: 'Email utilisateur' },
        channels: { type: 'array', items: { type: 'string' }, description: 'Channels à ajouter' },
        real_name: { type: 'string', description: 'Nom complet' },
      },
      required: ['action'],
    },
  },
  {
    name: 'alfa_slack_archive_export',
    description: 'Exporter historique Slack ou archiver channels',
    inputSchema: {
      type: 'object',
      properties: {
        action: { type: 'string', enum: ['export_history', 'archive_channel'] },
        channel_id: { type: 'string', description: 'Channel à traiter' },
        date_range: { type: 'object', properties: { start: { type: 'string' }, end: { type: 'string' } } },
        output_format: { type: 'string', enum: ['json', 'csv', 'html'] },
      },
      required: ['action'],
    },
  },
  {
    name: 'alfa_microsoft365_user_management',
    description: 'Gestion utilisateurs Azure AD / Microsoft 365',
    inputSchema: {
      type: 'object',
      properties: {
        action: { type: 'string', enum: ['create', 'delete', 'update', 'reset_password', 'assign_license'] },
        user_email: { type: 'string', description: 'Email utilisateur' },
        display_name: { type: 'string', description: 'Nom affiché' },
        licenses: { type: 'array', items: { type: 'string' }, description: 'SKUs licences (E3, E5, etc.)' },
        department: { type: 'string' },
        manager_email: { type: 'string' },
      },
      required: ['action'],
    },
  },
  {
    name: 'alfa_microsoft365_teams_management',
    description: 'Créer/gérer Teams, channels, permissions',
    inputSchema: {
      type: 'object',
      properties: {
        action: { type: 'string', enum: ['create_team', 'add_member', 'create_channel', 'set_permissions'] },
        team_name: { type: 'string', description: 'Nom de l\'équipe' },
        team_id: { type: 'string', description: 'ID équipe existante' },
        members: { type: 'array', items: { type: 'string' }, description: 'Emails membres' },
        channel_name: { type: 'string', description: 'Nom du channel' },
        is_private: { type: 'boolean' },
      },
      required: ['action'],
    },
  },
  {
    name: 'alfa_microsoft365_sharepoint',
    description: 'Gestion SharePoint: sites, listes, permissions',
    inputSchema: {
      type: 'object',
      properties: {
        action: { type: 'string', enum: ['create_site', 'upload_file', 'set_permissions', 'create_list'] },
        site_url: { type: 'string', description: 'URL du site SharePoint' },
        site_title: { type: 'string', description: 'Titre du site' },
        file_path: { type: 'string', description: 'Chemin fichier local' },
        destination_path: { type: 'string', description: 'Chemin SharePoint' },
        permissions: { type: 'object', description: 'Users/groupes et niveaux' },
      },
      required: ['action'],
    },
  },
  {
    name: 'alfa_microsoft365_exchange',
    description: 'Gestion Exchange: boîtes mail, groupes distrib, règles',
    inputSchema: {
      type: 'object',
      properties: {
        action: { type: 'string', enum: ['create_mailbox', 'create_distribution_list', 'set_forwarding', 'add_calendar_permissions'] },
        email: { type: 'string', description: 'Email concerné' },
        display_name: { type: 'string' },
        members: { type: 'array', items: { type: 'string' } },
        forward_to: { type: 'string', description: 'Email de redirection' },
      },
      required: ['action'],
    },
  },
  {
    name: 'alfa_google_workspace_users',
    description: 'Gestion utilisateurs Google Workspace',
    inputSchema: {
      type: 'object',
      properties: {
        action: { type: 'string', enum: ['create', 'delete', 'suspend', 'reset_password', 'update'] },
        email: { type: 'string', description: 'Email utilisateur' },
        first_name: { type: 'string' },
        last_name: { type: 'string' },
        password: { type: 'string', description: 'Mot de passe initial' },
        organizational_unit: { type: 'string', description: 'OU path' },
      },
      required: ['action', 'email'],
    },
  },
  {
    name: 'alfa_google_workspace_groups',
    description: 'Gestion groupes Google (groupes distrib, sécurité)',
    inputSchema: {
      type: 'object',
      properties: {
        action: { type: 'string', enum: ['create', 'add_member', 'remove_member', 'list_members'] },
        group_email: { type: 'string', description: 'Email du groupe' },
        group_name: { type: 'string', description: 'Nom du groupe' },
        member_email: { type: 'string', description: 'Email membre' },
        role: { type: 'string', enum: ['MEMBER', 'MANAGER', 'OWNER'] },
      },
      required: ['action', 'group_email'],
    },
  },
  {
    name: 'alfa_google_workspace_drive',
    description: 'Gestion Google Drive: partage, permissions, upload',
    inputSchema: {
      type: 'object',
      properties: {
        action: { type: 'string', enum: ['upload', 'share', 'create_folder', 'move', 'delete'] },
        file_path: { type: 'string', description: 'Chemin fichier local' },
        file_id: { type: 'string', description: 'ID fichier Google Drive' },
        folder_name: { type: 'string' },
        parent_folder_id: { type: 'string' },
        share_with: { type: 'array', items: { type: 'string' }, description: 'Emails à partager' },
        permission_role: { type: 'string', enum: ['reader', 'writer', 'commenter'] },
      },
      required: ['action'],
    },
  },
];

export async function executeCollaborationTool(name, args) {
  const SLACK_TOKEN = process.env.SLACK_BOT_TOKEN;
  const MS_GRAPH_TOKEN = process.env.MS_GRAPH_TOKEN;
  const GOOGLE_SA_KEY = process.env.GOOGLE_SERVICE_ACCOUNT_KEY;

  switch (name) {
    case 'alfa_slack_send_message': {
      if (!SLACK_TOKEN) throw new Error('SLACK_BOT_TOKEN not configured');

      const response = await fetch('https://slack.com/api/chat.postMessage', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${SLACK_TOKEN}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          channel: args.channel,
          text: args.text,
          blocks: args.blocks,
          thread_ts: args.thread_ts,
        }),
      });

      const data = await response.json();
      return JSON.stringify({ ok: data.ok, ts: data.ts, channel: data.channel }, null, 2);
    }

    case 'alfa_slack_create_channel': {
      if (!SLACK_TOKEN) throw new Error('SLACK_BOT_TOKEN not configured');

      const endpoint = args.is_private ? 'conversations.create' : 'conversations.create';
      const response = await fetch(`https://slack.com/api/${endpoint}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${SLACK_TOKEN}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          name: args.name,
          is_private: args.is_private || false,
          description: args.description,
        }),
      });

      const data = await response.json();
      return JSON.stringify({ ok: data.ok, channel: data.channel }, null, 2);
    }

    case 'alfa_slack_manage_users': {
      if (!SLACK_TOKEN) throw new Error('SLACK_BOT_TOKEN not configured');

      let endpoint = '';
      let body = {};

      switch (args.action) {
        case 'invite':
          endpoint = 'users.admin.invite';
          body = {
            email: args.email,
            channels: args.channels?.join(','),
            real_name: args.real_name,
          };
          break;
        case 'deactivate':
          endpoint = 'users.admin.setInactive';
          body = { user: args.email };
          break;
        case 'list':
          endpoint = 'users.list';
          break;
      }

      const response = await fetch(`https://slack.com/api/${endpoint}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${SLACK_TOKEN}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
      });

      const data = await response.json();
      return JSON.stringify(data, null, 2);
    }

    case 'alfa_microsoft365_user_management': {
      if (!MS_GRAPH_TOKEN) throw new Error('MS_GRAPH_TOKEN not configured');

      let endpoint = '';
      let method = 'POST';
      let body = {};

      switch (args.action) {
        case 'create':
          endpoint = 'https://graph.microsoft.com/v1.0/users';
          body = {
            accountEnabled: true,
            displayName: args.display_name,
            mailNickname: args.user_email.split('@')[0],
            userPrincipalName: args.user_email,
            passwordProfile: {
              forceChangePasswordNextSignIn: true,
              password: Math.random().toString(36).slice(-12) + 'Aa1!',
            },
            department: args.department,
          };
          break;

        case 'reset_password':
          endpoint = `https://graph.microsoft.com/v1.0/users/${args.user_email}`;
          method = 'PATCH';
          body = {
            passwordProfile: {
              forceChangePasswordNextSignIn: true,
              password: Math.random().toString(36).slice(-12) + 'Aa1!',
            },
          };
          break;

        case 'assign_license':
          endpoint = `https://graph.microsoft.com/v1.0/users/${args.user_email}/assignLicense`;
          body = {
            addLicenses: args.licenses.map(sku => ({ skuId: sku })),
            removeLicenses: [],
          };
          break;
      }

      const response = await fetch(endpoint, {
        method,
        headers: {
          'Authorization': `Bearer ${MS_GRAPH_TOKEN}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
      });

      const data = await response.json();
      return JSON.stringify(data, null, 2);
    }

    case 'alfa_microsoft365_teams_management': {
      if (!MS_GRAPH_TOKEN) throw new Error('MS_GRAPH_TOKEN not configured');

      let endpoint = '';
      let body = {};

      switch (args.action) {
        case 'create_team':
          endpoint = 'https://graph.microsoft.com/v1.0/teams';
          body = {
            'template@odata.bind': "https://graph.microsoft.com/v1.0/teamsTemplates('standard')",
            displayName: args.team_name,
            description: args.team_name,
          };
          break;

        case 'add_member':
          endpoint = `https://graph.microsoft.com/v1.0/teams/${args.team_id}/members`;
          body = {
            '@odata.type': '#microsoft.graph.aadUserConversationMember',
            roles: ['member'],
            'user@odata.bind': `https://graph.microsoft.com/v1.0/users('${args.members[0]}')`,
          };
          break;

        case 'create_channel':
          endpoint = `https://graph.microsoft.com/v1.0/teams/${args.team_id}/channels`;
          body = {
            displayName: args.channel_name,
            description: args.channel_name,
            membershipType: args.is_private ? 'private' : 'standard',
          };
          break;
      }

      const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${MS_GRAPH_TOKEN}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
      });

      const data = await response.json();
      return JSON.stringify(data, null, 2);
    }

    case 'alfa_google_workspace_users': {
      // Google Admin SDK
      const result = {
        action: args.action,
        email: args.email,
        note: 'Google Workspace Admin SDK integration',
        endpoint: `https://admin.googleapis.com/admin/directory/v1/users`,
        method: args.action === 'create' ? 'POST' : 'PATCH',
      };

      return JSON.stringify(result, null, 2);
    }

    default:
      throw new Error(`Unknown collaboration tool: ${name}`);
  }
}
