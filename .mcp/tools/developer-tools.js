/**
 * ALFA MCP - Developer Tools
 * GitHub management and browser automation
 */

import fetch from 'node-fetch';
import { execSync } from 'child_process';

export const developerTools = [
  {
    name: 'alfa_github_repo_management',
    description: 'Gestion repos GitHub: création, clonage, fork, archivage',
    inputSchema: {
      type: 'object',
      properties: {
        action: { type: 'string', enum: ['create', 'clone', 'fork', 'archive', 'delete', 'list'] },
        repo_name: { type: 'string', description: 'Nom du repository' },
        owner: { type: 'string', description: 'Owner du repo (username ou org)' },
        description: { type: 'string', description: 'Description du repo' },
        private: { type: 'boolean', description: 'Repo privé ou public' },
        clone_path: { type: 'string', description: 'Chemin local pour cloner' },
      },
      required: ['action'],
    },
  },
  {
    name: 'alfa_github_issues_management',
    description: 'Gestion issues GitHub: création, assignation, labels, fermeture',
    inputSchema: {
      type: 'object',
      properties: {
        action: { type: 'string', enum: ['create', 'update', 'close', 'assign', 'add_label', 'list'] },
        owner: { type: 'string', description: 'Owner du repo' },
        repo: { type: 'string', description: 'Nom du repo' },
        issue_number: { type: 'number', description: 'Numéro de l\'issue' },
        title: { type: 'string', description: 'Titre de l\'issue' },
        body: { type: 'string', description: 'Description de l\'issue' },
        assignees: { type: 'array', items: { type: 'string' }, description: 'Usernames à assigner' },
        labels: { type: 'array', items: { type: 'string' }, description: 'Labels à ajouter' },
        state: { type: 'string', enum: ['open', 'closed'] },
      },
      required: ['action', 'owner', 'repo'],
    },
  },
  {
    name: 'alfa_github_pr_management',
    description: 'Gestion Pull Requests: création, review, merge, commentaires',
    inputSchema: {
      type: 'object',
      properties: {
        action: { type: 'string', enum: ['create', 'review', 'merge', 'close', 'list', 'comment'] },
        owner: { type: 'string', description: 'Owner du repo' },
        repo: { type: 'string', description: 'Nom du repo' },
        pr_number: { type: 'number', description: 'Numéro de la PR' },
        title: { type: 'string', description: 'Titre de la PR' },
        body: { type: 'string', description: 'Description de la PR' },
        head: { type: 'string', description: 'Branche source' },
        base: { type: 'string', description: 'Branche destination' },
        review_event: { type: 'string', enum: ['APPROVE', 'REQUEST_CHANGES', 'COMMENT'] },
        review_body: { type: 'string', description: 'Commentaire de review' },
        merge_method: { type: 'string', enum: ['merge', 'squash', 'rebase'] },
      },
      required: ['action', 'owner', 'repo'],
    },
  },
  {
    name: 'alfa_github_actions_management',
    description: 'Gestion GitHub Actions: workflows, runs, artifacts',
    inputSchema: {
      type: 'object',
      properties: {
        action: { type: 'string', enum: ['list_workflows', 'trigger_workflow', 'list_runs', 'cancel_run', 'download_artifact'] },
        owner: { type: 'string', description: 'Owner du repo' },
        repo: { type: 'string', description: 'Nom du repo' },
        workflow_id: { type: 'string', description: 'ID du workflow' },
        run_id: { type: 'number', description: 'ID du run' },
        ref: { type: 'string', description: 'Branch/tag à trigger (default: main)' },
        inputs: { type: 'object', description: 'Inputs pour workflow_dispatch' },
      },
      required: ['action', 'owner', 'repo'],
    },
  },
  {
    name: 'alfa_github_release_management',
    description: 'Gestion releases GitHub: création, publication, assets',
    inputSchema: {
      type: 'object',
      properties: {
        action: { type: 'string', enum: ['create', 'update', 'delete', 'list', 'upload_asset'] },
        owner: { type: 'string', description: 'Owner du repo' },
        repo: { type: 'string', description: 'Nom du repo' },
        tag_name: { type: 'string', description: 'Tag de la release (ex: v1.0.0)' },
        release_id: { type: 'number', description: 'ID de la release' },
        name: { type: 'string', description: 'Nom de la release' },
        body: { type: 'string', description: 'Notes de release (markdown)' },
        draft: { type: 'boolean', description: 'Release en mode draft' },
        prerelease: { type: 'boolean', description: 'Marquer comme prerelease' },
        asset_path: { type: 'string', description: 'Chemin vers le fichier asset' },
      },
      required: ['action', 'owner', 'repo'],
    },
  },
  {
    name: 'alfa_browser_navigate',
    description: 'Navigation web automatisée: ouvrir URL, remplir forms, cliquer, scraper',
    inputSchema: {
      type: 'object',
      properties: {
        action: { type: 'string', enum: ['open', 'click', 'fill_form', 'screenshot', 'extract_text', 'wait'] },
        url: { type: 'string', description: 'URL à ouvrir' },
        selector: { type: 'string', description: 'CSS selector de l\'élément' },
        value: { type: 'string', description: 'Valeur à entrer dans un champ' },
        form_data: {
          type: 'object',
          description: 'Données de formulaire {selector: value}',
        },
        screenshot_path: { type: 'string', description: 'Chemin pour sauvegarder screenshot' },
        wait_time: { type: 'number', description: 'Temps d\'attente en ms' },
        headless: { type: 'boolean', description: 'Mode headless (default: true)' },
      },
      required: ['action'],
    },
  },
  {
    name: 'alfa_browser_scrape',
    description: 'Web scraping avancé: extraction données structurées',
    inputSchema: {
      type: 'object',
      properties: {
        url: { type: 'string', description: 'URL à scraper' },
        selectors: {
          type: 'object',
          description: 'Mapping de selectors {fieldName: cssSelector}',
        },
        pagination: {
          type: 'object',
          properties: {
            enabled: { type: 'boolean' },
            next_button_selector: { type: 'string' },
            max_pages: { type: 'number' },
          },
        },
        output_format: { type: 'string', enum: ['json', 'csv', 'markdown'] },
        wait_for: { type: 'string', description: 'Selector à attendre avant scraping' },
      },
      required: ['url', 'selectors'],
    },
  },
  {
    name: 'alfa_browser_authenticate',
    description: 'Authentification web automatisée: login, cookies, sessions',
    inputSchema: {
      type: 'object',
      properties: {
        url: { type: 'string', description: 'URL de la page de login' },
        username_selector: { type: 'string', description: 'Selector du champ username' },
        password_selector: { type: 'string', description: 'Selector du champ password' },
        submit_selector: { type: 'string', description: 'Selector du bouton submit' },
        username: { type: 'string', description: 'Username' },
        password: { type: 'string', description: 'Password' },
        save_cookies: { type: 'boolean', description: 'Sauvegarder cookies pour réutiliser' },
        cookies_path: { type: 'string', description: 'Chemin pour sauvegarder cookies' },
      },
      required: ['url', 'username_selector', 'password_selector', 'submit_selector', 'username', 'password'],
    },
  },
];

