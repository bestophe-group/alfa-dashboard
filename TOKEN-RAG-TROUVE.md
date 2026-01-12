# ✅ TOKEN N8N TROUVÉ DANS LE RAG

**Date**: 2026-01-12  
**Source**: RAG - Document "n8n API Key ALFA" (id: `b1d94dde-5e0a-45c6-bef4-7fa3eaa3a5d4`)

---

## 🔑 TOKEN N8N API

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5M2RhNGJjNy1lY2ViLTQ1N2YtYTg3ZS1jYzkzODdlYjQ3MWIiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzY4MjI5MTEwfQ.E1amsEqAQESuuvc0l2qABKXtIEwbxelnoubM1vh9xnM
```

---

## 📋 INFORMATIONS DU TOKEN

- **Type**: JWT Token
- **User ID**: `93da4bc7-eceb-457f-a87e-cc9387eb471b`
- **Issuer**: `n8n`
- **Audience**: `public-api`
- **Issued At**: 2026-01-12 (1768229110)
- **Associated User**: `arnaud.pasquier@gmail.com`
- **Role**: `global:owner`
- **Environment**: Production ALFA Dashboard

---

## 🔧 UTILISATION

```bash
# Variable d'environnement
export N8N_API_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5M2RhNGJjNy1lY2ViLTQ1N2YtYTg3ZS1jYzkzODdlYjQ3MWIiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzY4MjI5MTEwfQ.E1amsEqAQESuuvc0l2qABKXtIEwbxelnoubM1vh9xnM"

# Exemple d'utilisation
curl -X GET "http://localhost:5678/api/v1/workflows" \
  -H "X-N8N-API-KEY: $N8N_API_KEY"
```

---

## ✅ LEÇON APPRISE

**Principe "RAG First"** :
- ✅ Toujours chercher dans le RAG d'abord pour les tokens/credentials
- ✅ Utiliser `rag.search_fulltext()` ou `rag.search_alfa()` pour trouver les tokens
- ❌ Ne pas demander la régénération sans avoir cherché dans le RAG

---

**Référence RAG**: Document "n8n API Key ALFA" (id: `b1d94dde-5e0a-45c6-bef4-7fa3eaa3a5d4`)
