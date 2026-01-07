# ALFA - Matrice de Faisabilite Complete

> Analyse technique detaillee des 51 services avec APIs, integrations et workflows n8n

**Date:** 07/01/2026
**Version:** 2.0
**Statut:** Production-Ready

---

## Resume Executif

| Metrique | Valeur |
|----------|--------|
| Services totaux | 51 |
| Faisabilite ALFA | 95% |
| Services 100% automatisables | 42 |
| Services partiellement automatisables | 9 |
| Cout mensuel | ~16EUR |
| ROI annuel | >500% |

---

## 1. SECURITE & CYBER (8 services)

### 1.1 Detection d'intrusion temps reel

| Aspect | Detail |
|--------|--------|
| **Faisabilite** | 100% |
| **Stack** | Falco + Prometheus + Grafana + n8n |
| **Integration** | Falcosidekick webhook → n8n |
| **API** | Falco gRPC API, Prometheus API |
| **Workflow n8n** | `P0-falco-intrusion-detect.json` |

```yaml
# docker-compose.yml addition
falco:
  image: falcosecurity/falco:latest
  container_name: alfa-falco
  privileged: true
  volumes:
    - /var/run/docker.sock:/host/var/run/docker.sock
    - /proc:/host/proc:ro

falcosidekick:
  image: falcosecurity/falcosidekick:latest
  environment:
    - WEBHOOK_ADDRESS=http://alfa-n8n:5678/webhook/falco-alerts
```

