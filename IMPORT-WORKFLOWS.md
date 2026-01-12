# 🚀 IMPORT RAPIDE DES WORKFLOWS (2 minutes)

## Méthode 1: Interface Web (RECOMMANDÉ - 2 min)

### Étapes:

1. **Ouvrir n8n dans le navigateur:**
   ```
   http://localhost:5678
   ```

2. **Pour chaque workflow** (5 fichiers):
   - Cliquer sur "+" (nouveau workflow) ou menu hamburger
   - Sélectionner "Import from File"
   - Choisir le fichier:
     - `/Users/arnaud/Documents/ALFA-Agent-Method/mcp-server/workflows/iana-log.json`
     - `/Users/arnaud/Documents/ALFA-Agent-Method/mcp-server/workflows/iana-context.json`
     - `/Users/arnaud/Documents/ALFA-Agent-Method/mcp-server/workflows/iana-error-handler.json`
     - `/Users/arnaud/Documents/ALFA-Agent-Method/mcp-server/workflows/iana-rag-query.json`
     - `/Users/arnaud/Documents/ALFA-Agent-Method/mcp-server/workflows/alfa-slack-send.json`
   - Cliquer "Import"
   - **NE PAS ACTIVER** encore (laisser inactive)

3. **Vérifier l'import:**
   - Tu devrais voir 5 nouveaux workflows dans la liste
   - Tous doivent être "Inactive" (toggle gris)

---

## Méthode 2: Via SQL (TECHNIQUE - si UI bloquée)

**⚠️ Utiliser SEULEMENT si l'interface web ne marche pas**

```bash
# Script d'import automatique
cd /Users/arnaud/Documents/ALFA-Agent-Method

# Je vais créer un script SQL d'insertion
# ATTEND MA CONFIRMATION AVANT D'EXECUTER
```

---

## Après l'import:

### Test rapide (1 workflow)

```bash
# 1. Activer iana-log dans l'UI n8n (toggle en haut à droite)

# 2. Tester avec curl
curl -X POST http://localhost:5678/webhook/iana/log \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "test_user",
    "role": "user",
    "content": "Premier test IANA Log!",
    "tier": "L1"
  }'

# 3. Vérifier dans PostgreSQL
docker exec alfa-postgres psql -U alfa -d alfa -c \
  "SELECT * FROM iana.messages ORDER BY created_at DESC LIMIT 1;"
```

**Si tu vois un nouveau message dans iana.messages → ✅ ÇA MARCHE !**

---

## Debugging si ça bloque

### n8n ne s'ouvre pas?
```bash
# Vérifier que n8n tourne
docker ps | grep n8n

# Voir les logs
docker logs alfa-n8n --tail 50
```

### Erreur "credentials missing"?
```bash
# Créer credential PostgreSQL dans n8n UI:
# Settings → Credentials → New → PostgreSQL
# - Name: "PostgreSQL IANA"
# - Host: postgres
# - Port: 5432
# - Database: alfa
# - User: alfa
# - Password: alfapass123
```

### Webhook ne répond pas?
```bash
# Vérifier que le workflow est ACTIF (toggle vert)
# Vérifier le path: doit être "iana/log" pas "/iana/log"
```

---

**Temps estimé total: 2-5 minutes**

