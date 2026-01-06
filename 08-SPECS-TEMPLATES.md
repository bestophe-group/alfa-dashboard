# 08 - SPECS TEMPLATES
## Templates CURRENT.md Anti-Désalignement

---

## 📑 SOMMAIRE

1. [Pourquoi CURRENT.md](#1-pourquoi-currentmd)
2. [Template principal](#2-template-principal)
3. [Templates par type](#3-templates-par-type)
4. [Workflow avec CURRENT.md](#4-workflow-avec-currentmd)
5. [Exemples DO / DON'T](#5-exemples-do--dont)

---

## 1. POURQUOI CURRENT.MD

### Le problème sans spec écrite

```
Demande orale    →    Agent interprète    →    Désalignement
     ↓                      ↓                       ↓
 "Optimise ça"        "Je vais tout             3h de travail
                       refactorer"               non demandé
```

### La solution avec CURRENT.md

```
Demande écrite   →    Spec validée    →    Alignement
     ↓                      ↓                    ↓
 CURRENT.md           Checklist            Exactement ce
 avec scope           approuvée            qui est demandé
```

### Règle fondamentale

```markdown
PAS DE CURRENT.MD = PAS DE CODE

L'agent ne doit JAMAIS coder sans un CURRENT.md validé.
C'est la règle anti-désalignement #1.
```

---

## 2. TEMPLATE PRINCIPAL

**Livrable** : `@specs/CURRENT.md.template`

```markdown
# CURRENT.md - [Titre de la Feature]

## 📋 Méta
- **Date** : YYYY-MM-DD
- **Auteur** : [Qui demande]
- **Agent** : IANA
- **Statut** : [ ] Draft | [ ] En cours | [ ] Terminé

---

## 🎯 Objectif

[1-2 phrases claires décrivant CE QUI DOIT ÊTRE FAIT]

---

## ✅ Ce qui EST demandé

- [ ] Point 1
- [ ] Point 2
- [ ] Point 3

---

## 🚫 Ce qui N'EST PAS demandé

> ⚠️ IMPORTANT : L'agent ne doit PAS faire ces choses même si elles semblent utiles.

- Point exclu 1
- Point exclu 2
- Point exclu 3

---

## 📂 Fichiers autorisés

> L'agent ne peut modifier QUE ces fichiers. Tout autre fichier nécessite validation.

| Fichier | Action | Raison |
|---------|--------|--------|
| `src/xxx.ts` | Créer | Nouveau composant |
| `src/yyy.ts` | Modifier | Ajouter import |
| `tests/xxx.test.ts` | Créer | Tests |

---

## 🔍 État actuel vérifié

> Rempli par l'agent pendant la phase AUDIT

- [ ] Vérification 1 : [résultat]
- [ ] Vérification 2 : [résultat]
- [ ] Vérification 3 : [résultat]

---

## 📝 Checklist technique

> Chaque étape doit être cochée APRÈS exécution, pas avant.

### Étape 1 : [Nom] (X min)
- [ ] Action 1.1
- [ ] Action 1.2
- [ ] Commit : `type(scope): message`

### Étape 2 : [Nom] (X min)
- [ ] Action 2.1
- [ ] Action 2.2
- [ ] Commit : `type(scope): message`

### Étape 3 : Tests (X min)
- [ ] Écrire tests
- [ ] Vérifier coverage > 80%
- [ ] Commit : `test(scope): add tests`

⏱️ **Estimation totale** : XX min

---

## ⚠️ Risques identifiés

| Risque | Probabilité | Mitigation |
|--------|-------------|------------|
| [Risque 1] | Haute/Moyenne/Basse | [Action] |
| [Risque 2] | Haute/Moyenne/Basse | [Action] |

---

## 🛡️ Point de validation

> ⏸️ **STOP ICI** - Attendre validation humaine avant de passer à BUILD

- [ ] Humain a validé le plan
- [ ] Questions clarifiées
- [ ] GO pour BUILD

---

## ✅ Preuves de complétion

> Rempli par l'agent pendant la phase PROVE

### Tests
```
[Output npm test]
```

### Build
```
[Output npm run build]
```

### Vérification manuelle
[Screenshot ou description]

---

## 📦 Commits effectués

| # | Message | Fichiers |
|---|---------|----------|
| 1 | `type(scope): message` | file1, file2 |
| 2 | `type(scope): message` | file3 |

---

## 📝 Notes de session

[Notes libres, problèmes rencontrés, décisions prises]
```

---

## 3. TEMPLATES PAR TYPE

### Template : Nouvelle Feature

```markdown
# CURRENT.md - Feature: [Nom]

## 🎯 Objectif
Implémenter [feature] pour permettre [bénéfice utilisateur].

## ✅ Ce qui EST demandé
- [ ] Endpoint/Composant X
- [ ] Validation des inputs
- [ ] Tests unitaires
- [ ] Documentation inline

## 🚫 Ce qui N'EST PAS demandé
- UI/UX avancée (juste fonctionnel)
- Optimisation performance
- Gestion d'erreurs avancée
- Internationalisation

## 📂 Fichiers autorisés
| Fichier | Action |
|---------|--------|
| `src/features/[name]/index.ts` | Créer |
| `src/features/[name]/[name].test.ts` | Créer |
| `src/routes/index.ts` | Modifier (1 ligne: import) |

## 📝 Checklist
### Étape 1 : Tests (TDD)
- [ ] Écrire tests du happy path
- [ ] Écrire tests des erreurs

### Étape 2 : Implementation
- [ ] Implémenter pour faire passer les tests

### Étape 3 : Integration
- [ ] Brancher dans l'app
- [ ] Vérifier tous tests passent
```

### Template : Bug Fix

```markdown
# CURRENT.md - Fix: [Description Bug]

## 🎯 Objectif
Corriger le bug : [description précise]

## 🐛 Reproduction
1. Étape 1
2. Étape 2
3. Résultat actuel : [X]
4. Résultat attendu : [Y]

## ✅ Ce qui EST demandé
- [ ] Identifier la cause racine
- [ ] Corriger le code
- [ ] Ajouter test de non-régression

## 🚫 Ce qui N'EST PAS demandé
- Refactoring du code autour
- Amélioration "tant qu'on y est"
- Correction d'autres bugs trouvés (créer issues)

## 📂 Fichiers autorisés
| Fichier | Action |
|---------|--------|
| `src/[file].ts` | Modifier |
| `tests/[file].test.ts` | Modifier |

## 📝 Checklist
### Étape 1 : Analyse
- [ ] Localiser le bug (fichier, ligne)
- [ ] Comprendre la cause

### Étape 2 : Test
- [ ] Écrire test qui ÉCHOUE (prouve le bug)

### Étape 3 : Fix
- [ ] Corriger le code
- [ ] Test passe maintenant

### Étape 4 : Vérification
- [ ] Tous les autres tests passent
- [ ] Le bug ne se reproduit plus
```

### Template : Refactoring

```markdown
# CURRENT.md - Refactor: [Scope]

## 🎯 Objectif
Refactorer [scope] pour [raison: lisibilité/performance/maintenabilité]

## ✅ Ce qui EST demandé
- [ ] Extraction de [X] dans [Y]
- [ ] Renommage de [ancien] en [nouveau]
- [ ] Réorganisation de [structure]

## 🚫 Ce qui N'EST PAS demandé
- Changement de comportement
- Nouvelles features
- Changement d'API publique
- Modification des tests (sauf import paths)

## ⚠️ Contrainte CRITIQUE
```
TOUS LES TESTS DOIVENT PASSER AVANT ET APRÈS
Zéro changement de comportement
```

## 📂 Fichiers autorisés
[Liste stricte]

## 📝 Checklist
### Étape 0 : Baseline
- [ ] `npm test` → tous verts
- [ ] Noter le nombre de tests

### Étape 1-N : Refactoring
- [ ] Modification X
- [ ] `npm test` → tous verts
- [ ] Commit

### Étape finale : Vérification
- [ ] Même nombre de tests
- [ ] Tous verts
- [ ] Comportement identique
```

### Template : Migration DB

```markdown
# CURRENT.md - Migration: [Description]

## 🎯 Objectif
Migrer [table/schema/data] de [état A] vers [état B]

## ✅ Ce qui EST demandé
- [ ] Script de migration UP
- [ ] Script de migration DOWN (rollback)
- [ ] Test de la migration
- [ ] Backup avant migration

## 🚫 Ce qui N'EST PAS demandé
- Migration de données non concernées
- Optimisation de requêtes existantes
- Changement d'ORM/driver

## ⚠️ Contrainte CRITIQUE
```
BACKUP OBLIGATOIRE AVANT TOUTE MIGRATION
ROLLBACK TESTÉ OBLIGATOIRE
```

## 📂 Fichiers autorisés
| Fichier | Action |
|---------|--------|
| `migrations/YYYYMMDD_[name].sql` | Créer |
| `migrations/YYYYMMDD_[name]_down.sql` | Créer |

## 📝 Checklist
### Étape 1 : Préparation
- [ ] Backup de la DB actuelle
- [ ] Documenter état actuel

### Étape 2 : Migration UP
- [ ] Écrire script UP
- [ ] Tester sur DB de test

### Étape 3 : Migration DOWN
- [ ] Écrire script DOWN
- [ ] Tester rollback sur DB de test

### Étape 4 : Exécution
- [ ] Exécuter sur DB cible
- [ ] Vérifier intégrité données
```

---

## 4. WORKFLOW AVEC CURRENT.MD

### Cycle de vie

```
┌──────────────────────────────────────────────────────────────┐
│                  CYCLE DE VIE CURRENT.MD                     │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  1. CRÉATION (Humain)                                        │
│     └─► Copier template                                      │
│     └─► Remplir Objectif + Ce qui EST/N'EST PAS demandé     │
│                                                              │
│  2. AUDIT (Agent)                                            │
│     └─► Remplir "État actuel vérifié"                       │
│     └─► Compléter "Fichiers autorisés"                      │
│     └─► Rédiger Checklist détaillée                         │
│                                                              │
│  3. VALIDATION (Humain)                                      │
│     └─► Review du plan                                       │
│     └─► Cocher "GO pour BUILD"                              │
│                                                              │
│  4. BUILD (Agent)                                            │
│     └─► Exécuter checklist                                   │
│     └─► Cocher chaque étape APRÈS (pas avant)               │
│     └─► Commit après chaque étape                           │
│                                                              │
│  5. PROVE (Agent)                                            │
│     └─► Remplir "Preuves de complétion"                     │
│     └─► Remplir "Commits effectués"                         │
│                                                              │
│  6. ARCHIVE (Humain)                                         │
│     └─► Déplacer vers @specs/archive/YYYY-MM-DD_[name].md  │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### Règles strictes

| Règle | Détail |
|-------|--------|
| 1 feature = 1 CURRENT.md | Pas de mélange |
| Validation AVANT build | Jamais de code sans OK humain |
| Cocher APRÈS | Pas cocher en avance |
| Fichiers listés UNIQUEMENT | Bloquer si hors liste |
| Preuves OBLIGATOIRES | Pas de "c'est fait" sans output |

---

## 5. EXEMPLES DO / DON'T

### Exemple 1 : Section "Ce qui N'EST PAS demandé"

| ❌ Vide ou vague | ✅ Explicite |
|------------------|--------------|
| (rien) | - Pas de modal de confirmation |
| "Pas de trucs en plus" | - Pas d'animation |
| | - Pas de logging avancé |
| | - Pas de refactoring du code existant |

### Exemple 2 : Fichiers autorisés

| ❌ Vague | ✅ Précis |
|----------|----------|
| "Les fichiers nécessaires" | `src/users/create.ts` - Créer |
| "Le dossier src" | `src/routes/index.ts` - Modifier ligne 15 |
| | `tests/users/create.test.ts` - Créer |

### Exemple 3 : Checklist

| ❌ Vague | ✅ Actionnable |
|----------|----------------|
| "Implémenter la feature" | [ ] Créer fichier src/users/create.ts |
| "Faire les tests" | [ ] Test: POST valide → 201 |
| | [ ] Test: email dupliqué → 409 |
| | [ ] Test: email invalide → 400 |

### Exemple 4 : Preuves

| ❌ Insuffisant | ✅ Complet |
|----------------|-----------|
| "Tests OK" | ```npm test``` |
| "Ça marche" | ``` PASS tests/users.test.ts ``` |
| | ``` 4/4 tests passed ``` |

---

## 📋 CHECKLIST CURRENT.MD

### Avant de commencer (Humain)

- [ ] Template copié
- [ ] Objectif clair (1-2 phrases)
- [ ] "Ce qui EST demandé" listé
- [ ] "Ce qui N'EST PAS demandé" explicite
- [ ] Fichiers autorisés identifiés

### Avant BUILD (Agent → Humain)

- [ ] État vérifié rempli
- [ ] Checklist détaillée
- [ ] Risques identifiés
- [ ] ✅ Validation humaine obtenue

### Après BUILD (Agent)

- [ ] Toutes étapes cochées
- [ ] Preuves fournies
- [ ] Commits listés
- [ ] Notes de session si pertinent

---

**Fiabilité** : 97%
**💡 Conseil** : Un CURRENT.md bien rempli = 80% du travail anti-désalignement fait.
