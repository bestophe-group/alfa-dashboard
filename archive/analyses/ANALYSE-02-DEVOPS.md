# ANALYSE-02 : DevOps & Infrastructure

**Statut** : ✅ COMPLÉTÉ
**Date** : 2025-01-06

---

## 🎯 USE CASES ANALYSÉS

| Use Case | Faisabilité ALFA | Effort |
|----------|------------------|--------|
| Administration serveurs | ✅ Natif | Moyen |
| Monitoring services | ✅ Natif | Faible |
| Audits sécurité/performance | 🟡 Partiel | Élevé |
| Paramétrage SCIM/SSO | 🟡 Partiel | Élevé |
| Support N1/N2 | ✅ Natif | Moyen |
| Catalogue DSI complet | ✅ Natif | Élevé |

---

## 1. ADMINISTRATION SERVEURS

### Verdict : ✅ 100% FAISABLE

### MCP disponibles

| MCP | Repo | Fonction |
|-----|------|----------|
| **Docker** | `ckreiling/mcp-server-docker` | Containers, compose, SSH remote |
| **Kubernetes** | `containers/kubernetes-mcp-server` | Multi-cluster, CRUD, Helm |
| **K8s TypeScript** | `Flux159/mcp-server-kubernetes` | Pods, deployments, services |
| **SSH/PTY** | `yiwenlu66/PiloTY` | Sessions SSH interactives |
| **AWS CLI** | `alexei-led/aws-mcp-server` | AWS CLI dans Docker |

### Architecture recommandée

```
Agent ALFA
    ↓
MCP Gateway (port 50800)
    ├── Docker MCP (local)
    ├── Kubernetes MCP (multi-cluster)
    ├── SSH MCP (serveurs distants)
    └── AWS MCP (cloud)
```

### Exemple commande naturelle

```
"Déploie la nouvelle version de l'app sur le cluster staging"
→ K8s MCP : kubectl set image deployment/app app=myapp:v2.1
→ Monitoring : attente readiness
→ Report : "Déploiement OK, 3/3 pods ready"
```

---

## 2. MONITORING SERVICES

### Verdict : ✅ 100% FAISABLE

### MCP officiels Grafana

| MCP | Repo | Fonction |
|-----|------|----------|
| **Grafana** | `grafana/mcp-grafana` | Dashboards, alertes, incidents |
| **Prometheus** | `awslabs/prometheus-mcp-server` | PromQL queries |
| **Loki** | via Grafana MCP | LogQL queries |

### Fonctionnalités Grafana MCP

```
✅ Query Prometheus (PromQL instant/range)
✅ Query Loki (logs + metrics)
✅ Search/Create/Update dashboards
✅ Manage alerts (Grafana + datasource-managed)
✅ Incidents (create, search, add activities)
✅ OnCall (schedules, shifts, users)
✅ Annotations (CRUD)
✅ Deep links generation
```

### Exemple monitoring automatisé

```
Workflow n8n :
1. Cron toutes les 5min
2. Grafana MCP → query prometheus rate(errors[5m])
3. Si > threshold → créer incident
4. Notifier Slack
5. Log dans Obsidian
```

---

## 3. AUDITS SÉCURITÉ/PERFORMANCE

### Verdict : 🟡 PARTIELLEMENT FAISABLE

### Ce qui est faisable

| Audit | Outil | Faisabilité |
|-------|-------|-------------|
| Vulnérabilités deps | Trivy, Snyk | ✅ Via CLI |
| Secrets exposés | TruffleHog | ✅ Via CLI |
| Config K8s | Kubescape | ✅ Via CLI |
| Performance web | Lighthouse | ✅ Via Playwright |
| Logs analysis | Loki MCP | ✅ Native |

### Ce qui nécessite custom

| Audit | Limite | Solution |
|-------|--------|----------|
| Pentest actif | Risque légal | Humain requis |
| Audit réseau complet | Outils spécialisés | Nmap + scripts |
| Compliance (SOC2, ISO) | Checklist complexe | Templates + humain |

### Stack audit recommandée

```bash
# Sécurité deps
trivy image myapp:latest

# Secrets
trufflehog git file://./

# K8s security
kubescape scan framework nsa

# Web performance
lighthouse https://myapp.com --output json
```

### MCP custom à développer

```
mcp-security-audit
├── trivy_scan()
├── trufflehog_scan()
├── kubescape_scan()
└── generate_report()
```

---

