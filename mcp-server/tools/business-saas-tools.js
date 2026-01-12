/**
 * ALFA MCP - Business SaaS Tools
 * PayFit, PennyLane, Bitwarden, social media, content creation
 */

import fetch from 'node-fetch';
import { execSync } from 'child_process';

export const businessSaasTools = [
  {
    name: 'alfa_payfit_employees',
    description: 'Gestion employés PayFit: création, export, paie',
    inputSchema: {
      type: 'object',
      properties: {
        action: { type: 'string', enum: ['list', 'create', 'update', 'export_payroll', 'get_payslip'] },
        employee_id: { type: 'string', description: 'ID employé PayFit' },
        first_name: { type: 'string' },
        last_name: { type: 'string' },
        email: { type: 'string' },
        start_date: { type: 'string', description: 'Date d\'embauche YYYY-MM-DD' },
        salary: { type: 'number', description: 'Salaire brut mensuel' },
        contract_type: { type: 'string', enum: ['CDI', 'CDD', 'Stage', 'Apprentissage'] },
        month: { type: 'string', description: 'Mois paie YYYY-MM' },
      },
      required: ['action'],
    },
  },
  {
    name: 'alfa_payfit_time_off',
    description: 'Gestion congés PayFit: demandes, validations, soldes',
    inputSchema: {
      type: 'object',
      properties: {
        action: { type: 'string', enum: ['request', 'approve', 'reject', 'get_balance'] },
        employee_id: { type: 'string' },
        leave_type: { type: 'string', enum: ['CP', 'RTT', 'Maladie', 'Sans_solde'] },
        start_date: { type: 'string' },
        end_date: { type: 'string' },
        reason: { type: 'string' },
      },
      required: ['action', 'employee_id'],
    },
  },
  {
    name: 'alfa_pennylane_invoices',
    description: 'Gestion factures PennyLane: création, export, relances',
    inputSchema: {
      type: 'object',
      properties: {
        action: { type: 'string', enum: ['create', 'list', 'send', 'mark_paid', 'export'] },
        invoice_id: { type: 'string' },
        customer_id: { type: 'string', description: 'ID client PennyLane' },
        line_items: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              description: { type: 'string' },
              quantity: { type: 'number' },
              unit_price: { type: 'number' },
              vat_rate: { type: 'number', description: 'Taux TVA (0.20 pour 20%)' },
            },
          },
        },
        due_date: { type: 'string', description: 'Date échéance YYYY-MM-DD' },
        payment_method: { type: 'string', enum: ['virement', 'carte', 'cheque', 'especes'] },
      },
      required: ['action'],
    },
  },
  {
    name: 'alfa_pennylane_expenses',
    description: 'Gestion notes de frais PennyLane',
    inputSchema: {
      type: 'object',
      properties: {
        action: { type: 'string', enum: ['create', 'approve', 'list', 'export'] },
        expense_id: { type: 'string' },
        employee_email: { type: 'string' },
        amount: { type: 'number' },
        category: { type: 'string', description: 'Catégorie comptable' },
        description: { type: 'string' },
        receipt_path: { type: 'string', description: 'Chemin vers justificatif' },
        date: { type: 'string', description: 'Date dépense' },
      },
      required: ['action'],
    },
  },
  {
    name: 'alfa_pennylane_accounting_export',
    description: 'Export comptabilité PennyLane: FEC, bilan, compte de résultat',
    inputSchema: {
      type: 'object',
      properties: {
        export_type: { type: 'string', enum: ['FEC', 'balance', 'profit_loss', 'all_transactions'] },
        start_date: { type: 'string', description: 'Début période YYYY-MM-DD' },
        end_date: { type: 'string', description: 'Fin période YYYY-MM-DD' },
        format: { type: 'string', enum: ['csv', 'xlsx', 'pdf'] },
        output_path: { type: 'string' },
      },
      required: ['export_type', 'start_date', 'end_date'],
    },
  },
  {
    name: 'alfa_bitwarden_vault',
    description: 'Gestion coffre-fort Bitwarden: mots de passe, partage',
    inputSchema: {
      type: 'object',
      properties: {
        action: { type: 'string', enum: ['add', 'get', 'list', 'share', 'generate'] },
        name: { type: 'string', description: 'Nom identifiant' },
        username: { type: 'string' },
        password: { type: 'string' },
        uri: { type: 'string', description: 'URL du service' },
        folder: { type: 'string', description: 'Dossier organisation' },
        share_with: { type: 'array', items: { type: 'string' }, description: 'Emails à partager' },
        password_length: { type: 'number', description: 'Longueur mdp généré' },
      },
      required: ['action'],
    },
  },
  {
    name: 'alfa_instagram_post',
    description: 'Publier sur Instagram: photo, carrousel, story, reel',
    inputSchema: {
      type: 'object',
      properties: {
        post_type: { type: 'string', enum: ['photo', 'carousel', 'story', 'reel'] },
        media_paths: { type: 'array', items: { type: 'string' }, description: 'Chemins images/vidéos' },
        caption: { type: 'string', description: 'Légende' },
        hashtags: { type: 'array', items: { type: 'string' } },
        location: { type: 'string', description: 'Lieu' },
        schedule_time: { type: 'string', description: 'Publication programmée ISO 8601' },
      },
      required: ['post_type', 'media_paths'],
    },
  },
  {
    name: 'alfa_facebook_page_post',
    description: 'Publier sur page Facebook: texte, image, vidéo, lien',
    inputSchema: {
      type: 'object',
      properties: {
        page_id: { type: 'string', description: 'ID page Facebook' },
        message: { type: 'string', description: 'Texte du post' },
        media_type: { type: 'string', enum: ['text', 'photo', 'video', 'link'] },
        media_path: { type: 'string', description: 'Chemin média' },
        link: { type: 'string', description: 'URL à partager' },
        schedule_time: { type: 'string', description: 'Publication programmée' },
      },
      required: ['page_id', 'message'],
    },
  },
  {
    name: 'alfa_tiktok_post',
    description: 'Publier vidéo TikTok',
    inputSchema: {
      type: 'object',
      properties: {
        video_path: { type: 'string', description: 'Chemin vidéo locale' },
        caption: { type: 'string', description: 'Légende' },
        hashtags: { type: 'array', items: { type: 'string' } },
        privacy: { type: 'string', enum: ['public', 'friends', 'private'] },
        allow_comments: { type: 'boolean' },
        allow_duet: { type: 'boolean' },
        allow_stitch: { type: 'boolean' },
      },
      required: ['video_path'],
    },
  },
  {
    name: 'alfa_youtube_upload',
    description: 'Upload vidéo YouTube: titre, description, playlist',
    inputSchema: {
      type: 'object',
      properties: {
        video_path: { type: 'string', description: 'Chemin vidéo' },
        title: { type: 'string', description: 'Titre vidéo' },
        description: { type: 'string' },
        tags: { type: 'array', items: { type: 'string' } },
        category_id: { type: 'string', description: 'ID catégorie YouTube' },
        privacy: { type: 'string', enum: ['public', 'unlisted', 'private'] },
        playlist_id: { type: 'string', description: 'Ajouter à playlist' },
        thumbnail_path: { type: 'string', description: 'Miniature custom' },
        schedule_time: { type: 'string', description: 'Publication programmée' },
      },
      required: ['video_path', 'title'],
    },
  },
  {
    name: 'alfa_canva_design',
    description: 'Créer design Canva via API',
    inputSchema: {
      type: 'object',
      properties: {
        template_id: { type: 'string', description: 'ID template Canva' },
        design_type: { type: 'string', enum: ['instagram-post', 'story', 'linkedin-post', 'presentation', 'logo'] },
        elements: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              type: { type: 'string', enum: ['text', 'image', 'shape'] },
              content: { type: 'string' },
              position: { type: 'object' },
              style: { type: 'object' },
            },
          },
        },
        export_format: { type: 'string', enum: ['png', 'jpg', 'pdf', 'mp4'] },
      },
      required: ['design_type'],
    },
  },
];

