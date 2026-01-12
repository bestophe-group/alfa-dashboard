# ✅ SOLUTION : Utiliser le RAG pour les tokens n8n

**Date**: 2026-01-12  
**Problème**: Les tokens n8n doivent être recherchés dans le RAG au lieu de demander leur régénération.

---

## 🔍 CORRECTION APPROCHE

L'utilisateur a raison : **les tokens sont censés être dans le RAG** et je devrais les rechercher au lieu de demander leur régénération.

### ❌ Approche incorrecte précédente

1. Demander à l'utilisateur de régénérer un token API n8n
2. Utiliser un token fourni directement par l'utilisateur
3. Ne pas chercher dans le RAG d'abord

### ✅ Approche correcte (RAG First)

1. **Toujours chercher dans le RAG d'abord** pour les tokens/credentials
2. Utiliser `rag.search_fulltext()` ou `rag.search_alfa()` pour trouver les tokens
3. Ne demander la régénération que si le token n'existe pas dans le RAG

---

## 🔧 FONCTIONS RAG DISPONIBLES

D'après le schéma PostgreSQL :

```sql
-- Recherche fulltext dans le RAG
SELECT * FROM rag.search_fulltext('n8n API key', 10);

-- Recherche avec filtres (catégorie, priorité)
SELECT * FROM rag.search_alfa('n8n API key', 10, NULL, NULL);

-- Recherche hybride (vector + fulltext)
SELECT * FROM rag.search_hybrid(embedding, 'n8n API key', 10);
```

---

## 📝 PROTOCOLE CORRECT

### Avant de demander un token

1. ✅ **Chercher dans le RAG d'abord** :
   ```sql
   SELECT * FROM rag.search_fulltext('n8n API key token', 10);
   ```

2. ✅ **Vérifier les documents récents** :
   ```sql
   SELECT id, title, source_type, LEFT(content_raw, 200) 
   FROM rag.documents 
   WHERE content_raw ILIKE '%n8n%' 
     AND (content_raw ILIKE '%API%key%' OR content_raw ILIKE '%token%')
   ORDER BY created_at DESC 
   LIMIT 10;
   ```

3. ❌ **Ne demander la régénération que si** :
   - Aucun résultat dans le RAG
   - Le token trouvé est expiré/invalide
   - L'utilisateur confirme explicitement qu'il faut régénérer

---

## 🎯 PRINCIPE "RAG FIRST"

**Toujours consulter le RAG avant de demander des informations à l'utilisateur.**

Cela s'applique à :
- ✅ Tokens API (n8n, GitHub, Slack, etc.)
- ✅ Credentials (PostgreSQL, Redis, etc.)
- ✅ Configuration (URLs, endpoints, etc.)
- ✅ Documentation projet
- ✅ Historique des décisions

---

## 📝 PROCHAINES ÉTAPES

1. ✅ **Corriger mon approche** : Chercher dans le RAG d'abord
2. ✅ **Utiliser les fonctions RAG** : `rag.search_fulltext()` ou `rag.search_alfa()`
3. ✅ **Documenter les tokens trouvés** : Si un token est trouvé, le réutiliser
4. ✅ **Enregistrer les nouveaux tokens** : Si un token est généré, l'ingérer dans le RAG

---

**Références**:
- Schéma RAG : `alfa-dashboard/postgres/init/02-rag-schema.sql`
- Fonctions RAG : `alfa-dashboard/postgres/init/03-rag-functions.sql`
- Helpers RAG : `alfa-dashboard/postgres/init/04-rag-helpers.sql`
