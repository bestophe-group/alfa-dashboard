# ✅ SYSTÈME "RAG First" - Mise en place complète

**Date**: 2026-01-12  
**Objectif**: Éviter de demander des tokens/credentials à l'utilisateur sans avoir cherché dans le RAG d'abord.

---

## ✅ ÉLÉMENTS MIS EN PLACE

### 1. Règle permanente (`.cursor/rules/RAG-FIRST.md`)

**Contenu**:
- Principe fondamental : "RAG First"
- Workflow obligatoire pour tokens/credentials/configurations
- Fonctions RAG disponibles
- Liste des services à chercher
- Anti-patterns à éviter
- Exemples concrets (bon vs mauvais)
- Checklist avant demande

**Statut**: ✅ Créé

---

### 2. Documentation dans CORE.md

**Modification**: Ajout de la règle "RAG First" dans la section "CAPACITÉS RAG + MCP"

**Localisation**: `CORE.md` (ligne ~125)

**Statut**: ✅ Modifié

---

### 3. Règle dans .cursorrules

**Modification**: Ajout de la règle "RAG First" dans le fichier `.cursorrules`

**Localisation**: `.cursorrules` (section "RÈGLE RAG FIRST")

**Statut**: ✅ Modifié

**Note**: Cette règle est chargée automatiquement par Cursor

---

### 4. Script utilitaire (`scripts/check-rag-first.sh`)

**Usage**:
```bash
./scripts/check-rag-first.sh "n8n API key"
```

**Fonction**: Recherche dans le RAG avant de demander un token/credential

**Statut**: ✅ Créé et exécutable

---

## 📋 PRINCIPE "RAG First"

**TOUJOURS chercher dans le RAG AVANT de demander des informations à l'utilisateur.**

### Workflow obligatoire

```
1. Chercher dans le RAG
   ↓
2. Résultat trouvé ?
   ├─ OUI → Utiliser le résultat (tester si nécessaire)
   └─ NON → Chercher dans fichiers de config
            ↓
           Résultat trouvé ?
           ├─ OUI → Utiliser
           └─ NON → Demander à l'utilisateur
```

---

## 🔧 UTILISATION

### Pour les tokens/credentials

**AVANT** de demander un token à l'utilisateur :

1. ✅ Chercher dans le RAG :
   ```sql
   SELECT * FROM rag.search_fulltext('n8n API key', 10);
   ```

2. ✅ Vérifier les fichiers de configuration (`.env`, `docker-compose.yml`)

3. ❌ Ne demander QUE si aucun résultat valide trouvé

### Services concernés

- n8n (API keys, credentials, URLs)
- PostgreSQL (credentials, connection strings)
- Redis (credentials, URLs)
- GitHub (tokens, credentials)
- Slack (tokens, webhooks)
- Docker (compose files, configurations)
- Etc. (TOUS les services du projet)

---

## ✅ CHECKLIST AVANT DEMANDE

Avant de demander un token/credential/configuration à l'utilisateur :

- [ ] J'ai cherché dans le RAG avec `rag.search_fulltext()`
- [ ] J'ai vérifié les documents trouvés (`rag.documents`)
- [ ] J'ai cherché dans les fichiers de configuration
- [ ] J'ai testé le token/credential trouvé (si applicable)
- [ ] Aucun résultat valide trouvé → Alors seulement demander

---

## 📚 FICHIERS CRÉÉS/MODIFIÉS

1. ✅ `.cursor/rules/RAG-FIRST.md` - Règle permanente (nouveau)
2. ✅ `.cursorrules` - Règle ajoutée (modifié)
3. ✅ `CORE.md` - Documentation mise à jour (modifié)
4. ✅ `scripts/check-rag-first.sh` - Script utilitaire (nouveau)
5. ✅ `MISE-EN-PLACE-RAG-FIRST.md` - Documentation (nouveau)
6. ✅ `SYSTEME-RAG-FIRST-COMPLET.md` - Ce document (nouveau)

---

## 🎯 RÉSULTAT ATTENDU

**À partir de maintenant** :

1. ✅ **Je chercherai TOUJOURS dans le RAG d'abord** pour tokens/credentials/configurations
2. ✅ **Je documenterai mes recherches** dans le RAG
3. ✅ **Je ne demanderai à l'utilisateur QUE si** aucun résultat valide trouvé
4. ✅ **Je testerai les tokens trouvés** avant utilisation

---

## 🔄 MAINTENANCE

**Cette règle doit être respectée pour** :
- ✅ Tous les futurs tokens/credentials
- ✅ Toutes les configurations
- ✅ Toutes les informations de projet

**Révision**: À chaque fois qu'une erreur "RAG First" est identifiée

---

## 📝 VALIDATION

**Test effectué** :
```bash
./scripts/check-rag-first.sh "n8n API key"
```

**Résultat**: ✅ Script fonctionnel

---

**Créé suite à l'erreur identifiée le 2026-01-12** : Demande de régénération de token n8n sans avoir cherché dans le RAG d'abord.

**Système mis en place**: ✅ Complet
