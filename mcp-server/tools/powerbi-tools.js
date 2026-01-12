/**
 * ALFA MCP - Power BI Tools
 * Expertise en Power BI: dashboards, datasets, dataflows, REST API
 */

import fetch from 'node-fetch';
import fs from 'fs';

const POWERBI_API_URL = 'https://api.powerbi.com/v1.0/myorg';
const POWERBI_TOKEN = process.env.POWERBI_ACCESS_TOKEN;

export const powerbiTools = [
  {
    name: 'alfa_powerbi_create_dataset',
    description: 'Create Power BI dataset with schema and tables',
    inputSchema: {
      type: 'object',
      properties: {
        name: { type: 'string', description: 'Dataset name' },
        tables: {
          type: 'array',
          description: 'Array of table definitions with columns and types',
          items: {
            type: 'object',
            properties: {
              name: { type: 'string' },
              columns: { type: 'array', items: { type: 'object' } },
            },
          },
        },
        workspace_id: { type: 'string', description: 'Target workspace ID' },
      },
      required: ['name', 'tables'],
    },
  },
  {
    name: 'alfa_powerbi_push_data',
    description: 'Push rows to Power BI dataset table',
    inputSchema: {
      type: 'object',
      properties: {
        dataset_id: { type: 'string', description: 'Dataset ID' },
        table_name: { type: 'string', description: 'Table name' },
        rows: {
          type: 'array',
          description: 'Array of row objects to push',
          items: { type: 'object' },
        },
      },
      required: ['dataset_id', 'table_name', 'rows'],
    },
  },
  {
    name: 'alfa_powerbi_create_report',
    description: 'Create Power BI report from dataset',
    inputSchema: {
      type: 'object',
      properties: {
        name: { type: 'string', description: 'Report name' },
        dataset_id: { type: 'string', description: 'Source dataset ID' },
        pages: {
          type: 'array',
          description: 'Report pages with visuals configuration',
          items: { type: 'object' },
        },
        workspace_id: { type: 'string' },
      },
      required: ['name', 'dataset_id'],
    },
  },
  {
    name: 'alfa_powerbi_refresh_dataset',
    description: 'Trigger dataset refresh',
    inputSchema: {
      type: 'object',
      properties: {
        dataset_id: { type: 'string', description: 'Dataset ID to refresh' },
        notify_option: { type: 'string', enum: ['NoNotification', 'MailOnFailure', 'MailOnCompletion'] },
      },
      required: ['dataset_id'],
    },
  },
  {
    name: 'alfa_powerbi_export_report',
    description: 'Export Power BI report to PDF, PNG, or PPTX',
    inputSchema: {
      type: 'object',
      properties: {
        report_id: { type: 'string', description: 'Report ID' },
        format: { type: 'string', enum: ['PDF', 'PNG', 'PPTX'], description: 'Export format' },
        output_path: { type: 'string', description: 'Local output path' },
        page_names: { type: 'array', items: { type: 'string' }, description: 'Specific pages to export' },
      },
      required: ['report_id', 'format'],
    },
  },
  {
    name: 'alfa_powerbi_create_dataflow',
    description: 'Create Power BI dataflow with transformations',
    inputSchema: {
      type: 'object',
      properties: {
        name: { type: 'string', description: 'Dataflow name' },
        workspace_id: { type: 'string' },
        entities: {
          type: 'array',
          description: 'Data entities with M queries',
          items: {
            type: 'object',
            properties: {
              name: { type: 'string' },
              query: { type: 'string', description: 'M query' },
            },
          },
        },
      },
      required: ['name', 'entities'],
    },
  },
  {
    name: 'alfa_powerbi_embed_token',
    description: 'Generate embed token for embedding reports in web apps',
    inputSchema: {
      type: 'object',
      properties: {
        report_id: { type: 'string', description: 'Report ID' },
        dataset_ids: { type: 'array', items: { type: 'string' } },
        access_level: { type: 'string', enum: ['View', 'Edit', 'Create'] },
      },
      required: ['report_id'],
    },
  },
  {
    name: 'alfa_powerbi_query_dax',
    description: 'Execute DAX query on dataset',
    inputSchema: {
      type: 'object',
      properties: {
        dataset_id: { type: 'string', description: 'Dataset ID' },
        dax_query: { type: 'string', description: 'DAX query to execute' },
      },
      required: ['dataset_id', 'dax_query'],
    },
  },
];

