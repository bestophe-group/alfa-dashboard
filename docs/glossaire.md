# 10 - GLOSSAIRE
## Termes et Définitions ALFA-Agent

---

## 📑 SOMMAIRE

1. [Termes Anti-Désalignement](#1-termes-anti-désalignement)
2. [Termes Workflow](#2-termes-workflow)
3. [Termes Techniques](#3-termes-techniques)
4. [Acronymes](#4-acronymes)
5. [Formules Interdites vs Autorisées](#5-formules-interdites-vs-autorisées)

---

## 1. TERMES ANTI-DÉSALIGNEMENT

### Désalignement
> Situation où l'agent fait **autre chose** que ce qui est demandé.

| Type | Définition | Exemple |
|------|------------|---------|
| **Hallucination** | Invention de faits | "Cette API a une méthode X" (faux) |
| **Drift** | Dérive hors du scope | Ajouter des features non demandées |
| **Contournement** | Ignorer une règle | Supprimer un test qui échoue |
| **Overclaim** | Affirmer sans preuve | "C'est fait" sans output |

### Alignement
> État où l'agent exécute **exactement** ce qui est demandé, ni plus ni moins.

### Murphy Defense
> Ensemble de 28 failure modes identifiés et leurs parades.

### Golden Dataset
> Jeu de données de référence pour évaluer les réponses de l'agent.

### Régression
> Dégradation de la qualité par rapport à un état précédent.

---

## 2. TERMES WORKFLOW

### INTAKE
> Phase 1 : Réception et reformulation de la demande.
- **Input** : Demande orale/écrite
- **Output** : CURRENT.md section Objectif

### AUDIT
> Phase 2 : Vérification de l'état réel du système.
- **Input** : CURRENT.md
- **Output** : Section "État vérifié"

### PLAN
> Phase 3 : Rédaction du plan d'exécution.
- **Input** : État vérifié
- **Output** : Checklist détaillée
- **⚠️ Requiert validation humaine**

### BUILD
> Phase 4 : Exécution du plan étape par étape.
- **Input** : Plan validé
- **Output** : Code + Tests

### PROVE
> Phase 5 : Fourniture des preuves de complétion.
- **Input** : Code terminé
- **Output** : Screenshots, logs, outputs

### CURRENT.md
> Document de spécification vivant qui définit le scope exact d'une feature.

### Spec First
> Principe : jamais de code sans spécification écrite et validée.

### Validation Humaine
> Point de contrôle obligatoire entre PLAN et BUILD.

---

## 3. TERMES TECHNIQUES

### Infisical
> Gestionnaire de secrets open-source. Source de vérité pour les variables d'environnement.

```bash
# Usage
infisical run -- npm run dev
```

### MCP Gateway
> Hub central pour les outils MCP (Model Context Protocol).
- Port par défaut : 50800
- Outils : obsidian, brave-search, github, n8n

### Context7
> Service de documentation officielle pour les librairies. Anti-hallucination.

```
Avant d'utiliser une lib → Consulter Context7
```

### MCP (Model Context Protocol)
> Protocole standard pour connecter des outils aux LLM.

### RAG (Retrieval Augmented Generation)
> Technique pour enrichir les réponses LLM avec des données externes.

### Eval Suite
> Suite de tests automatisés pour valider les outputs LLM.

### Token
> Unité de mesure du texte pour les LLM (~4 caractères en anglais).

### Context Window
> Limite de texte qu'un LLM peut traiter en une fois (ex: 200k tokens).

### Commit Atomique
> Commit qui contient un seul changement logique, < 400 lignes.

### TDD (Test-Driven Development)
> Pratique : écrire les tests AVANT le code.

### Clean Architecture
> Structure de code avec séparation stricte des responsabilités.

```
src/
├── domain/        # Logique métier
├── application/   # Use cases
├── infrastructure/# DB, APIs
└── presentation/  # HTTP, CLI
```

### SPIKE
> Mode exploration limité à 4h. Aucun code en prod.

### IMPL
> Mode implémentation standard avec TDD et specs.

---

## 4. ACRONYMES

| Acronyme | Signification | Contexte |
|----------|---------------|----------|
| **ALFA** | Agent LLM Framework for Alignment | Nom de la méthode |
| **IANA** | Intelligent Automated Network Administrator | Identité agent |
| **LLM** | Large Language Model | Claude, GPT, etc. |
| **MCP** | Model Context Protocol | Protocole outils |
| **RAG** | Retrieval Augmented Generation | Enrichissement contexte |
| **TDD** | Test-Driven Development | Tests d'abord |
| **CI/CD** | Continuous Integration/Continuous Deployment | Pipelines auto |
| **PR** | Pull Request | Demande de merge |
| **DB** | Database | Base de données |
| **API** | Application Programming Interface | Interface |
| **JWT** | JSON Web Token | Auth token |
| **SSH** | Secure Shell | Connexion sécurisée |
| **CRUD** | Create Read Update Delete | Opérations de base |
| **ORM** | Object-Relational Mapping | Abstraction DB |

---

## 5. FORMULES INTERDITES VS AUTORISÉES

### ❌ Formules INTERDITES

| Formule | Problème | Alternative |
|---------|----------|-------------|
| "De mémoire..." | Hallucination probable | "Je vérifie dans Context7..." |
| "Je pense que..." | Supposition | "D'après [source]..." |
| "Normalement..." | Incertitude | "Je teste pour confirmer..." |
| "Ça devrait..." | Overclaim | "Voici le résultat : [output]" |
| "En général..." | Généralisation | "Dans ce cas précis..." |
| "Je suppose..." | Supposition | "Je vérifie..." |
| "J'ai aussi ajouté..." | Scope drift | "Ce n'est pas dans la spec" |
| "Pour simplifier..." | Contournement | "Je suis le plan exact" |
| "C'est fait" | Sans preuve | "Voici la preuve : [output]" |

### ✅ Formules AUTORISÉES

| Formule | Pourquoi c'est bien |
|---------|---------------------|
| "Je vérifie dans [source]..." | Action vérifiable |
| "D'après Context7, la syntaxe est..." | Source citée |
| "Je viens de tester, voici le résultat..." | Preuve fournie |
| "Avant de continuer, je confirme..." | Validation demandée |
| "Ce fichier n'est pas dans la spec, on l'ajoute ?" | Respect du scope |
| "Je suis bloqué sur [X] parce que [Y]" | Transparence |
| "⚠️ Désalignement potentiel détecté" | Auto-détection |

---

## 📊 MATRICE DE RÉFÉRENCE RAPIDE

### Quand utiliser quoi

| Situation | Outil/Action |
|-----------|--------------|
| Syntaxe d'une lib | Context7 |
| Variable manquante | Demander ajout Infisical |
| Info dans KB | MCP Obsidian |
| Recherche web | MCP Brave/Perplexity |
| Créer issue | MCP GitHub |
| Avant de coder | CURRENT.md |
| Avant BUILD | Validation humaine |
| Après BUILD | Preuves |
| Test qui échoue | Corriger le CODE |
| Scope drift détecté | STOP + signaler |

### Signaux par couleur

| 🔴 STOP | 🟠 ATTENTION | 🟢 OK |
|---------|--------------|-------|
| "De mémoire" | Code > 50 lignes | Source citée |
| Test supprimé | Fichier pas listé | Preuve fournie |
| "C'est fait" sans preuve | Pas de commit | Validation obtenue |
| Secret hardcodé | Estimation dépassée | Spec suivie |

---

## 📚 RESSOURCES

### Documentation ALFA
- `00-LISEZMOI.md` - Navigation
- `01-METHODE-ALFA.md` - Workflow complet
- `02-CURSORRULES.md` - Règles agent
- `03-ANTI-DESALIGNEMENT.md` - 28 failure modes
- `04-STACK-COMPLETE.md` - Outils
- `05-CICD-PIPELINES.md` - Pipelines
- `06-WORKFLOWS-N8N.md` - Automation
- `07-PROMPTS-SYSTEME.md` - Templates prompts
- `08-SPECS-TEMPLATES.md` - Templates specs
- `09-CHECKLIST-PROJET.md` - Checklists

### Ressources externes
- [Anthropic Claude](https://docs.anthropic.com)
- [Infisical Docs](https://infisical.com/docs)
- [MCP Protocol](https://modelcontextprotocol.io)
- [Context7](https://context7.com)

---

**Fiabilité** : 99%
**💡 Conseil** : Garder ce glossaire ouvert pendant les sessions pour référence rapide.
