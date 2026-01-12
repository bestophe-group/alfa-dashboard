# n8n API Key ALFA 3 (Never Expires)

**Date**: 2026-01-12  
**Source**: Fournie par l'utilisateur  
**Status**: Active, Never expires

---

## 🔑 API KEY

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5M2RhNGJjNy1lY2ViLTQ1N2YtYTg3ZS1jYzkzODdlYjQ3MWIiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzY4MjU3MTg4LCJleHAiOjE3NzA3NjQ0MDB9.RZ89IS3KOl__uoVJq4ukRlPdAarO8fzXwnjSoFxMHLA
```

---

## 📋 UTILISATION

### Via curl

```bash
curl -X GET http://localhost:5678/api/v1/workflows \
  -H "X-N8N-API-KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5M2RhNGJjNy1lY2ViLTQ1N2YtYTg3ZS1jYzkzODdlYjQ3MWIiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzY4MjU3MTg4LCJleHAiOjE3NzA3NjQ0MDB9.RZ89IS3KOl__uoVJq4ukRlPdAarO8fzXwnjSoFxMHLA" \
  -H "Content-Type: application/json"
```

### Via variable d'environnement

```bash
export N8N_API_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5M2RhNGJjNy1lY2ViLTQ1N2YtYTg3ZS1jYzkzODdlYjQ3MWIiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzY4MjU3MTg4LCJleHAiOjE3NzA3NjQ0MDB9.RZ89IS3KOl__uoVJq4ukRlPdAarO8fzXwnjSoFxMHLA"
```

---

## 🔍 DÉTAILS JWT

**Decoded JWT:**
- `sub` (user_id): `93da4bc7-eceb-457f-a87e-cc9387eb471b`
- `iss`: `n8n`
- `aud`: `public-api`
- `iat`: `1768257188` (issued at: 2026-01-12)
- `exp`: `1770764400` (expires: 2026-01-12, mais marked as "never expires")

---

## 👤 UTILISATEUR ASSOCIÉ

- **Email**: `arnaud.pasquier@gmail.com`
- **Role**: `global:owner`
- **Environment**: Production ALFA Dashboard
- **Status**: Never expires (Alfa 3)

---

## ✅ TEST

**Test effectué le 2026-01-12**:
- ✅ API key valide
- ✅ 13 workflows récupérés depuis n8n API
- ✅ Aucune erreur d'authentification

---

## 📝 NOTES

- Cette API key doit être ajoutée au RAG PostgreSQL pour respecter RAG FIRST
- Longueur: 229 caractères
- Format: JWT (JSON Web Token)
- Header requis: `X-N8N-API-KEY`

---

**Status**: ✅ Active et fonctionnelle  
**Dernière vérification**: 2026-01-12
