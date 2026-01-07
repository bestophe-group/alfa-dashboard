# ALFA Dashboard - n8n Workflows

## Overview

This directory contains 40 pre-configured n8n workflows organized by priority level for the ALFA Dashboard automation stack.

## Directory Structure

```
workflows/
├── p0/           # Critical workflows (6)
├── p1/           # High priority workflows (9)
├── p2/           # Medium priority workflows (20)
├── p3/           # Low priority workflows (5)
└── README.md     # This file
```

## Workflow Inventory

### P0 - Critical (6 workflows)
| # | Name | Trigger | Description |
|---|------|---------|-------------|
| 01 | Webhook Router | Webhook | Central routing for all incoming webhooks |
| 02 | Error Handler | Manual/Called | Centralized error handling and alerting |
| 03 | Slack Notifier | Webhook | Unified Slack notification gateway |
| 04 | Database Logger | Webhook | Centralized logging to PostgreSQL |
| 05 | GitHub Issue Creator | Webhook | Auto-creates GitHub issues from incidents |
| 06 | Incident Response | Webhook | Automated incident detection and response |

### P1 - High Priority (9 workflows)
| # | Name | Trigger | Description |
|---|------|---------|-------------|
| 07 | GitHub Webhook Handler | Webhook | Processes GitHub events (push, PR, issues) |
| 08 | Daily Report | Schedule (6 AM) | Daily summary report generation |
| 09 | Health Check Services | Schedule (5 min) | Service health monitoring |
| 10 | Stack Health Check | Schedule (2 min) | Docker stack health via Traefik |
| 11 | Backup Automation | Schedule (2 AM) | Daily backup of all services |
| 12 | SSL Renewal | Schedule (Daily) | SSL certificate monitoring |
| 13 | Eval Suite Execution | Schedule (4 hours) | AI model evaluation suite |
| 14 | Commit Validation | Webhook | Validates commit conventions |
| 15 | Security Audit Trail | Webhook | Security event logging |

### P2 - Medium Priority (20 workflows)
| # | Name | Trigger | Description |
|---|------|---------|-------------|
| 16 | OSINT Company Scraper | Webhook | Company data from Pappers |
| 17 | OSINT Director Profile | Webhook | Director research |
| 18 | OSINT DNS WHOIS | Webhook | DNS/WHOIS lookups |
| 19 | OSINT Social Media | Webhook | Social presence search |
| 20 | OSINT Reputation Monitor | Schedule (Daily) | Sentiment monitoring |
| 21 | OSINT Investor Search | Webhook | Shareholder research |
| 22 | PennyLane Invoice Sync | Schedule (9 AM) | Invoice synchronization |
| 23 | PayFit Employee Export | Schedule (Monday) | Weekly employee export |
| 24 | Veille Technologique | Schedule (7 AM) | Tech watch from HN/Reddit |
| 25 | Full OSINT Report | Webhook | Aggregated OSINT report |
| 26 | Container Resource Monitor | Schedule (5 min) | Docker container monitoring |
| 27 | GitLab Pipeline Monitor | Webhook | Pipeline status tracking |
| 28 | Notion Sync | Schedule (2 hours) | Project sync from Notion |
| 29 | Linear Issue Tracker | Webhook | Issue tracking from Linear |
| 30 | Sentry Error Aggregator | Webhook | Error aggregation |
| 31 | Discord Bot Commands | Webhook | Discord slash commands |
| 32 | Telegram Notifications | Webhook | Telegram notification gateway |
| 33 | Weekly Digest | Schedule (Monday) | Weekly summary report |
| 34 | API Rate Limiter | Webhook | Rate limiting service |
| 35 | Log Aggregator | Webhook | Centralized log ingestion |

### P3 - Low Priority (5 workflows)
| # | Name | Trigger | Description |
|---|------|---------|-------------|
| 36 | Birthday Reminder | Schedule (8 AM) | Team birthday notifications |
| 37 | Weather Alert | Schedule (7 AM) | Daily weather report |
| 38 | Quote of the Day | Schedule (9 AM) | Inspirational quotes |
| 39 | Standup Reminder | Schedule (9:55 AM) | Daily standup reminder |
| 40 | Coffee Roulette | Schedule (Monday) | Random pairing for team bonding |

## Import Instructions

### Method 1: Manual Import via UI

1. Open n8n at `https://n8n.yourdomain.com`
2. Go to **Workflows** → **Import from File**
3. Select the JSON file(s) to import
4. Click **Import**
5. Configure credentials for each workflow
6. Activate the workflow

### Method 2: Bulk Import via CLI

```bash
# Using n8n CLI
n8n import:workflow --input=/path/to/workflows/p0/*.json
n8n import:workflow --input=/path/to/workflows/p1/*.json
n8n import:workflow --input=/path/to/workflows/p2/*.json
n8n import:workflow --input=/path/to/workflows/p3/*.json
```

