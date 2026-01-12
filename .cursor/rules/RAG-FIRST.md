# 🔴 RÈGLE OBLIGATOIRE : RAG First

**Date de création**: 2026-01-12  
**Priorité**: P0 - Critique  
**Statut**: Active

---

## 📋 PRINCIPE FONDAMENTAL

**TOUJOURS chercher dans le RAG AVANT de demander des informations à l'utilisateur.**

Cette règle s'applique à **TOUS** les tokens, credentials, configurations, et informations de projet.

---

## ✅ OBLIGATOIRE AVANT DE DEMANDER

### 1. Tokens API / Credentials

**AVANT** de demander un token/credential à l'utilisateur :

1. ✅ **Chercher dans le RAG d'abord** :
   ```sql
   SELECT * FROM rag.search_fulltext('{service} API key token', 10);
   ```

2. ✅ **Lire les documents trouvés** :
   ```sql
   SELECT id, title, content_raw 
   FROM rag.documents 
   WHERE title ILIKE '%{service}%API%key%' 
      OR title ILIKE '%{service}%Credentials%'
   ORDER BY created_at DESC 
   LIMIT 5;
   ```

3. ✅ **Extraire le token/credential** du contenu

4. ❌ **Ne demander à l'utilisateur QUE si** :
   - Aucun résultat dans le RAG
   - Le token trouvé est expiré/invalide (vérifié par test)
   - L'utilisateur confirme explicitement qu'il faut régénérer

### 2. Configuration / URLs / Endpoints

**AVANT** de demander une configuration :

1. ✅ **Chercher dans le RAG** :
   ```sql
   SELECT * FROM rag.search_fulltext('{service} URL endpoint configuration', 10);
   ```

2. ✅ **Vérifier les fichiers de configuration** (`.env`, `docker-compose.yml`, etc.)

3. ❌ **Ne demander à l'utilisateur QUE si** :
   - Aucun résultat dans le RAG
   - Aucune configuration trouvée dans les fichiers

### 3. Documentation Projet

**AVANT** de demander des informations sur le projet :

1. ✅ **Chercher dans le RAG d'abord** :
   ```sql
   SELECT * FROM rag.search_fulltext('{question}', 10);
   ```

2. ✅ **Consulter la documentation** (`CORE.md`, `README.md`, etc.)

3. ❌ **Ne demander à l'utilisateur QUE si** :
   - Aucun résultat dans le RAG
   - Documentation non trouvée

---

## 🔧 FONCTIONS RAG DISPONIBLES

### Recherche Fulltext
```sql
SELECT * FROM rag.search_fulltext('query', 10);
```

### Recherche avec Filtres
```sql
SELECT * FROM rag.search_alfa('query', 10, category, priority);
```

### Recherche Hybride (Vector + Fulltext)
```sql
SELECT * FROM rag.search_hybrid(embedding, 'query', 10);
```

### Recherche MCP Tools
```sql
SELECT * FROM rag.search_mcp_tools_simple('query', 5);
```

---

## 📊 SERVICES À CHERCHER DANS LE RAG

Cette liste n'est **pas exhaustive** - chercher dans le RAG pour **TOUS** les services :

- ✅ n8n (API keys, credentials, URLs)
- ✅ PostgreSQL (credentials, connection strings)
- ✅ Redis (credentials, URLs)
- ✅ GitHub (tokens, credentials)
- ✅ Slack (tokens, webhooks)
- ✅ Docker (compose files, configurations)
- ✅ Traefik (configurations, URLs)
- ✅ Grafana (credentials, URLs)
- ✅ Prometheus (configurations, URLs)
- ✅ Etc. (TOUS les services du projet)

---

## 🎯 WORKFLOW OBLIGATOIRE

### Pour TOUT token/credential/configuration :

