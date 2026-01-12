# 🔴 RÈGLE OBLIGATOIRE : State First (Vérifier l'état réel AVANT de conclure)

**Date de création**: 2026-01-12  
**Priorité**: P0 - Critique  
**Statut**: Active

---

## 📋 PRINCIPE FONDAMENTAL

**TOUJOURS vérifier l'état réel AVANT de conclure.**

Cette règle s'applique à **TOUS** les diagnostics, conclusions, et suppositions.

---

## ✅ OBLIGATOIRE AVANT DE CONCLURE

### 1. Diagnostics / Conclusions

**AVANT** de conclure sur un diagnostic :

1. ✅ **Vérifier l'état réel** dans la source de vérité (base de données, logs, configuration)
2. ✅ **Fournir des preuves** (requêtes SQL, logs, tests)
3. ✅ **Documenter le raisonnement**

**❌ FORBIDDEN**: Conclure sans preuve de l'état réel

**Exemple**:
```
❌ MAUVAIS : "Le workflow n'est pas activé"
✅ BON : "Vérification dans PostgreSQL :
  SELECT active FROM workflow_entity WHERE id = 'xxx';
  Résultat: active = true
  Conclusion: Le workflow EST activé (preuve: requête SQL ci-dessus)"
```

---

### 2. Suppositions / Hypothèses

**AVANT** de faire une supposition :

1. ✅ **Vérifier l'état réel** d'abord
2. ✅ **Documenter la supposition** comme hypothèse
3. ✅ **Tester l'hypothèse** avant de conclure

**❌ FORBIDDEN**: Faire une supposition sans vérification

**Exemple**:
```
❌ MAUVAIS : "Le workflow n'est probablement pas activé"
✅ BON : "Hypothèse : Le workflow n'est pas activé
  Vérification : SELECT active FROM workflow_entity WHERE id = 'xxx';
  Résultat : active = true
  Conclusion : Hypothèse rejetée, le workflow EST activé"
```

---

### 3. États de Services / Configurations

**AVANT** de conclure sur l'état d'un service :

1. ✅ **Vérifier directement** (logs, base de données, API health)
2. ✅ **Fournir des preuves** (commandes exécutées, résultats)
3. ✅ **Documenter la source** de l'information

**❌ FORBIDDEN**: Conclure sur l'état d'un service sans vérification

**Exemple**:
```
❌ MAUVAIS : "n8n n'est probablement pas accessible"
✅ BON : "Vérification :
  curl -s -o /dev/null -w '%{http_code}' http://localhost:5678
  Résultat : 200
  Conclusion : n8n EST accessible (preuve: HTTP 200)"
```

---

## 🔧 WORKFLOW OBLIGATOIRE

### Pour TOUTE conclusion / diagnostic :

```
1. Formuler l'hypothèse (si nécessaire)
   ↓
2. Vérifier l'état réel dans la source de vérité
   ↓
3. Exécuter une requête/test pour obtenir des preuves
   ↓
4. Documenter les preuves (requêtes, résultats)
   ↓
5. Tirer une conclusion basée sur les preuves
   ↓
6. Documenter le raisonnement
```

---

## ❌ ANTI-PATTERNS À ÉVITER

### NE PAS FAIRE

❌ **Conclure sans vérifier l'état réel**
```
AI: "Le workflow n'est pas activé"
[Conclusion sans vérification]
→ ❌ ERREUR : Le workflow EST activé
```

❌ **Faire des suppositions sans vérification**
```
AI: "Le token est probablement invalide"
[Supposition sans vérification]
→ ❌ ERREUR : Le token est peut-être valide
```

❌ **Utiliser des informations non vérifiées**
```
AI: "D'après les logs, le workflow a échoué"
[Information non vérifiée]
→ ❌ ERREUR : Les logs montrent peut-être autre chose
```

### FAIRE

✅ **Vérifier l'état réel avant de conclure**
```
AI: "Vérifions d'abord l'état réel du workflow..."
[Requête SQL]
AI: "Le workflow est activé (preuve: active = true dans PostgreSQL)"
→ ✅ CORRECT
```

✅ **Fournir des preuves avec chaque conclusion**
```
AI: "Conclusion : Le workflow est activé
     Preuve : SELECT active FROM workflow_entity WHERE id = 'xxx';
              Résultat: active = true"
→ ✅ CORRECT
```

✅ **Documenter le raisonnement**
```
AI: "Hypothèse : Le workflow n'est pas activé
     Vérification : [requête SQL]
     Résultat : active = true
     Conclusion : Hypothèse rejetée, le workflow EST activé"
→ ✅ CORRECT
```

---

## ✅ CHECKLIST AVANT CONCLUSION

Avant de conclure sur un diagnostic :

- [ ] J'ai vérifié l'état réel dans la source de vérité
- [ ] J'ai exécuté une requête/test pour obtenir des preuves
- [ ] J'ai documenté les preuves (requêtes, résultats)
- [ ] J'ai tiré une conclusion basée sur les preuves
- [ ] J'ai documenté le raisonnement

---

## 📚 RÉFÉRENCES

- Méthode ALFA : Phase AUDIT - Vérifier l'état RÉEL (pas supposé)
- Règle "NO SUPPOSITION" : Toujours vérifier avant d'affirmer
- Règle "PROVE IT" : Jamais dire "ça marche" sans preuve

---

**Créé suite à l'erreur identifiée le 2026-01-12** : Conclusion que le workflow n'était pas activé sans vérification préalable.
