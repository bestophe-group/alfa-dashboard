#!/usr/bin/env node
/**
 * ALFA MCP Server
 * Provides access to ALFA dashboard stack via MCP protocol
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { CallToolRequestSchema, ListToolsRequestSchema } from '@modelcontextprotocol/sdk/types.js';
import { execSync } from 'child_process';
import path from 'path';
import fs from 'fs';

const ALFA_ROOT = '/Users/arnaud/Documents/ALFA-Agent-Method/alfa-dashboard';

const server = new Server(
  {
    name: 'alfa-dashboard',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Helper function to execute docker compose commands
function dockerCompose(command, args = []) {
  const cmd = `cd ${ALFA_ROOT} && docker compose ${command} ${args.join(' ')}`;
  return execSync(cmd, { encoding: 'utf8' });
}

// Helper function to execute Docker commands
function dockerExec(container, command) {
  const cmd = `docker exec ${container} ${command}`;
  return execSync(cmd, { encoding: 'utf8' });
}

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'alfa_status',
        description: 'Get status of all ALFA services',
        inputSchema: {
          type: 'object',
          properties: {},
        },
      },
      {
        name: 'alfa_logs',
        description: 'Get logs from ALFA service',
        inputSchema: {
          type: 'object',
          properties: {
            service: {
              type: 'string',
              description: 'Service name (traefik, postgres, n8n, prometheus, grafana, loki, etc.)',
            },
            lines: {
              type: 'number',
              description: 'Number of lines to show (default: 50)',
            },
          },
          required: ['service'],
        },
      },
      {
        name: 'alfa_restart',
        description: 'Restart an ALFA service',
        inputSchema: {
          type: 'object',
          properties: {
            service: {
              type: 'string',
              description: 'Service name to restart',
            },
          },
          required: ['service'],
        },
      },
      {
        name: 'alfa_health',
        description: 'Check health of ALFA services',
        inputSchema: {
          type: 'object',
          properties: {},
        },
      },
      {
        name: 'alfa_metrics',
        description: 'Query Prometheus metrics',
        inputSchema: {
          type: 'object',
          properties: {
            query: {
              type: 'string',
              description: 'PromQL query',
            },
          },
          required: ['query'],
        },
      },
      {
        name: 'alfa_workflows',
        description: 'List n8n workflows',
        inputSchema: {
          type: 'object',
          properties: {
            priority: {
              type: 'string',
              description: 'Filter by priority: p0, p1, p2, p3',
            },
          },
        },
      },
      {
        name: 'alfa_db_query',
        description: 'Execute PostgreSQL query on ALFA database',
        inputSchema: {
          type: 'object',
          properties: {
            database: {
              type: 'string',
              description: 'Database name (alfa, backstage, service_desk)',
            },
            query: {
              type: 'string',
              description: 'SQL query to execute',
            },
          },
          required: ['database', 'query'],
        },
      },
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case 'alfa_status': {
        const output = dockerCompose('ps', ['--format', 'json']);
        return {
          content: [
            {
              type: 'text',
              text: output,
            },
          ],
        };
      }

      case 'alfa_logs': {
        const lines = args.lines || 50;
        const output = dockerCompose('logs', ['--tail', lines.toString(), args.service]);
        return {
          content: [
            {
              type: 'text',
              text: output,
            },
          ],
        };
      }

      case 'alfa_restart': {
        const output = dockerCompose('restart', [args.service]);
        return {
          content: [
            {
              type: 'text',
              text: `Service ${args.service} restarted successfully\n${output}`,
            },
          ],
        };
      }

      case 'alfa_health': {
        const output = execSync(
          `docker ps --filter "name=alfa-" --format "{{.Names}}\t{{.Status}}\t{{.State}}"`,
          { encoding: 'utf8' }
        );
        return {
          content: [
            {
              type: 'text',
              text: output,
            },
          ],
        };
      }

      case 'alfa_metrics': {
        const query = encodeURIComponent(args.query);
        const output = execSync(
          `curl -s "http://localhost:9090/api/v1/query?query=${query}"`,
          { encoding: 'utf8' }
        );
        return {
          content: [
            {
              type: 'text',
              text: output,
            },
          ],
        };
      }

      case 'alfa_workflows': {
        const workflowsDir = path.join(ALFA_ROOT, 'n8n', 'workflows');
        let pattern = '**/*.json';
        if (args.priority) {
          pattern = `${args.priority}/*.json`;
        }
        const files = execSync(`find ${workflowsDir} -name "*.json" -type f`, {
          encoding: 'utf8',
        }).split('\n').filter(Boolean);

        const workflows = files.map(f => {
          const content = fs.readFileSync(f, 'utf8');
          const workflow = JSON.parse(content);
          return {
            file: path.basename(f),
            name: workflow.name,
            priority: path.basename(path.dirname(f)),
          };
        });

        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify(workflows, null, 2),
            },
          ],
        };
      }

      case 'alfa_db_query': {
        const output = dockerExec(
          'alfa-postgres',
          `psql -U alfa -d ${args.database} -c "${args.query}"`
        );
        return {
          content: [
            {
              type: 'text',
              text: output,
            },
          ],
        };
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    return {
      content: [
        {
          type: 'text',
          text: `Error: ${error.message}`,
        },
      ],
      isError: true,
    };
  }
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('ALFA MCP Server running on stdio');
}

main().catch((error) => {
  console.error('Server error:', error);
  process.exit(1);
});
