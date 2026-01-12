# ALFA - Current Mission Tracker

**Status**: 🔄 EN COURS - MCP Lazy Loading Implementation
**Last Update**: 2026-01-12 14:45
**Started**: 2026-01-12 14:45

---

## Current Mission: MCP Lazy Loading Gateway (2026-01-12)

**Status**: 🔄 EN COURS
**Durée estimée**: 30-45 minutes
**Méthode**: INTAKE → AUDIT → PLAN → BUILD → PROVE

### Objectif

Implémenter lazy loading MCP pour :
- **Problème actuel** : Claude Desktop charge TOUS les MCP tools au démarrage → 66K+ tokens
- **Solution** : MCP Gateway qui expose 1 seul outil de recherche → ~500 tokens
- **Bénéfice** : 99.2% réduction context + <50ms latency + découverte dynamique

### Architecture Cible

```
Claude Desktop (client)
   ↓ charge 1 seul MCP server
ALFA MCP Gateway (Mac host - Node.js)
   ↓ lazy loading <50ms
PostgreSQL Tool Discovery (✅ déjà créé)
   ↓ routing on-demand
125+ MCP tools (chargés uniquement si invoqués)
```

**Différence critique vs tentative précédente** :
- ❌ Avant : Tentative en GO → échecs compilation
- ✅ Maintenant : Node.js + @modelcontextprotocol/sdk (officiel)
- ✅ Réutilise PostgreSQL RAG (déjà opérationnel)
- ✅ Aucune dépendance Docker/ALFA dashboard

---

## Checklist Mission

### ✅ Phase INTAKE (EN COURS)
- [x] Besoin identifié : MCP Lazy Loading
- [x] Objectif défini : 99% réduction context
- [x] CURRENT.md créé
- [ ] Audit échec précédent GO (comprendre pourquoi)

### ⏳ Phase AUDIT
- [ ] Vérifier Node.js installé sur Mac
- [ ] Vérifier @modelcontextprotocol/sdk disponible
- [ ] Tester connexion PostgreSQL depuis Mac host
- [ ] Vérifier Claude Desktop config location

### ⏳ Phase PLAN
- [ ] Plan détaillé architecture (éviter GO)
- [ ] Design API MCP Gateway
- [ ] Schéma routing vers PostgreSQL

### ⏳ Phase BUILD
- [ ] Créer projet Node.js ~/alfa-mcp-gateway
- [ ] Installer dépendances MCP SDK
- [ ] Coder serveur MCP (stdio transport)
- [ ] Implémenter search_tools (lazy loading)
- [ ] Connexion PostgreSQL RAG
- [ ] Config Claude Desktop

### ⏳ Phase PROVE
- [ ] Test 1 : Gateway démarre sans erreur
- [ ] Test 2 : Claude Desktop détecte le server
- [ ] Test 3 : search_tools('slack message') < 50ms
- [ ] Test 4 : Context initial < 1000 tokens
- [ ] Test 5 : Routing fonctionne vers vrais MCPs

---

## Plan Détaillé

### Étape 1 : AUDIT Node.js (5 min)

**Objectif** : Vérifier environnement Node.js fonctionnel

**Commandes** :
```bash
node --version  # Should be v18+
npm --version
```

**Preuve attendue** : Node v18+ installé

---

### Étape 2 : Créer projet MCP Gateway (5 min)

**Objectif** : Initialiser projet Node.js

**Commandes** :
```bash
mkdir -p ~/alfa-mcp-gateway
cd ~/alfa-mcp-gateway
npm init -y
npm install @modelcontextprotocol/sdk pg
```

**Fichiers créés** :
- package.json
- node_modules/

**Preuve attendue** : Dépendances installées

---

### Étape 3 : Coder MCP Server (15 min)

**Objectif** : Serveur MCP avec lazy loading

**Fichier** : `~/alfa-mcp-gateway/index.js`

**Features** :
- Expose 1 seul outil : `search_tools`
- Connexion PostgreSQL RAG
- Routing dynamique

**Preuve attendue** : Code compilable

---

### Étape 4 : Config Claude Desktop (5 min)

**Objectif** : Ajouter gateway dans Claude Desktop config

**Fichier** : `~/Library/Application Support/Claude/claude_desktop_config.json`

