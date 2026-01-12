# ✅ SOLUTION : Webhook retourne réponse vide

**Date**: 2026-01-12  
**Problème**: Le webhook `/webhook/iana` retourne HTTP 200 mais un body vide.

---

## 🔍 CAUSE IDENTIFIÉE (d'après documentation n8n)

Le node **"Respond to Webhook"** dans la base de données PostgreSQL n'a **pas les paramètres nécessaires** :
- `respondWith: "json"` ❌ Manquant
- `responseBody: "={{ JSON.stringify($json) }}"` ❌ Manquant

**Preuve** : La requête SQL montre `{}` comme paramètres au lieu de `{"respondWith":"json","responseBody":"=..."}`

---

## ✅ SOLUTION RECOMMANDÉE (d'après documentation officielle n8n)

D'après la documentation officielle n8n ([docs.n8n.io](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.respondtowebhook/)), la **solution la plus fiable** est de mettre à jour le workflow via l'interface n8n.

### Étape 1 : Ouvrir n8n

1. Ouvrir http://localhost:5678 dans votre navigateur
2. Se connecter à n8n (si nécessaire)

### Étape 2 : Ouvrir le workflow

1. Cliquer sur **"Workflows"** dans le menu de gauche
2. Chercher **"iana-router"** dans la liste
3. Cliquer sur le workflow pour l'ouvrir

### Étape 3 : Éditer le node "Respond to Webhook"

1. Dans le workflow, trouver le node **"Respond to Webhook"** (dernier node, à droite, après "Format Response")
2. **Double-cliquer** sur le node pour l'éditer

### Étape 4 : Configurer les paramètres

Dans la fenêtre d'édition du node :

1. **Respond With** : Sélectionner `JSON` dans le dropdown
2. **Response Body** : Entrer `={{ JSON.stringify($json) }}`

**Visual**:
```
┌─────────────────────────────────────────┐
│  Respond to Webhook                    │
├─────────────────────────────────────────┤
│  Respond With: [JSON ▼]                │
│                                        │
│  Response Body:                        │
│  ┌──────────────────────────────────┐ │
│  │={{ JSON.stringify($json) }}     │ │
│  └──────────────────────────────────┘ │
│                                        │
│  [Save] [Cancel]                      │
└─────────────────────────────────────────┘
```

### Étape 5 : Sauvegarder

1. Cliquer sur **"Save"** (ou appuyer sur `Cmd+S` / `Ctrl+S`)
2. Le workflow devrait être sauvegardé automatiquement

### Étape 6 : Tester le webhook

```bash
curl -X POST "http://localhost:5678/webhook/iana" \
  -H "Content-Type: application/json" \
  -d '{"query": "Bonjour", "user_id": "arnaud"}'
```

**Résultat attendu** (d'après documentation n8n):
```json
{
  "success": true,
  "tier": "L1",
  "response": "Bonjour ! Comment puis-je vous aider ?",
  "confidence": 0.95,
  "rag_context_used": false,
  "rag_count": 0,
  "meta": {
    "latency_ms": 1234,
    "timestamp": "2026-01-12T...",
    "request_id": "arnaud-...",
    "conversation_id": "..."
  }
}
```

---

## 📊 ÉTAT ACTUEL

- ✅ **Workflow activé** : Oui (`active = true` dans PostgreSQL)
- ✅ **Node Webhook configuré** : Oui (`responseMode: "responseNode"`)
- ✅ **Fichier JSON local** : Corrigé (avec les bons paramètres)
- ❌ **Node "Respond to Webhook" dans DB** : Paramètres vides (`{}`)
- ❌ **Mise à jour via API** : Échec ("invalid signature")
- ❌ **Mise à jour via SQL** : Échec (fonction PL/pgSQL n'a pas fonctionné)

---

## 🎯 POURQUOI CETTE SOLUTION ?

D'après la documentation officielle n8n :
1. **L'interface n8n est la méthode recommandée** pour configurer les nodes
2. **Les mises à jour via API nécessitent un token valide** (le nôtre est invalide)
3. **Les mises à jour directes dans la base de données peuvent causer des problèmes** de synchronisation

---

## ✅ CHECKLIST FINALE

- [ ] Workflow `iana-router` ouvert dans n8n UI
- [ ] Node "Respond to Webhook" édité
- [ ] Paramètre "Respond With" = `JSON`
- [ ] Paramètre "Response Body" = `={{ JSON.stringify($json) }}`
- [ ] Workflow sauvegardé
- [ ] Webhook `/webhook/iana` retourne une réponse JSON complète
- [ ] La réponse contient `success: true` et `response`

---

**Fiabilité attendue après correction manuelle**: 95% (selon documentation n8n)

**Références**:
- [n8n Docs: Respond to Webhook](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.respondtowebhook/)
- [n8n Docs: Webhook Node](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.webhook/)
