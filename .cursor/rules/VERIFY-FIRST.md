# 🔴 RÈGLE OBLIGATOIRE : Verify First (Test Before Propose)

**Date de création**: 2026-01-12  
**Priorité**: P0 - Critique  
**Statut**: Active

---

## 📋 PRINCIPE FONDAMENTAL

**TOUJOURS tester/verifier AVANT de proposer une solution.**

Cette règle s'applique à **TOUTES** les solutions proposées, scripts créés, et conclusions tirées.

---

## ✅ OBLIGATOIRE AVANT DE PROPOSER

### 1. Scripts SQL / Database

**AVANT** de proposer un script SQL :

1. ✅ **Tester le script dans un environnement de test** (si possible)
2. ✅ **Vérifier la syntaxe SQL** avec `EXPLAIN` ou `\d`
3. ✅ **Tester avec des données de test** avant données réelles
4. ✅ **Documenter les hypothèses** sur la structure des données

**❌ FORBIDDEN**: Proposer un script SQL complexe sans l'avoir testé d'abord

**Exemple**:
```sql
-- ❌ MAUVAIS : Proposer directement
UPDATE workflow_entity SET nodes = (complex JSONB manipulation) WHERE id = 'xxx';

-- ✅ BON : Tester d'abord
-- 1. Vérifier la structure
SELECT jsonb_typeof(nodes) FROM workflow_entity WHERE id = 'xxx';
-- 2. Tester sur un cas simple
SELECT jsonb_set('{"test": {}}'::jsonb, '{test,key}', '"value"'::jsonb);
-- 3. Tester sur le workflow réel (en mode SELECT d'abord)
SELECT jsonb_set(nodes::jsonb, '{test}', '{}'::jsonb) FROM workflow_entity WHERE id = 'xxx';
-- 4. Alors seulement proposer UPDATE
```

---

### 2. API Calls / Tokens

**AVANT** de proposer d'utiliser un token API :

1. ✅ **Tester le token** avec une requête simple
2. ✅ **Vérifier la validité** (expiration, permissions)
3. ✅ **Documenter le résultat du test**

**❌ FORBIDDEN**: Utiliser un token sans l'avoir testé d'abord

**Exemple**:
```bash
# ✅ BON : Tester d'abord
curl -X GET "http://localhost:5678/api/v1/workflows" \
  -H "X-N8N-API-KEY: $TOKEN" | jq '.'
  
# Si le test réussit → Utiliser le token
# Si le test échoue → Ne pas utiliser, chercher une alternative
```

---

### 3. Solutions Alternatives

**AVANT** de conclure qu'une solution est obligatoire :

1. ✅ **Chercher toutes les alternatives possibles**
2. ✅ **Tester chaque alternative** (si possible)
3. ✅ **Documenter les tests et résultats**
4. ✅ **Comparer les alternatives** avant de conclure

**❌ FORBIDDEN**: Conclure qu'une solution est obligatoire sans avoir cherché toutes les alternatives

**Exemple**:
```
❌ MAUVAIS : "La correction manuelle est obligatoire"
✅ BON : "J'ai testé 3 alternatives :
  1. API n8n : ❌ Token invalide
  2. SQL direct : ❌ Fonction complexe, non testée
  3. Interface manuelle : ✅ Fonctionne, recommandé par doc n8n
  Conclusion : Interface manuelle est la méthode recommandée"
```

---

### 4. Conclusions / Diagnostics

**AVANT** de conclure sur un diagnostic :

1. ✅ **Vérifier l'état réel** (base de données, logs, configuration)
2. ✅ **Fournir des preuves** (requêtes SQL, logs, tests)
3. ✅ **Documenter le raisonnement**

**❌ FORBIDDEN**: Conclure sans preuve de l'état réel

**Exemple**:
```
❌ MAUVAIS : "Le workflow n'est pas activé"
✅ BON : "Vérification dans PostgreSQL :
  SELECT active FROM workflow_entity WHERE id = 'xxx';
  Résultat: active = true
  Conclusion: Le workflow EST activé"
```

---

## 🔧 WORKFLOW OBLIGATOIRE

### Pour TOUTE solution proposée :

```
1. Identifier la solution
   ↓
2. Chercher des alternatives
   ↓
3. Tester chaque solution/alternative (si possible)
   ↓
4. Documenter les tests et résultats
   ↓
5. Comparer les solutions
   ↓
6. Proposer la meilleure solution avec preuves
```

---

## ❌ ANTI-PATTERNS À ÉVITER

### NE PAS FAIRE

❌ **Proposer un script SQL sans l'avoir testé**
```
AI: "Voici un script SQL pour mettre à jour le workflow..."
[Script complexe non testé]
→ ❌ ERREUR : Le script ne fonctionne pas
```

❌ **Utiliser un token sans le tester**
```
AI: "J'ai trouvé un token dans le RAG, je l'utilise"
[Utilise le token sans test]
→ ❌ ERREUR : Token invalide/expiré
```

❌ **Conclure sans vérifier l'état réel**
```
AI: "Le workflow n'est pas activé"
[Conclusion sans vérification]
→ ❌ ERREUR : Le workflow EST activé
```

❌ **Proposer une solution sans chercher d'alternatives**
```
AI: "La correction manuelle est obligatoire"
[Conclusion sans avoir cherché d'alternatives]
→ ❌ ERREUR : Il existe peut-être d'autres solutions
```

### FAIRE

✅ **Tester avant de proposer**
```
AI: "Je vais créer un script SQL pour mettre à jour le workflow.
     Testons d'abord la syntaxe sur un cas simple..."
[Test du script]
AI: "Le script fonctionne, je le propose maintenant"
→ ✅ CORRECT
```

✅ **Vérifier l'état réel avant de conclure**
```
AI: "Vérifions d'abord l'état réel du workflow..."
[Requête SQL]
AI: "Le workflow est activé (preuve: active = true dans PostgreSQL)"
→ ✅ CORRECT
```

✅ **Chercher des alternatives avant de conclure**
```
AI: "Cherchons toutes les solutions possibles:
     1. API n8n : ❌ Token invalide
     2. SQL direct : ❌ Complexe, non testé
     3. Interface manuelle : ✅ Recommandé par doc
     Conclusion: Interface manuelle est la meilleure solution"
→ ✅ CORRECT
```

---

## ✅ CHECKLIST AVANT PROPOSITION

Avant de proposer une solution :

- [ ] J'ai testé la solution (si possible)
- [ ] J'ai vérifié l'état réel (si diagnostic)
- [ ] J'ai cherché des alternatives
- [ ] J'ai documenté les tests et résultats
- [ ] J'ai fourni des preuves de mes conclusions

---

## 📚 RÉFÉRENCES

- Méthode ALFA : `CORE.md` (PROVE IT - Jamais dire "ça marche" sans preuve)
- Règle "NO SUPPOSITION" : Toujours vérifier avant d'affirmer
- Phase PROVE : Fournir preuves tangibles

---

**Créé suite à l'erreur identifiée le 2026-01-12** : Scripts SQL complexes proposés sans tests préalables.
