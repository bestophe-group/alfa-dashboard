# ALFA - Current Mission Tracker

**Status**: 🔄 EN COURS - MCP Tool Discovery Implementation
**Last Update**: 2026-01-12
**Started**: 2026-01-12 12:00

---

## Current Mission: MCP Tool Discovery (2026-01-12)

**Status**: 🔄 EN COURS
**Durée estimée**: 2-3 heures
**Méthode**: INTAKE → AUDIT → PLAN → BUILD → PROVE

### Objectif

Créer système de découverte et recherche d'outils MCP dans RAG pour :
- **Problème** : Agent ne sait pas quels outils MCP exister sans lister tous les serveurs
- **Solution** : Index des outils MCP dans PostgreSQL avec recherche sémantique
- **Bénéfice** : Réduction 99% tokens (50K+ → ~500 tokens) + recherche précise

### Architecture

```
Agent IA
   ↓
"Je veux envoyer notification Slack"
   ↓
rag.search_mcp_tools_simple('slack notification', 5)
   ↓
Résultats: slack-mcp → send_message (score: 0.95)
   ↓
Agent utilise l'outil exact
```

---

## Checklist Mission

### ✅ Phase INTAKE
- [x] Besoin identifié : MCP Tool Discovery
- [x] Objectif défini : Index + recherche sémantique
- [x] CURRENT.md créé

### ⏳ Phase AUDIT
- [ ] Backup base de données
- [ ] Vérifier schéma RAG actuel
- [ ] Lister serveurs MCP disponibles

### ⏳ Phase PLAN
- [ ] Plan détaillé validé (voir ci-dessous)

### ⏳ Phase BUILD
- [ ] **Étape 2** : Backup base (CRITIQUE)
- [ ] **Étape 3** : Créer schéma SQL (tables)
- [ ] **Étape 4** : Créer fonctions recherche
- [ ] **Étape 5** : Script Python indexation
- [ ] **Étape 6** : Tester indexation
- [ ] **Étape 7** : Optimiser index
- [ ] **Étape 8** : Documentation

### ⏳ Phase PROVE
- [ ] Backup vérifié
- [ ] Tables créées
- [ ] Fonctions testées
- [ ] Outils indexés
- [ ] Recherche fonctionne
- [ ] Métriques validées

---

## Plan Détaillé

### Étape 2 : Backup (5 min)
**Objectif** : Sauvegarder base AVANT modifications

**Commandes** :
```bash
mkdir -p backups/
docker exec alfa-postgres pg_dump -U alfa alfa > backups/backup_alfa_mcp_$(date +%Y%m%d_%H%M%S).sql
ls -lh backups/ | tail -1
```

**Preuve attendue** : Fichier backup créé (~XXX KB)

---

### Étape 3 : Schéma SQL (10 min)
**Objectif** : Tables `mcp_servers` et `mcp_tools`

**Fichier** : `alfa-dashboard/postgres/init/05-mcp-discovery.sql`

**Tables** :
- `rag.mcp_servers` (id, name, description, status, config)
- `rag.mcp_tools` (id, server_id, name, description, parameters, usage_count)

**Preuve attendue** : `\dt rag.*` montre 2 nouvelles tables

---

### Étape 4 : Fonctions Recherche (15 min)
**Objectif** : Fonctions SQL pour recherche outils

**Fonctions** :
- `rag.index_mcp_server()` - Indexer serveur
- `rag.index_mcp_tool()` - Indexer outil
- `rag.search_mcp_tools()` - Recherche fulltext
- `rag.search_mcp_tools_simple()` - Recherche simplifiée
- `rag.list_mcp_servers()` - Liste serveurs

**Preuve attendue** : `\df rag.*mcp*` montre 5 fonctions

---

### Étape 5 : Script Python (20 min)
**Objectif** : Script pour scanner et indexer outils MCP

**Fichier** : `scripts/index-mcp-tools.py`

**Logique** :
1. Lire serveurs MCP depuis docker/mcp-gateway
2. Parser outils disponibles
3. Insérer dans `rag.mcp_tools`

**Preuve attendue** : `SELECT COUNT(*) FROM rag.mcp_tools` > 100

---

