# 🔐 CRÉER LA CREDENTIAL POSTGRESQL DANS n8n

**API Key**: ✅ Validée  
**Date**: 2026-01-12

---

## ✅ TON API KEY FONCTIONNE

Test réussi : 2 workflows listés avec la nouvelle API key.

---

## 📋 CREDENTIALS À UTILISER

```
Host:     postgres
Port:     5432
Database: alfa
User:     alfa
Password: alfapass123
SSL:      Désactivé
```

---

## 🎯 ÉTAPES POUR CRÉER LA CREDENTIAL

### 1. Ouvrir n8n
```
http://localhost:5678
```

### 2. Aller dans Settings
- Cliquer sur l'icône **⚙️ Settings** (en haut à droite)
- Ou menu : **Settings** → **Credentials**

### 3. Créer nouvelle credential
- Cliquer sur **"New Credential"** ou **"+"**
- Chercher **"PostgreSQL"** dans la liste
- Cliquer sur **PostgreSQL**

### 4. Remplir les champs

**Name** : `PostgreSQL IANA`

**Configuration** :
- **Host**: `postgres`
- **Port**: `5432`
- **Database**: `alfa`
- **User**: `alfa`
- **Password**: `alfapass123`
- **SSL**: Désactivé / Disable

### 5. Tester et sauvegarder
- Cliquer sur **"Test Connection"**
- Si ✅ vert → **Save**
- Si ❌ erreur → Vérifier les valeurs

---

## ✅ VÉRIFICATION

### Test 1 : Vérifier que la credential existe

Dans n8n UI → Settings → Credentials → Vérifier que `PostgreSQL IANA` apparaît

### Test 2 : Tester le webhook

```bash
curl -X POST "http://localhost:5678/webhook/iana" \
  -H "Content-Type: application/json" \
  -d '{"query": "Dis bonjour", "user_id": "test"}'
```

**Résultat attendu** :
```json
{
  "success": true,
  "tier": "L1",
  "response": "...",
  ...
}
```

**Au lieu de** :
```json
{
  "code": 0,
  "message": "Workflow Webhook Error: Workflow could not be started!"
}
```

---

## 🔍 SI ÇA NE MARCHE TOUJOURS PAS

### Vérifier l'ID de la credential dans le workflow

1. Ouvrir le workflow `iana-router` dans n8n
2. Cliquer sur un node PostgreSQL (ex: "Get Conversation")
3. Vérifier la credential sélectionnée
4. Si elle n'est pas `PostgreSQL IANA`, la sélectionner

### Vérifier les logs d'exécution

Dans n8n UI → **Executions** → Cliquer sur la dernière exécution → Voir l'erreur détaillée

---

## 📝 NOTES

- **Host = `postgres`** : Nom du service Docker, pas `localhost`
- **L'API n8n ne permet pas** de créer des credentials directement (format complexe)
- **Il faut utiliser l'UI** n8n pour créer la credential
- **Une fois créée**, le workflow devrait fonctionner automatiquement

---

**Après création de la credential, le webhook `/webhook/iana` devrait répondre correctement !**
