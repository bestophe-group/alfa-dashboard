#!/usr/bin/env node
/**
 * Liste tous les outils ALFA MCP disponibles
 */

import { grafanaTools } from './tools/grafana-tools.js';
import { powerbiTools } from './tools/powerbi-tools.js';
import { osintTools } from './tools/osint-tools.js';
import { etlTools } from './tools/etl-tools.js';
import { communicationTools } from './tools/communication-agency-tools.js';
import { agentOrchestrationTools } from './tools/agent-orchestration-tools.js';
import { claudeCodeTools } from './tools/claude-code-tools.js';
import { collaborationTools } from './tools/collaboration-tools.js';
import { infrastructureTools } from './tools/infrastructure-tools.js';
import { businessSaasTools } from './tools/business-saas-tools.js';
import { cmsTools } from './tools/cms-tools.js';
import { developerTools } from './tools/developer-tools.js';
import { azureSSOTools } from './tools/azure-sso-tools.js';
import { productivityTools } from './tools/productivity-tools.js';

const alfaCoreTools = [
  { name: 'alfa_status', description: 'Get status of all ALFA services' },
  { name: 'alfa_logs', description: 'Get logs from ALFA service' },
  { name: 'alfa_restart', description: 'Restart an ALFA service' },
  { name: 'alfa_health', description: 'Check health of ALFA services' },
  { name: 'alfa_metrics', description: 'Query Prometheus metrics' },
  { name: 'alfa_workflows', description: 'List n8n workflows' },
  { name: 'alfa_db_query', description: 'Execute PostgreSQL query on ALFA database' },
];

const allTools = [
  { category: 'Core ALFA', tools: alfaCoreTools },
  { category: 'Grafana', tools: grafanaTools },
  { category: 'Power BI', tools: powerbiTools },
  { category: 'OSINT', tools: osintTools },
  { category: 'ETL', tools: etlTools },
  { category: 'Communication', tools: communicationTools },
  { category: 'Agents', tools: agentOrchestrationTools },
  { category: 'Claude Code', tools: claudeCodeTools },
  { category: 'Collaboration', tools: collaborationTools },
  { category: 'Infrastructure', tools: infrastructureTools },
  { category: 'Business SaaS', tools: businessSaasTools },
  { category: 'CMS', tools: cmsTools },
  { category: 'Developer', tools: developerTools },
  { category: 'Azure SSO', tools: azureSSOTools },
  { category: 'Productivity', tools: productivityTools },
];

console.log('╔════════════════════════════════════════════════╗');
console.log('║     ALFA MCP Tools - Liste Complète           ║');
console.log('╚════════════════════════════════════════════════╝\n');

let totalTools = 0;

allTools.forEach(({ category, tools }) => {
  console.log(`\n📦 ${category} (${tools.length} outils)\n`);
  console.log('─'.repeat(60));

  tools.forEach((tool, index) => {
    console.log(`${index + 1}. ${tool.name}`);
    console.log(`   ${tool.description}`);
    if (index < tools.length - 1) console.log('');
  });

  totalTools += tools.length;
});

console.log('\n' + '═'.repeat(60));
console.log(`\n✅ Total: ${totalTools} outils MCP disponibles`);
console.log(`📚 14 domaines d'expertise`);
console.log(`🔗 40+ intégrations API\n`);

// Générer aussi un fichier JSON
const toolsList = allTools.map(({ category, tools }) => ({
  category,
  count: tools.length,
  tools: tools.map(t => ({ name: t.name, description: t.description }))
}));

import fs from 'fs';
fs.writeFileSync(
  '/Users/arnaud/Documents/ALFA-Agent-Method/.mcp/tools-list.json',
  JSON.stringify({ totalTools, categories: toolsList }, null, 2)
);

console.log('📄 Liste JSON sauvegardée: tools-list.json\n');
