# INTAKE - Workflow Data Collection

**Date**: 2026-01-12  
**Status**: ✅ Compris

---

## 📋 DEMANDE UTILISATEUR

**Objectif** : Créer un workflow ALFA pour analyser et collecter des données depuis tous les moyens de communication et les enregistrer dans le RAG Knowledge Base.

**Sources de données** :
- ✅ Emails (Microsoft 365 / Exchange)
- ✅ Teams (messages, conversations)
- ✅ Autres données

**Action** : Enregistrer dans RAG Knowledge Base via le workflow `iana-rag-auto-save` (déjà créé).

---

## ✅ COMPRÉHENSION CONFIRMÉE

**Workflow à créer** : `iana-data-collect`

**Fonctionnalités** :
1. **Récupérer** : Collecter des données depuis emails, Teams, etc.
2. **Formater** : Préparer les données pour le RAG (title, content, metadata)
3. **Enregistrer** : Appeler le workflow `iana-rag-auto-save` pour enregistrer dans RAG

**Architecture** :
- **Workflow** : `iana-data-collect.json`
- **Endpoint** : `/webhook/data/collect`
- **Actions** : `email`, `teams`, `all`
- **Intégration** : Appel HTTP vers `iana-rag-auto-save`

---

## 🎯 MÉTHODE ALFA

**Phase** : INTAKE ✅

**Prochaines phases** :
1. ⏳ **AUDIT** : Identifier sources de données disponibles et intégrations n8n
2. ⏳ **PLAN** : Planifier workflow avec actions pour chaque source
3. ⏳ **BUILD** : Créer workflow iana-data-collect
4. ⏳ **PROVE** : Tester avec données réelles

---

**INTAKE complété le**: 2026-01-12  
**Status**: ✅ Compris et confirmé
