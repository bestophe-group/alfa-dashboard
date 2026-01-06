# INSTRUCTIONS CLAUDE CODE - ALFA DASHBOARD

## 🎯 TA MISSION
Tu es le développeur. Tu implémentes la stack ALFA Dashboard.

## 📋 TODO PROGRESSIF (Affiche et mets à jour)

```
╔════════════════════════════════════════════════════════════╗
║                 ALFA DASHBOARD - PROGRESS                  ║
╠════════════════════════════════════════════════════════════╣
║ [ ] 1. Setup repo GitHub bestophe-group/alfa-dashboard     ║
║ [ ] 2. Structure fichiers de base                          ║
║ [ ] 3. docker-compose.yml (Traefik + Postgres + Redis)     ║
║ [ ] 4. Ajouter Huly                                        ║
║ [ ] 5. Ajouter Infisical                                   ║
║ [ ] 6. Ajouter n8n                                         ║
║ [ ] 7. Ajouter Uptime Kuma                                 ║
║ [ ] 8. Scripts (setup, backup, health)                     ║
║ [ ] 9. Tests docker-compose                                ║
║ [ ] 10. Documentation README                               ║
╚════════════════════════════════════════════════════════════╝
```

## 📏 RÈGLES OBLIGATOIRES

### Git
- Commits conventionnels : `feat:`, `fix:`, `docs:`, `test:`
- Un commit par étape TODO
- Push après chaque étape validée
- Messages clairs en français

### TDD
- Écrire le test/validation AVANT l'implémentation
- `docker compose config` pour valider syntaxe
- `docker compose up -d` pour tester
- Health checks pour chaque service

### Workflow par étape
```
1. Afficher TODO avec [→] sur l'étape en cours
2. Écrire le test/validation
3. Implémenter
4. Valider (docker compose config)
5. Commit + Push
6. Marquer [✓] et passer à la suite
```

## 🔐 GITHUB
- Organisation : bestophe-group
- Nom repo : alfa-dashboard
- Créer le repo si n'existe pas

## 🚀 COMMENCE MAINTENANT
1. Affiche le TODO
2. Crée le repo GitHub
3. Avance étape par étape
