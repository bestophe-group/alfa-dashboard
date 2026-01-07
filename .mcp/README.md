# 🤖 ALFA MCP - Mode d'Emploi

**Version**: 2.0.0
**Date**: 2026-01-07
**Status**: ✅ Production Ready

---

## 🎯 Objectif

ALFA permet de communiquer avec **129 outils MCP** depuis:
- **Slack** (channel #bct)
- **Claude Desktop**
- **Cursor IDE**

---

## ⚡ Démarrage Rapide

### 1. Vérifier le Statut

```bash
cd /Users/arnaud/Documents/ALFA-Agent-Method/.mcp
./alfa-manage.sh status
```

**Résultat attendu**: ✅ Tous les services en ligne

### 2. Configurer Slack (1 minute)

**Ouvrir**: https://api.slack.com/apps/A0A73J9107P/slash-commands

**Créer commande `/alfa`** avec:
- **Request URL**: `https://aviation-audit-adjacent-alternative.trycloudflare.com/slack/command`
- **Description**: `Execute ALFA MCP tools`

Ou utiliser:
```bash
./alfa-manage.sh config
```

### 3. Tester dans Slack

Dans le channel **#bct**:
```
/alfa status
```

---

## 📋 Commandes Disponibles

### Script de Gestion
```bash
./alfa-manage.sh status    # Statut complet
./alfa-manage.sh logs      # Voir les logs
./alfa-manage.sh restart   # Redémarrer
./alfa-manage.sh config    # Config Slack
./alfa-manage.sh test      # Tests
./alfa-manage.sh help      # Aide
```

### PM2 Direct
```bash
pm2 status                 # Statut PM2
pm2 logs alfa-webhook      # Logs en temps réel
pm2 restart alfa-webhook   # Redémarrer
pm2 monit                  # Monitoring CPU/RAM
```

---

## 🎨 Exemples - Depuis Slack (#bct)

```bash
# Monitoring
/alfa status
/alfa grafana_create_dashboard title="Production"

# Communication
/alfa slack_send_message channel="bct" text="Hello!"

# OSINT
/alfa osint_company_research company="Acme Corp"

# GitHub
/alfa github_repo_management action=list

# Productivity
/alfa obsidian_create_note title="Notes" content="Ma note"
```

---

## 📚 Documentation

| Fichier | Description |
|---------|-------------|
| **STATUS-FINAL.md** | Statut actuel et configuration |
| **TOOLS-LIST-COMPLETE.md** | Liste complète des 129 outils |
| **alfa-manage.sh** | Script de gestion |

---

## 🔧 Maintenance

```bash
# Status
./alfa-manage.sh status

# Logs
pm2 logs alfa-webhook

# Redémarrer
pm2 restart alfa-webhook
```

---

**🤖 ALFA Bot v2.0.0** - 129 outils | Production Ready ✅
