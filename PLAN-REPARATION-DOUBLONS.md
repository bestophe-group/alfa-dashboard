# Plan de Réparation des Doublons - Workflows n8n

**Date**: 2026-01-12  
**Objectif**: Supprimer les doublons de workflows n8n

---

## 📋 RÉSUMÉ DES DOUBLONS

| Nom | Occurrences | Status | Priorité |
|-----|-------------|--------|----------|
| `iana-router` | 3 | Tous actifs | 🔴 CRITIQUE |
| `iana-l1-handler` | 2 | Tous inactifs | 🟡 MOYEN |
| `iana-l2-handler` | 2 | Tous inactifs | 🟡 MOYEN |
| `iana-l3-handler` | 2 | Tous inactifs | 🟡 MOYEN |

---

## 🎯 STRATÉGIE DE RÉPARATION

### 1. iana-router (CRITIQUE - 3 occurrences actives)

**Problème**: 3 workflows actifs avec le même nom peuvent causer des conflits.

**Solution**:
1. Analyser les 3 workflows pour identifier celui à garder :
   - Préférer celui avec un `webhookId` valide
   - Sinon, garder le plus récent
2. Désactiver les 2 autres workflows
3. Supprimer les workflows désactivés

**IDs des workflows iana-router**:
- `xLAc38D3vJve0EpL` (✅ Actif)
- `KhG3Q5MkT5Ko8W3X` (✅ Actif)
- `Fowjj0lqqwb1Abbi` (✅ Actif)

**Action**: 
- À déterminer après analyse : quel workflow garder
- Supprimer les 2 autres via API n8n

### 2. iana-l1-handler (2 occurrences inactives)

**IDs**:
- `trJusOUdAeLNy2fO` (❌ Inactif)
- `NtyCIlfvWUdeDwV4` (❌ Inactif)

**Action**: Supprimer le plus ancien (ou les deux si non utilisés)

### 3. iana-l2-handler (2 occurrences inactives)

**IDs**:
- `sIujuHOGLT16KWbA` (❌ Inactif)
- `P64Ew7gj8WWW0N2D` (❌ Inactif)

**Action**: Supprimer le plus ancien (ou les deux si non utilisés)

### 4. iana-l3-handler (2 occurrences inactives)

**IDs**:
- `Jn18X8vRu3EMRAfB` (❌ Inactif)
- `SkigwSVEEiCBRDRD` (❌ Inactif)

**Action**: Supprimer le plus ancien (ou les deux si non utilisés)

---

## 🔧 MÉTHODE D'IMPLÉMENTATION

### Via n8n API

**Endpoint**: `DELETE /api/v1/workflows/{workflow_id}`

**Headers**:
```
X-N8N-API-KEY: {api_key_alfa3}
Content-Type: application/json
```

**Exemple**:
```bash
curl -X DELETE "http://localhost:5678/api/v1/workflows/{workflow_id}" \
  -H "X-N8N-API-KEY: {api_key_alfa3}" \
  -H "Content-Type: application/json"
```

### Ordre d'exécution

1. **Priorité 1**: Corriger `iana-router` (CRITIQUE)
   - Analyser les 3 workflows
   - Identifier celui à garder
   - Désactiver les 2 autres
   - Supprimer les 2 autres

2. **Priorité 2**: Nettoyer handlers (MOYEN)
   - Pour chaque handler (l1, l2, l3):
     - Supprimer le doublon le plus ancien
     - Vérifier qu'il reste un handler (ou supprimer les deux si non utilisés)

3. **Priorité 3**: Vérification
   - Exécuter audit après nettoyage
   - Vérifier qu'il n'y a plus de doublons
   - Vérifier que les workflows actifs fonctionnent toujours

---

## ✅ CRITÈRES DE SUCCÈS

- [ ] `iana-router` : 1 seul workflow actif (les 2 autres supprimés)
- [ ] `iana-l1-handler` : 0 ou 1 occurrence (doublon supprimé)
- [ ] `iana-l2-handler` : 0 ou 1 occurrence (doublon supprimé)
- [ ] `iana-l3-handler` : 0 ou 1 occurrence (doublon supprimé)
- [ ] Audit final : 0 doublon détecté
- [ ] Workflows actifs fonctionnent toujours

---

## ⚠️ RISQUES

1. **Supprimer le mauvais workflow iana-router** :
   - Risque : Perte du workflow principal
   - Mitigation : Analyser chaque workflow avant suppression

2. **Supprimer des handlers utilisés** :
   - Risque : Workflows principaux cassés
   - Mitigation : Vérifier que handlers sont des sub-workflows (inactifs par nature)

3. **API n8n échoue** :
   - Risque : Doublons restants
   - Mitigation : Retry logic, vérification après chaque suppression

---

## 📝 NOTES

- Les handlers sont des sub-workflows (inactifs par nature, appelés via `Execute Workflow`)
- Il est normal que les handlers soient inactifs
- Le problème principal est `iana-router` avec 3 occurrences actives

---

**Plan créé le**: 2026-01-12  
**Status**: ⏳ En attente d'implémentation
