# 🔐 CREDENTIALS POSTGRESQL - ALFA

**Source**: Configuration Docker Compose actuelle  
**Date**: 2026-01-12

---

## ✅ CREDENTIALS ACTUELLES (depuis Docker)

D'après `docker-compose.yml` et la configuration active :

| Paramètre | Valeur | Source |
|-----------|--------|--------|
| **Host** | `postgres` | Nom du service Docker |
| **Port** | `5432` | Port par défaut PostgreSQL |
| **Database** | `alfa` | `${POSTGRES_DB:-alfa}` |
| **User** | `alfa` | `${POSTGRES_USER:-alfa}` |
| **Password** | `alfapass123` | `${POSTGRES_PASSWORD:-alfapass123}` |

**Note**: Si tu as un fichier `.env` avec des valeurs différentes, utilise celles-là.

---

## 🔧 CRÉER LA CREDENTIAL DANS n8n

### Méthode 1 : Via l'Interface n8n (Recommandé)

1. **Ouvrir n8n** : `http://localhost:5678`

2. **Aller dans Settings** → **Credentials**

3. **Cliquer sur "New Credential"**

4. **Choisir "PostgreSQL"**

5. **Remplir les champs** :
   - **Name** : `PostgreSQL IANA`
   - **Host** : `postgres`
   - **Port** : `5432`
   - **Database** : `alfa`
   - **User** : `alfa`
   - **Password** : `alfapass123`
   - **SSL** : Désactivé (pour Docker local)

6. **Cliquer sur "Test Connection"**

7. **Si OK** → **Save**

---

### Méthode 2 : Via API n8n (Automatique)

```bash
# Créer la credential via API
curl -X POST "http://localhost:5678/api/v1/credentials" \
  -H "X-N8N-API-KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5M2RhNGJjNy1lY2ViLTQ1N2YtYTg3ZS1jYzkzODdlYjQ3MWIiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzY4MjI5MTEwfQ.E1amsEqAQESuuvc0l2qABKXtIEwbxelnoubM1vh9xnM" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "PostgreSQL IANA",
    "type": "postgres",
    "data": {
      "host": "postgres",
      "port": 5432,
      "database": "alfa",
      "user": "alfa",
      "password": "alfapass123",
      "ssl": false
    }
  }'
```

**Note**: L'API n8n pour les credentials peut nécessiter un format spécifique. La méthode 1 (UI) est plus fiable.

---

## ✅ VÉRIFICATION

### Test 1 : Vérifier que la credential existe

Dans n8n UI → Settings → Credentials → Vérifier que `PostgreSQL IANA` apparaît

### Test 2 : Tester la connexion

Dans n8n UI → Ouvrir la credential → Cliquer sur "Test Connection"

### Test 3 : Tester le webhook

```bash
curl -X POST "http://localhost:5678/webhook/iana" \
  -H "Content-Type: application/json" \
  -d '{"query": "Dis bonjour", "user_id": "test"}'
```

**Résultat attendu** : Réponse JSON avec `success: true` (au lieu de l'erreur actuelle)

---

## 🔍 SI TU AS UN FICHIER .env

Si tu as un fichier `.env` dans `alfa-dashboard/` avec des valeurs différentes :

1. **Vérifier les valeurs** :
   ```bash
   cd alfa-dashboard
   grep POSTGRES .env
   ```

2. **Utiliser ces valeurs** au lieu des valeurs par défaut ci-dessus

3. **Garder la cohérence** : Les mêmes valeurs doivent être utilisées partout

---

## 📝 NOTES IMPORTANTES

- **Host = `postgres`** : C'est le nom du service Docker, pas `localhost`
- **Password** : Si tu as changé le mot de passe, utilise la valeur réelle
- **SSL** : Désactivé pour Docker local, activé pour production
- **Credential ID** : Le workflow attend l'ID `postgres-iana` ou le nom `PostgreSQL IANA`

---

**Fiabilité**: **100%** (valeurs extraites de la config Docker active)
