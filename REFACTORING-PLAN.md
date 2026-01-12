# Plan de Refactoring - ALFA-Agent-Method
**Date:** 2026-01-12
**Objectif:** Nettoyer et réorganiser le projet pour une structure PARFAITE

---

## 📊 Problèmes Identifiés

### 🔴 Racine polluée
- **24 fichiers MD** à la racine (devrait être ~5 max)
- Mélange de docs officielles (00-11) et fichiers de travail
- Doublons avec `/docs/`

### 🟡 Dossier `.mcp/` désordonné
- **22 fichiers MD historiques** (rapports, status, tests)
- Code fonctionnel (alfa-server.js, tools/) mélangé avec docs
- Devrait contenir UNIQUEMENT le serveur MCP actif

### 🟡 Dossier `docs/` redondant
- Doublon avec fichiers racine
- Pas de structure claire

---

## 🎯 Structure Cible

```
ALFA-Agent-Method/
├── README.md                    # Point d'entrée
├── CORE.md                      # Prompt système (nouveau)
├── CURRENT.md                   # Mission actuelle
├── .gitignore
├── .cursorrules
│
├── alfa-dashboard/              # Stack Docker (sous-projet)
│   └── [inchangé]
│
├── mcp-server/                  # Serveur MCP ALFA (renommé de .mcp/)
│   ├── README.md
│   ├── package.json
│   ├── alfa-server.js           # Point d'entrée
│   ├── tools/                   # Modules outils
│   └── tests/                   # Tests E2E
│
├── docs/                        # Documentation consolidée
│   ├── method/                  # Méthode ALFA
│   │   ├── 01-METHODE-ALFA.md
│   │   ├── 02-ANTI-DESALIGNEMENT.md
│   │   └── 03-CHECKLIST-PROJET.md
│   ├── stack/                   # Infrastructure
│   │   ├── 01-STACK-COMPLETE.md
│   │   ├── 02-CICD-PIPELINES.md
│   │   └── 03-WORKFLOWS-N8N.md
│   ├── guides/                  # Guides pratiques
│   │   ├── cursorrules.md
│   │   ├── prompts-systeme.md
│   │   └── specs-templates.md
│   ├── mcp/                     # Documentation MCP
│   │   └── lazy-loading-guide.md
│   └── glossaire.md
│
├── archive/                     # Fichiers historiques (nouveau)
│   ├── analyses/
│   ├── reflexions/
│   ├── status-reports/
│   └── migrations/
│
└── backups/                     # Backups SQL (gitignored)
```

---

## 🔄 Actions de Refactoring

### Phase 1: Créer nouvelle structure
```bash
mkdir -p mcp-server/tests
mkdir -p docs/{method,stack,guides,mcp}
mkdir -p archive/{analyses,reflexions,status-reports,migrations}
```

### Phase 2: Déplacer fichiers méthode ALFA
```bash
# Racine → docs/method/
mv 01-METHODE-ALFA.md docs/method/
mv 03-ANTI-DESALIGNEMENT.md docs/method/
mv 09-CHECKLIST-PROJET.md docs/method/
```

### Phase 3: Déplacer fichiers stack
```bash
# Racine → docs/stack/
mv 04-STACK-COMPLETE.md docs/stack/01-STACK-COMPLETE.md
mv 05-CICD-PIPELINES.md docs/stack/02-CICD-PIPELINES.md
mv 06-WORKFLOWS-N8N.md docs/stack/03-WORKFLOWS-N8N.md
mv 11-STACK-SELFHOSTED-VPS.md docs/stack/04-SELFHOSTED-VPS.md
```

### Phase 4: Déplacer guides
```bash
# Racine → docs/guides/
mv 02-CURSORRULES.md docs/guides/cursorrules.md
mv 07-PROMPTS-SYSTEME.md docs/guides/prompts-systeme.md
mv 08-SPECS-TEMPLATES.md docs/guides/specs-templates.md
mv 10-GLOSSAIRE.md docs/glossaire.md
```

### Phase 5: Archiver fichiers historiques
```bash
# Racine → archive/
mv ANALYSE-*.md archive/analyses/
mv REFLEXION-*.md archive/reflexions/
mv REPONSE-*.md archive/reflexions/
mv SYNTHESE-*.md archive/reflexions/
mv IMPLEMENTATION-COMPLETE.md archive/migrations/
mv STATUS-ALFA-DASHBOARD.md archive/status-reports/
mv TODO-ALFA-DASHBOARD.md archive/status-reports/
mv ACTION-GITHUB-AUTH.md archive/guides/
mv MCP-ACCESS.md archive/migrations/
```

### Phase 6: Réorganiser .mcp/ → mcp-server/
```bash
# Déplacer code fonctionnel
mv .mcp/alfa-server.js mcp-server/
mv .mcp/tools/ mcp-server/
mv .mcp/package.json mcp-server/
mv .mcp/package-lock.json mcp-server/
mv .mcp/test-e2e.js mcp-server/tests/
mv .mcp/test-results.json mcp-server/tests/

# Archiver docs MCP historiques
mv .mcp/MCP-LAZY-LOADING-GUIDE.md docs/mcp/lazy-loading-guide.md
mv .mcp/*.md archive/mcp-history/

# Supprimer node_modules (sera réinstallé)
rm -rf .mcp/node_modules
```

### Phase 7: Nettoyer docs/ existant
```bash
# Supprimer doublons
rm docs/00-CORE.md           # Remplacé par /CORE.md
rm docs/ALFA-METHOD.md       # Doublon avec 01-METHODE-ALFA.md
mv docs/FAISABILITE-COMPLETE.md archive/reflexions/
```

### Phase 8: Mettre à jour README.md racine
Pointer vers nouvelle structure

### Phase 9: Créer mcp-server/README.md
Documentation du serveur MCP

---

## ✅ Fichiers à Conserver à la Racine

1. **README.md** - Point d'entrée projet
2. **CORE.md** - Prompt système agent
3. **CURRENT.md** - Mission en cours
4. **.gitignore** - Git config
5. **.cursorrules** - Cursor config
6. **.claude/** - Claude Code config

**Total racine:** 6 fichiers (+3 dossiers principaux)

---

## 🗑️ Fichiers à Supprimer

```bash
# Scripts orphelins déjà dans .mcp/
rm .mcp/configure-slack.sh
rm .mcp/slack-webhook.js
rm .mcp/alfa-manage.sh

# Backups de fichiers (déjà dans archive ou git)
rm .mcp/TOOLS-CATALOG-v1-backup.md
rm .mcp/tools-list.json
rm .mcp/list-tools.js
```

---

## 📝 Fichiers à Créer

1. **mcp-server/README.md** - Doc serveur MCP
2. **docs/README.md** - Index documentation
3. **archive/README.md** - Explication archive

---

## 🎯 Résultat Final

### Avant
- 24 fichiers MD racine
- .mcp/ pollué (22 MD + code)
- docs/ redondant (3 MD)
- **Total:** ~50 fichiers désorganisés

### Après
- 3 fichiers MD racine (+ CORE.md)
- mcp-server/ propre (code + tests)
- docs/ structuré (3 catégories)
- archive/ pour historique
- **Total:** Structure claire et maintenable

---

## ⚠️ Pré-requis Avant Exécution

1. ✅ Commit état actuel
2. ✅ Backup SQL déjà dans backups/
3. ⚠️ Validation structure par Arnaud
4. ⚠️ Tests serveur MCP après déplacement

---

## 🚀 Commande d'Exécution

```bash
# À exécuter depuis la racine du projet
bash refactoring-script.sh
```
