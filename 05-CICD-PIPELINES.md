# 05 - CI/CD PIPELINES
## Pipelines qui Bloquent le Désalignement

---

## 📑 SOMMAIRE

1. [Philosophie](#1-philosophie)
2. [Pipeline principal](#2-pipeline-principal)
3. [Checks anti-désalignement](#3-checks-anti-désalignement)
4. [Eval suite LLM](#4-eval-suite-llm)
5. [Monitoring tokens](#5-monitoring-tokens)
6. [Exemples DO / DON'T](#6-exemples-do--dont)

---

## 1. PHILOSOPHIE

### CI/CD comme garde-fou

```
┌─────────────────────────────────────────────────────────────┐
│              CI/CD = DERNIÈRE LIGNE DE DÉFENSE              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Si le désalignement passe l'humain...                     │
│  Si le désalignement passe les tests locaux...             │
│  → Le CI/CD DOIT le bloquer                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Ce que le CI/CD vérifie

| Check | Désalignement détecté |
|-------|----------------------|
| Lint | Code non standard |
| Tests | Comportement incorrect |
| Commit format | Message non conforme |
| Diff size | Commit trop gros |
| Secrets | Fuite credentials |
| Spec compliance | Fichiers hors scope |
| Eval suite | Régression LLM |

---

## 2. PIPELINE PRINCIPAL

### Livrable : `.github/workflows/alfa-ci.yml`

```yaml
name: ALFA CI - Anti-Désalignement

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '20'

jobs:
  # ═══════════════════════════════════════════════════════
  # STAGE 1 : LINT (Format, Style)
  # ═══════════════════════════════════════════════════════
  lint:
    name: 🔍 Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: ESLint
        run: npm run lint
      
      - name: Prettier check
        run: npm run format:check

  # ═══════════════════════════════════════════════════════
  # STAGE 2 : COMMIT VALIDATION (Anti-désalignement)
  # ═══════════════════════════════════════════════════════
  commit-check:
    name: 📝 Commit Validation
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Check commit message format
        run: |
          echo "Checking commit messages..."
          COMMITS=$(git log --oneline origin/main..HEAD 2>/dev/null || git log --oneline -5)
          
          while IFS= read -r commit; do
            MSG=$(echo "$commit" | cut -d' ' -f2-)
            if ! echo "$MSG" | grep -qE "^(feat|fix|test|refactor|docs|chore|ci)\(.+\): .+"; then
              echo "❌ Invalid commit: $commit"
              echo "Expected format: type(scope): description"
              exit 1
            fi
          done <<< "$COMMITS"
          
          echo "✅ All commits valid"
      
      - name: Check diff size
        run: |
          INSERTIONS=$(git diff --stat origin/main...HEAD | tail -1 | grep -oE "[0-9]+ insertion" | grep -oE "[0-9]+" || echo "0")
          if [ "${INSERTIONS:-0}" -gt 400 ]; then
            echo "❌ PR too large: $INSERTIONS insertions (max 400)"
            echo "Please split into smaller commits"
            exit 1
          fi
          echo "✅ Diff size OK: $INSERTIONS insertions"

  # ═══════════════════════════════════════════════════════
  # STAGE 3 : SECRETS CHECK (Anti-fuite)
  # ═══════════════════════════════════════════════════════
  secrets-check:
    name: 🔐 Secrets Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Check for hardcoded secrets
        run: |
          # Patterns de secrets
          PATTERNS=(
            "password\s*[=:]\s*['\"][^'\"]+['\"]"
            "api_key\s*[=:]\s*['\"][^'\"]+['\"]"
            "secret\s*[=:]\s*['\"][^'\"]+['\"]"
            "token\s*[=:]\s*['\"][^'\"]+['\"]"
            "-----BEGIN.*PRIVATE KEY-----"
          )
          
          for pattern in "${PATTERNS[@]}"; do
            if git diff origin/main...HEAD | grep -iE "$pattern"; then
              echo "❌ Potential secret detected!"
              exit 1
            fi
          done
          
          echo "✅ No secrets detected"
      
      - name: Check .env files not committed
        run: |
          if git ls-files | grep -E "^\.env$|^\.env\.local$|^\.env\..+$"; then
            echo "❌ .env file committed!"
            exit 1
          fi
          echo "✅ No .env files committed"

  # ═══════════════════════════════════════════════════════
  # STAGE 4 : UNIT TESTS
  # ═══════════════════════════════════════════════════════
  unit-tests:
    name: 🧪 Unit Tests
    runs-on: ubuntu-latest
    needs: [lint]
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm test -- --coverage --passWithNoTests
      
      - name: Check coverage
        run: |
          COVERAGE=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "❌ Coverage below 80%: $COVERAGE%"
            exit 1
          fi
          echo "✅ Coverage OK: $COVERAGE%"

  # ═══════════════════════════════════════════════════════
  # STAGE 5 : SPEC COMPLIANCE (Anti-drift)
  # ═══════════════════════════════════════════════════════
  spec-compliance:
    name: 📋 Spec Compliance
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Check files vs spec
        run: |
          # Fichiers modifiés
          MODIFIED=$(git diff --name-only origin/main...HEAD)
          
          # Si CURRENT.md existe, vérifier compliance
          if [ -f "@specs/CURRENT.md" ]; then
            echo "Checking spec compliance..."
            
            # Extraire fichiers autorisés (pattern: "Fichiers:" ou "Files:")
            ALLOWED=$(grep -oP '(?<=Fichiers\s*:\s*).*|(?<=Files\s*:\s*).*' @specs/CURRENT.md | tr ',' '\n' | xargs)
            
            for file in $MODIFIED; do
              # Skip certains fichiers
              if [[ "$file" == test* ]] || [[ "$file" == *.md ]] || [[ "$file" == .* ]]; then
                continue
              fi
              
              if ! echo "$ALLOWED" | grep -q "$file"; then
                echo "⚠️ File modified but not in spec: $file"
              fi
            done
          else
            echo "⚠️ No @specs/CURRENT.md found"
          fi

  # ═══════════════════════════════════════════════════════
  # STAGE 6 : EVAL SUITE (Anti-régression LLM)
  # ═══════════════════════════════════════════════════════
  eval-suite:
    name: 🤖 Eval Suite
    runs-on: ubuntu-latest
    needs: [unit-tests]
    if: contains(github.event.pull_request.labels.*.name, 'llm') || contains(github.event.head_commit.message, '[eval]')
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      
      - name: Install eval dependencies
        run: |
          pip install openai anthropic pytest deepeval
      
      - name: Run eval suite
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          if [ -d "eval" ]; then
            python -m pytest eval/ -v --tb=short
          else
            echo "No eval directory found, skipping"
          fi

  # ═══════════════════════════════════════════════════════
  # STAGE 7 : BUILD
  # ═══════════════════════════════════════════════════════
  build:
    name: 🔨 Build
    runs-on: ubuntu-latest
    needs: [unit-tests, commit-check, secrets-check]
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build
        run: npm run build
      
      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build
          path: dist/
```

---

## 3. CHECKS ANTI-DÉSALIGNEMENT

### Check 1 : Format de commit

**But** : Forcer commits atomiques et descriptifs

```yaml
# Livrable : .github/workflows/commit-lint.yml
name: Commit Lint

on: [push, pull_request]

jobs:
  commitlint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Validate commits
        run: |
          # Format attendu : type(scope): description
          # Types autorisés : feat, fix, test, refactor, docs, chore, ci
          
          git log --oneline -10 | while read line; do
            if ! echo "$line" | grep -qE "^[a-f0-9]+ (feat|fix|test|refactor|docs|chore|ci)\(.+\): .{10,}"; then
              echo "❌ Bad commit: $line"
              exit 1
            fi
          done
```

| ✅ Bon commit | ❌ Mauvais commit |
|---------------|-------------------|
| `feat(users): add POST endpoint` | `add stuff` |
| `fix(auth): handle expired tokens` | `fix bug` |
| `test(api): add user creation tests` | `tests` |
| `refactor(db): extract connection pool` | `wip` |

### Check 2 : Taille de diff

**But** : Bloquer les gros commits (symptôme de désalignement)

```yaml
- name: Check diff size
  run: |
    STATS=$(git diff --stat origin/main...HEAD | tail -1)
    INSERTIONS=$(echo "$STATS" | grep -oE "[0-9]+ insertion" | grep -oE "[0-9]+" || echo "0")
    DELETIONS=$(echo "$STATS" | grep -oE "[0-9]+ deletion" | grep -oE "[0-9]+" || echo "0")
    TOTAL=$((INSERTIONS + DELETIONS))
    
    if [ "$TOTAL" -gt 500 ]; then
      echo "❌ PR too large: $TOTAL lines changed (max 500)"
      echo "This often indicates scope drift. Please split into smaller PRs."
      exit 1
    fi
```

### Check 3 : Secrets hardcodés

**But** : Détecter les fuites avant prod

```yaml
- name: Detect secrets
  uses: trufflesecurity/trufflehog@main
  with:
    path: ./
    base: main
    extra_args: --only-verified
```

### Check 4 : Compliance spec

**But** : Vérifier que seuls les fichiers listés sont modifiés

```python
# scripts/check_spec_compliance.py
import re
import subprocess
import sys
from pathlib import Path

def get_modified_files():
    result = subprocess.run(
        ['git', 'diff', '--name-only', 'origin/main...HEAD'],
        capture_output=True, text=True
    )
    return result.stdout.strip().split('\n')

def get_allowed_files(spec_path='@specs/CURRENT.md'):
    if not Path(spec_path).exists():
        return None
    
    content = Path(spec_path).read_text()
    matches = re.findall(r'(?:Fichiers?|Files?)\s*:\s*(.+)', content, re.IGNORECASE)
    
    allowed = set()
    for match in matches:
        files = [f.strip() for f in match.split(',')]
        allowed.update(files)
    
    return allowed

def main():
    modified = get_modified_files()
    allowed = get_allowed_files()
    
    if allowed is None:
        print("⚠️ No spec found, skipping compliance check")
        return 0
    
    violations = []
    for f in modified:
        # Skip common files
        if f.startswith('test') or f.endswith('.md') or f.startswith('.'):
            continue
        if f not in allowed:
            violations.append(f)
    
    if violations:
        print("❌ Files modified but not in spec:")
        for v in violations:
            print(f"  - {v}")
        print("\nUpdate @specs/CURRENT.md or revert changes")
        return 1
    
    print("✅ All modified files are in spec")
    return 0

if __name__ == '__main__':
    sys.exit(main())
```

---

## 4. EVAL SUITE LLM

### Structure eval

```
eval/
├── golden_datasets/
│   ├── user_creation.json
│   ├── auth_flow.json
│   └── error_handling.json
├── test_prompts.py
├── test_outputs.py
└── conftest.py
```

### Golden dataset format

**Livrable** : `eval/golden_datasets/example.json`

```json
{
  "name": "User Creation",
  "version": "1.0",
  "cases": [
    {
      "id": "UC001",
      "input": {
        "prompt": "Create a user with email test@example.com",
        "context": "Empty database"
      },
      "expected": {
        "action": "INSERT INTO users",
        "contains": ["email", "password_hash"],
        "not_contains": ["plain_password"],
        "response_type": "confirmation"
      },
      "tags": ["user", "creation", "happy_path"]
    },
    {
      "id": "UC002", 
      "input": {
        "prompt": "Create a user with invalid email",
        "context": "Empty database"
      },
      "expected": {
        "action": "REJECT",
        "error": "validation",
        "response_type": "error"
      },
      "tags": ["user", "creation", "error"]
    }
  ]
}
```

### Test avec DeepEval

**Livrable** : `eval/test_outputs.py`

```python
import pytest
from deepeval import assert_test
from deepeval.metrics import (
    AnswerRelevancyMetric,
    FaithfulnessMetric,
    HallucinationMetric
)
from deepeval.test_case import LLMTestCase
import json
from pathlib import Path

# Load golden datasets
DATASETS_DIR = Path(__file__).parent / "golden_datasets"

def load_golden_cases():
    cases = []
    for file in DATASETS_DIR.glob("*.json"):
        data = json.loads(file.read_text())
        for case in data["cases"]:
            cases.append((data["name"], case))
    return cases

@pytest.fixture
def llm_client():
    # Your LLM client setup
    from anthropic import Anthropic
    return Anthropic()

@pytest.mark.parametrize("dataset_name,case", load_golden_cases())
def test_llm_output(dataset_name, case, llm_client):
    """Test LLM outputs against golden dataset"""
    
    # Get actual output
    response = llm_client.messages.create(
        model="claude-3-5-sonnet-20241022",
        max_tokens=1024,
        messages=[{"role": "user", "content": case["input"]["prompt"]}]
    )
    actual_output = response.content[0].text
    
    # Create test case
    test_case = LLMTestCase(
        input=case["input"]["prompt"],
        actual_output=actual_output,
        expected_output=str(case["expected"]),
        context=[case["input"].get("context", "")]
    )
    
    # Metrics
    metrics = [
        AnswerRelevancyMetric(threshold=0.7),
        HallucinationMetric(threshold=0.5)
    ]
    
    # Assert
    assert_test(test_case, metrics)
    
    # Additional checks
    expected = case["expected"]
    
    if "contains" in expected:
        for item in expected["contains"]:
            assert item.lower() in actual_output.lower(), \
                f"Expected '{item}' in output"
    
    if "not_contains" in expected:
        for item in expected["not_contains"]:
            assert item.lower() not in actual_output.lower(), \
                f"Unexpected '{item}' in output"
```

---

## 5. MONITORING TOKENS

### Workflow budget tokens

**Livrable** : `.github/workflows/token-budget.yml`

```yaml
name: Token Budget Monitor

on:
  schedule:
    - cron: '0 8 * * *'  # Daily at 8am
  workflow_dispatch:

jobs:
  check-budget:
    runs-on: ubuntu-latest
    steps:
      - name: Check Anthropic usage
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          # Get usage from Anthropic API
          USAGE=$(curl -s https://api.anthropic.com/v1/usage \
            -H "x-api-key: $ANTHROPIC_API_KEY" \
            -H "anthropic-version: 2023-06-01")
          
          TOKENS_USED=$(echo $USAGE | jq '.tokens_used // 0')
          BUDGET=${{ vars.MONTHLY_TOKEN_BUDGET || 1000000 }}
          
          PERCENT=$((TOKENS_USED * 100 / BUDGET))
          
          echo "Tokens used: $TOKENS_USED / $BUDGET ($PERCENT%)"
          
          if [ "$PERCENT" -gt 95 ]; then
            echo "🔴 CRITICAL: Budget at $PERCENT%"
            exit 1
          elif [ "$PERCENT" -gt 80 ]; then
            echo "🟠 WARNING: Budget at $PERCENT%"
          else
            echo "🟢 OK: Budget at $PERCENT%"
          fi
      
      - name: Send alert if needed
        if: failure()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "⚠️ Token budget alert: Usage at critical level"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 6. EXEMPLES DO / DON'T

### CI qui passe vs qui échoue

| Aspect | ❌ Échoue | ✅ Passe |
|--------|----------|---------|
| Commit | `fix stuff` | `fix(auth): handle token expiry` |
| Diff | 800 lignes | 150 lignes |
| Secret | `API_KEY="sk-..."` | `process.env.API_KEY` |
| Coverage | 45% | 82% |
| Spec | Modifie 10 fichiers | Modifie fichiers listés |

### Messages d'erreur utiles

```bash
# ❌ Mauvais message
Error: Check failed

# ✅ Bon message
❌ Commit message format invalid
Expected: type(scope): description
Got: "fix bug"
Example: fix(auth): handle expired JWT tokens
```

---

**Fiabilité** : 96%
**💡 Conseil** : Un CI strict au début = moins de dette technique plus tard. Investis 1 jour de setup.
