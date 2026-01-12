/**
 * ALFA MCP - Grafana Tools
 * Expertise complète en Grafana dashboards, datasources, alerts
 */

import { execSync } from 'child_process';
import fetch from 'node-fetch';

const GRAFANA_URL = process.env.GRAFANA_URL || 'http://localhost:3000';
const GRAFANA_API_KEY = process.env.GRAFANA_API_KEY || 'admin:admin';

export const grafanaTools = [
  {
    name: 'alfa_grafana_create_dashboard',
    description: 'Create a new Grafana dashboard with panels and queries',
    inputSchema: {
      type: 'object',
      properties: {
        title: { type: 'string', description: 'Dashboard title' },
        panels: {
          type: 'array',
          description: 'Array of panel configurations (title, query, type, datasource)',
          items: { type: 'object' }
        },
        tags: { type: 'array', items: { type: 'string' } },
        folder: { type: 'string', description: 'Folder name or UID' },
      },
      required: ['title', 'panels'],
    },
  },
  {
    name: 'alfa_grafana_query_prometheus',
    description: 'Execute PromQL query and format results for visualization',
    inputSchema: {
      type: 'object',
      properties: {
        query: { type: 'string', description: 'PromQL query' },
        time_range: { type: 'string', description: 'Time range (e.g., "1h", "24h", "7d")' },
        step: { type: 'string', description: 'Query resolution step' },
      },
      required: ['query'],
    },
  },
  {
    name: 'alfa_grafana_create_alert',
    description: 'Create Grafana alert rule with conditions and notifications',
    inputSchema: {
      type: 'object',
      properties: {
        name: { type: 'string', description: 'Alert rule name' },
        query: { type: 'string', description: 'Metric query' },
        condition: { type: 'string', description: 'Alert condition (e.g., "> 80")' },
        for_duration: { type: 'string', description: 'Duration before firing (e.g., "5m")' },
        severity: { type: 'string', enum: ['critical', 'warning', 'info'] },
        channels: { type: 'array', items: { type: 'string' }, description: 'Notification channels' },
      },
      required: ['name', 'query', 'condition'],
    },
  },
  {
    name: 'alfa_grafana_export_dashboard',
    description: 'Export dashboard as JSON or PDF',
    inputSchema: {
      type: 'object',
      properties: {
        dashboard_uid: { type: 'string', description: 'Dashboard UID' },
        format: { type: 'string', enum: ['json', 'pdf'], description: 'Export format' },
        output_path: { type: 'string', description: 'Output file path' },
      },
      required: ['dashboard_uid', 'format'],
    },
  },
  {
    name: 'alfa_grafana_import_dashboard',
    description: 'Import dashboard from JSON or Grafana.com',
    inputSchema: {
      type: 'object',
      properties: {
        source: { type: 'string', description: 'JSON file path or Grafana.com dashboard ID' },
        folder: { type: 'string', description: 'Target folder' },
        datasource_mapping: { type: 'object', description: 'Map datasource names' },
      },
      required: ['source'],
    },
  },
];

export async function executeGrafanaTool(name, args) {
  const auth = Buffer.from(GRAFANA_API_KEY).toString('base64');
  const headers = {
    'Authorization': `Basic ${auth}`,
    'Content-Type': 'application/json',
  };

  switch (name) {
    case 'alfa_grafana_create_dashboard': {
      const dashboard = {
        dashboard: {
          title: args.title,
          tags: args.tags || [],
          timezone: 'browser',
          panels: args.panels.map((panel, idx) => ({
            id: idx + 1,
            title: panel.title,
            type: panel.type || 'graph',
            datasource: panel.datasource || 'Prometheus',
            targets: [{
              expr: panel.query,
              refId: 'A',
            }],
            gridPos: { h: 8, w: 12, x: (idx % 2) * 12, y: Math.floor(idx / 2) * 8 },
          })),
        },
        folderUid: args.folder,
        overwrite: false,
      };

      const response = await fetch(`${GRAFANA_URL}/api/dashboards/db`, {
        method: 'POST',
        headers,
        body: JSON.stringify(dashboard),
      });

      const result = await response.json();
      return `Dashboard created: ${GRAFANA_URL}${result.url}`;
    }

    case 'alfa_grafana_query_prometheus': {
      const timeRange = args.time_range || '1h';
      const end = Date.now() / 1000;
      const start = end - parseTimeRange(timeRange);

      const url = `${GRAFANA_URL}/api/datasources/proxy/1/api/v1/query_range?query=${encodeURIComponent(args.query)}&start=${start}&end=${end}&step=${args.step || '15s'}`;

      const response = await fetch(url, { headers });
      const data = await response.json();

      return JSON.stringify(data, null, 2);
    }

    case 'alfa_grafana_create_alert': {
      const alertRule = {
        name: args.name,
        grafana_alert: {
          condition: 'A',
          data: [{
            refId: 'A',
            queryType: '',
            model: {
              expr: args.query,
              refId: 'A',
            },
          }],
        },
        for: args.for_duration || '5m',
        annotations: {
          severity: args.severity || 'warning',
        },
        labels: {},
      };

      const response = await fetch(`${GRAFANA_URL}/api/v1/provisioning/alert-rules`, {
        method: 'POST',
        headers,
        body: JSON.stringify(alertRule),
      });

      return `Alert rule created: ${args.name}`;
    }

    case 'alfa_grafana_export_dashboard': {
      const response = await fetch(`${GRAFANA_URL}/api/dashboards/uid/${args.dashboard_uid}`, {
        headers,
      });

      const data = await response.json();
      const output = args.output_path || `/tmp/${args.dashboard_uid}.json`;

      require('fs').writeFileSync(output, JSON.stringify(data, null, 2));
      return `Dashboard exported to: ${output}`;
    }

    default:
      throw new Error(`Unknown Grafana tool: ${name}`);
  }
}

function parseTimeRange(range) {
  const match = range.match(/^(\d+)([smhd])$/);
  if (!match) return 3600;

  const value = parseInt(match[1]);
  const unit = match[2];

  const multipliers = { s: 1, m: 60, h: 3600, d: 86400 };
  return value * multipliers[unit];
}