## 4. PARAMÉTRAGE SCIM/SSO

### Verdict : 🟡 PARTIELLEMENT FAISABLE

### Ce qui existe

| Outil | Support SCIM/SSO | MCP disponible |
|-------|------------------|----------------|
| Grafana | SCIM natif (v12+) | ✅ grafana/mcp-grafana |
| Okta | API complète | ❌ À développer |
| Azure AD | Graph API | 🟡 Microsoft 365 MCP |
| Google Workspace | API Admin | 🟡 Partiel |

### Workflow SCIM type

```
1. Définir mapping attributs (JSON)
2. Configurer IdP (Okta/Azure/Google)
3. Tester provisioning
4. Activer sync automatique
```

### Limite ALFA

```
⚠️ Configuration SCIM = souvent UI-only
⚠️ Pas d'API standardisée cross-vendors
→ Solution : Scripts Playwright pour UI automation
```

---

## 5. SUPPORT N1/N2

### Verdict : ✅ 100% FAISABLE

### Architecture Support AI

```
Ticket entrant (n8n webhook)
    ↓
Classification (LLM)
    ↓
┌─────────────────────────────────────┐
│ N1 Automatisé                       │
│ - Reset password (API)              │
│ - Status service (Grafana MCP)      │
│ - FAQ (RAG Obsidian)                │
│ - Logs récents (Loki MCP)           │
└─────────────────────────────────────┘
    ↓ Si non résolu
┌─────────────────────────────────────┐
│ N2 Assisté                          │
│ - Diagnostic (K8s MCP + logs)       │
│ - Rollback (Docker/K8s MCP)         │
│ - Escalade (Jira MCP)               │
└─────────────────────────────────────┘
```

### MCP requis

```json
{
  "grafana": "grafana/mcp-grafana",
  "kubernetes": "containers/kubernetes-mcp-server", 
  "jira": "jira-mcp-server",
  "slack": "slack-mcp",
  "obsidian": "mcp-obsidian"
}
```

---

## 6. CATALOGUE DSI COMPLET

### Verdict : ✅ FAISABLE (effort élevé)

### Couverture par domaine

| Domaine DSI | MCP/Outils | Couverture |
|-------------|------------|------------|
| Infra serveurs | Docker, K8s, SSH | 95% |
| Monitoring | Grafana, Prometheus | 95% |
| CI/CD | GitHub Actions, GitLab | 90% |
| Ticketing | Jira, Linear | 90% |
| Documentation | Obsidian, Notion | 95% |
| Communication | Slack, Teams | 85% |
| Cloud | AWS, GCP, Azure | 80% |
| Sécurité | Trivy, Snyk (CLI) | 70% |
| ITSM | ServiceNow | 60% |

### Repos clés

| Repo | Stars | Description |
|------|-------|-------------|
| `docker/mcp-gateway` | 🔥 | Gateway officiel Docker |
| `containers/kubernetes-mcp-server` | ⭐⭐⭐ | K8s natif Go, multi-cluster |
| `grafana/mcp-grafana` | ⭐⭐⭐ | Monitoring complet |
| `github/github-mcp-server` | 🔥 | Officiel GitHub |
| `awslabs/prometheus-mcp-server` | ⭐⭐ | PromQL queries |

---

## ⚠️ LIMITES GLOBALES

| Limite | Impact | Mitigation |
|--------|--------|------------|
| Accès SSH sécurisé | Critique | Bastion + clés dans Infisical |
| Permissions K8s | Élevé | RBAC strict, service accounts |
| Audit compliance | Moyen | Templates + validation humaine |
| Multi-cloud | Moyen | MCP par provider |

---

## 🔧 MCP À DÉVELOPPER

| MCP custom | Priorité | Complexité |
|------------|----------|------------|
| `mcp-security-audit` | Haute | Moyenne |
| `mcp-scim-generic` | Moyenne | Élevée |
| `mcp-servicenow` | Basse | Moyenne |

---

## ✅ CONCLUSION CATÉGORIE 2

**ALFA couvre ~85% des use cases DevOps/Infra**

| Aspect | Couverture |
|--------|------------|
| Admin serveurs | 100% |
| Monitoring | 100% |
| Support N1/N2 | 100% |
| Audits | 70% |
| SCIM/SSO | 50% |

**Fiabilité : 90%**
**💡 Conseil** : Commencer par Docker + K8s + Grafana MCP = 80% des besoins couverts.
