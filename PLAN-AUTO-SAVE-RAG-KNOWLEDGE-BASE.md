# Plan : Système d'Enregistrement Automatique RAG Knowledge Base

**Date**: 2026-01-12  
**Objectif**: Mettre en place un système pour enregistrer systématiquement toutes les données fournies par l'utilisateur dans le RAG

---

## 📋 CONTEXTE

L'utilisateur veut que **TOUTES les données qu'il fournit** soient enregistrées automatiquement dans le RAG pour servir de Knowledge Base.

**Exigence**: Enregistrement **SYSTÉMATIQUE** de toutes les données utilisateur.

---

## 🎯 STRATÉGIE

### Option 1: Workflow n8n (RECOMMANDÉ - Conforme ALFA)

**Principe**: Créer un workflow n8n `iana-rag-auto-save` qui peut être appelé pour enregistrer des données.

**Avantages**:
- ✅ Conforme aux règles ALFA (tout via workflows)
- ✅ Traçable (logs dans `iana.operation_logs`)
- ✅ Réutilisable depuis d'autres workflows
- ✅ Format standardisé

**Structure**:
- **Endpoint**: `/webhook/rag/auto-save`
- **Method**: POST
- **Format request**: 
  ```json
  {
    "action": "save",
    "data": {
      "title": "Titre du document",
      "content": "Contenu à enregistrer",
      "category": "conversation|credentials|config|other",
      "metadata": {}
    },
    "user_id": "string"
  }
  ```

**Actions**:
- `save` - Enregistrer données dans RAG via `rag.ingest_document()`

### Option 2: Script Python Direct (Alternative)

**Principe**: Script Python qui utilise directement PostgreSQL pour enregistrer dans RAG.

**Avantages**:
- ✅ Simple et direct
- ✅ Utilisable depuis terminal

**Inconvénients**:
- ❌ Non conforme aux règles ALFA (pas via workflow)
- ❌ Pas de traçabilité standardisée

---

## 🔧 IMPLÉMENTATION RECOMMANDÉE

### Solution: Workflow n8n `iana-rag-auto-save`

**Architecture**:
```
Webhook → Validate Input → Prepare Data → PostgreSQL (rag.ingest_document) → Log → Response
```

**Nodes**:
1. **Webhook** (POST `/webhook/rag/auto-save`)
2. **Validate Input** (Code) - Vérifier action, data, user_id
3. **Prepare Data** (Code) - Formater données pour `rag.ingest_document()`
4. **Ingest Document** (PostgreSQL) - Appeler `rag.ingest_document()`
5. **Log Operation** (PostgreSQL) - Log dans `iana.operation_logs`
6. **Format Response** (Code) - Formater réponse standard
7. **Respond to Webhook** (Respond) - Retourner réponse

**Utilisation depuis Cursor/Claude**:
- Appel HTTP POST vers `/webhook/rag/auto-save`
- Format standardisé avec metadata

---

## 📝 DÉTAILS TECHNIQUES

### Fonction PostgreSQL Utilisée

```sql
SELECT rag.ingest_document(
  $1::text,  -- title
  $2::text,  -- content
  $3::text,  -- source_type (default: 'markdown')
  $4::text,  -- source_path (optional)
  $5::jsonb, -- metadata
  $6::text,  -- project (default: 'ALFA')
  $7::text,  -- category
  $8::text   -- priority (default: 'P2')
) AS document_id;
```

### Format Metadata Recommandé

```json
{
  "source": "cursor_conversation",
  "user_id": "arnaud",
  "session_id": "session-uuid",
  "timestamp": "2026-01-12T...",
  "type": "user_data|credentials|config|conversation",
  "tags": ["knowledge-base", "auto-save"]
}
```

---

## 🔄 WORKFLOW D'UTILISATION

### Depuis Cursor/Claude

**Après réception de données utilisateur**:
1. Formater données (title, content, category, metadata)
2. Appel HTTP POST vers `/webhook/rag/auto-save`
3. Vérifier réponse (success/error)
4. Continuer traitement normal

**Exemple**:
```javascript
// Après réception de données utilisateur
const dataToSave = {
  title: "API Key n8n ALFA 3",
  content: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  category: "credentials",
  metadata: {
    source: "cursor_conversation",
    user_id: "arnaud",
    type: "api_key",
    expires: "never"
  }
};

// Enregistrer dans RAG
fetch('http://localhost:5678/webhook/rag/auto-save', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    action: 'save',
    data: dataToSave,
    user_id: 'arnaud'
  })
});
```

---

## ✅ CRITÈRES DE SUCCÈS

- [ ] Workflow `iana-rag-auto-save` créé et fonctionnel
- [ ] Endpoint `/webhook/rag/auto-save` accessible
- [ ] Enregistrement automatique testé avec données réelles
- [ ] Document enregistré visible dans `rag.documents`
- [ ] Déduplication fonctionnelle (SHA256 hash)
- [ ] Logs traçables dans `iana.operation_logs`

---

## 📊 CATÉGORIES DE DONNÉES

**Catégories suggérées**:
- `conversation` - Conversations et échanges
- `credentials` - Tokens, API keys, mots de passe
- `config` - Configurations, paramètres
- `knowledge` - Connaissances générales
- `project` - Informations projet
- `other` - Autres données

---

**Plan créé le**: 2026-01-12  
**Status**: ⏳ En attente d'implémentation
