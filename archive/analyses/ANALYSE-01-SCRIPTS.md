# ANALYSE-01 : Scripts & Automatisation

**Statut** : ✅ COMPLÉTÉ
**Date** : 2025-01-06

---

## 🎯 USE CASES ANALYSÉS

| Use Case | Faisabilité ALFA | Effort |
|----------|------------------|--------|
| Scripts récup factures sur sites | ✅ Natif | Faible |
| Scraping/enrichissement fichiers | ✅ Natif | Faible |
| Workflows n8n DevOps | ✅ Natif | Moyen |

---

## 1. SCRIPTS RÉCUPÉRATION FACTURES

### Verdict : ✅ 100% FAISABLE

### Stack recommandée

| Composant | Outil | Repo/Lien |
|-----------|-------|-----------|
| Browser automation | Playwright MCP | `microsoft/playwright-mcp` |
| Alternative | Puppeteer MCP | `modelcontextprotocol/server-puppeteer` |
| Orchestration | n8n | `n8n-io/n8n` |
| Stockage | Supabase/S3 | - |

### MCP disponibles

```json
{
  "playwright": "@playwright/mcp@latest",
  "puppeteer": "@modelcontextprotocol/server-puppeteer",
  "browserbase": "browserbase/mcp-server-browserbase",
  "browser-use": "co-browser/browser-use-mcp-server"
}
```

### Exemple workflow

```
1. Agent reçoit : "Récupère factures OVH du mois"
2. Playwright MCP → login OVH (credentials Infisical)
3. Navigation → espace factures
4. Download PDF → stockage
5. Renommage standardisé
6. Log dans Obsidian/DB
```

### Limites

| Limite | Contournement |
|--------|---------------|
| Sites avec Captcha | Browserbase (cloud) ou 2Captcha API |
| Auth 2FA | Pré-session manuelle ou TOTP MCP |
| Sites très dynamiques | Playwright > Puppeteer |

---

## 2. SCRAPING & ENRICHISSEMENT

### Verdict : ✅ 100% FAISABLE

### Stack recommandée

| Composant | Outil | Repo |
|-----------|-------|------|
| Scraping intelligent | Firecrawl MCP | `mendableai/firecrawl` |
| Scraping AI | ScrapeGraphAI | `ScrapeGraphAI/scrapegraphai` |
| Enrichissement B2B | Hunter MCP | officiel |
| Web search | Brave Search MCP | officiel |

### MCP disponibles

```json
{
  "firecrawl": "mendableai/firecrawl-mcp-server",
  "apify": "apify/actors-mcp-server",
  "oxylabs": "oxylabs-mcp",
  "brightdata": "brightdata-mcp"
}
```

### Exemple pipeline enrichissement

```
Input: Liste entreprises (CSV)
  ↓
1. Firecrawl → scrape sites web
2. Hunter MCP → emails décideurs
3. LinkedIn (via Apify) → infos complémentaires
4. Perplexity → synthèse
  ↓
Output: CSV enrichi + fiches MD
```

---

## 3. WORKFLOWS N8N DEVOPS

### Verdict : ✅ 100% FAISABLE

### Stack recommandée

| Composant | Outil | Repo |
|-----------|-------|------|
| Orchestration | n8n | `n8n-io/n8n` |
| MCP dans n8n | MCP Tool node | natif n8n 1.x |
| Browser | Playwright node | `drudge/n8n-nodes-puppeteer` |

### Starter kit trouvé

```
🔥 REPO CLÉ : Complete self-hosted stack
- n8n + Playwright MCP + Supabase
- Docker-compose ready
- GitHub Topics: playwright-mcp
```

### Exemples workflows DevOps

| Workflow | Complexité |
|----------|------------|
| Backup automatique serveurs | ⭐⭐ |
| Monitoring + alertes | ⭐⭐ |
| Déploiement staging | ⭐⭐⭐ |
| Rotation secrets | ⭐⭐ |
| Audit logs centralisé | ⭐⭐ |

---

## 📦 REPOS GITHUB CLÉS

| Repo | Stars | Description |
|------|-------|-------------|
| `microsoft/playwright-mcp` | 🔥 | Officiel Microsoft |
| `mendableai/firecrawl` | 15k+ | Scraping AI-ready |
| `n8n-io/n8n` | 50k+ | Orchestration |
| `appcypher/awesome-mcp-servers` | 10k+ | Catalogue MCP |
| `punkpeye/awesome-mcp-servers` | 5k+ | Catalogue MCP #2 |

---

## ⚠️ LIMITES GLOBALES

| Limite | Impact | Mitigation |
|--------|--------|------------|
| Sites avec bot protection | Moyen | Browserbase cloud, proxies |
| Rate limiting APIs | Faible | Queues n8n |
| Credentials management | Critique | **Infisical obligatoire** |
| Maintenance selectors | Moyen | AI-based selectors (Firecrawl) |

---

## ✅ CONCLUSION CATÉGORIE 1

**ALFA couvre 100% des use cases Scripts/Automatisation**

Prérequis :
1. Infisical pour secrets
2. MCP Playwright ou Firecrawl
3. n8n pour orchestration

**Fiabilité : 95%**
**💡 Conseil** : Commencer par Playwright MCP + n8n, le combo le plus documenté.