export async function executeDeveloperTool(name, args) {
  const GITHUB_TOKEN = process.env.GITHUB_TOKEN || process.env.GITHUB_PAT;
  const GITHUB_API = 'https://api.github.com';

  switch (name) {
    case 'alfa_github_repo_management': {
      if (!GITHUB_TOKEN) throw new Error('GITHUB_TOKEN not configured');

      let endpoint = '';
      let method = 'GET';
      let body = {};

      switch (args.action) {
        case 'create':
          endpoint = `${GITHUB_API}/user/repos`;
          method = 'POST';
          body = {
            name: args.repo_name,
            description: args.description,
            private: args.private || false,
          };
          break;

        case 'list':
          endpoint = `${GITHUB_API}/user/repos`;
          break;

        case 'clone':
          const cloneUrl = `https://github.com/${args.owner}/${args.repo_name}.git`;
          const output = execSync(`git clone ${cloneUrl} ${args.clone_path || ''}`, { encoding: 'utf8' });
          return output;

        case 'fork':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo_name}/forks`;
          method = 'POST';
          break;

        case 'archive':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo_name}`;
          method = 'PATCH';
          body = { archived: true };
          break;
      }

      const response = await fetch(endpoint, {
        method,
        headers: {
          'Authorization': `Bearer ${GITHUB_TOKEN}`,
          'Accept': 'application/vnd.github+json',
          'Content-Type': 'application/json',
        },
        body: method !== 'GET' ? JSON.stringify(body) : undefined,
      });

      const data = await response.json();
      return JSON.stringify(data, null, 2);
    }

    case 'alfa_github_issues_management': {
      if (!GITHUB_TOKEN) throw new Error('GITHUB_TOKEN not configured');

      let endpoint = '';
      let method = 'GET';
      let body = {};

      switch (args.action) {
        case 'create':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo}/issues`;
          method = 'POST';
          body = {
            title: args.title,
            body: args.body,
            assignees: args.assignees,
            labels: args.labels,
          };
          break;

        case 'update':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo}/issues/${args.issue_number}`;
          method = 'PATCH';
          body = {
            title: args.title,
            body: args.body,
            state: args.state,
          };
          break;

        case 'close':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo}/issues/${args.issue_number}`;
          method = 'PATCH';
          body = { state: 'closed' };
          break;

        case 'assign':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo}/issues/${args.issue_number}/assignees`;
          method = 'POST';
          body = { assignees: args.assignees };
          break;

        case 'add_label':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo}/issues/${args.issue_number}/labels`;
          method = 'POST';
          body = { labels: args.labels };
          break;

        case 'list':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo}/issues`;
          break;
      }

      const response = await fetch(endpoint, {
        method,
        headers: {
          'Authorization': `Bearer ${GITHUB_TOKEN}`,
          'Accept': 'application/vnd.github+json',
          'Content-Type': 'application/json',
        },
        body: method !== 'GET' ? JSON.stringify(body) : undefined,
      });

      const data = await response.json();
      return JSON.stringify(data, null, 2);
    }

    case 'alfa_github_pr_management': {
      if (!GITHUB_TOKEN) throw new Error('GITHUB_TOKEN not configured');

      let endpoint = '';
      let method = 'GET';
      let body = {};

      switch (args.action) {
        case 'create':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo}/pulls`;
          method = 'POST';
          body = {
            title: args.title,
            body: args.body,
            head: args.head,
            base: args.base || 'main',
          };
          break;

        case 'review':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo}/pulls/${args.pr_number}/reviews`;
          method = 'POST';
          body = {
            event: args.review_event,
            body: args.review_body,
          };
          break;

        case 'merge':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo}/pulls/${args.pr_number}/merge`;
          method = 'PUT';
          body = {
            merge_method: args.merge_method || 'merge',
          };
          break;

        case 'close':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo}/pulls/${args.pr_number}`;
          method = 'PATCH';
          body = { state: 'closed' };
          break;

        case 'list':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo}/pulls`;
          break;

        case 'comment':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo}/issues/${args.pr_number}/comments`;
          method = 'POST';
          body = { body: args.review_body };
          break;
      }

      const response = await fetch(endpoint, {
        method,
        headers: {
          'Authorization': `Bearer ${GITHUB_TOKEN}`,
          'Accept': 'application/vnd.github+json',
          'Content-Type': 'application/json',
        },
        body: method !== 'GET' ? JSON.stringify(body) : undefined,
      });

      const data = await response.json();
      return JSON.stringify(data, null, 2);
    }

    case 'alfa_github_actions_management': {
      if (!GITHUB_TOKEN) throw new Error('GITHUB_TOKEN not configured');

      let endpoint = '';
      let method = 'GET';
      let body = {};

      switch (args.action) {
        case 'list_workflows':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo}/actions/workflows`;
          break;

        case 'trigger_workflow':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo}/actions/workflows/${args.workflow_id}/dispatches`;
          method = 'POST';
          body = {
            ref: args.ref || 'main',
            inputs: args.inputs || {},
          };
          break;

        case 'list_runs':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo}/actions/runs`;
          break;

        case 'cancel_run':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo}/actions/runs/${args.run_id}/cancel`;
          method = 'POST';
          break;
      }

      const response = await fetch(endpoint, {
        method,
        headers: {
          'Authorization': `Bearer ${GITHUB_TOKEN}`,
          'Accept': 'application/vnd.github+json',
          'Content-Type': 'application/json',
        },
        body: method !== 'GET' ? JSON.stringify(body) : undefined,
      });

      const data = await response.json();
      return JSON.stringify(data, null, 2);
    }

    case 'alfa_github_release_management': {
      if (!GITHUB_TOKEN) throw new Error('GITHUB_TOKEN not configured');

      let endpoint = '';
      let method = 'GET';
      let body = {};

      switch (args.action) {
        case 'create':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo}/releases`;
          method = 'POST';
          body = {
            tag_name: args.tag_name,
            name: args.name,
            body: args.body,
            draft: args.draft || false,
            prerelease: args.prerelease || false,
          };
          break;

        case 'list':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo}/releases`;
          break;

        case 'update':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo}/releases/${args.release_id}`;
          method = 'PATCH';
          body = {
            name: args.name,
            body: args.body,
          };
          break;

        case 'delete':
          endpoint = `${GITHUB_API}/repos/${args.owner}/${args.repo}/releases/${args.release_id}`;
          method = 'DELETE';
          break;
      }

      const response = await fetch(endpoint, {
        method,
        headers: {
          'Authorization': `Bearer ${GITHUB_TOKEN}`,
          'Accept': 'application/vnd.github+json',
          'Content-Type': 'application/json',
        },
        body: method !== 'GET' ? JSON.stringify(body) : undefined,
      });

      const data = await response.json();
      return JSON.stringify(data, null, 2);
    }

    case 'alfa_browser_navigate':
    case 'alfa_browser_scrape':
    case 'alfa_browser_authenticate': {
      // Browser automation requires Playwright or Puppeteer
      const result = {
        tool: name,
        action: args.action || 'scrape',
        note: 'Browser automation requires Playwright/Puppeteer installation',
        installation: 'npm install playwright or pip install playwright',
        example_code: `
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch({ headless: ${args.headless !== false} });
  const page = await browser.newPage();
  await page.goto('${args.url}');
  ${args.action === 'screenshot' ? `await page.screenshot({ path: '${args.screenshot_path}' });` : ''}
  ${args.action === 'fill_form' ? 'await page.fill(selector, value);' : ''}
  ${args.action === 'click' ? 'await page.click(selector);' : ''}
  await browser.close();
})();
        `.trim(),
        recommendation: 'Use alfa_manus_task for complex browser automation',
      };

      return JSON.stringify(result, null, 2);
    }

    default:
      throw new Error(`Unknown developer tool: ${name}`);
  }
}