```
1. Chercher dans le RAG
   ↓
2. Résultat trouvé ?
   ├─ OUI → Utiliser le résultat
   │        ↓
   │     3. Tester si nécessaire
   │        ↓
   │     4. Fonctionne ?
   │        ├─ OUI → ✅ Utiliser
   │        └─ NON → Demander à l'utilisateur
   │
   └─ NON → Chercher dans fichiers de config
            ↓
           Résultat trouvé ?
           ├─ OUI → Utiliser
           └─ NON → Demander à l'utilisateur
```

---

## ❌ ANTI-PATTERNS À ÉVITER

### NE PAS FAIRE

❌ **Demander un token sans chercher dans le RAG**
```
User: "Je veux mettre à jour un workflow n8n"
AI: "Pouvez-vous me fournir le token API n8n ?"
→ ❌ ERREUR : N'a pas cherché dans le RAG d'abord
```

❌ **Supposer qu'un token n'existe pas**
```
AI: "Le token n8n n'existe pas, pouvez-vous le générer ?"
→ ❌ ERREUR : N'a pas vérifié dans le RAG
```

❌ **Ignorer le RAG pour des "raisons de sécurité"**
```
AI: "Pour des raisons de sécurité, je préfère que vous me donniez le token"
→ ❌ ERREUR : Le RAG EST la source de vérité pour les credentials
```

### FAIRE

✅ **Chercher dans le RAG d'abord**
```
User: "Je veux mettre à jour un workflow n8n"
AI: [Cherche dans le RAG]
AI: "J'ai trouvé un token n8n dans le RAG, je vais l'utiliser"
→ ✅ CORRECT
```

✅ **Documenter si un token est trouvé**
```
AI: "Token n8n trouvé dans le RAG (document: 'n8n API Key ALFA', id: xxx)"
→ ✅ CORRECT
```

✅ **Tester le token trouvé avant utilisation**
```
AI: "Token trouvé dans le RAG, testons-le..."
[Test du token]
AI: "Token valide, je l'utilise"
→ ✅ CORRECT
```

---

## 📝 EXEMPLE CONCRET

### ❌ MAUVAIS EXEMPLE

```
User: "Mets à jour le workflow iana-router"

AI: "Je dois mettre à jour le workflow via l'API n8n, mais j'ai besoin 
     d'un token API. Pouvez-vous me le fournir ?"
```

**Problème**: N'a pas cherché dans le RAG d'abord.

### ✅ BON EXEMPLE

```
User: "Mets à jour le workflow iana-router"

AI: [Cherche dans le RAG]
    SELECT * FROM rag.search_fulltext('n8n API key', 10);
    
AI: "Token n8n trouvé dans le RAG (document: 'n8n API Key ALFA').
     Je vais l'utiliser pour mettre à jour le workflow."
     
[Utilise le token trouvé]
```

---

## ✅ CHECKLIST AVANT DEMANDE

Avant de demander un token/credential/configuration à l'utilisateur :

- [ ] J'ai cherché dans le RAG avec `rag.search_fulltext()`
- [ ] J'ai vérifié les documents trouvés (`rag.documents`)
- [ ] J'ai cherché dans les fichiers de configuration (`.env`, `docker-compose.yml`, etc.)
- [ ] J'ai testé le token/credential trouvé (si applicable)
- [ ] Aucun résultat valide trouvé → Alors seulement demander à l'utilisateur

---

## 🔄 MAINTENANCE

**Cette règle doit être mise à jour si** :
- Nouveaux services sont ajoutés au projet
- Nouvelle structure RAG est mise en place
- Nouveaux patterns de recherche sont découverts

**Révision**: À chaque fois qu'une erreur "RAG First" est identifiée

---

## 📚 RÉFÉRENCES

- Schéma RAG : `alfa-dashboard/postgres/init/02-rag-schema.sql`
- Fonctions RAG : `alfa-dashboard/postgres/init/03-rag-functions.sql`
- Helpers RAG : `alfa-dashboard/postgres/init/04-rag-helpers.sql`
- Documentation CORE : `CORE.md`

---

**Créé suite à l'erreur identifiée le 2026-01-12** : Demande de régénération de token n8n sans avoir cherché dans le RAG d'abord.
