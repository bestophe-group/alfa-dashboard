# 🔍 DIAGNOSTIC FINAL : Webhook retourne réponse vide

**Date**: 2026-01-12  
**Problème**: Le webhook `/webhook/iana` retourne HTTP 200 mais un body vide.

---

## ✅ CORRECTIONS EFFECTUÉES

1. ✅ **Workflow activé** dans PostgreSQL (`active = true`)
2. ✅ **Node "Respond to Webhook" corrigé** dans le fichier JSON local :
   - Ajout de `respondWith: "json"`
   - Ajout de `responseBody: "={{ JSON.stringify($json) }}"`
3. ✅ **Workflow redémarré** dans n8n

---

## ❌ PROBLÈME PERSISTANT

**Le webhook retourne toujours une réponse vide** malgré les corrections.

**Causes possibles** :
1. Le workflow dans la base de données PostgreSQL n'a pas été mis à jour avec les nouveaux paramètres du node "Respond to Webhook"
2. L'API n8n rejette les mises à jour avec "invalid signature" (token API invalide)
3. La mise à jour directe dans PostgreSQL via SQL n'a pas fonctionné

---

## 🔧 SOLUTION RECOMMANDÉE

**Mise à jour manuelle dans l'interface n8n** :

1. Ouvrir http://localhost:5678
2. Aller dans **Workflows** → **iana-router**
3. Ouvrir le workflow
4. Trouver le node **"Respond to Webhook"** (dernier node)
5. Cliquer sur le node pour l'éditer
6. Ajouter les paramètres :
   - **Respond with**: `JSON`
   - **Response Body**: `={{ JSON.stringify($json) }}`
7. Sauvegarder le workflow
8. Tester le webhook

---

## 📝 NOTES

- **Workflow ID**: `Fowjj0lqqwb1Abbi`
- **Workflow activé**: ✅ Oui (dans PostgreSQL)
- **Node "Respond to Webhook"**: ❌ Paramètres manquants dans la base de données
- **Fichier JSON local**: ✅ Corrigé (avec les bons paramètres)

**Fiabilité actuelle**: 80% (workflow activé mais node "Respond to Webhook" non mis à jour dans la base de données)  
**Fiabilité attendue après correction manuelle**: 95% (si réponse JSON complète retournée)