**Config** :
```json
{
  "mcpServers": {
    "alfa-gateway": {
      "command": "node",
      "args": ["/Users/arnaud/alfa-mcp-gateway/index.js"],
      "env": {
        "POSTGRES_HOST": "localhost",
        "POSTGRES_DB": "alfa",
        "POSTGRES_USER": "alfa",
        "POSTGRES_PASSWORD": "alfapass123"
      }
    }
  }
}
```

**Preuve attendue** : Fichier JSON valide

---

### Étape 5 : Test <50ms (10 min)

**Objectif** : Valider performance

**Tests** :
1. Restart Claude Desktop
2. Vérifier gateway chargé
3. Test search_tools('slack message')
4. Mesurer latency

**Preuve attendue** : Latency < 50ms

---

## Métriques Cibles

| Métrique | Avant | Après | Objectif |
|----------|-------|-------|----------|
| Context démarrage | 66K+ tokens | ~500 tokens | 99% réduction |
| Tools exposés | 125+ | 1 (search) | Lazy loading |
| Latency recherche | N/A | <50ms | Fast |
| Précision | 100% | 95%+ | High |
| Dépendances | GO (failed) | Node.js | Stable |

---

## Contraintes Critiques

### ❌ Ce qu'on NE FAIT PAS

1. **PAS de compilation GO** (échec précédent)
2. **PAS de Docker** (gateway tourne sur Mac host)
3. **PAS de modification ALFA dashboard** (séparation totale)
4. **PAS de mélange avec infra monitoring**

### ✅ Ce qu'on FAIT

1. **Node.js pur** (SDK officiel MCP)
2. **Mac host natif** (pas de conteneur)
3. **Réutilise PostgreSQL RAG** (déjà créé ✅)
4. **Lazy loading** (1 seul outil exposé)
5. **Performance <50ms** (recherche PostgreSQL optimisée)

---

## Preuves Attendues (PROVE)

### 1. Gateway démarre

```bash
cd ~/alfa-mcp-gateway
node index.js
# Expected: Server listening on stdio
```

### 2. Claude Desktop détecte

Restart Claude Desktop → Settings → Developers → MCP Servers
**Expected** : "alfa-gateway" visible

### 3. Performance <50ms

Dans Claude Desktop :
```
"Search for slack messaging tool"
```

**Expected** : Réponse < 50ms avec tool trouvé

### 4. Context < 1000 tokens

Check context usage in Claude Desktop
**Expected** : ~500 tokens initial (vs 66K+)

### 5. Routing fonctionne

Test multiple queries :
- "slack message" → slack-mcp/send_message
- "github issue" → github-mcp/create_issue
- "database query" → database-mcp/execute_query

**Expected** : 100% précision

---

## Rollback Plan

Si problème critique :

### Option 1 : Disable Gateway

```bash
# Éditer claude_desktop_config.json
# Supprimer section "alfa-gateway"
# Restart Claude Desktop
```

### Option 2 : Delete projet

```bash
rm -rf ~/alfa-mcp-gateway
```

---

## Règles Absolues

1. ✅ **ÉVITER GO** - Node.js uniquement
2. ✅ **MAC HOST** - Pas de Docker pour gateway
3. ✅ **RÉUTILISER RAG** - PostgreSQL déjà créé
4. ✅ **LAZY LOADING** - 1 outil exposé
5. ✅ **PROUVER <50ms** - Tests performance obligatoires
6. ✅ **COMMITS FRÉQUENTS** - Git après chaque étape

---

## Previous Missions

### Mission 4: MCP Tool Discovery (2026-01-12)
**Status**: ✅ 100% COMPLÉTÉ
**Durée**: 2.5 heures

**Réalisations**:
- ✅ PostgreSQL RAG (mcp_servers, mcp_tools)
- ✅ 6 fonctions SQL (search_mcp_tools_simple, etc.)
- ✅ 99% réduction tokens (50K+ → ~500)
- ✅ <50ms search performance
- ✅ Documentation complète

**Impact**: Infrastructure prête pour lazy loading ✅

📁 Archive: Voir `.mcp/MCP-TOOL-DISCOVERY-SUMMARY.md`

---

**🤖 ALFA Mission Tracker v2.2**
**Current**: MCP Lazy Loading 🔄
**Started**: 2026-01-12 14:45
