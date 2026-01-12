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
import { fileURLToPath } from 'url';
import { dirname } from 'path';

// Import all tool modules
import { grafanaTools, executeGrafanaTool } from './tools/grafana-tools.js';
import { powerbiTools, executePowerBITool } from './tools/powerbi-tools.js';
import { osintTools, executeOSINTTool } from './tools/osint-tools.js';
import { etlTools, executeETLTool } from './tools/etl-tools.js';
import { communicationTools, executeCommunicationTool } from './tools/communication-agency-tools.js';
import { agentOrchestrationTools, executeAgentOrchestrationTool } from './tools/agent-orchestration-tools.js';
import { claudeCodeTools, executeClaudeCodeTool } from './tools/claude-code-tools.js';
import { collaborationTools, executeCollaborationTool } from './tools/collaboration-tools.js';
import { infrastructureTools, executeInfrastructureTool } from './tools/infrastructure-tools.js';
import { businessSaasTools, executeBusinessSaasTool } from './tools/business-saas-tools.js';
import { cmsTools, executeCMSTool } from './tools/cms-tools.js';
import { developerTools, executeDeveloperTool } from './tools/developer-tools.js';
import { azureSSOTools, executeAzureSSOTool } from './tools/azure-sso-tools.js';
import { productivityTools, executeProductivityTool } from './tools/productivity-tools.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

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

// ALFA core tools
const alfaCoreTools = [
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
];

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      ...alfaCoreTools,
      ...grafanaTools,
      ...powerbiTools,
      ...osintTools,
      ...etlTools,
      ...communicationTools,
      ...agentOrchestrationTools,
      ...claudeCodeTools,
      ...collaborationTools,
      ...infrastructureTools,
      ...businessSaasTools,
      ...cmsTools,
      ...developerTools,
      ...azureSSOTools,
      ...productivityTools,
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    // Route to appropriate executor based on tool name prefix
    let result;

    if (name.startsWith('alfa_grafana_')) {
      result = await executeGrafanaTool(name, args);
    } else if (name.startsWith('alfa_powerbi_')) {
      result = await executePowerBITool(name, args);
    } else if (name.startsWith('alfa_osint_')) {
      result = await executeOSINTTool(name, args);
    } else if (name.startsWith('alfa_etl_')) {
      result = await executeETLTool(name, args);
    } else if (name.startsWith('alfa_design_') || name.startsWith('alfa_generate_') || name.startsWith('alfa_marketing_') || name.startsWith('alfa_content_') || name.startsWith('alfa_video_script_')) {
      result = await executeCommunicationTool(name, args);
    } else if (name.startsWith('alfa_manus_') || name.startsWith('alfa_chatgpt_') || name.startsWith('alfa_perplexity_') || name.startsWith('alfa_grok_') || name.startsWith('alfa_notebooklm_') || name.startsWith('alfa_elevenlabs_') || name.startsWith('alfa_opendata_') || name.startsWith('alfa_multi_agent_') || name.startsWith('alfa_comet_') || name.startsWith('alfa_nano_')) {
      result = await executeAgentOrchestrationTool(name, args);
    } else if (name.startsWith('alfa_claude_')) {
      result = await executeClaudeCodeTool(name, args);
    } else if (name.startsWith('alfa_slack_') || name.startsWith('alfa_microsoft365_') || name.startsWith('alfa_google_workspace_')) {
      result = await executeCollaborationTool(name, args);
    } else if (name.startsWith('alfa_ovh_') || name.startsWith('alfa_hostinger_') || name.startsWith('alfa_aws_') || name.startsWith('alfa_vercel_') || name.startsWith('alfa_v0dev_') || name.startsWith('alfa_cloudflare_')) {
      result = await executeInfrastructureTool(name, args);
    } else if (name.startsWith('alfa_payfit_') || name.startsWith('alfa_pennylane_') || name.startsWith('alfa_bitwarden_') || name.startsWith('alfa_instagram_') || name.startsWith('alfa_facebook_') || name.startsWith('alfa_tiktok_') || name.startsWith('alfa_youtube_') || name.startsWith('alfa_canva_')) {
      result = await executeBusinessSaasTool(name, args);
    } else if (name.startsWith('alfa_wix_') || name.startsWith('alfa_wordpress_')) {
      result = await executeCMSTool(name, args);
    } else if (name.startsWith('alfa_github_') || name.startsWith('alfa_browser_')) {
      result = await executeDeveloperTool(name, args);
    } else if (name.startsWith('alfa_azure_sso_')) {
      result = await executeAzureSSOTool(name, args);
    } else if (name.startsWith('alfa_obsidian_')) {
      result = await executeProductivityTool(name, args);
    } else {
      // Handle ALFA core tools
      switch (name) {
        case 'alfa_status': {
          const output = dockerCompose('ps', ['--format', 'json']);
          result = output;
          break;
        }

        case 'alfa_logs': {
          const lines = args.lines || 50;
          const output = dockerCompose('logs', ['--tail', lines.toString(), args.service]);
          result = output;
          break;
        }

        case 'alfa_restart': {
          const output = dockerCompose('restart', [args.service]);
          result = `Service ${args.service} restarted successfully\n${output}`;
          break;
        }

        case 'alfa_health': {
          const output = execSync(
            `docker ps --filter "name=alfa-" --format "{{.Names}}\t{{.Status}}\t{{.State}}"`,
            { encoding: 'utf8' }
          );
          result = output;
          break;
        }

        case 'alfa_metrics': {
          const query = encodeURIComponent(args.query);
          const output = execSync(
            `curl -s "http://localhost:9090/api/v1/query?query=${query}"`,
            { encoding: 'utf8' }
          );
          result = output;
          break;
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

          result = JSON.stringify(workflows, null, 2);
          break;
        }

        case 'alfa_db_query': {
          const output = dockerExec(
            'alfa-postgres',
            `psql -U alfa -d ${args.database} -c "${args.query}"`
          );
          result = output;
          break;
        }

        default:
          throw new Error(`Unknown tool: ${name}`);
      }
    }

    // Return result
    return {
      content: [
        {
          type: 'text',
          text: result,
        },
      ],
    };
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
