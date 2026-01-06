# 📚 ALFA-Agent Method v2.0
## Méthode Anti-Désalignement pour Production IA

---

## 🎯 PROBLÈME CENTRAL : LE DÉSALIGNEMENT

Le désalignement = quand l'agent fait **autre chose** que ce qu'on veut.

### Manifestations du désalignement

| Type | Exemple | Fréquence |
|------|---------|-----------|
| **Hallucination** | Invente une API qui n'existe pas | 15-30% |
| **Drift de scope** | "Crée un user" → crée user + envoie email + modifie billing | 40% |
| **Interprétation libre** | Comprend "optimiser" comme "réécrire entièrement" | 60% |
| **Contournement** | Ignore une règle "pour simplifier" | 80% |
| **Overclaim** | "Ça devrait marcher" sans vérifier | 90% |

### Coût du désalignement

```
1 désalignement non détecté = 2-8h de debug
10 désalignements/semaine = 1 dev à temps plein perdu
```

---

## 📁 LIVRABLES DE LA MÉTHODE

| # | Document | Objectif Anti-Désalignement |
|---|----------|----------------------------|
| 00 | Ce fichier | Navigation |
| 01 | `01-METHODE-ALFA.md` | Workflow qui FORCE l'alignement |
| 02 | `02-CURSORRULES.md` | Règles agent anti-drift |
| 03 | `03-ANTI-DESALIGNEMENT.md` | 28 failure modes + détection |
| 04 | `04-STACK-COMPLETE.md` | Infisical + MCP + Outils |
| 05 | `05-CICD-PIPELINES.md` | CI qui BLOQUE les dérives |
| 06 | `06-WORKFLOWS-N8N.md` | Automation monitoring |
| 07 | `07-PROMPTS-SYSTEME.md` | Prompts anti-hallucination |
| 08 | `08-SPECS-TEMPLATES.md` | Templates CURRENT.md |
| 09 | `09-CHECKLIST-PROJET.md` | Validation alignement |
| 10 | `10-GLOSSAIRE.md` | Termes |
| 11 | `11-STACK-SELFHOSTED-VPS.md` | Docker Compose OVH + n8n 2.0 |

---

## 🚨 SIGNAUX DE DÉSALIGNEMENT

### 🔴 STOP IMMÉDIAT

| Signal | Action |
|--------|--------|
| "Normalement ça devrait..." | STOP - demander preuve |
| "Je pense que..." | STOP - demander source |
| Code > 100 lignes sans validation | STOP - découper |
| Modification fichier hors spec | STOP - revenir au CURRENT.md |

### 🟢 SIGNAL ALIGNÉ

| Signal | Continuer |
|--------|-----------|
| "D'après [lien doc officielle]..." | ✅ |
| "Je viens de vérifier, voici le résultat..." | ✅ |
| "Avant d'agir, je confirme avec toi..." | ✅ |
| Suit exactement CURRENT.md | ✅ |

---

## ⚡ QUICK START (3 jours)

| Jour | Durée | Actions |
|------|-------|---------|
| 1 | 2h | Lire 01, 02, 03 - Comprendre le workflow |
| 2 | 2h | Setup : .cursorrules + Infisical + MCP |
| 3+ | - | Produire avec CURRENT.md |

---

**Version** : 2.0 | **Focus** : Anti-Désalignement
