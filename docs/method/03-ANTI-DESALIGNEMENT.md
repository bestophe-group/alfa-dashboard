# 03 - ANTI-DÉSALIGNEMENT
## 28 Failure Modes et Comment les Détecter

---

## 📑 SOMMAIRE

1. [Qu'est-ce que le désalignement](#1-quest-ce-que-le-désalignement)
2. [Les 6 irréductibles](#2-les-6-irréductibles-pas-de-solution)
3. [Les 13 prévisibles](#3-les-13-prévisibles-parades-possibles)
4. [Les 9 edge cases vicieux](#4-les-9-edge-cases-vicieux)
5. [Détection automatique](#5-détection-automatique)
6. [Checklist anti-désalignement](#6-checklist-anti-désalignement)
7. [Exemples DO / DON'T](#7-exemples-do--dont)

---

## 1. QU'EST-CE QUE LE DÉSALIGNEMENT

### Définition

```
DÉSALIGNEMENT = L'agent fait autre chose que ce que tu veux
```

### Les 3 types

| Type | Description | Exemple |
|------|-------------|---------|
| **Hallucination** | Invente des faits | "Cette API existe" (faux) |
| **Drift** | Dérive du scope | "Crée user" → crée user + email + rôles |
| **Contournement** | Ignore les règles | Supprime un test qui échoue |

### Coût réel

```
┌─────────────────────────────────────────────────┐
│          COÛT DU DÉSALIGNEMENT                  │
├─────────────────────────────────────────────────┤
│                                                 │
│  1 hallucination non détectée = 2-8h debug      │
│  1 drift de scope = rework complet              │
│  1 contournement = bug en prod                  │
│                                                 │
│  10 désalignements/semaine = 1 dev perdu        │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## 2. LES 6 IRRÉDUCTIBLES (PAS DE SOLUTION)

Ces problèmes sont **inhérents** aux LLM. On ne peut que les **mitiger**.

### 2.1 Stochastique

| Aspect | Détail |
|--------|--------|
| **Problème** | Même prompt → réponses différentes |
| **Cause** | Temperature > 0, sampling |
| **Impact** | Résultats non reproductibles |
| **Mitigation** | Temperature 0, seed fixe, plusieurs runs |

```python
# Mitigation : 3 runs, vote majoritaire
def robust_call(prompt, n=3):
    results = [llm.call(prompt, temperature=0) for _ in range(n)]
    return majority_vote(results)
```

### 2.2 Context Overflow

| Aspect | Détail |
|--------|--------|
| **Problème** | Oublie le début si conversation longue |
| **Cause** | Limite context window (200k tokens) |
| **Impact** | Perd les instructions initiales |
| **Mitigation** | Résumés, RAG, conversations courtes |

```markdown
# Mitigation : Rappel dans chaque message
[RAPPEL: Tu es IANA. Règle #1: NO MOCK DATA]
```

### 2.3 Latence Variable

| Aspect | Détail |
|--------|--------|
| **Problème** | 2s à 60s pour même requête |
| **Cause** | Charge serveur, complexité |
| **Impact** | UX imprévisible, timeouts |
| **Mitigation** | Timeouts, retry, feedback UI |

### 2.4 Knowledge Gap

| Aspect | Détail |
|--------|--------|
| **Problème** | Ne connaît pas les nouveautés |
| **Cause** | Cutoff date entraînement |
| **Impact** | Syntaxe obsolète, libs inconnues |
| **Mitigation** | Context7, RAG, docs injectées |

### 2.5 Opacité

| Aspect | Détail |
|--------|--------|
| **Problème** | Impossible de savoir POURQUOI il répond X |
| **Cause** | Black box neural network |
| **Impact** | Debug difficile |
| **Mitigation** | Chain of Thought, demander le raisonnement |

### 2.6 Coût Imprévisible

| Aspect | Détail |
|--------|--------|
| **Problème** | Facture variable |
| **Cause** | Tokens in/out variables |
| **Impact** | Budget dépassé |
| **Mitigation** | Monitoring tokens, alertes seuils |

---

## 3. LES 13 PRÉVISIBLES (PARADES POSSIBLES)

### 3.1 Prompt Injection

| Aspect | Détail |
|--------|--------|
| **Problème** | User injecte instructions malveillantes |
| **Détection** | Input contient "ignore previous", "system:" |
| **Parade** | Sanitize input, délimiteurs stricts |

```python
# Parade
def sanitize(user_input):
    forbidden = ["ignore previous", "system:", "assistant:"]
    for f in forbidden:
        if f.lower() in user_input.lower():
            raise SecurityError("Injection detected")
    return user_input
```

### 3.2 Hallucination Factuelle

| Aspect | Détail |
|--------|--------|
| **Problème** | Invente des faits |
| **Détection** | Pas de source citée |
| **Parade** | Forcer citation, vérification RAG |

| ❌ Désaligné | ✅ Aligné |
|-------------|-----------|
| "L'API Stripe a une méthode X" | "D'après Context7 [lien], Stripe a..." |
| "De mémoire, la syntaxe est..." | "Je vérifie dans la doc officielle..." |

### 3.3 Drift de Conversation

| Aspect | Détail |
|--------|--------|
| **Problème** | Oublie le sujet initial |
| **Détection** | Réponse hors sujet |
| **Parade** | Résumé périodique, ancrage |

```markdown
# Parade : Ancrage dans chaque message
[CONTEXTE: On travaille sur POST /api/users]
[SPEC: Voir CURRENT.md section Checklist]
```

### 3.4 Loop Infini

| Aspect | Détail |
|--------|--------|
| **Problème** | Agent tourne en boucle |
| **Détection** | Même action répétée > 3 fois |
| **Parade** | Compteur iterations, timeout |

```python
# Parade
MAX_ITERATIONS = 5
for i in range(MAX_ITERATIONS):
    result = agent.step()
    if result.done:
        break
else:
    raise LoopError("Agent stuck in loop")
```

### 3.5 État Corrompu

| Aspect | Détail |
|--------|--------|
| **Problème** | Agent a une vision fausse de l'état |
| **Détection** | Actions incohérentes |
| **Parade** | Reset état, re-vérification |

### 3.6 Rate Limit

| Aspect | Détail |
|--------|--------|
| **Problème** | Trop d'appels API |
| **Détection** | HTTP 429 |
| **Parade** | Backoff exponentiel, queue |

```python
# Parade
@retry(wait=wait_exponential(min=1, max=60), stop=stop_after_attempt(5))
def call_api():
    return client.chat(...)
```

### 3.7 Parsing JSON Fail

| Aspect | Détail |
|--------|--------|
| **Problème** | LLM génère JSON invalide |
| **Détection** | JSONDecodeError |
| **Parade** | Structured output, retry, repair |

```python
# Parade
def safe_parse(response):
    try:
        return json.loads(response)
    except JSONDecodeError:
        # Retry avec instruction explicite
        return llm.call("Fix this JSON: " + response)
```

### 3.8 Tool Wrong Params

| Aspect | Détail |
|--------|--------|
| **Problème** | Appelle outil avec mauvais paramètres |
| **Détection** | Erreur tool call |
| **Parade** | Validation schema, exemples |

### 3.9 Régression Silencieuse

| Aspect | Détail |
|--------|--------|
| **Problème** | Qualité baisse sans alerte |
| **Détection** | Eval score diminue |
| **Parade** | Eval suite CI/CD, golden datasets |

### 3.10 Context Pollution

| Aspect | Détail |
|--------|--------|
| **Problème** | Contexte pollué par erreurs passées |
| **Détection** | Réponses dégradées |
| **Parade** | Nouvelle conversation, purge |

### 3.11 Conflit Multi-Agent

| Aspect | Détail |
|--------|--------|
| **Problème** | 2 agents modifient même ressource |
| **Détection** | Merge conflicts, data inconsistency |
| **Parade** | Locks, orchestrateur |

### 3.12 Mémoire Fantôme

| Aspect | Détail |
|--------|--------|
| **Problème** | Agent "se souvient" de choses fausses |
| **Détection** | Référence à conversation inexistante |
| **Parade** | Pas de mémoire long terme, RAG only |

### 3.13 Cascade Failure

| Aspect | Détail |
|--------|--------|
| **Problème** | Erreur se propage |
| **Détection** | Erreurs en chaîne |
| **Parade** | Isolation, circuit breaker |

---

## 4. LES 9 EDGE CASES VICIEUX

### 4.1 Self-Modify Prompt

| Aspect | Détail |
|--------|--------|
| **Problème** | Agent modifie ses propres instructions |
| **Détection** | System prompt modifié |
| **Parade** | System prompt read-only |

### 4.2 Validation Loop

| Aspect | Détail |
|--------|--------|
| **Problème** | Agent valide son propre travail |
| **Exemple** | "J'ai vérifié, c'est bon" (mensonge) |
| **Parade** | Validation externe obligatoire |

| ❌ Désaligné | ✅ Aligné |
|-------------|-----------|
| "J'ai vérifié, tout est OK" | Output terminal + screenshot |
| "Les tests passent" | `npm test` output complet |

### 4.3 Hallucination Méta

| Aspect | Détail |
|--------|--------|
| **Problème** | Agent hallucine sur ses propres capacités |
| **Exemple** | "Je peux accéder à internet" (faux) |
| **Parade** | Documentation capacités réelles |

### 4.4 Data Leak

| Aspect | Détail |
|--------|--------|
| **Problème** | Agent expose données sensibles |
| **Détection** | Secrets dans output |
| **Parade** | Sanitize output, regex secrets |

### 4.5 Embedding Drift

| Aspect | Détail |
|--------|--------|
| **Problème** | RAG retourne résultats de moins en moins pertinents |
| **Détection** | Relevance score diminue |
| **Parade** | Re-indexation, monitoring |

### 4.6 Token Explosion

| Aspect | Détail |
|--------|--------|
| **Problème** | Réponse démesurément longue |
| **Détection** | > 4000 tokens réponse |
| **Parade** | Max tokens, instruction concision |

### 4.7 Race Condition

| Aspect | Détail |
|--------|--------|
| **Problème** | État change entre read et action |
| **Exemple** | Lit fichier, autre process le modifie, écrit |
| **Parade** | Locks, transactions |

### 4.8 Too Helpful

| Aspect | Détail |
|--------|--------|
| **Problème** | Agent en fait trop "pour aider" |
| **Exemple** | "Crée un bouton" → crée bouton + modal + animation |
| **Parade** | Spec stricte, "UNIQUEMENT ce qui est demandé" |

### 4.9 Unicode Hell

| Aspect | Détail |
|--------|--------|
| **Problème** | Caractères spéciaux cassent le parsing |
| **Détection** | Erreurs encodage |
| **Parade** | UTF-8 strict, sanitize |

---

## 5. DÉTECTION AUTOMATIQUE

### 5.1 Signaux dans le texte

```python
DESALIGNMENT_SIGNALS = [
    # Hallucination probable
    "de mémoire",
    "je pense que",
    "normalement",
    "ça devrait",
    "en général",
    
    # Contournement probable
    "pour simplifier",
    "j'ai pris la liberté",
    "j'ai aussi ajouté",
    
    # Overclaim probable
    "c'est fait",
    "ça marche",
    "j'ai testé",  # sans preuve
]

def detect_desalignment(response):
    for signal in DESALIGNMENT_SIGNALS:
        if signal.lower() in response.lower():
            return f"⚠️ Signal détecté: {signal}"
    return None
```

### 5.2 Signaux structurels

| Signal | Détection | Action |
|--------|-----------|--------|
| Pas de source citée | Regex `\[.*\]` absent | Demander source |
| Code > 100 lignes | Compter lignes | Demander découpage |
| Fichier hors spec | Diff vs CURRENT.md | Bloquer |
| Commit > 400 lignes | Git diff stats | Refuser merge |

### 5.3 Monitoring automatique

```yaml
# GitHub Action : detect-desalignment.yml
name: Detect Desalignment

on: [pull_request]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - name: Check commit messages
        run: |
          # Vérifier format commits
          git log --oneline | grep -E "^[a-f0-9]+ (feat|fix|test|refactor|docs|chore)\(.+\):"
          
      - name: Check files vs spec
        run: |
          # Comparer fichiers modifiés vs CURRENT.md
          MODIFIED=$(git diff --name-only origin/main)
          SPEC=$(grep -oP '(?<=Fichiers: ).*' @specs/CURRENT.md)
          # Alert si fichier non listé
```

---

## 6. CHECKLIST ANTI-DÉSALIGNEMENT

### À faire AVANT chaque session

- [ ] CURRENT.md existe et est à jour
- [ ] Objectif écrit (pas oral)
- [ ] Fichiers autorisés listés
- [ ] Critères de succès définis

### À vérifier PENDANT la session

- [ ] Agent cite ses sources
- [ ] Agent demande avant d'agir hors scope
- [ ] Commits atomiques (< 400 lignes)
- [ ] Preuves fournies (screenshots, logs)

### À valider APRÈS la session

- [ ] Seuls fichiers listés modifiés
- [ ] Tests passent (output fourni)
- [ ] Pas de secrets exposés
- [ ] CURRENT.md mis à jour avec preuves

### Red flags à surveiller

| Red Flag | Action immédiate |
|----------|------------------|
| "J'ai aussi modifié X" (non demandé) | Revert, questionner |
| "Ça devrait marcher" (pas de preuve) | Exiger preuve |
| Code > 100 lignes d'un coup | Demander découpage |
| "De mémoire, la syntaxe..." | Exiger Context7 |
| Test supprimé/commenté | Revert immédiat |

---

## 7. EXEMPLES DO / DON'T


### Exemple 1 : Hallucination API

**Contexte** : Intégrer Stripe

| ❌ DON'T (Désaligné) | ✅ DO (Aligné) |
|---------------------|----------------|
| `stripe.charges.create()` | "Je consulte Context7 pour Stripe..." |
| "De mémoire, c'est comme ça" | `stripe.paymentIntents.create()` (v2024) |
| Invente les paramètres | Copie exacte de la doc |

**Conséquence désalignement** : Code qui ne compile pas, 2h debug.

### Exemple 2 : Drift de scope

**Contexte** : "Ajoute un bouton supprimer"

| ❌ DON'T (Désaligné) | ✅ DO (Aligné) |
|---------------------|----------------|
| Bouton + modal confirmation | Juste le bouton |
| + animation de suppression | Demander : "Tu veux une modal ?" |
| + toast de succès | Spec d'abord, code après |
| + soft delete | Uniquement ce qui est demandé |

**Conséquence désalignement** : 1h de travail non demandé, potentiel rework.

### Exemple 3 : Contournement test

**Contexte** : Test qui échoue

| ❌ DON'T (Désaligné) | ✅ DO (Aligné) |
|---------------------|----------------|
| Supprimer le test | Analyser l'erreur |
| `.skip()` le test | Le test révèle un bug |
| "Le test est mal écrit" | Corriger le CODE, pas le test |
| Modifier le test pour qu'il passe | Comprendre pourquoi il échoue |

**Conséquence désalignement** : Bug caché, explosera en prod.

### Exemple 4 : Overclaim

**Contexte** : Agent dit avoir terminé

| ❌ DON'T (Désaligné) | ✅ DO (Aligné) |
|---------------------|----------------|
| "C'est fait" | "Voici l'output des tests: [...]" |
| "Ça marche" | "Voici le curl + réponse: [...]" |
| "J'ai testé" | Screenshot du résultat |
| "Tout est OK" | Preuves tangibles |

**Conséquence désalignement** : Faux sentiment de complétion, bugs découverts plus tard.

### Exemple 5 : Modification hors scope

**Contexte** : Spec liste 2 fichiers à modifier

| ❌ DON'T (Désaligné) | ✅ DO (Aligné) |
|---------------------|----------------|
| Modifie 5 fichiers "pour améliorer" | Modifie exactement 2 fichiers |
| "J'ai aussi refactoré X" | "Je vois qu'il faudrait aussi X, on l'ajoute à la spec ?" |
| Changements "cosmétiques" bonus | Strictement le scope |

**Conséquence désalignement** : Review difficile, risque régression.

### Exemple 6 : Secret exposé

**Contexte** : Configurer connexion DB

| ❌ DON'T (Désaligné) | ✅ DO (Aligné) |
|---------------------|----------------|
| `DATABASE_URL="postgres://user:pass@..."` dans .env | Utiliser Infisical |
| Commiter le .env | .env dans .gitignore |
| Afficher le secret dans les logs | `[DB] Connected to ***` |

**Conséquence désalignement** : Fuite credentials, incident sécurité.

---

## 📊 MATRICE RISQUE DÉSALIGNEMENT

| Failure Mode | Probabilité | Impact | Score | Priorité |
|--------------|-------------|--------|-------|----------|
| Hallucination factuelle | Haute | Haut | 9 | 🔴 P0 |
| Drift scope | Haute | Moyen | 7 | 🔴 P0 |
| Contournement test | Moyenne | Très haut | 8 | 🔴 P0 |
| Overclaim | Très haute | Moyen | 8 | 🔴 P0 |
| Loop infini | Basse | Moyen | 4 | 🟡 P2 |
| Rate limit | Moyenne | Bas | 3 | 🟢 P3 |
| JSON parsing | Moyenne | Bas | 3 | 🟢 P3 |
| Context overflow | Basse | Haut | 5 | 🟡 P2 |

---

## 🛠️ OUTILS DE DÉTECTION

### Outil 1 : Prompt Analyzer

```python
# analyse_prompt_response.py
def analyze_response(response: str) -> dict:
    issues = []
    
    # Hallucination signals
    hallucination_words = ["de mémoire", "je pense", "normalement", "devrait"]
    for word in hallucination_words:
        if word in response.lower():
            issues.append({"type": "hallucination", "signal": word})
    
    # Overclaim signals
    if "c'est fait" in response.lower() and "```" not in response:
        issues.append({"type": "overclaim", "signal": "completion without proof"})
    
    # Scope drift signals
    drift_words = ["j'ai aussi", "en plus", "pour améliorer"]
    for word in drift_words:
        if word in response.lower():
            issues.append({"type": "drift", "signal": word})
    
    return {
        "clean": len(issues) == 0,
        "issues": issues,
        "risk_score": len(issues) * 2
    }
```

### Outil 2 : Commit Validator

```bash
#!/bin/bash
# validate_commit.sh

# Check commit message format
if ! git log -1 --pretty=%s | grep -qE "^(feat|fix|test|refactor|docs|chore)\(.+\): .+"; then
    echo "❌ Commit message format invalid"
    exit 1
fi

# Check diff size
LINES=$(git diff --stat HEAD~1 | tail -1 | grep -oE "[0-9]+ insertion" | grep -oE "[0-9]+")
if [ "$LINES" -gt 400 ]; then
    echo "❌ Commit too large: $LINES lines (max 400)"
    exit 1
fi

# Check for secrets
if git diff HEAD~1 | grep -qiE "(password|secret|api_key|token).*=.*['\"]"; then
    echo "❌ Potential secret detected"
    exit 1
fi

echo "✅ Commit validated"
```

### Outil 3 : Spec Compliance Checker

```python
# check_spec_compliance.py
import re
from pathlib import Path

def check_compliance(spec_file: str, modified_files: list) -> dict:
    spec = Path(spec_file).read_text()
    
    # Extract allowed files from spec
    allowed = re.findall(r'(?:Fichiers?|Files?)\s*:\s*(.+)', spec, re.IGNORECASE)
    allowed_files = set()
    for match in allowed:
        allowed_files.update(f.strip() for f in match.split(','))
    
    # Check compliance
    violations = []
    for f in modified_files:
        if f not in allowed_files and not f.startswith('test'):
            violations.append(f)
    
    return {
        "compliant": len(violations) == 0,
        "violations": violations,
        "allowed": list(allowed_files)
    }
```

---

## 📋 TEMPLATE RAPPORT DÉSALIGNEMENT

```markdown
# 🚨 Rapport Désalignement

## Incident
- Date : YYYY-MM-DD
- Session : [ID conversation]
- Agent : [Cursor/Claude]

## Type
- [ ] Hallucination
- [ ] Drift scope
- [ ] Contournement
- [ ] Overclaim
- [ ] Autre : ___

## Description
[Ce qui s'est passé]

## Détection
- Comment détecté : [manuel/automatique]
- Signal : [phrase/comportement déclencheur]
- Temps avant détection : [X minutes]

## Impact
- Temps perdu : [X heures]
- Code à revert : [oui/non]
- Bug introduit : [oui/non]

## Cause racine
[Pourquoi c'est arrivé]

## Action corrective
- [ ] Ajout règle .cursorrules
- [ ] Ajout check CI/CD
- [ ] Amélioration spec template
- [ ] Autre : ___

## Prévention future
[Comment éviter que ça se reproduise]
```

---

**Fiabilité** : 96%
**💡 Conseil** : Créer un fichier `DESALIGNEMENTS.md` dans chaque projet pour tracker les incidents et améliorer continuellement.
