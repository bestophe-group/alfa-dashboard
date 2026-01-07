# ALFA Slack Integration Guide

## 🚀 Quick Setup

### 1. Start the Webhook Server

```bash
cd /Users/arnaud/Documents/ALFA-Agent-Method/.mcp
node slack-webhook.js
```

Server runs on port 3333 and is ready to receive Slack slash commands.

### 2. Configure Slack App

**Navigate to**: https://api.slack.com/apps/A0A73J9107P/slash-commands

**Add these slash commands**:

| Command | Request URL | Description |
|---------|-------------|-------------|
| `/alfa` | `http://your-domain:3333/slack/command` | Execute any ALFA MCP tool |
| `/alfa-status` | `http://your-domain:3333/slack/command` | Quick ALFA status check |
| `/alfa-help` | `http://your-domain:3333/slack/command` | Show available commands |

### 3. Ngrok for Development

If testing locally, use ngrok to expose the webhook:

```bash
ngrok http 3333
```

Then use the ngrok URL in Slack configuration: `https://xxxxx.ngrok.io/slack/command`

## 📝 Slash Command Usage

### Format

```
/alfa <tool_name> [key=value] [key=value] ...
```

### Examples

#### Core ALFA Tools

```slack
/alfa status
/alfa health
/alfa logs service=grafana lines=100
/alfa restart service=prometheus
```

#### Grafana Tools

```slack
/alfa grafana_create_dashboard title="My Dashboard" tags=["monitoring","production"]
/alfa grafana_query_prometheus query="up{job='prometheus'}"
/alfa grafana_create_alert name="High CPU" threshold=80
```

#### Slack Tools (Meta!)

```slack
/alfa slack_send_message channel="#general" text="Hello from ALFA!"
/alfa slack_create_channel name="alfa-alerts" is_private=false
```

#### GitHub Tools

```slack
/alfa github_repo_management action=list
/alfa github_issues_management action=create owner=bestophe-group repo=alfa-dashboard title="Bug Fix" body="Description"
/alfa github_pr_management action=list owner=bestophe-group repo=alfa-dashboard
```

#### Infrastructure Tools

```slack
/alfa aws_s3_management action=list_objects bucket_name=alfa-assets
/alfa vercel_deploy project_path=/path/to/app production=true
/alfa cloudflare_dns action=list_zones
```

#### Obsidian Tools

```slack
/alfa obsidian_create_note vault_path=/path/to/vault note_title="Meeting Notes" content="# Meeting notes from Slack"
/alfa obsidian_search_notes vault_path=/path/to/vault query="project alpha"
```

#### Business SaaS Tools

```slack
/alfa payfit_employees action=list
/alfa pennylane_invoices action=list
/alfa canva_design type=instagram-post theme="Technology"
```

#### WordPress/CMS Tools

```slack
/alfa wordpress_content_management action=create_post site_url=https://mysite.com title="New Post" content="Content" status=publish
/alfa wix_site_management action=list_sites
```

## 🔐 Security Configuration

### Environment Variables

Create `.env` file in `.mcp/` directory:

```bash
# Slack
SLACK_WEBHOOK_PORT=3333
SLACK_BOT_TOKEN=xoxb-your-bot-token
SLACK_SIGNING_SECRET=your-signing-secret

# All other ALFA API keys
GRAFANA_URL=http://localhost:3000
GRAFANA_API_KEY=admin:admin
GITHUB_TOKEN=ghp_xxxxx
AWS_ACCESS_KEY_ID=xxxxx
AWS_SECRET_ACCESS_KEY=xxxxx
# ... (see README.md for complete list)
```

### Webhook Verification

The webhook server automatically validates Slack requests using the signing secret.

## 📊 Available Tools via Slack

**Total**: 91 tools across 14 domains

### By Category

