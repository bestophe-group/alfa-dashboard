# ALFA RAG Implementation - Phase 4: BUILD

**Date de début**: 2026-01-12
**Status**: 🔄 EN COURS
**Méthode**: INTAKE → AUDIT → PLAN → BUILD → PROVE

---

## 📋 CONTEXTE VÉRIFIÉ

| Élément | État |
|---------|------|
| PostgreSQL | ✅ alfa-postgres, postgres:16-alpine, healthy |
| Extensions actuelles | ✅ plpgsql, uuid-ossp |
| pgvector | ❌ NON DISPONIBLE (à installer) |
| Schéma rag | ❌ N'EXISTE PAS (à créer) |
| n8n | ✅ Fonctionnel, 55 workflows |
| Chemin projet | /Users/arnaud/Documents/ALFA-Agent-Method/alfa-dashboard |

---

## 🎯 CHECKLIST BUILD - Phase 4

### ✅ Étape 1 : Backup préventif (OBLIGATOIRE)
**Status**: ⏸️ EN ATTENTE
**Commande**:
```bash
mkdir -p backups
docker exec alfa-postgres pg_dump -U alfa alfa > backups/backup_alfa_$(date +%Y%m%d_%H%M%S).sql
```
**Commit attendu**: `chore: backup before RAG implementation`
**Preuve requise**: Fichier backup créé avec taille > 0

---

### ⏸️ Étape 2 : Créer postgres/Dockerfile
**Status**: ⏸️ EN ATTENTE
**Fichier**: `postgres/Dockerfile`
**Contenu**: PostgreSQL 16 + pgvector v0.7.4
**Commit attendu**: `feat(postgres): add Dockerfile with pgvector`
**Preuve requise**: Fichier Dockerfile créé

---

### ⏸️ Étape 3 : Modifier docker-compose.yml
**Status**: ⏸️ EN ATTENTE
**Modification**: Ligne 63 - `image: postgres:16-alpine` → `build: ./postgres`
**Commit attendu**: `feat(postgres): switch to custom build with pgvector`
**Preuve requise**: Git diff montrant la modification

---

### ⏸️ Étape 4 : Build et restart PostgreSQL
**Status**: ⏸️ EN ATTENTE
**Commandes**:
```bash
docker compose build postgres
docker compose up -d postgres
docker exec alfa-postgres pg_isready -U alfa
```
**Commit attendu**: (inclus dans étape 3)
**Preuve requise**: Container healthy, pg_isready = accepting connections

---

### ⏸️ Étape 5 : Vérifier pgvector disponible
**Status**: ⏸️ EN ATTENTE
**Commande**:
```bash
docker exec alfa-postgres psql -U alfa -d alfa -c "SELECT * FROM pg_available_extensions WHERE name = 'vector';"
```
**Critère de succès**: Extension 'vector' listée
**⚠️ STOP si pgvector pas disponible**

---

### ⏸️ Étape 6 : Créer schéma RAG
**Status**: ⏸️ EN ATTENTE
**Actions**:
1. Activer extension vector
2. Créer schéma rag
3. Créer table documents
4. Créer table chunks
5. Créer table embeddings
6. Créer index HNSW pour embeddings
7. Créer index fulltext pour chunks

**Commit attendu**: `feat(rag): create schema with documents, chunks, embeddings tables`
**Preuve requise**: `\dt rag.*` montre 3 tables

---

### ⏸️ Étape 7 : Créer fonctions SQL
**Status**: ⏸️ EN ATTENTE
**Fonctions à créer**:
- [ ] `rag.ingest_document()` - Ingestion avec hash dédoublonnage
- [ ] `rag.chunk_document()` - Découpage avec overlap
- [ ] `rag.store_embedding()` - Stockage vecteur
- [ ] `rag.search_vector()` - Recherche cosine similarity
- [ ] `rag.search_fulltext()` - Recherche FTS français
- [ ] `rag.search_hybrid()` - Combinaison vector + fulltext

**Commit attendu**: `feat(rag): create search functions`
**Preuve requise**: 6 fonctions listées dans `\df rag.*`

---

### ⏸️ Étape 8 : Test de validation
**Status**: ⏸️ EN ATTENTE
**Test**:
```sql
SELECT rag.ingest_document('Test ALFA', 'La méthode ALFA prévient le désalignement.', 'markdown');
SELECT id, title, status FROM rag.documents;
```
**Commit attendu**: `test(rag): validate basic ingestion`
**Preuve requise**: Document inséré visible dans la table

---

### ⏸️ Étape 9 : Vérification finale (PROVE)
**Status**: ⏸️ EN ATTENTE
**Vérifications**:
```bash
# Extensions
docker exec alfa-postgres psql -U alfa -d alfa -c "SELECT extname FROM pg_extension WHERE extname = 'vector';"

# Tables
docker exec alfa-postgres psql -U alfa -d alfa -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'rag';"

# Fonctions
docker exec alfa-postgres psql -U alfa -d alfa -c "SELECT routine_name FROM information_schema.routines WHERE routine_schema = 'rag';"
```
**Preuve requise**:
- ✅ Extension vector activée
- ✅ 3 tables RAG créées
- ✅ 6 fonctions RAG créées

---

## 📊 PROGRESSION

| Phase | Étapes | Complétées | % |
|-------|--------|------------|---|
| BUILD | 9 | 0 | 0% |

---

## 🚨 RÈGLES ABSOLUES

1. ✅ **BACKUP AVANT TOUT** - Étape 1 non négociable
2. ✅ **COMMITS FRÉQUENTS** - Après chaque étape réussie
3. ✅ **PROVE IT** - Montrer les résultats des commandes, pas "ça devrait marcher"
4. ✅ **STOP SI ERREUR** - Ne pas continuer si une étape échoue
5. ✅ **PAS DE MOCK** - Utiliser les vraies commandes docker

---

## 🔙 ROLLBACK EN CAS DE PROBLÈME

```bash
# Restaurer docker-compose.yml
cd /Users/arnaud/Documents/ALFA-Agent-Method/alfa-dashboard
cp docker-compose.yml.backup docker-compose.yml
docker compose up -d postgres

# Restaurer données
docker exec -i alfa-postgres psql -U alfa alfa < backups/backup_alfa_XXXXXX.sql
```

---

## 📝 JOURNAL D'EXÉCUTION

### 2026-01-12 - Initialisation
- ✅ Fichier CURRENT.md créé
- ⏸️ En attente : Backup base de données

---

**🤖 ALFA RAG Implementation Tracker v1.0**

**Méthode**: INTAKE → AUDIT → PLAN → BUILD → PROVE
