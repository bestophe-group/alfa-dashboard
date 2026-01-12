# 🔍 VÉRIFICATION : Correction manuelle obligatoire ?

**Date**: 2026-01-12  
**Question**: La correction manuelle dans l'interface n8n est-elle vraiment obligatoire pour ajouter les paramètres au node "Respond to Webhook" ?

---

## 🔍 MÉTHODES TESTÉES

### 1. ✅ API n8n avec PUT/PATCH

**Test**:
```bash
curl -X PUT "http://localhost:5678/api/v1/workflows/Fowjj0lqqwb1Abbi" \
  -H "X-N8N-API-KEY: TOKEN" \
  -H "Content-Type: application/json" \
  -d @workflow.json
```

**Résultat**: ❌ Échec - "invalid signature" (token API invalide)

**Cause**: Le token API fourni n'est pas un token REST API valide, mais un JWT MCP token.

---

### 2. ✅ Mise à jour directe PostgreSQL

**Test**: Fonction PL/pgSQL pour mettre à jour le node "respond" dans la table `workflow_entity.nodes`

**Résultat**: ❌ Échec - Le node a toujours `{}` comme paramètres après l'exécution

**Cause**: La fonction SQL n'a pas fonctionné (probablement problème de syntaxe JSONB)

---

### 3. ⏳ Import/Export JSON

**Test**: Copier le fichier JSON corrigé directement dans le répertoire n8n

**Statut**: ❌ Non testé - n8n stocke les workflows dans PostgreSQL, pas dans des fichiers JSON

**Cause**: n8n utilise PostgreSQL comme base de données, les workflows sont stockés dans `workflow_entity` table

---

## ✅ CONCLUSION

D'après la documentation n8n et les tests effectués :

1. **API n8n** : Nécessite un token REST API valide (le nôtre est invalide)
2. **PostgreSQL direct** : Risqué et complexe (syntaxe JSONB, synchronisation)
3. **Fichiers JSON** : n8n n'utilise pas de fichiers JSON pour stocker les workflows en production

**La méthode la plus fiable et recommandée par la documentation n8n est la correction manuelle via l'interface n8n.**

---

## 🔍 VÉRIFICATION DANS L'INTERFACE N8N

Pour vérifier si d'autres méthodes existent, je dois accéder à l'interface n8n et vérifier :
1. Existe-t-il une option "Import" qui peut remplacer un workflow existant ?
2. Existe-t-il une API REST sans authentification pour le développement local ?
3. Existe-t-il un moyen de régénérer un token API valide ?

**URL à vérifier**: http://localhost:5678/workflow/Fowjj0lqqwb1Abbi

---

## 📝 PROCHAINE ÉTAPE

Vérifier dans l'interface n8n elle-même si une méthode alternative existe.