1. **Core ALFA** (7 tools): status, logs, restart, health, metrics, workflows, db_query
2. **Grafana** (5 tools): dashboards, queries, alerts, export, import
3. **Power BI** (8 tools): datasets, reports, DAX, exports, dataflows
4. **OSINT** (8 tools): company research, person lookup, dark web, social scraping
5. **ETL** (10 tools): transcription, OCR, conversions, TTS
6. **Communication** (9 tools): branding, design, web generation, marketing
7. **Agents** (10 tools): ChatGPT, Perplexity, Manus, ElevenLabs orchestration
8. **Claude Code** (9 tools): project creation, debugging, testing, CI/CD
9. **Collaboration** (12 tools): Slack, Microsoft 365, Google Workspace
10. **Infrastructure** (9 tools): OVH, AWS, Vercel, Cloudflare
11. **Business SaaS** (11 tools): PayFit, PennyLane, Social Media, Canva
12. **CMS** (9 tools): Wix, WordPress, WooCommerce
13. **Developer** (8 tools): GitHub, Browser Automation
14. **Azure SSO** (7 tools): SAML, OIDC, Conditional Access
15. **Productivity** (8 tools): Obsidian vault management

## 🔄 Webhook Response Flow

```
User in Slack: /alfa github_repo_management action=list
         ↓
Slack API → Webhook Server (port 3333)
         ↓
Parse command → Execute ALFA MCP Tool
         ↓
MCP Server (alfa-server.js) → Tool Execution
         ↓
Result → Format Response → Send to Slack
         ↓
User sees: ✅ ALFA Result [formatted output]
```

## 🧪 Testing

### Test Webhook Locally

```bash
curl -X POST http://localhost:3333/slack/command \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "command=/alfa&text=status&user_name=test&response_url=http://example.com"
```

### Health Check

```bash
curl http://localhost:3333/health
# Returns: {"status":"ok","tools":91,"domains":14}
```

### List Commands

```bash
curl http://localhost:3333/commands
# Returns: JSON list of available commands
```

## 📸 Screenshots

### Webhook Server Running

![Webhook Server](./screenshots/webhook-running.png)

### Slack Command Example

![Slack Command](./screenshots/slack-command-example.png)

### ALFA Response in Slack

![ALFA Response](./screenshots/alfa-response.png)

## 🚨 Production Deployment

### Option 1: Cloud Function

Deploy `slack-webhook.js` as:
- AWS Lambda + API Gateway
- Google Cloud Functions
- Vercel Serverless Function

### Option 2: VPS

Run webhook server on VPS with:
- Reverse proxy (nginx/Caddy)
- SSL certificate
- Process manager (PM2)

```bash
pm2 start slack-webhook.js --name alfa-slack-webhook
pm2 save
pm2 startup
```

### Option 3: Docker

```dockerfile
FROM node:18
WORKDIR /app
COPY .mcp/package.json .
COPY .mcp/slack-webhook.js .
COPY .mcp/alfa-server.js .
COPY .mcp/tools ./tools
RUN npm install
EXPOSE 3333
CMD ["node", "slack-webhook.js"]
```

## 🔗 Useful Links

- **Slack App Config**: https://api.slack.com/apps/A0A73J9107P
- **ALFA MCP Documentation**: [TOOLS-CATALOG.md](./TOOLS-CATALOG.md)
- **Test Results**: [TEST-REPORT.md](./TEST-REPORT.md)
- **E2E Test Suite**: Run `node test-e2e.js`

## 💡 Tips

1. **Use Docker MCP Gateway**: Route through `docker mcp gateway` to avoid saturating Claude
2. **Batch Operations**: Chain multiple commands with `alfa_multi_agent_chain`
3. **Async Operations**: Long-running tasks return immediately with status URL
4. **Error Handling**: All errors are caught and returned as formatted Slack messages
5. **Rate Limiting**: Webhook implements automatic rate limiting per user

## 🐛 Troubleshooting

### Webhook not responding

```bash
# Check if server is running
curl http://localhost:3333/health

# Check logs
tail -f /var/log/alfa-slack-webhook.log
```

### Slack command timeout

- Commands must respond within 3 seconds
- Long operations use asynchronous response_url pattern
- Check webhook server logs for errors

### Tool execution fails

```bash
# Test MCP server directly
node alfa-server.js

# Run E2E tests
node test-e2e.js
```

---

🤖 **ALFA Slack Integration v1.0.0**

Generated by Claude Code for the ALFA-Agent Method

