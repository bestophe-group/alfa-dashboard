# n8n Workflows Reference

> Complete catalog of ALFA automation workflows

## Workflow Naming Convention

```
P{priority}-{number}-{description}.json

Examples:
P0-001-health-check-ping.json
P1-015-github-webhook-handler.json
P2-025-linear-notion-sync.json
```

## P0 - Critical Infrastructure

### P0-001 Health Check Ping
**Trigger:** Every 1 minute (cron)
**Purpose:** System heartbeat verification
**Actions:**
- Ping internal services
- Log response times
- Alert if any service unreachable

### P0-002 Container Monitoring
**Trigger:** Every 5 minutes (cron)
**Purpose:** Docker container health
**Actions:**
- Query Docker API
- Check container states
- Log stats to database
- Alert on stopped/unhealthy

### P0-003 SSL Certificate Monitor
**Trigger:** Daily at 9 AM
**Purpose:** Prevent certificate expiry
**Actions:**
- Check all domain certificates
- Alert 30 days before expiry
- Create incident if < 7 days

### P0-004 Backup Automation
**Trigger:** Daily at 3 AM
**Purpose:** Data protection
**Actions:**
- Backup PostgreSQL databases
- Backup n8n workflows
- Upload to cloud storage
- Prune old backups (>30 days)

### P0-005 Incident Management
**Trigger:** Webhook
**Purpose:** Centralized alerting
**Actions:**
- Parse incoming alerts
- Classify severity
- Route to appropriate channel
- Create tracking record

### P0-006 Uptime Dashboard Sync
**Trigger:** Every 30 minutes
**Purpose:** Update status page
**Actions:**
- Fetch service status
- Update Uptime Kuma
- Log historical data

### P0-007 Log Aggregator
**Trigger:** Every 5 minutes
**Purpose:** Centralized logging
**Actions:**
- Collect logs from services
- Parse and structure
- Store in database
- Alert on error patterns

### P0-008 Security Event Monitor
**Trigger:** Webhook
**Purpose:** Security audit trail
**Actions:**
- Log authentication events
- Detect anomalies
- Flag suspicious activity
- Alert security team

### P0-009 Rate Limiter
**Trigger:** Webhook (pre-processor)
**Purpose:** API protection
**Actions:**
- Track request counts
- Enforce limits
- Block abusers
- Log violations

### P0-010 System Metrics Collector
**Trigger:** Every 1 minute
**Purpose:** Resource monitoring
**Actions:**
- Collect CPU/Memory/Disk
- Track trends
- Alert on thresholds
- Feed dashboards

## P1 - Core Business

### P1-011 GitHub Webhook Handler
**Trigger:** Webhook
**Purpose:** Repository events
**Actions:**
- Parse GitHub events
- Route to processors
- Update integrations

### P1-012 GitHub PR Notifier
**Trigger:** Webhook (from P1-011)
**Purpose:** PR notifications
**Actions:**
- Format PR details
- Post to Slack
- Update project boards

### P1-013 GitHub Issue Tracker
**Trigger:** Webhook (from P1-011)
**Purpose:** Issue management
**Actions:**
- Create tracking record
- Assign to team
- Set due dates
- Notify assignees

### P1-014 GitLab Pipeline Monitor
**Trigger:** Webhook
**Purpose:** CI/CD visibility
**Actions:**
- Parse pipeline events
- Log results
- Alert on failures
- Update dashboards

### P1-015 Slack Command Handler
**Trigger:** Webhook
**Purpose:** Slash commands
**Actions:**
- Parse command
- Execute action
- Return response

### P1-016 Slack Interactive Handler
**Trigger:** Webhook
**Purpose:** Button/Menu responses
**Actions:**
- Handle interactions
- Update messages
- Trigger workflows

### P1-017 Discord Bot Handler
**Trigger:** Webhook
**Purpose:** Bot interactions
**Actions:**
- Parse commands
- Execute actions
- Send responses

### P1-018 Telegram Bot Handler
**Trigger:** Webhook
**Purpose:** Telegram notifications
**Actions:**
- Parse messages
- Route commands
- Send updates

### P1-019 PennyLane Invoice Monitor
**Trigger:** Daily at 8 AM
**Purpose:** Invoice tracking
**Actions:**
- Fetch unpaid invoices
- Identify late payments
- Send reminders
- Update accounting

### P1-020 PayFit Employee Sync
**Trigger:** Weekly on Monday
**Purpose:** HR data sync
**Actions:**
- Export employee data
- Update internal systems
- Generate reports

## P2 - Integrations

### P2-021 Linear Webhook Handler
**Trigger:** Webhook
**Purpose:** Issue tracking
**Actions:**
- Parse Linear events
- Sync status changes
- Update related systems

### P2-022 Notion Sync
**Trigger:** Every 6 hours
**Purpose:** Documentation sync
**Actions:**
- Fetch Notion pages
- Update databases
- Sync to other tools

### P2-023 Linear-Notion Sync
**Trigger:** Webhook
**Purpose:** Two-way sync
**Actions:**
- Sync Linear → Notion
- Sync Notion → Linear
- Handle conflicts

