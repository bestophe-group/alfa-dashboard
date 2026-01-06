# 09 - CHECKLIST PROJET
## Validation Alignement Complète

---

## 📑 SOMMAIRE

1. [Checklist Setup Projet](#1-checklist-setup-projet)
2. [Checklist par Feature](#2-checklist-par-feature)
3. [Checklist Release](#3-checklist-release)
4. [Audit Mensuel](#4-audit-mensuel)
5. [Quick Reference](#5-quick-reference)

---

## 1. CHECKLIST SETUP PROJET

### Phase 0 : Prérequis (30 min)

#### Environnement
- [ ] Node.js v20+ installé
- [ ] Git configuré (SSH)
- [ ] Cursor IDE installé
- [ ] Infisical CLI installé et login

#### Abonnements
- [ ] Anthropic API access
- [ ] GitHub repo créé
- [ ] Infisical workspace créé

#### MCP
- [ ] MCP Gateway running (port 50800)
- [ ] Context7 configuré
- [ ] Obsidian vault connecté (si KB)

### Phase 1 : Initialisation (15 min)

#### Structure dossiers
```bash
mkdir -p @specs docs/{00_Context,10_Tech,99_Assets} src tests prompts/{system,tasks,guards}
touch @specs/CURRENT.md
touch .cursorrules
touch .gitignore
```

- [ ] Structure créée
- [ ] `@specs/` avec CURRENT.md vide
- [ ] `docs/` avec sous-dossiers
- [ ] `prompts/` avec sous-dossiers

#### Fichiers config
- [ ] `.cursorrules` copié (voir 02-CURSORRULES.md)
- [ ] `.gitignore` configuré (secrets, node_modules, .env)
- [ ] `.cursor/mcp.json` créé
- [ ] `.infisical.json` initialisé (`infisical init`)

#### Git
- [ ] `git init`
- [ ] Remote ajouté (SSH)
- [ ] Premier commit : `chore(init): initial project setup`
- [ ] Branch `develop` créée

### Phase 2 : Setup CI/CD (30 min)

- [ ] `.github/workflows/alfa-ci.yml` copié
- [ ] Secrets GitHub configurés :
  - [ ] `ANTHROPIC_API_KEY`
  - [ ] `INFISICAL_TOKEN` (si utilisé en CI)
- [ ] Branch protection activée sur `main` :
  - [ ] Require PR
  - [ ] Require status checks
  - [ ] Require review

### Phase 3 : Setup Prompts (15 min)

- [ ] `prompts/system/main.md` copié
- [ ] Adapter identité si besoin
- [ ] Vérifier que .cursorrules inclut les règles

### Phase 4 : Setup DB (si applicable) (20 min)

- [ ] Choix DB : PostgreSQL / SQLite / autre
- [ ] Variables dans Infisical :
  - [ ] `DATABASE_URL`
  - [ ] `DATABASE_PASSWORD` (si séparé)
- [ ] Script migration initial
- [ ] Seed data (si applicable)

### Phase 5 : Setup Monitoring (optionnel) (30 min)

- [ ] n8n workflows importés (voir 06-WORKFLOWS-N8N.md)
- [ ] Slack webhook configuré
- [ ] Tables audit créées en DB

### Validation Setup

```bash
# Tester que tout fonctionne
infisical run -- echo "Infisical OK"
npm test || echo "Tests OK ou skip"
git push origin develop
```

- [ ] Infisical fonctionne
- [ ] Git push fonctionne (SSH)
- [ ] CI passe

---

## 2. CHECKLIST PAR FEATURE

### Avant de commencer

- [ ] CURRENT.md créé avec :
  - [ ] Objectif clair
  - [ ] Ce qui EST demandé
  - [ ] Ce qui N'EST PAS demandé
  - [ ] Fichiers autorisés

### Phase INTAKE

- [ ] Demande comprise
- [ ] Questions de clarification posées
- [ ] Scope défini par écrit

### Phase AUDIT

- [ ] Fichiers existants lus (pas supposés)
- [ ] Versions packages vérifiées
- [ ] Context7 consulté si lib externe
- [ ] État vérifié documenté dans CURRENT.md

### Phase PLAN

- [ ] Checklist technique rédigée
- [ ] Estimation temps par étape
- [ ] Risques identifiés
- [ ] **⏸️ VALIDATION HUMAINE OBTENUE**

### Phase BUILD

Pour chaque étape :
- [ ] Étape exécutée
- [ ] Test associé passe
- [ ] Commit atomique fait
- [ ] Étape cochée dans CURRENT.md

Règles respectées :
- [ ] Seuls fichiers autorisés modifiés
- [ ] Pas de "bonus" ajoutés
- [ ] Commits < 400 lignes chacun

### Phase PROVE

- [ ] Output tests fourni
- [ ] Screenshot si UI
- [ ] Curl response si API
- [ ] CURRENT.md mis à jour avec preuves

### Après la feature

- [ ] PR créée
- [ ] CI passe
- [ ] Review demandée
- [ ] Merge après approbation
- [ ] CURRENT.md archivé

---

## 3. CHECKLIST RELEASE

### Pré-release

- [ ] Tous les tests passent
- [ ] Coverage > 80%
- [ ] Pas de TODO/FIXME bloquants
- [ ] CHANGELOG.md à jour
- [ ] Version bumped (package.json)

### Release

- [ ] Tag créé : `git tag v1.x.x`
- [ ] Push tag : `git push origin v1.x.x`
- [ ] GitHub Release créée
- [ ] Notes de release rédigées

### Post-release

- [ ] Deploy vérifié (si applicable)
- [ ] Monitoring vérifié
- [ ] Communication faite (si applicable)

---

## 4. AUDIT MENSUEL

### Métriques à collecter

| Métrique | Cible | Actuel |
|----------|-------|--------|
| Incidents désalignement | < 5/mois | |
| Heures perdues désalignement | < 10h/mois | |
| Tests coverage | > 80% | |
| Commits rejetés CI | < 10% | |
| Rollbacks | < 2/mois | |

### Questions d'audit

#### Processus
- [ ] CURRENT.md utilisé pour chaque feature ?
- [ ] Validation humaine respectée ?
- [ ] Preuves fournies systématiquement ?

#### Technique
- [ ] .cursorrules à jour ?
- [ ] Prompts efficaces ?
- [ ] CI bloque les désalignements ?

#### Incidents
- [ ] Incidents documentés ?
- [ ] Causes racines identifiées ?
- [ ] Actions correctives implémentées ?

### Actions post-audit

| Problème identifié | Action | Responsable | Deadline |
|--------------------|--------|-------------|----------|
| | | | |
| | | | |

---

## 5. QUICK REFERENCE

### Commandes quotidiennes

```bash
# Démarrer session
infisical run -- npm run dev

# Avant de coder
cat @specs/CURRENT.md  # Relire la spec

# Pendant dev
npm test               # Vérifier tests
git status             # Vérifier fichiers

# Commit
git add [fichiers]
git commit -m "type(scope): description"

# Fin de session
git push origin develop
```

### Format commit

```
feat(scope): nouvelle fonctionnalité
fix(scope): correction bug
test(scope): ajout/modif tests
refactor(scope): refactoring sans changement comportement
docs(scope): documentation
chore(scope): maintenance, config
```

### Signaux STOP

| Signal | Action |
|--------|--------|
| "De mémoire..." | STOP → Context7 |
| "Ça devrait..." | STOP → Tester |
| Fichier hors spec | STOP → Demander |
| > 100 lignes sans commit | STOP → Découper |
| Test qui échoue | STOP → Fix (pas skip) |

### Checklist rapide avant commit

```
[ ] Fichier dans la spec ?
[ ] Tests passent ?
[ ] Pas de secret ?
[ ] Message format OK ?
[ ] < 400 lignes ?
```

### Structure CURRENT.md minimale

```markdown
# CURRENT.md - [Titre]

## Objectif
[1 phrase]

## Ce qui EST demandé
- [ ] Point 1
- [ ] Point 2

## Ce qui N'EST PAS demandé
- Exclusion 1
- Exclusion 2

## Fichiers autorisés
- `src/xxx.ts`
- `tests/xxx.test.ts`

## Checklist
- [ ] Étape 1
- [ ] Étape 2

⏸️ VALIDATION : [ ]

## Preuves
[À remplir]
```

---

## 📊 SCORECARD PROJET

### Auto-évaluation (0-10)

| Critère | Score | Notes |
|---------|-------|-------|
| CURRENT.md systématique | /10 | |
| Validation humaine respectée | /10 | |
| Preuves fournies | /10 | |
| Tests coverage | /10 | |
| Commits atomiques | /10 | |
| Zéro secret exposé | /10 | |
| CI qui bloque | /10 | |
| Incidents documentés | /10 | |
| **TOTAL** | **/80** | |

### Interprétation

| Score | Niveau | Action |
|-------|--------|--------|
| 70-80 | Excellent | Maintenir |
| 50-69 | Bon | Améliorer points faibles |
| 30-49 | À risque | Revoir processus |
| < 30 | Critique | Formation urgente |

---

**Fiabilité** : 96%
**💡 Conseil** : Imprimer la Quick Reference et la garder visible pendant les sessions.