export async function executeBusinessSaasTool(name, args) {
  const PAYFIT_API_KEY = process.env.PAYFIT_API_KEY;
  const PENNYLANE_API_KEY = process.env.PENNYLANE_API_KEY;
  const BITWARDEN_SESSION = process.env.BW_SESSION;
  const FACEBOOK_ACCESS_TOKEN = process.env.FACEBOOK_ACCESS_TOKEN;
  const YOUTUBE_API_KEY = process.env.YOUTUBE_API_KEY;
  const CANVA_API_KEY = process.env.CANVA_API_KEY;

  switch (name) {
    case 'alfa_payfit_employees': {
      if (!PAYFIT_API_KEY) throw new Error('PAYFIT_API_KEY not configured');

      const baseUrl = 'https://api.payfit.com/partner/v1';
      let endpoint = '';
      let method = 'GET';
      let body = {};

      switch (args.action) {
        case 'list':
          endpoint = `${baseUrl}/employees`;
          break;

        case 'create':
          endpoint = `${baseUrl}/employees`;
          method = 'POST';
          body = {
            firstName: args.first_name,
            lastName: args.last_name,
            email: args.email,
            startDate: args.start_date,
            contractType: args.contract_type,
            salary: args.salary,
          };
          break;

        case 'export_payroll':
          endpoint = `${baseUrl}/payroll/${args.month}/export`;
          break;
      }

      const response = await fetch(endpoint, {
        method,
        headers: {
          'Authorization': `Bearer ${PAYFIT_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: method !== 'GET' ? JSON.stringify(body) : undefined,
      });

      const data = await response.json();
      return JSON.stringify(data, null, 2);
    }

    case 'alfa_pennylane_invoices': {
      if (!PENNYLANE_API_KEY) throw new Error('PENNYLANE_API_KEY not configured');

      const baseUrl = 'https://app.pennylane.com/api/external/v1';
      let endpoint = '';
      let method = 'GET';
      let body = {};

      switch (args.action) {
        case 'create':
          endpoint = `${baseUrl}/customer_invoices`;
          method = 'POST';
          body = {
            invoice: {
              customer_id: args.customer_id,
              due_date: args.due_date,
              line_items: args.line_items.map(item => ({
                label: item.description,
                quantity: item.quantity,
                unit_price: item.unit_price,
                vat_rate: item.vat_rate || 0.20,
              })),
            },
          };
          break;

        case 'list':
          endpoint = `${baseUrl}/customer_invoices`;
          break;

        case 'send':
          endpoint = `${baseUrl}/customer_invoices/${args.invoice_id}/send`;
          method = 'POST';
          break;

        case 'mark_paid':
          endpoint = `${baseUrl}/customer_invoices/${args.invoice_id}/payment`;
          method = 'POST';
          body = {
            payment: {
              method: args.payment_method,
              amount: 0, // Will be calculated
              date: new Date().toISOString().split('T')[0],
            },
          };
          break;
      }

      const response = await fetch(endpoint, {
        method,
        headers: {
          'Authorization': `Bearer ${PENNYLANE_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: method !== 'GET' ? JSON.stringify(body) : undefined,
      });

      const data = await response.json();
      return JSON.stringify(data, null, 2);
    }

    case 'alfa_pennylane_accounting_export': {
      if (!PENNYLANE_API_KEY) throw new Error('PENNYLANE_API_KEY not configured');

      const endpoint = `https://app.pennylane.com/api/external/v1/exports/${args.export_type}`;

      const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${PENNYLANE_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          start_date: args.start_date,
          end_date: args.end_date,
          format: args.format || 'csv',
        }),
      });

      const data = await response.json();

      if (args.output_path && data.download_url) {
        const fileResponse = await fetch(data.download_url);
        const buffer = await fileResponse.buffer();
        require('fs').writeFileSync(args.output_path, buffer);

        return `Export saved to: ${args.output_path}`;
      }

      return JSON.stringify(data, null, 2);
    }

    case 'alfa_bitwarden_vault': {
      if (!BITWARDEN_SESSION) throw new Error('BW_SESSION not configured. Run: bw login');

      let command = `BW_SESSION=${BITWARDEN_SESSION} bw `;

      switch (args.action) {
        case 'add':
          const item = {
            type: 1, // Login
            name: args.name,
            login: {
              username: args.username,
              password: args.password,
              uris: [{ match: null, uri: args.uri }],
            },
          };

          command += `create item '${JSON.stringify(item).replace(/'/g, "\\'")}'`;
          break;

        case 'get':
          command += `get item "${args.name}"`;
          break;

        case 'list':
          command += `list items`;
          break;

        case 'generate':
          command += `generate --length ${args.password_length || 32} --uppercase --lowercase --number --special`;
          break;
      }

      const output = execSync(command, { encoding: 'utf8' });
      return output;
    }

    case 'alfa_instagram_post': {
      // Instagram Graph API
      const result = {
        post_type: args.post_type,
        media: args.media_paths,
        caption: args.caption,
        note: 'Instagram Graph API - requires Facebook Page connection',
        api_endpoint: 'https://graph.facebook.com/v18.0/me/media',
        workflow: [
          '1. Upload media to container',
          '2. Publish container',
          '3. Verify post',
        ],
      };

      return JSON.stringify(result, null, 2);
    }

    case 'alfa_facebook_page_post': {
      if (!FACEBOOK_ACCESS_TOKEN) throw new Error('FACEBOOK_ACCESS_TOKEN not configured');

      const endpoint = `https://graph.facebook.com/v18.0/${args.page_id}/feed`;

      const formData = {
        message: args.message,
        access_token: FACEBOOK_ACCESS_TOKEN,
      };

      if (args.link) {
        formData.link = args.link;
      }

      if (args.schedule_time) {
        formData.scheduled_publish_time = Math.floor(new Date(args.schedule_time).getTime() / 1000);
        formData.published = false;
      }

      const response = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData),
      });

      const data = await response.json();
      return JSON.stringify(data, null, 2);
    }

    case 'alfa_youtube_upload': {
      if (!YOUTUBE_API_KEY) throw new Error('YOUTUBE_API_KEY not configured');

      const result = {
        video: args.video_path,
        title: args.title,
        note: 'YouTube Data API v3 - requires OAuth2',
        api_endpoint: 'https://www.googleapis.com/upload/youtube/v3/videos',
        workflow: [
          '1. Authenticate with OAuth2',
          '2. Upload video file',
          '3. Set metadata (title, description, tags)',
          '4. Add to playlist if specified',
          '5. Set thumbnail',
        ],
      };

      return JSON.stringify(result, null, 2);
    }

    case 'alfa_canva_design': {
      const result = {
        design_type: args.design_type,
        template: args.template_id,
        note: 'Canva API integration',
        suggested_workflow: [
          '1. Create design from template',
          '2. Update elements',
          '3. Export in desired format',
        ],
      };

      return JSON.stringify(result, null, 2);
    }

    default:
      throw new Error(`Unknown business SaaS tool: ${name}`);
  }
}