### Étape 6 : Test Indexation (10 min)
**Objectif** : Vérifier outils indexés correctement

**Tests** :
```sql
SELECT * FROM rag.list_mcp_servers();
SELECT COUNT(*) FROM rag.mcp_tools;
SELECT * FROM rag.search_mcp_tools_simple('slack', 3);
```

**Preuve attendue** : Résultats pertinents

---

### Étape 7 : Optimisation Index (10 min)
**Objectif** : Index GIN pour performance

**Index** :
- GIN sur `to_tsvector(description)`
- B-tree sur `server_id`
- B-tree sur `usage_count`

**Preuve attendue** : `\di rag.*` montre nouveaux index

---

### Étape 8 : Documentation (15 min)
**Objectif** : Doc usage pour agents IA

**Fichier** : `docs/MCP-TOOL-DISCOVERY.md`

**Contenu** :
- Comment rechercher outils
- Exemples requêtes
- Métriques réduction tokens

**Preuve attendue** : Fichier créé, ~300 lignes

---

## Métriques Cibles

| Métrique | Avant | Après | Objectif |
|----------|-------|-------|----------|
| Tokens démarrage | ~50K+ | ~500 | 99% réduction |
| Serveurs indexés | 0 | 10+ | Tous actifs |
| Outils indexés | 0 | 125+ | Tous MCP |
| Précision recherche | N/A | 90%+ | High relevance |
| Temps recherche | N/A | <100ms | Fast |

---

## Preuves Attendues (PROVE)

### 1. Backup Créé
```bash
ls -lh backups/backup_alfa_mcp_*.sql
```

### 2. Tables Créées
```bash
docker exec alfa-postgres psql -U alfa -d alfa -c "\dt rag.*"
```

### 3. Fonctions Créées
```bash
docker exec alfa-postgres psql -U alfa -d alfa -c "\df rag.*mcp*"
```

### 4. Serveurs Indexés
```bash
docker exec alfa-postgres psql -U alfa -d alfa -c "SELECT * FROM rag.list_mcp_servers();"
```

### 5. Outils Indexés
```bash
docker exec alfa-postgres psql -U alfa -d alfa -c "SELECT COUNT(*) FROM rag.mcp_tools;"
```

### 6. Recherche Fonctionne
```bash
docker exec alfa-postgres psql -U alfa -d alfa -c "SELECT * FROM rag.search_mcp_tools_simple('slack message', 3);"
```

---

## Commits Git Prévus

1. `feat(mcp): create discovery schema (tables + functions)`
2. `feat(mcp): add indexation script for MCP tools`
3. `feat(mcp): optimize search with GIN indexes`
4. `docs(mcp): add tool discovery documentation`
5. `feat(mcp): complete tool discovery system`

---

## Rollback Plan

Si problème critique :
```bash
# Restaurer backup
docker exec -i alfa-postgres psql -U alfa alfa < backups/backup_alfa_mcp_XXXXXX.sql

# Ou supprimer tables
docker exec alfa-postgres psql -U alfa -d alfa -c "
DROP TABLE IF EXISTS rag.mcp_tools CASCADE;
DROP TABLE IF EXISTS rag.mcp_servers CASCADE;
"
```

---

## Règles Absolues

1. ✅ **BACKUP AVANT TOUT** - Étape 2 non négociable
2. ✅ **COMMITS FRÉQUENTS** - Après chaque étape réussie
3. ✅ **PROVE IT** - Montrer résultats commandes
4. ✅ **STOP SI ERREUR** - Ne pas continuer si échec
5. ✅ **PAS DE MOCK** - Vraies commandes uniquement

---

## Previous Missions

### Mission 3: CORE + RAG Architecture (2026-01-12)
**Status**: ✅ 100% COMPLÉTÉ

**Réalisations**:
- ✅ CORE.md créé (465 lignes)
- ✅ 7 documents ingérés RAG (59KB)
- ✅ 5 helper SQL functions
- ✅ 6 docs techniques supprimés (2,723 lignes)
- ✅ 5 commits Git

📁 Archive: Voir section "Previous Missions" dans version précédente

---

**🤖 ALFA Mission Tracker v2.0**
**Current**: MCP Tool Discovery 🔄
