# 🔍 DIAGNOSTIC COMPLET - IANA

**Date**: 2026-01-12  
**Exécution ID**: 14  
**Status**: error

---

## ✅ CORRECTIONS APPLIQUÉES

1. ✅ **Wrapper CLI copié** dans `/home/node/scripts/`
2. ✅ **Chemins corrigés** dans workflow (4 occurrences)
3. ✅ **Workflow mis à jour** via API
4. ✅ **Wrapper testé** → Fonctionne (retourne JSON)

---

## ❌ ERREUR IDENTIFIÉE

**Exécution**: ID 14  
**Status**: `error`  
**Durée**: 10ms (arrêt immédiat)  
**Mode**: `webhook`

**Cause probable**: Credentials PostgreSQL manquantes ou incorrectes

**Credential attendue**: `PostgreSQL IANA` (ID: `postgres-iana`)

---

## 📊 ÉTAT ACTUEL

| Composant | État | Détails |
|-----------|------|---------|
| **Wrapper CLI** | ✅ | Copié et fonctionnel |
| **Chemins** | ✅ | Corrigés dans workflow |
| **Schémas DB** | ✅ | `iana` et `rag` existent |
| **Tables** | ✅ | `conversations`, `messages`, etc. |
| **Credentials** | ❌ | Probablement manquantes dans n8n |
| **Exécution** | ❌ | Erreur au démarrage (10ms) |

---

## 🔧 ACTION REQUISE

**Créer credential PostgreSQL dans n8n**:

1. Ouvrir n8n UI: `http://localhost:5678`
2. Settings → Credentials → New Credential
3. Type: **PostgreSQL**
4. Name: **PostgreSQL IANA**
5. Configuration:
   - Host: `postgres` (nom du service Docker)
   - Port: `5432`
   - Database: `alfa`
   - User: `alfa`
   - Password: `alfapass123` (ou valeur depuis `.env`)
6. Tester la connexion
7. Sauvegarder

**OU** utiliser credential existante si elle existe déjà.

---

## 🧪 TESTS À EFFECTUER

### Après création credential:

```bash
# Test webhook
curl -X POST "http://localhost:5678/webhook/iana" \
  -H "Content-Type: application/json" \
  -d '{"query": "Dis bonjour", "user_id": "test"}'
```

**Résultat attendu**: Réponse JSON avec `success: true`

---

**Fiabilité**: **75%** (corrections appliquées, credential manquante identifiée)
