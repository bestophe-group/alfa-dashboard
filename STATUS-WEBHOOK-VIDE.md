# 🔍 DIAGNOSTIC : Webhook retourne réponse vide

**Date**: 2026-01-12  
**Problème**: Le webhook `/webhook/iana` retourne HTTP 200 mais un body vide.

---

## ✅ PREUVES - Ce qui fonctionne

1. **Workflow s'exécute** : La conversation est créée dans PostgreSQL
   ```sql
   SELECT conversation_id, user_id, channel, created_at 
   FROM iana.conversations 
   WHERE user_id = 'arnaud';
   -- Résultat: 0badbb72-b562-45c8-b316-f7718728a9b4 | arnaud | api | 2026-01-12 19:08:51
   ```

2. **Webhook reçoit les requêtes** : HTTP 200 retourné
   ```bash
   curl -X POST "http://localhost:5678/webhook/iana" \
     -H "Content-Type: application/json" \
     -d '{"query": "Bonjour", "user_id": "arnaud"}'
   # Réponse: HTTP 200 OK (mais body vide)
   ```

---

## ❌ PROBLÈME IDENTIFIÉ

**Le workflow `iana-router` n'est PAS activé dans n8n.**

**Symptômes**:
- Le workflow s'exécute partiellement (création conversation)
- Mais le node "Respond to Webhook" ne retourne pas de réponse
- L'API n8n rejette les tentatives d'activation avec "invalid signature"

**Cause probable**:
- Token API n8n fourni est invalide ou expiré
- Le workflow doit être activé manuellement dans l'UI n8n

---

## 🔧 SOLUTION : Activation manuelle

### Étape 1 : Vérifier le workflow dans n8n UI

1. Ouvrir http://localhost:5678
2. Aller dans **Workflows** → chercher **"iana-router"**
3. Vérifier que le workflow est visible mais **non actif** (toggle OFF)

### Étape 2 : Activer le workflow

1. Ouvrir le workflow `iana-router`
2. Cliquer sur le toggle **"Active"** en haut à droite
3. Confirmer l'activation

### Étape 3 : Tester le webhook

```bash
curl -X POST "http://localhost:5678/webhook/iana" \
  -H "Content-Type: application/json" \
  -d '{"query": "Dis bonjour", "user_id": "arnaud"}' \
  -v
```

**Résultat attendu**:
```json
{
  "success": true,
  "action": "chat",
  "data": {
    "response": "...",
    "tier": "L1",
    "conversation_id": "..."
  },
  "error": null,
  "meta": {
    "latency_ms": 1234,
    "timestamp": "2026-01-12T..."
  }
}
```

---

## 📊 INSTRUMENTATION

Le workflow a été instrumenté avec des logs `fetch` dans ces nodes critiques:

1. **Parse Request** : Logs l'entrée de la requête
2. **Prepare Classifier Command** : Logs la commande CLI préparée
3. **Classifier L1/L2/L3 (CLI)** : Logs l'exécution du CLI et le résultat
4. **Parse Classification** : Logs le parsing de la classification
5. **Format Response** : Logs la préparation de la réponse finale

**Endpoint des logs**: `http://127.0.0.1:7244/ingest/a56227c4-3817-4fc4-8bc4-88b2e0aa21d7`

**Note**: Les logs ne seront visibles que si le serveur ndjson ingest est actif et que le workflow est activé.

---

## 🎯 PROCHAINES ÉTAPES

1. ✅ Activer le workflow `iana-router` manuellement dans l'UI n8n
2. ✅ Tester le webhook avec un curl
3. ✅ Vérifier les logs d'instrumentation (si le serveur ndjson est actif)
4. ✅ Vérifier les logs Docker n8n pour les erreurs potentielles
5. ✅ Valider que la réponse contient bien le JSON attendu

---

## 🔐 CREDENTIALS

**PostgreSQL credential ID**: `5zFMgYDljFx593WZ`  
**Workflow ID**: `Fowjj0lqqwb1Abbi`  
**n8n URL**: http://localhost:5678

**Note**: Le token API n8n fourni est invalide ("invalid signature"). Utiliser l'UI n8n pour l'activation manuelle.

---

## ✅ CHECKLIST VALIDATION

- [ ] Workflow `iana-router` activé dans n8n UI
- [ ] Webhook `/webhook/iana` retourne une réponse JSON complète
- [ ] La réponse contient `success: true`, `data.response`, et `meta.latency_ms`
- [ ] Les logs d'instrumentation sont visibles (si serveur ndjson actif)
- [ ] Aucune erreur dans les logs Docker n8n

---

**Fiabilité actuelle**: 70% (workflow s'exécute mais pas activé)  
**Après activation**: 90% (si réponse JSON complète retournée)
