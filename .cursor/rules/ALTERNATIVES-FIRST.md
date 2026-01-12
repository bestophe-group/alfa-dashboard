# 🔴 RÈGLE OBLIGATOIRE : Alternatives First (Chercher toutes les alternatives AVANT de conclure)

**Date de création**: 2026-01-12  
**Priorité**: P0 - Critique  
**Statut**: Active

---

## 📋 PRINCIPE FONDAMENTAL

**TOUJOURS chercher toutes les alternatives AVANT de conclure qu'une solution est obligatoire.**

Cette règle s'applique à **TOUTES** les conclusions sur les solutions, méthodes, et approches.

---

## ✅ OBLIGATOIRE AVANT DE CONCLURE

### 1. Solutions / Méthodes

**AVANT** de conclure qu'une solution est obligatoire :

1. ✅ **Chercher toutes les alternatives possibles**
2. ✅ **Tester chaque alternative** (si possible)
3. ✅ **Documenter les tests et résultats**
4. ✅ **Comparer les alternatives** avant de conclure

**❌ FORBIDDEN**: Conclure qu'une solution est obligatoire sans avoir cherché toutes les alternatives

**Exemple**:
```
❌ MAUVAIS : "La correction manuelle est obligatoire"
✅ BON : "Alternatives trouvées :
  1. API n8n : ❌ Token invalide (testé)
  2. SQL direct : ❌ Complexe, non testé
  3. Interface manuelle : ✅ Fonctionne, recommandé par doc n8n
  Conclusion : Interface manuelle est la méthode recommandée"
```

---

### 2. Approches / Stratégies

**AVANT** de conclure sur une approche :

1. ✅ **Chercher différentes approches** possibles
2. ✅ **Évaluer les avantages/inconvénients** de chaque approche
3. ✅ **Documenter l'évaluation**
4. ✅ **Recommandation basée sur l'évaluation**

**❌ FORBIDDEN**: Conclure sur une approche sans avoir cherché d'alternatives

---

### 3. Recherche de Solutions

**AVANT** de conclure qu'il n'y a pas de solution :

1. ✅ **Chercher dans la documentation officielle**
2. ✅ **Chercher dans les forums/communautés**
3. ✅ **Chercher dans le code existant**
4. ✅ **Chercher dans le RAG** (si applicable)

**❌ FORBIDDEN**: Conclure qu'il n'y a pas de solution sans avoir cherché exhaustivement

---

## 🔧 WORKFLOW OBLIGATOIRE

### Pour TOUTE conclusion sur une solution :

```
1. Identifier la solution proposée
   ↓
2. Chercher des alternatives possibles
   ├─ Documentation officielle
   ├─ Forums/Communautés
   ├─ Code existant
   └─ RAG (si applicable)
   ↓
3. Tester chaque alternative (si possible)
   ↓
4. Documenter les tests et résultats
   ↓
5. Comparer les alternatives
   ↓
6. Recommander la meilleure solution avec justification
```

---

## ❌ ANTI-PATTERNS À ÉVITER

### NE PAS FAIRE

❌ **Conclure qu'une solution est obligatoire sans chercher d'alternatives**
```
AI: "La correction manuelle est obligatoire"
[Conclusion sans avoir cherché d'alternatives]
→ ❌ ERREUR : Il existe peut-être d'autres solutions
```

❌ **Supposer qu'il n'y a pas d'alternatives**
```
AI: "Il n'y a pas d'autre solution que..."
[Supposition sans recherche]
→ ❌ ERREUR : Il existe peut-être des alternatives
```

❌ **Recommander une solution sans avoir comparé avec d'autres**
```
AI: "Je recommande la solution X"
[Recommandation sans comparaison]
→ ❌ ERREUR : La solution Y pourrait être meilleure
```

### FAIRE

✅ **Chercher toutes les alternatives avant de conclure**
```
AI: "Cherchons toutes les solutions possibles:
     1. API n8n : ❌ Token invalide (testé)
     2. SQL direct : ❌ Complexe, non testé
     3. Interface manuelle : ✅ Fonctionne, recommandé par doc
     Conclusion : Interface manuelle est la meilleure solution"
→ ✅ CORRECT
```

✅ **Documenter la recherche d'alternatives**
```
AI: "Alternatives recherchées :
     - Documentation n8n : Interface manuelle recommandée
     - API n8n : Testé, token invalide
     - SQL direct : Complexe, risques de corruption
     Conclusion : Interface manuelle est la méthode recommandée"
→ ✅ CORRECT
```

---

## ✅ CHECKLIST AVANT CONCLUSION

Avant de conclure qu'une solution est obligatoire :

- [ ] J'ai cherché dans la documentation officielle
- [ ] J'ai cherché dans les forums/communautés
- [ ] J'ai cherché dans le code existant
- [ ] J'ai cherché dans le RAG (si applicable)
- [ ] J'ai testé chaque alternative (si possible)
- [ ] J'ai documenté les tests et résultats
- [ ] J'ai comparé les alternatives
- [ ] J'ai recommandé la meilleure solution avec justification

---

## 📚 RÉFÉRENCES

- Méthode ALFA : Phase PLAN - Lister les risques et alternatives
- Règle "NO SUPPOSITION" : Toujours vérifier avant d'affirmer
- Règle "VERIFY FIRST" : Tester avant de proposer

---

**Créé suite à l'erreur identifiée le 2026-01-12** : Conclusion que la correction manuelle était obligatoire sans avoir cherché toutes les alternatives.
