# 🔴 RÈGLE OBLIGATOIRE : Workflow ALFA Strict (Suivre systématiquement)

**Date de création**: 2026-01-12  
**Priorité**: P0 - Critique  
**Statut**: Active

---

## 📋 PRINCIPE FONDAMENTAL

**TOUJOURS suivre le workflow ALFA systématiquement : INTAKE → AUDIT → PLAN → BUILD → PROVE**

Aucune étape ne doit être sautée, aucune phase ne doit être ignorée.

---

## ✅ WORKFLOW ALFA OBLIGATOIRE

### Phase 0 : INTAKE (OBLIGATOIRE)

**Actions** :
1. ✅ Reformuler demande en 1 phrase
2. ✅ Lister prérequis supposés
3. ✅ 1-3 questions max
4. ✅ Attendre validation

**Livrable** : Objectif écrit dans CURRENT.md

**❌ FORBIDDEN**: Passer directement à BUILD sans INTAKE

---

### Phase 1 : AUDIT (OBLIGATOIRE)

**Actions** :
1. ✅ Script audit existant (si disponible)
2. ✅ Vérifier état réel vs supposé
3. ✅ Rapport tableau

**Livrable** : État vérifié (pas supposé)

**❌ FORBIDDEN**: Proposer des solutions sans AUDIT préalable

**Exemple**:
```
✅ BON : "AUDIT - État réel du workflow:
  - Workflow ID: Fowjj0lqqwb1Abbi
  - Actif dans PostgreSQL: true (SELECT active FROM workflow_entity WHERE id = 'xxx')
  - Node 'Respond to Webhook' paramètres: {} (vide)
  Conclusion AUDIT: Workflow activé mais node mal configuré"
```

---

### Phase 2 : PLAN (OBLIGATOIRE)

**Actions** :
1. ✅ TODO numérotée + estimations
2. ✅ Risques identifiés
3. ✅ Critères "Done"
4. ✅ Validation humaine

**Livrable** : Checklist détaillée

**❌ FORBIDDEN**: Commencer BUILD sans PLAN validé

---

### Phase 3 : BUILD (OBLIGATOIRE)

**Actions** :
- Mode IMPL (production) :
  1. ✅ Test AVANT code
  2. ✅ 1 commit = 1 test vert
  3. ✅ Logs précis : [SERVICE:FONCTION] message

**Livrable** : Code + commits atomiques

**❌ FORBIDDEN**: Coder sans tests préalables (mode IMPL)

---

### Phase 4 : PROVE (OBLIGATOIRE)

**Actions** :
1. ✅ Exécuter test
2. ✅ Screenshot/log comme preuve
3. ✅ "✅ Prouvé" ou "❌ Échec : [raison]"

**Livrable** : Preuves tangibles

**❌ FORBIDDEN**: Dire "ça marche" sans preuve

**Exemple**:
```
✅ BON : "PROVE - Test du webhook:
  curl -X POST "http://localhost:5678/webhook/iana" ...
  Résultat: HTTP 200, body: {"success": true, ...}
  ✅ Prouvé : Webhook fonctionne"
```

---

## 🔧 WORKFLOW COMPLET

```
INTAKE
  ↓ (validation)
AUDIT
  ↓ (rapport)
PLAN
  ↓ (validation)
BUILD
  ↓ (code + commits)
PROVE
  ↓ (preuves)
COMMIT
```

**Aucune étape ne peut être sautée.**

---

## ❌ ANTI-PATTERNS À ÉVITER

### NE PAS FAIRE

❌ **Sauter l'AUDIT**
```
AI: "Je vais corriger le workflow..."
[Passe directement à BUILD sans AUDIT]
→ ❌ ERREUR : État réel non vérifié
```

❌ **Sauter le PLAN**
```
AI: "Je vais créer un script SQL..."
[Passe directement à BUILD sans PLAN]
→ ❌ ERREUR : Pas de plan validé
```

❌ **Sauter le PROVE**
```
AI: "Le script est créé, il devrait fonctionner"
[Pas de test/preuve]
→ ❌ ERREUR : Pas de preuve que ça fonctionne
```

### FAIRE

✅ **Suivre le workflow ALFA systématiquement**
```
AI: "INTAKE - Reformulation : Mettre à jour le node 'Respond to Webhook'
     AUDIT - État réel : Node a {} comme paramètres (SELECT ...)
     PLAN - TODO : 1. Tester script SQL, 2. Proposer solution
     BUILD - Script créé et testé
     PROVE - Test réussi (preuve: requête SQL ci-dessus)
     ✅ Solution validée"
→ ✅ CORRECT
```

---

## ✅ CHECKLIST WORKFLOW ALFA

Pour chaque tâche :

- [ ] INTAKE : Demande reformulée, prérequis listés
- [ ] AUDIT : État réel vérifié (pas supposé)
- [ ] PLAN : TODO créée, risques identifiés, critères "Done"
- [ ] BUILD : Code/test créé, commits atomiques
- [ ] PROVE : Tests exécutés, preuves fournies
- [ ] COMMIT : Changements validés

---

## 📚 RÉFÉRENCES

- Méthode ALFA : `CORE.md` - 5 PHASES OBLIGATOIRES
- Workflow ALFA : `.cursorrules` - Phase 0 à 5

---

**Créé suite à l'erreur identifiée le 2026-01-12** : Saut de certaines phases ALFA (AUDIT, PROVE) lors du debug.
