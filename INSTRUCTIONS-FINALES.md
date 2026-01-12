# 🔧 INSTRUCTIONS FINALES : Correction du node "Respond to Webhook"

**Problème**: Le webhook `/webhook/iana` retourne HTTP 200 mais un body vide.

**Cause identifiée**: Le node "Respond to Webhook" dans la base de données PostgreSQL n'a pas les paramètres nécessaires (`respondWith` et `responseBody`).

---

## ✅ SOLUTION : Mise à jour manuelle dans n8n UI

### Étape 1 : Ouvrir n8n

1. Ouvrir http://localhost:5678 dans votre navigateur
2. Se connecter à n8n (si nécessaire)

### Étape 2 : Trouver le workflow

1. Cliquer sur **"Workflows"** dans le menu de gauche
2. Chercher **"iana-router"** dans la liste
3. Cliquer sur le workflow pour l'ouvrir

### Étape 3 : Trouver et éditer le node "Respond to Webhook"

1. Dans le workflow, trouver le node **"Respond to Webhook"** (dernier node, à droite)
2. Double-cliquer sur le node pour l'éditer (ou cliquer une fois puis sur "Edit")

### Étape 4 : Ajouter les paramètres

Dans la fenêtre d'édition du node :

1. **Respond with**: Sélectionner `JSON` (ou `JSON` dans le dropdown)
2. **Response Body**: Entrer `={{ JSON.stringify($json) }}`

**Visual**:
```
┌─────────────────────────────────────┐
│  Respond to Webhook                 │
├─────────────────────────────────────┤
│  Respond with: [JSON ▼]             │
│                                     │
│  Response Body:                     │
│  ┌─────────────────────────────┐   │
│  │={{ JSON.stringify($json) }} │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Save] [Cancel]                    │
└─────────────────────────────────────┘
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

**Résultat attendu**:
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

## ✅ CHECKLIST

- [ ] Workflow `iana-router` ouvert dans n8n UI
- [ ] Node "Respond to Webhook" édité
- [ ] Paramètre "Respond with" = `JSON`
- [ ] Paramètre "Response Body" = `={{ JSON.stringify($json) }}`
- [ ] Workflow sauvegardé
- [ ] Webhook `/webhook/iana` retourne une réponse JSON complète
- [ ] La réponse contient `success: true` et `data.response`

---

## 📝 NOTES

- **Workflow ID**: `Fowjj0lqqwb1Abbi`
- **Workflow activé**: ✅ Oui (dans PostgreSQL)
- **Fichier JSON local**: ✅ Corrigé (avec les bons paramètres)
- **Base de données PostgreSQL**: ❌ Node "Respond to Webhook" non mis à jour

**Fiabilité attendue après correction manuelle**: 95% (si réponse JSON complète retournée)