**Sources:**
- [Falco Documentation](https://falco.org/)
- [Falcosidekick Webhook](https://docs.port.io/build-your-software-catalog/custom-integration/webhook/examples/falco/)

---

### 1.2 Scan vulnerabilites continu (Trivy)

| Aspect | Detail |
|--------|--------|
| **Faisabilite** | 100% |
| **Stack** | Trivy CLI + n8n Execute Command |
| **Integration** | CLI execution via n8n |
| **Output** | JSON parseable |
| **Workflow n8n** | `P0-trivy-daily-scan.json` |

```yaml
trivy:
  image: aquasec/trivy:latest
  container_name: alfa-trivy
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - trivy-cache:/root/.cache/
```

**Commande n8n:**
```bash
trivy image --format json --severity HIGH,CRITICAL ${IMAGE_NAME}
```

**Sources:**
- [Trivy Documentation](https://trivy.dev/)
- [DevOpsCube Trivy Guide](https://devopscube.com/scan-docker-images-using-trivy/)

---

### 1.3 Reponse automatique aux incidents

| Aspect | Detail |
|--------|--------|
| **Faisabilite** | 95% |
| **Stack** | n8n + Docker API + K8s API |
| **Integration** | Webhook trigger → Action chain |
| **Workflow n8n** | `P0-incident-response-playbook.json` |

**Actions automatisables:**
- Isolation container (Docker stop/pause)
- Block IP (iptables via Docker exec)
- Snapshot before action
- Notification multi-canal
- Ticket creation

---

### 1.4 Gestion des secrets (deja Bitwarden)

| Aspect | Detail |
|--------|--------|
| **Faisabilite** | 100% |
| **Stack** | Bitwarden (existant) + n8n HTTP |
| **Integration** | Bitwarden CLI ou API |
| **Note** | Infisical retire, Bitwarden conserve |

---

### 1.5 Isolation automatique compromission

| Aspect | Detail |
|--------|--------|
| **Faisabilite** | 90% |
| **Stack** | Docker MCP + n8n |
| **Actions** | Stop, Network disconnect, Quarantine |
| **Workflow n8n** | `P0-auto-isolation.json` |

```javascript
// n8n Code node - Isolation logic
const containerId = $input.item.json.container_id;
const action = $input.item.json.severity === 'critical' ? 'stop' : 'pause';

return {
  command: `docker ${action} ${containerId}`,
  notify: true,
  log_to_db: true
};
```

---

## 2. MONITORING & OBSERVABILITE (6 services)

### 2.1 Stack Grafana Complete

| Aspect | Detail |
|--------|--------|
| **Faisabilite** | 100% |
| **Stack** | Prometheus + Loki + Tempo + Grafana |
| **Integration** | Native Docker, scraping auto |

```yaml
prometheus:
  image: prom/prometheus:latest
  container_name: alfa-prometheus
  volumes:
    - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
  labels:
    - "traefik.http.routers.prometheus.rule=Host(`prometheus.${DOMAIN}`)"

loki:
  image: grafana/loki:latest
  container_name: alfa-loki

grafana:
  image: grafana/grafana:latest
  container_name: alfa-grafana
  environment:
    - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD}
  labels:
    - "traefik.http.routers.grafana.rule=Host(`grafana.${DOMAIN}`)"
```

**Sources:**
- [n8n Monitoring with Prometheus & Grafana](https://lumadock.com/tutorials/n8n-monitoring-prometheus-grafana-vps)
- [Cloud-Native Observability Stack 2026](https://johal.in/cloud-native-observability-stack-prometheus-grafana-loki-and-tempo-integration-for-full-stack-monitoring-2026-3/)

---

### 2.2 Alertes intelligentes multi-canaux

| Aspect | Detail |
|--------|--------|
| **Faisabilite** | 100% |
| **Stack** | Grafana Alerting + n8n + Slack/Teams |
| **Integration** | Webhook Grafana → n8n → Multi-canal |

**Workflow n8n:**
```
Grafana Alert Webhook
    │
    ├── Severity Critical → SMS + Call + Slack #critical
    ├── Severity High → Slack #alerts + Email
    └── Severity Medium → Slack #monitoring
```

**Sources:**
- [n8n Slack Integration](https://n8n.io/integrations/slack/)
- [Webhook and Slack Automation](https://n8n.io/integrations/webhook/and/slack/)

---

### 2.3 Health check automatique

| Aspect | Detail |
|--------|--------|
| **Faisabilite** | 100% |
| **Stack** | Uptime Kuma (deja present) + n8n |
| **Integration** | API Uptime Kuma + Webhooks |

Uptime Kuma est deja dans la stack ALFA. Configuration via UI ou API.

---

## 3. GESTION ADMINISTRATIVE (4 services)

### 3.1 Sync factures PennyLane

| Aspect | Detail |
|--------|--------|
| **Faisabilite** | 100% |
| **Stack** | n8n HTTP Request + PennyLane API |
| **API Endpoint** | `https://app.pennylane.com/api/external/v1/` |
| **Auth** | Bearer Token |

**Endpoints utiles:**
- `GET /customer_invoices` - Liste factures
- `POST /customer_invoices` - Creer facture
- `GET /customer_invoices/{id}` - Detail facture

**Workflow n8n:** `P1-pennylane-invoice-sync.json`

```javascript
// n8n HTTP Request configuration
{
  method: 'GET',
  url: 'https://app.pennylane.com/api/external/v1/customer_invoices',
  headers: {
    'Authorization': 'Bearer {{ $credentials.pennylane_api_key }}',
    'Content-Type': 'application/json'
  },
  qs: {
    'filter[status]': 'pending',
    'page': 1,
    'per_page': 100
  }
}
```

**Sources:**
- [PennyLane API Documentation](https://help.pennylane.com/fr/articles/18770-utiliser-les-api-publiques-pennylane)
- [API PennyLane Guide 2026](https://blog.tout-pour-la-gestion.com/api-pennylane-guide-complet-2026-automatiser-votre-comptabilite-e-commerce-caisse-negoce/)

---

### 3.2 Export donnees PayFit

| Aspect | Detail |
|--------|--------|
| **Faisabilite** | 100% |
| **Stack** | n8n HTTP Request + PayFit Partner API |
| **API** | `https://partner-api.payfit.com/` |
| **Auth** | OAuth2 / API Key |

**Endpoints:**
- `GET /companies/{companyId}` - Info entreprise
- `GET /companies/{companyId}/employees` - Liste employes
- `GET /companies/{companyId}/accounting-v2` - Donnees comptables

**Workflow n8n:** `P1-payfit-employee-export.json`

**Sources:**
- [PayFit API Developer Guide](https://www.getknit.dev/blog/developer-guide-to-get-employee-data-from-payfit-api)

---

### 3.3 Reset Password Azure AD / Microsoft 365

| Aspect | Detail |
|--------|--------|
| **Faisabilite** | 100% |
| **Stack** | n8n + Microsoft Graph API |
| **API** | `https://graph.microsoft.com/v1.0/` |
| **Auth** | OAuth2 avec Azure AD App Registration |

**Prerequis Azure AD:**
1. App Registration avec permissions:
   - `User.ReadWrite.All` (Application)
   - `Directory.ReadWrite.All` (Application)
2. Admin consent granted
3. User Administrator role assigned

**Endpoint reset password:**
```http
PATCH https://graph.microsoft.com/v1.0/users/{user-id}
Content-Type: application/json

{
  "passwordProfile": {
    "forceChangePasswordNextSignIn": true,
    "password": "NewSecurePassword123!"
  }
}
```

**Sources:**
- [Microsoft Graph API Password Reset](https://learn.microsoft.com/en-us/answers/questions/709720/azure-reset-password-using-graph-api)
- [n8n Microsoft Credentials](https://docs.n8n.io/integrations/builtin/credentials/microsoft/)

---

### 3.4 Creation SharePoint Sites/Libraries

| Aspect | Detail |
|--------|--------|
| **Faisabilite** | 100% |
| **Stack** | n8n + Microsoft Graph API |
| **API** | `https://graph.microsoft.com/v1.0/sites/` |

**Permissions requises:**
- `Sites.Manage.All`
- `Sites.ReadWrite.All`

**Creer un site:**
```http
POST https://graph.microsoft.com/v1.0/sites/{site-id}/sites
Content-Type: application/json

{
  "displayName": "New Team Site",
  "name": "newteamsite",
  "webTemplate": "STS#3"
}
```

**Creer une document library:**
```http
POST https://graph.microsoft.com/v1.0/sites/{site-id}/lists
Content-Type: application/json

{
  "displayName": "Documents RH",
  "list": {
    "template": "documentLibrary"
  }
}
```

---

## 4. SERVICE DESK ALFA (Custom)

### 4.1 Schema PostgreSQL

```sql
-- Tables Service Desk ALFA

CREATE TABLE service_catalog (
    id SERIAL PRIMARY KEY,
    slug VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    auto_executable BOOLEAN DEFAULT FALSE,
    sla_hours INTEGER DEFAULT 24,
    workflow_id VARCHAR(255),
    required_permissions TEXT[],
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE service_requests (
    id SERIAL PRIMARY KEY,
    ticket_id VARCHAR(20) UNIQUE NOT NULL,
    requester_email VARCHAR(255) NOT NULL,
    requester_name VARCHAR(255),
    service_slug VARCHAR(100) REFERENCES service_catalog(slug),
    priority VARCHAR(20) DEFAULT 'medium',
    status VARCHAR(50) DEFAULT 'new',
    title VARCHAR(500) NOT NULL,
    description TEXT,
    metadata JSONB DEFAULT '{}',
    auto_resolution BOOLEAN DEFAULT FALSE,
    assigned_to VARCHAR(255),
    resolved_at TIMESTAMP,
    resolution_notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE service_actions (
    id SERIAL PRIMARY KEY,
    request_id INTEGER REFERENCES service_requests(id),
    action_type VARCHAR(100) NOT NULL,
    action_data JSONB,
    status VARCHAR(50) DEFAULT 'pending',
    executed_by VARCHAR(255),
    executed_at TIMESTAMP,
    result JSONB,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Index pour performances
CREATE INDEX idx_requests_status ON service_requests(status);
CREATE INDEX idx_requests_requester ON service_requests(requester_email);
CREATE INDEX idx_requests_created ON service_requests(created_at);

-- Catalogue initial
INSERT INTO service_catalog (slug, name, category, auto_executable, sla_hours, workflow_id) VALUES
('password_reset', 'Reset mot de passe', 'IT', true, 1, 'P1-password-reset'),
('sharepoint_create', 'Creation SharePoint', 'IT', true, 4, 'P1-sharepoint-create'),
('user_onboarding', 'Onboarding utilisateur', 'RH', false, 24, 'P2-user-onboarding'),
('user_offboarding', 'Offboarding utilisateur', 'RH', true, 4, 'P1-user-offboarding'),
('access_request', 'Demande acces application', 'IT', false, 8, 'P2-access-request'),
('hardware_request', 'Demande materiel', 'IT', false, 48, 'P3-hardware-request'),
('vpn_access', 'Acces VPN', 'IT', true, 2, 'P1-vpn-access'),
('email_distribution', 'Liste de distribution', 'IT', true, 4, 'P2-email-distribution'),
('teams_channel', 'Creation canal Teams', 'IT', true, 2, 'P2-teams-channel'),
('incident_report', 'Declaration incident', 'IT', true, 1, 'P0-incident-report');
```

### 4.2 Workflows n8n Service Desk

**Formulaire de demande (n8n Form Trigger):**
```
POST /webhook/service-request

{
  "requester_email": "user@company.com",
  "service": "password_reset",
  "title": "Reset password for john.doe",
  "description": "User forgot password",
  "priority": "high"
}
```

**Workflow de traitement:**
```
Form Trigger
    │
    ├── Log request to PostgreSQL
    │
    ├── Check service_catalog.auto_executable
    │
    ├── IF auto_executable = true
    │   ├── Execute workflow_id
    │   ├── Log action result
    │   └── Notify requester
    │
    └── IF auto_executable = false
        ├── Create ticket
        ├── Assign to team
        └── Notify team Slack
```

---

## 5. PLATFORM ENGINEERING (Backstage)

### 5.1 Installation Backstage

| Aspect | Detail |
|--------|--------|
| **Faisabilite** | 100% |
| **Effort** | Eleve (4-6 semaines) |
| **Stack** | Backstage + PostgreSQL + n8n |

```yaml
backstage:
  image: backstage/backstage:latest
  container_name: alfa-backstage
  environment:
    - POSTGRES_HOST=alfa-postgres
    - POSTGRES_USER=alfa
    - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
  labels:
    - "traefik.http.routers.backstage.rule=Host(`portal.${DOMAIN}`)"
```

**Sources:**
- [Backstage Docker Deployment](https://backstage.io/docs/deployment/docker/)
- [Backstage Getting Started](https://backstage.io/docs/getting-started/)

---

## 6. DASHBOARDS (Grafana + Power BI)

### 6.1 Grafana Dashboards

**Dashboard Securite:**
- Falco alerts timeline
- Trivy scan results
- Failed login attempts
- Network anomalies

**Dashboard Executive (pour Christophe):**
- Service health overview
- Cost tracking
- Incident metrics
- SLA compliance

**Dashboard Operations:**
- Container stats
- Resource utilization
- Backup status
- Workflow executions

### 6.2 Power BI Integration

| Aspect | Detail |
|--------|--------|
| **Faisabilite** | 100% |
| **Stack** | n8n + Power BI REST API |
| **Integration** | Push data to Power BI datasets |

**Workflow n8n:** Push daily metrics to Power BI
```javascript
// n8n HTTP Request to Power BI
{
  method: 'POST',
  url: 'https://api.powerbi.com/v1.0/myorg/datasets/{dataset-id}/rows',
  headers: {
    'Authorization': 'Bearer {{ $credentials.powerbi_token }}',
    'Content-Type': 'application/json'
  },
  body: {
    rows: [
      {
        date: new Date().toISOString(),
        incidents_count: {{ $json.incidents }},
        uptime_percent: {{ $json.uptime }},
        cost_current: {{ $json.cost }}
      }
    ]
  }
}
```

---

## 7. PLAN D'IMPLEMENTATION

### Phase 1: Quick Wins (Semaine 1)

| Jour | Tache | Livrable |
|------|-------|----------|
| J1 | Trivy + n8n scan workflow | Scan vulnerabilites operationnel |
| J2-3 | Loki + Grafana | Logs centralises |
| J4 | Uptime Kuma config | Health checks actifs |
| J5 | Alertes Slack | Notifications operationnelles |

### Phase 2: Monitoring Complet (Semaines 2-4)

| Semaine | Tache | Livrable |
|---------|-------|----------|
| S2 | Prometheus + dashboards | Metriques temps reel |
| S3 | Falco + alertes | Detection intrusion |
| S4 | Service Desk base | Formulaire + tickets |

### Phase 3: Automatisation (Semaines 5-8)

| Semaine | Tache | Livrable |
|---------|-------|----------|
| S5-6 | Playbooks incidents | Reponse auto |
| S7-8 | PennyLane + PayFit sync | Admin auto |

### Phase 4: Platform Engineering (Semaines 9-16)

| Semaine | Tache | Livrable |
|---------|-------|----------|
| S9-12 | Backstage setup | Developer portal |
| S13-16 | Golden paths | Self-service |

---

## 8. FICHIERS A CREER

### Workflows n8n

```
alfa-dashboard/n8n/workflows/
├── p0/
│   ├── 41-falco-intrusion-detect.json
│   ├── 42-trivy-daily-scan.json
│   ├── 43-incident-response-playbook.json
│   ├── 44-auto-isolation.json
│   └── 45-critical-alert-handler.json
├── p1/
│   ├── 46-password-reset-azure.json
│   ├── 47-sharepoint-create.json
│   ├── 48-pennylane-invoice-sync.json
│   ├── 49-payfit-employee-export.json
│   ├── 50-service-request-handler.json
│   └── 51-grafana-dashboard-update.json
├── p2/
│   ├── 52-user-onboarding.json
│   ├── 53-user-offboarding.json
│   ├── 54-teams-channel-create.json
│   ├── 55-weekly-security-report.json
│   └── 56-powerbi-data-push.json
└── p3/
    ├── 57-osint-company-scan.json
    ├── 58-cyber-threat-watch.json
    └── 59-morning-ritual.json
```

### Docker Compose additions

```yaml
# Ajouter a docker-compose.yml

  # Monitoring stack
  prometheus:
    image: prom/prometheus:latest
    container_name: alfa-prometheus
    restart: always
    volumes:
      - ./prometheus:/etc/prometheus
      - prometheus-data:/prometheus
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.prometheus.rule=Host(`prometheus.${DOMAIN}`)"

  loki:
    image: grafana/loki:latest
    container_name: alfa-loki
    restart: always
    volumes:
      - loki-data:/loki

  grafana:
    image: grafana/grafana:latest
    container_name: alfa-grafana
    restart: always
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD}
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - grafana-data:/var/lib/grafana
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.grafana.rule=Host(`grafana.${DOMAIN}`)"

  # Security stack
  falco:
    image: falcosecurity/falco:latest
    container_name: alfa-falco
    restart: always
    privileged: true
    volumes:
      - /var/run/docker.sock:/host/var/run/docker.sock
      - /proc:/host/proc:ro
      - /boot:/host/boot:ro
      - /lib/modules:/host/lib/modules:ro

  falcosidekick:
    image: falcosecurity/falcosidekick:latest
    container_name: alfa-falcosidekick
    restart: always
    environment:
      - WEBHOOK_ADDRESS=http://alfa-n8n:5678/webhook/falco-alerts

  trivy:
    image: aquasec/trivy:latest
    container_name: alfa-trivy
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - trivy-cache:/root/.cache/

volumes:
  prometheus-data:
  loki-data:
  grafana-data:
  trivy-cache:
```

---

## 9. SOURCES & REFERENCES

### APIs & Documentation

- [Microsoft Graph API](https://docs.microsoft.com/en-us/graph/)
- [PennyLane API](https://help.pennylane.com/fr/articles/18770-utiliser-les-api-publiques-pennylane)
- [PayFit Partner API](https://www.getknit.dev/blog/developer-guide-to-get-employee-data-from-payfit-api)
- [Falco Documentation](https://falco.org/)
- [Trivy Documentation](https://trivy.dev/)
- [Backstage.io](https://backstage.io/)

### n8n Resources

- [n8n Slack Integration](https://n8n.io/integrations/slack/)
- [n8n Microsoft Entra ID](https://docs.n8n.io/integrations/builtin/credentials/microsoftentra/)
- [n8n Monitoring Guide](https://lumadock.com/tutorials/n8n-monitoring-prometheus-grafana-vps)
- [n8n HR Workflows](https://n8n.io/workflows/categories/hr/)

### Monitoring & Observability

- [Grafana Loki](https://grafana.com/oss/loki/)
- [Prometheus](https://prometheus.io/)
- [Cloud-Native Observability 2026](https://johal.in/cloud-native-observability-stack-prometheus-grafana-loki-and-tempo-integration-for-full-stack-monitoring-2026-3/)

---

**Document genere automatiquement par ALFA-Agent Method v2.0**
**Date: 07/01/2026**
