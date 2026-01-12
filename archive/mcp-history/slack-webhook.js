#!/usr/bin/env node
/**
 * ALFA Slack Webhook Server
 * Receives Slack slash commands and executes ALFA MCP tools
 */

import express from 'express';
import bodyParser from 'body-parser';
import { spawn } from 'child_process';

const app = express();
const PORT = process.env.SLACK_WEBHOOK_PORT || 3333;

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// Store for tracking command executions
const executions = new Map();

// Execute MCP tool via alfa-server.js
async function executeMCPTool(toolName, args) {
  return new Promise((resolve, reject) => {
    const mcpServer = spawn('node', ['alfa-server.js'], {
      cwd: '/Users/arnaud/Documents/ALFA-Agent-Method/.mcp',
      stdio: ['pipe', 'pipe', 'pipe']
    });

    let output = '';
    let error = '';

    // Send tool call request via MCP protocol
    const request = {
      jsonrpc: '2.0',
      id: 1,
      method: 'tools/call',
      params: {
        name: toolName,
        arguments: args
      }
    };

    mcpServer.stdin.write(JSON.stringify(request) + '\n');
    mcpServer.stdin.end();

    mcpServer.stdout.on('data', (data) => {
      output += data.toString();
    });

    mcpServer.stderr.on('data', (data) => {
      error += data.toString();
    });

    mcpServer.on('close', (code) => {
      if (code === 0) {
        try {
          // Parse MCP response
          const lines = output.split('\n').filter(l => l.trim());
          const response = JSON.parse(lines[lines.length - 1]);
          resolve(response.result);
        } catch (e) {
          resolve({ content: [{ type: 'text', text: output }] });
        }
      } else {
        reject(new Error(error || `Process exited with code ${code}`));
      }
    });

    setTimeout(() => {
      mcpServer.kill();
      reject(new Error('Execution timeout'));
    }, 30000);
  });
}

// Slack slash command endpoint
app.post('/slack/command', async (req, res) => {
  const { command, text, user_name, response_url } = req.body;

  console.log(`Received command: ${command} ${text} from ${user_name}`);

  // Respond immediately to Slack (required within 3 seconds)
  res.json({
    response_type: 'in_channel',
    text: `⚡ ALFA executing: \`${command} ${text}\`...`
  });

  // Parse command and arguments
  const parts = text.split(' ');
  const toolName = `alfa_${parts[0]}`;
  const args = {};

  // Parse key=value arguments
  for (let i = 1; i < parts.length; i++) {
    const [key, ...valueParts] = parts[i].split('=');
    if (valueParts.length > 0) {
      args[key] = valueParts.join('=');
    }
  }

  // Execute tool asynchronously
  try {
    const result = await executeMCPTool(toolName, args);
    const resultText = result.content ? result.content[0].text : JSON.stringify(result);

    // Send result back to Slack
    await fetch(response_url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        response_type: 'in_channel',
        text: `✅ *ALFA Result*\n\`\`\`\n${resultText.slice(0, 2000)}\n\`\`\``
      })
    });
  } catch (error) {
    await fetch(response_url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        response_type: 'in_channel',
        text: `❌ *ALFA Error*\n\`\`\`\n${error.message}\n\`\`\``
      })
    });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', tools: 91, domains: 14 });
});

// List available commands
app.get('/commands', (req, res) => {
  res.json({
    commands: [
      '/alfa status - Get ALFA services status',
      '/alfa grafana_create_dashboard title="Dashboard" - Create Grafana dashboard',
      '/alfa slack_send_message channel="#general" text="Hello" - Send Slack message',
      '/alfa github_repo_management action=list - List GitHub repos',
      '/alfa obsidian_create_note title="Note" content="Content" - Create Obsidian note',
      '... 91 tools total'
    ]
  });
});

app.listen(PORT, () => {
  console.log(`🚀 ALFA Slack Webhook Server running on port ${PORT}`);
  console.log(`📍 Webhook URL: http://localhost:${PORT}/slack/command`);
  console.log(`🏥 Health check: http://localhost:${PORT}/health`);
});