### Method 3: API Import

```bash
# Import single workflow
curl -X POST "https://n8n.yourdomain.com/api/v1/workflows" \
  -H "X-N8N-API-KEY: your-api-key" \
  -H "Content-Type: application/json" \
  -d @workflows/p0/01-webhook-router.json
```

## Required Credentials

Before activating workflows, configure these credentials in n8n:

| Credential Name | Type | Used By |
|-----------------|------|---------|
| PostgreSQL ALFA | Postgres | All database operations |
| Slack API | Slack | Notifications |
| GitHub Token | GitHub | Issue creation, webhooks |
| Pappers API | HTTP Header | OSINT company data |
| Google CSE API | HTTP Header | Search operations |
| PennyLane API | HTTP Header | Invoice sync |
| PayFit API | HTTP Header | Employee export |
| Telegram Bot | Telegram | Notifications |
| Notion API | HTTP Header | Project sync |

## Environment Variables

Set these in your `.env` file:

```env
# n8n Configuration
N8N_WEBHOOK_BASE_URL=https://n8n.yourdomain.com

# API Keys
PAPPERS_API_KEY=your_pappers_key
GOOGLE_CSE_API_KEY=your_google_key
GOOGLE_CSE_CX=your_search_engine_id
OPENWEATHER_API_KEY=your_openweather_key

# Slack
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/xxx
SLACK_BOT_TOKEN=xoxb-xxx

# Database
POSTGRES_HOST=postgres
POSTGRES_DB=alfa
POSTGRES_USER=alfa
POSTGRES_PASSWORD=your_password

# Optional
WEATHER_CITY=Paris,FR
TELEGRAM_DEFAULT_CHAT=your_chat_id
STANDUP_MEET_LINK=https://meet.google.com/xxx
NOTION_PROJECTS_DB=your_notion_db_id
```

## Webhook Endpoints

After import, these webhook endpoints will be available:

| Endpoint | Workflow | Method |
|----------|----------|--------|
| `/webhook/router` | Webhook Router | POST |
| `/webhook/error` | Error Handler | POST |
| `/webhook/notify` | Slack Notifier | POST |
| `/webhook/log` | Database Logger | POST |
| `/webhook/github` | GitHub Handler | POST |
| `/webhook/osint/company` | OSINT Company | POST |
| `/webhook/osint/dns` | OSINT DNS | POST |
| `/webhook/osint/social` | OSINT Social | POST |
| `/webhook/osint/investors` | OSINT Investors | POST |
| `/webhook/osint/full-report` | Full OSINT Report | POST |
| `/webhook/gitlab/pipeline` | GitLab Pipeline | POST |
| `/webhook/linear/webhook` | Linear Issues | POST |
| `/webhook/sentry/webhook` | Sentry Errors | POST |
| `/webhook/discord/commands` | Discord Bot | POST |
| `/webhook/telegram/send` | Telegram | POST |
| `/webhook/ratelimit/check` | Rate Limiter | POST |
| `/webhook/logs/ingest` | Log Aggregator | POST |

## Testing

### Test Webhook Router
```bash
curl -X POST "https://n8n.yourdomain.com/webhook/router" \
  -H "Content-Type: application/json" \
  -d '{"type": "test", "message": "Hello ALFA!"}'
```

### Test OSINT Company
```bash
curl -X POST "https://n8n.yourdomain.com/webhook/osint/company" \
  -H "Content-Type: application/json" \
  -d '{"company_name": "Anthropic", "siret": "123456789"}'
```

### Test Slack Notification
```bash
curl -X POST "https://n8n.yourdomain.com/webhook/notify" \
  -H "Content-Type: application/json" \
  -d '{"channel": "#test", "message": "Test notification"}'
```

## Maintenance

### Disable All Workflows
```bash
n8n update:workflow --all --active=false
```

### Export All Workflows
```bash
n8n export:workflow --all --output=./backup/
```

### Check Workflow Status
```bash
n8n list:workflow
```

## Troubleshooting

### Common Issues

1. **Webhook not responding**
   - Check if workflow is activated
   - Verify `N8N_WEBHOOK_BASE_URL` is correct
   - Check firewall/proxy settings

2. **Database connection failed**
   - Verify PostgreSQL is running
   - Check credentials in n8n
   - Ensure database schema is initialized

3. **Slack notifications not sending**
   - Verify Slack API token has correct scopes
   - Check channel exists and bot is invited

4. **API rate limits**
   - Implement delays between API calls
   - Use caching where possible
   - Check API quotas

## Support

For issues with these workflows:
1. Check n8n execution logs
2. Verify all credentials are configured
3. Check the PostgreSQL logs for database errors
4. Review Traefik logs for routing issues

---

**ALFA Dashboard v1.0** - Automating operations with n8n
