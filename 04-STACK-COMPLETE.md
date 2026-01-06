# 04 - STACK COMPLÈTE
## Infisical + MCP Gateway + Outils Anti-Désalignement

---

## 📑 SOMMAIRE

1. [Vue d'ensemble](#1-vue-densemble)
2. [Infisical - Secrets](#2-infisical---secrets)
3. [MCP Gateway](#3-mcp-gateway)
4. [Context7 - Anti-hallucination](#4-context7---anti-hallucination)
5. [Outils natifs Cursor](#5-outils-natifs-cursor)
6. [Configuration complète](#6-configuration-complète)
7. [Exemples DO / DON'T](#7-exemples-do--dont)

> **📦 DÉPLOIEMENT SELF-HOSTED** : Voir `11-STACK-SELFHOSTED-VPS.md` pour Docker Compose + VPS OVH + n8n 2.0

---

## 1. VUE D'ENSEMBLE

### Architecture Anti-Désalignement

```
┌─────────────────────────────────────────────────────────────────┐
│                    STACK ANTI-DÉSALIGNEMENT                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐       │
│  │   CURSOR    │────►│    AGENT    │────►│   OUTPUT    │       │
│  │    IDE      │     │    IANA     │     │   (Code)    │       │
│  └─────────────┘     └──────┬──────┘     └─────────────┘       │
│                             │                                   │
│         ┌───────────────────┼───────────────────┐              │
│         │                   │                   │              │
│         ▼                   ▼                   ▼              │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐       │
│  │  INFISICAL  │     │ MCP GATEWAY │     │  CONTEXT7   │       │
│  │  (Secrets)  │     │  (Port 50800)│     │   (Docs)    │       │
│  │             │     │             │     │             │       │
│  │ ✓ API Keys  │     │ ✓ Obsidian  │     │ ✓ Libs      │       │
│  │ ✓ DB URLs   │     │ ✓ GitHub    │     │ ✓ APIs      │       │
│  │ ✓ Tokens    │     │ ✓ n8n       │     │ ✓ Syntaxe   │       │
│  └─────────────┘     └─────────────┘     └─────────────┘       │
│                                                                 │
│  Rôle: Source      Rôle: Outils        Rôle: Anti-            │
│        de vérité          vérifiés            hallucination    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Mapping Problème → Solution

| Problème | Outil | Rôle |
|----------|-------|------|
| Hallucination syntaxe | Context7 | Docs officielles |
| Secret en clair | Infisical | Gestion centralisée |
| Donnée inventée | MCP Obsidian | KB vérifiée |
| API inconnue | MCP Brave/Perplexity | Recherche web |
| Workflow manuel | MCP n8n | Automation |
| Issue tracking | MCP GitHub | Intégration native |

---

## 2. INFISICAL - SECRETS

### Pourquoi Infisical (Anti-désalignement)

| Sans Infisical | Avec Infisical |
|----------------|----------------|
| Secret dans .env | Secret centralisé |
| Risque commit secret | Impossible de commit |
| Agent peut inventer | Agent doit demander |
| Pas d'audit | Audit complet |

### Installation

```bash
# macOS
brew install infisical/infisical-cli/infisical

# Linux
curl -1sLf 'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.deb.sh' | sudo -E bash
sudo apt-get install infisical

# Login (une fois)
infisical login

# Init dans projet
cd mon-projet
infisical init
```

### Configuration projet

**Livrable** : `.infisical.json` à la racine

```json
{
  "workspaceId": "votre-workspace-id",
  "defaultEnvironment": "dev",
  "gitBranchToEnvironmentMapping": {
    "main": "prod",
    "staging": "staging",
    "dev": "dev"
  }
}
```

### Usage quotidien

```bash
# ❌ DON'T : Variables en dur
DATABASE_URL="postgres://..." npm run dev

# ✅ DO : Via Infisical wrapper
infisical run -- npm run dev

# ✅ DO : Avec environnement spécifique
infisical run --env=staging -- npm run dev

# ✅ DO : Exporter (temporaire)
infisical export --env=dev > .env.local
```

### Workflow avec Agent

| Étape | Agent | Humain |
|-------|-------|--------|
| 1 | "J'ai besoin de STRIPE_KEY" | - |
| 2 | - | Ajoute dans Infisical |
| 3 | - | "C'est ajouté" |
| 4 | `infisical run -- npm run dev` | - |
| 5 | Code utilise `process.env.STRIPE_KEY` | - |

### Règles .cursorrules

```markdown
# Secrets (Infisical) - RÈGLES ABSOLUES
1. Source de vérité UNIQUE : Infisical
2. INTERDIT : écrire secrets dans .env, .env.local
3. INTERDIT : secrets dans le code source
4. INTERDIT : secrets dans les logs/output
5. Wrapper OBLIGATOIRE : infisical run -- [commande]
6. Si variable manquante → DEMANDER ajout Infisical
7. JAMAIS inventer une valeur de secret
```

---

## 3. MCP GATEWAY

### Architecture Gateway (Port 50800)

```
┌─────────────────────────────────────────┐
│         MCP GATEWAY (localhost:50800)    │
├─────────────────────────────────────────┤
│                                          │
│  obsidian__*        Knowledge Base       │
│  ├── search_notes   Chercher dans KB     │
│  ├── get_note       Lire une note        │
│  └── create_note    Créer une note       │
│                                          │
│  brave-search__*    Recherche Web        │
│  └── search         Recherche            │
│                                          │
│  perplexity__*      Recherche Avancée    │
│  └── search         Recherche + Synthèse │
│                                          │
│  github__*          GitHub Integration   │
│  ├── create_issue   Créer issue          │
│  ├── list_issues    Lister issues        │
│  └── create_pr      Créer PR             │
│                                          │
│  n8n__*             Workflows            │
│  ├── list_workflows Lister workflows     │
│  ├── execute        Exécuter workflow    │
│  └── get_execution  Statut exécution     │
│                                          │
└─────────────────────────────────────────┘
```

### Configuration .cursor/mcp.json

**Livrable** : Fichier de config MCP

```json
{
  "mcpServers": {
    "gateway": {
      "command": "node",
      "args": ["/path/to/mcp-gateway/dist/index.js"],
      "env": {
        "PORT": "50800",
        "OBSIDIAN_VAULT": "/Users/arnaud/LifeOS",
        "GITHUB_TOKEN": "${GITHUB_TOKEN}",
        "N8N_URL": "http://localhost:5678",
        "N8N_API_KEY": "${N8N_API_KEY}"
      }
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@anthropics/context7-mcp"]
    }
  }
}
```

### Usage par besoin

| Besoin | Outil MCP | Commande |
|--------|-----------|----------|
| Chercher dans KB | obsidian__search_notes | `{"query": "stripe integration"}` |
| Recherche web | brave-search__search | `{"query": "react query v5 syntax"}` |
| Créer issue | github__create_issue | `{"title": "Bug X", "body": "..."}` |
| Déclencher workflow | n8n__execute | `{"workflow_id": "123"}` |

### Quand utiliser quel outil

```markdown
# Arbre de décision MCP

Question: Où trouver l'information ?

├── Dans ma KB personnelle ?
│   └── OUI → obsidian__search_notes
│
├── Documentation officielle d'une lib ?
│   └── OUI → context7 (TOUJOURS avant de coder)
│
├── Information récente/actuelle ?
│   └── OUI → brave-search ou perplexity
│
├── Créer/gérer issue ?
│   └── OUI → github__*
│
└── Déclencher automation ?
    └── OUI → n8n__*
```

---

## 4. CONTEXT7 - ANTI-HALLUCINATION

### Pourquoi Context7 est OBLIGATOIRE

| Sans Context7 | Avec Context7 |
|---------------|---------------|
| "De mémoire, c'est..." | "D'après la doc [lien]..." |
| API deprecated | API actuelle |
| Paramètres inventés | Paramètres exacts |
| 2h debug | Code qui marche |

### Usage obligatoire

```markdown
# RÈGLE : Avant d'utiliser une lib/API

1. TOUJOURS consulter Context7 D'ABORD
2. Vérifier version installée (package.json)
3. Copier syntaxe EXACTE de la doc
4. JAMAIS inventer de syntaxe
```

### Exemples concrets

**Exemple 1 : React Query**

```javascript
// ❌ SANS Context7 (hallucination)
import { useQuery } from 'react-query';  // Mauvais package
const { data } = useQuery('users', fetchUsers);  // Ancienne API

// ✅ AVEC Context7
// Agent: "Je consulte Context7 pour @tanstack/react-query v5..."
import { useQuery } from '@tanstack/react-query';
const { data } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers
});
```

**Exemple 2 : Stripe**

```javascript
// ❌ SANS Context7 (hallucination)
const charge = await stripe.charges.create({...});  // Deprecated 2023

// ✅ AVEC Context7
// Agent: "Je consulte Context7 pour stripe-node v14..."
const paymentIntent = await stripe.paymentIntents.create({
  amount: 1000,
  currency: 'eur',
  payment_method_types: ['card']
});
```

**Exemple 3 : Next.js**

```javascript
// ❌ SANS Context7 (hallucination)
export async function getServerSideProps() {...}  // Pages Router

// ✅ AVEC Context7 (App Router v14)
// Agent: "Je consulte Context7 pour Next.js App Router..."
export async function generateMetadata() {...}
```

---

## 5. OUTILS NATIFS CURSOR

### Règle de séparation

```markdown
# RÈGLE : Outils natifs vs MCP

OUTILS NATIFS (code source) :
- read_file
- edit_file  
- create_file
- Terminal (zsh)

MCP (données externes) :
- obsidian__* (KB)
- brave-search__* (web)
- github__* (issues)
- n8n__* (workflows)
- context7 (docs)

INTERDIT : Utiliser filesystem__* MCP pour le code source
```

### Pourquoi cette séparation

| Outil natif | MCP filesystem |
|-------------|----------------|
| Intégré Cursor | Couche supplémentaire |
| Rapide | Plus lent |
| Fiable | Peut échouer |
| Audit intégré | Pas d'audit |

---

## 6. CONFIGURATION COMPLÈTE

### Checklist setup projet

**Livrables à créer** :

- [ ] `.cursorrules` (règles agent)
- [ ] `.cursor/mcp.json` (config MCP)
- [ ] `.infisical.json` (config secrets)
- [ ] `.gitignore` (exclure secrets)
- [ ] `@specs/CURRENT.md` (spec vivante)

### Fichier .gitignore

```gitignore
# Secrets
.env
.env.local
.env.*.local
*.pem
*.key

# Infisical
.infisical.json

# IDE
.cursor/
.vscode/

# Logs
*.log
logs/

# OS
.DS_Store
Thumbs.db
```

### Structure projet recommandée

```
mon-projet/
├── .cursorrules              # Règles agent
├── .cursor/
│   └── mcp.json              # Config MCP
├── .infisical.json           # Config secrets
├── .gitignore
├── @specs/
│   └── CURRENT.md            # Spec vivante
├── docs/
│   ├── 00_Context/           # Contexte projet
│   ├── 10_Tech/              # Docs techniques
│   └── 99_Assets/            # Images
├── src/                      # Code source
├── tests/                    # Tests
└── package.json
```

---

## 7. EXEMPLES DO / DON'T

### Exemple 1 : Nouvelle feature avec lib inconnue

| ❌ DON'T | ✅ DO |
|----------|-------|
| Coder "de mémoire" | 1. Context7 pour la lib |
| Inventer syntaxe | 2. Vérifier version package.json |
| Copier StackOverflow 2020 | 3. Copier exactement la doc |
| "Ça devrait marcher" | 4. Tester + preuve |

### Exemple 2 : Variable d'environnement manquante

| ❌ DON'T | ✅ DO |
|----------|-------|
| Inventer une valeur | "Ajoute X dans Infisical" |
| Mettre "xxx" ou "todo" | Attendre que l'humain ajoute |
| Hardcoder temporairement | `infisical run -- npm run dev` |

### Exemple 3 : Information dans KB

| ❌ DON'T | ✅ DO |
|----------|-------|
| Supposer le contenu | `obsidian__search_notes` |
| Demander à l'humain direct | Chercher d'abord dans KB |
| Inventer si pas trouvé | "Pas trouvé dans KB, quelle est la réponse ?" |

### Exemple 4 : Bug à tracer

| ❌ DON'T | ✅ DO |
|----------|-------|
| TODO dans le code | `github__create_issue` |
| Note mentale | Issue avec labels |
| Oublier | Traçabilité complète |

---

## 📋 CHECKLIST STACK COMPLÈTE

### Installation (une fois)

- [ ] Infisical CLI installé
- [ ] Infisical login effectué
- [ ] MCP Gateway installé
- [ ] Context7 configuré
- [ ] Obsidian vault configuré

### Par projet

- [ ] `infisical init` dans le projet
- [ ] `.cursor/mcp.json` créé
- [ ] `.cursorrules` copié
- [ ] `.gitignore` vérifié
- [ ] Test : `infisical run -- echo $TEST_VAR`

### À chaque session

- [ ] MCP Gateway running (port 50800)
- [ ] Infisical connecté
- [ ] CURRENT.md ouvert

---

**Fiabilité** : 97%
**💡 Conseil** : Context7 AVANT de coder = division par 10 des hallucinations syntaxiques.