export async function executePowerBITool(name, args) {
  if (!POWERBI_TOKEN) {
    throw new Error('POWERBI_ACCESS_TOKEN environment variable not set');
  }

  const headers = {
    'Authorization': `Bearer ${POWERBI_TOKEN}`,
    'Content-Type': 'application/json',
  };

  switch (name) {
    case 'alfa_powerbi_create_dataset': {
      const dataset = {
        name: args.name,
        tables: args.tables.map(table => ({
          name: table.name,
          columns: table.columns.map(col => ({
            name: col.name,
            dataType: col.type || 'String',
          })),
        })),
      };

      const workspaceId = args.workspace_id || '';
      const url = workspaceId
        ? `${POWERBI_API_URL}/groups/${workspaceId}/datasets`
        : `${POWERBI_API_URL}/datasets`;

      const response = await fetch(url, {
        method: 'POST',
        headers,
        body: JSON.stringify(dataset),
      });

      const result = await response.json();
      return `Dataset created: ${result.id} - ${result.name}`;
    }

    case 'alfa_powerbi_push_data': {
      const url = `${POWERBI_API_URL}/datasets/${args.dataset_id}/tables/${args.table_name}/rows`;

      const response = await fetch(url, {
        method: 'POST',
        headers,
        body: JSON.stringify({ rows: args.rows }),
      });

      if (response.ok) {
        return `Successfully pushed ${args.rows.length} rows to ${args.table_name}`;
      } else {
        const error = await response.text();
        throw new Error(`Failed to push data: ${error}`);
      }
    }

    case 'alfa_powerbi_refresh_dataset': {
      const url = `${POWERBI_API_URL}/datasets/${args.dataset_id}/refreshes`;

      const response = await fetch(url, {
        method: 'POST',
        headers,
        body: JSON.stringify({
          notifyOption: args.notify_option || 'NoNotification',
        }),
      });

      if (response.ok) {
        return `Dataset refresh triggered for ${args.dataset_id}`;
      } else {
        const error = await response.text();
        throw new Error(`Failed to refresh: ${error}`);
      }
    }

    case 'alfa_powerbi_export_report': {
      const url = `${POWERBI_API_URL}/reports/${args.report_id}/ExportTo`;

      const exportRequest = {
        format: args.format,
      };

      if (args.page_names && args.page_names.length > 0) {
        exportRequest.powerBIReportConfiguration = {
          pages: args.page_names.map(name => ({ pageName: name })),
        };
      }

      const response = await fetch(url, {
        method: 'POST',
        headers,
        body: JSON.stringify(exportRequest),
      });

      const result = await response.json();
      const exportId = result.id;

      // Poll for completion
      let status = 'Running';
      let attempts = 0;
      while (status === 'Running' && attempts < 30) {
        await new Promise(resolve => setTimeout(resolve, 2000));

        const statusResponse = await fetch(
          `${POWERBI_API_URL}/reports/${args.report_id}/exports/${exportId}`,
          { headers }
        );

        const statusData = await statusResponse.json();
        status = statusData.status;
        attempts++;

        if (status === 'Succeeded') {
          // Download file
          const fileResponse = await fetch(
            `${POWERBI_API_URL}/reports/${args.report_id}/exports/${exportId}/file`,
            { headers }
          );

          const buffer = await fileResponse.buffer();
          const outputPath = args.output_path || `/tmp/report_${args.report_id}.${args.format.toLowerCase()}`;

          fs.writeFileSync(outputPath, buffer);
          return `Report exported to: ${outputPath}`;
        }
      }

      throw new Error('Export timeout or failed');
    }

    case 'alfa_powerbi_query_dax': {
      const url = `${POWERBI_API_URL}/datasets/${args.dataset_id}/executeQueries`;

      const response = await fetch(url, {
        method: 'POST',
        headers,
        body: JSON.stringify({
          queries: [{
            query: args.dax_query,
          }],
        }),
      });

      const result = await response.json();
      return JSON.stringify(result.results[0].tables[0].rows, null, 2);
    }

    case 'alfa_powerbi_embed_token': {
      const url = `${POWERBI_API_URL}/GenerateToken`;

      const response = await fetch(url, {
        method: 'POST',
        headers,
        body: JSON.stringify({
          reports: [{ id: args.report_id }],
          datasets: args.dataset_ids?.map(id => ({ id })) || [],
          targetWorkspaces: [],
        }),
      });

      const result = await response.json();
      return JSON.stringify({
        token: result.token,
        tokenId: result.tokenId,
        expiration: result.expiration,
      }, null, 2);
    }

    default:
      throw new Error(`Unknown Power BI tool: ${name}`);
  }
}