### P2-024 Sentry Error Router
**Trigger:** Webhook
**Purpose:** Error distribution
**Actions:**
- Parse Sentry alerts
- Route by severity
- Create incidents
- Notify developers

### P2-025 AI Evaluation Pipeline
**Trigger:** On-demand / Scheduled
**Purpose:** Model testing
**Actions:**
- Run test suites
- Collect metrics
- Compare results
- Generate reports

### P2-026 OSINT Company Lookup
**Trigger:** Webhook / API
**Purpose:** Company intelligence
**Actions:**
- Query APIs (Pappers, etc.)
- Aggregate data
- Generate report
- Cache results

### P2-027 OSINT Director Search
**Trigger:** Part of P2-026
**Purpose:** Leadership data
**Actions:**
- Find company directors
- LinkedIn enrichment
- Cross-reference

### P2-028 OSINT DNS Analysis
**Trigger:** Part of P2-026
**Purpose:** Domain intelligence
**Actions:**
- DNS lookup
- WHOIS query
- Email security check
- Tech stack detection

### P2-029 OSINT Social Presence
**Trigger:** Part of P2-026
**Purpose:** Social media analysis
**Actions:**
- Find social accounts
- Analyze presence
- Score visibility

### P2-030 OSINT Full Report
**Trigger:** Webhook
**Purpose:** Complete dossier
**Actions:**
- Orchestrate P2-026 to P2-029
- Compile report
- Generate PDF
- Send to requester

## P3 - Experimental

### P3-031 Daily Quote Generator
**Trigger:** Daily at 9 AM
**Purpose:** Team inspiration
**Actions:**
- Fetch random quote
- Post to Slack
- Log to database

### P3-032 Coffee Roulette Matcher
**Trigger:** Weekly on Monday
**Purpose:** Team building
**Actions:**
- Get opted-in members
- Random pairing
- Notify participants
- Log pairings

### P3-033 Tech News Aggregator
**Trigger:** Daily at 7 AM
**Purpose:** Industry awareness
**Actions:**
- Scrape news sources
- Categorize articles
- Summarize with AI
- Post digest

### P3-034 Birthday Reminder
**Trigger:** Daily at 8 AM
**Purpose:** Team culture
**Actions:**
- Check upcoming birthdays
- Send reminders
- Schedule celebrations

### P3-035 Workiversary Reminder
**Trigger:** Daily at 8 AM
**Purpose:** Employee recognition
**Actions:**
- Check work anniversaries
- Notify managers
- Send congratulations

### P3-036 Weekly Digest Generator
**Trigger:** Friday at 5 PM
**Purpose:** Summary report
**Actions:**
- Aggregate week's data
- Generate statistics
- Format digest
- Send to team

### P3-037 Data Cleanup
**Trigger:** Weekly on Sunday
**Purpose:** Maintenance
**Actions:**
- Remove old logs
- Archive data
- Optimize tables
- Report savings

### P3-038 Reputation Monitor
**Trigger:** Daily
**Purpose:** Brand monitoring
**Actions:**
- Search mentions
- Analyze sentiment
- Alert on negative
- Track trends

### P3-039 Investor Tracker
**Trigger:** Weekly
**Purpose:** Market intelligence
**Actions:**
- Monitor funding news
- Track competitors
- Update database

### P3-040 Webhook Test Endpoint
**Trigger:** Webhook
**Purpose:** Development testing
**Actions:**
- Log payload
- Echo response
- Debug info

## Workflow Status Dashboard

```
╔══════════════════════════════════════════════════════════╗
║           ALFA Workflow Status                           ║
╠══════════════════════════════════════════════════════════╣
║  P0 Critical    [██████████] 10/10 active               ║
║  P1 Core        [████████░░] 8/10  active               ║
║  P2 Integration [██████░░░░] 6/10  active               ║
║  P3 Experimental[████░░░░░░] 4/10  active               ║
╠══════════════════════════════════════════════════════════╣
║  Total: 28/40 workflows active                          ║
║  Last check: 2024-01-15 10:30:00                        ║
╚══════════════════════════════════════════════════════════╝
```

## Creating New Workflows

### Template

```json
{
  "name": "P{X}-{NNN}-{description}",
  "nodes": [
    {
      "name": "Trigger",
      "type": "n8n-nodes-base.{triggerType}"
    },
    {
      "name": "Error Handler",
      "type": "n8n-nodes-base.errorTrigger"
    },
    {
      "name": "Log Start",
      "type": "n8n-nodes-base.postgres"
    },
    {
      "name": "Main Logic",
      "type": "..."
    },
    {
      "name": "Log End",
      "type": "n8n-nodes-base.postgres"
    }
  ]
}
```

### Checklist

- [ ] Follows naming convention
- [ ] Has error handling
- [ ] Logs execution
- [ ] Tested locally
- [ ] Documentation updated
- [ ] Added to monitoring

---

*Workflows are the building blocks of automation. Treat them with respect.*
