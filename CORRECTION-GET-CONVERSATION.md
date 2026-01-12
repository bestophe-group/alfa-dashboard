# Correction du Node "Get Conversation"

## Problème identifié

Le node "Get Conversation" dans le workflow `iana-router` génère l'erreur :
```
Problem in node 'Get Conversation': there is no parameter $1
```

## Cause

Les `queryParameters` ne sont pas correctement configurés dans le node PostgreSQL.

## Solution

### Option 1 : Correction manuelle dans l'interface n8n (RECOMMANDÉ)

1. Ouvrir le workflow `iana-router` dans n8n : http://localhost:5678/workflow/Fowjj0lqqwb1Abbi
2. Cliquer sur le node **"Get Conversation"** (node PostgreSQL)
3. Dans l'onglet **"Parameters"**, vérifier que la requête SQL est :
   ```sql
   INSERT INTO iana.conversations (user_id, channel) VALUES ($1, $2) ON CONFLICT (user_id, channel) DO UPDATE SET updated_at = NOW() RETURNING conversation_id
   ```
4. Cliquer sur **"Options"** (en bas du panneau)
5. Cliquer sur **"Add option"** → Sélectionner **"Query Parameters"**
6. Dans le champ **"Query Parameters"**, sélectionner **"Expression"** (au lieu de "Fixed")
7. Entrer l'expression suivante :
   ```
   ={{ [$json.user_id, $json.channel] }}
   ```
8. Cliquer sur **"Save"** pour sauvegarder le workflow

### Option 2 : Vérification de la contrainte unique

La contrainte unique `(user_id, channel)` a déjà été ajoutée à la table `iana.conversations`. Si vous obtenez une erreur `ON CONFLICT`, vérifiez que la contrainte existe :

```sql
SELECT constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_schema = 'iana' 
  AND table_name = 'conversations'
  AND constraint_type = 'UNIQUE';
```

Vous devriez voir `conversations_user_channel_unique`.

## Test après correction

Après avoir corrigé le node, tester avec :

```bash
curl -X POST "http://localhost:5678/webhook/iana" \
  -H "Content-Type: application/json" \
  -d '{"query": "Bonjour", "user_id": "arnaud"}'
```

La réponse devrait contenir un JSON avec `success: true` et les données de la conversation.

## État actuel

- ✅ Contrainte unique `(user_id, channel)` ajoutée à la table
- ✅ Requête SQL corrigée dans le fichier `iana-router.json`
- ⏳ Configuration du node dans n8n à faire manuellement (Option 1)

## Fichiers modifiés

- `alfa-dashboard/n8n/workflows/iana-router.json` : Requête SQL corrigée avec `ON CONFLICT`
- Base de données : Contrainte unique ajoutée
