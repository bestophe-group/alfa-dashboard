# 🔐 MES CREDENTIALS POSTGRESQL - ALFA

**Date**: 2026-01-12  
**Source**: Configuration Docker active

---

## ✅ CREDENTIALS ACTUELLES

```
Host:     postgres
Port:     5432
Database: alfa
User:     alfa
Password: alfapass123
SSL:      Désactivé (pour Docker local)
```

---

## 📋 POUR n8n

**Credential Name**: `PostgreSQL IANA`

**Configuration**:
- **Host**: `postgres` (nom du service Docker, pas localhost)
- **Port**: `5432`
- **Database**: `alfa`
- **User**: `alfa`
- **Password**: `alfapass123`
- **SSL**: Désactivé

---

## 🔗 CONNEXION DIRECTE

**Via psql**:
```bash
docker exec -it alfa-postgres psql -U alfa -d alfa
```

**Via connection string**:
```
postgresql://alfa:alfapass123@postgres:5432/alfa
```

**Depuis l'extérieur du Docker** (si port exposé):
```
postgresql://alfa:alfapass123@localhost:5432/alfa
```

---

## ⚠️ NOTES IMPORTANTES

- **Host = `postgres`** : C'est le nom du service Docker, utilisé depuis les autres containers
- **Host = `localhost`** : Si tu te connectes depuis ton Mac (port 5432 exposé)
- **Password** : `alfapass123` est la valeur par défaut de Docker Compose
- **Si tu as un `.env`** : Vérifie s'il contient `POSTGRES_PASSWORD` avec une valeur différente

---

## 🔍 VÉRIFICATION

**Tester la connexion**:
```bash
docker exec alfa-postgres psql -U alfa -d alfa -c "SELECT current_database(), current_user;"
```

**Résultat attendu**:
```
 current_database | current_user 
------------------+--------------
 alfa             | alfa
```

---

**Ces credentials sont actuellement utilisées par ton stack Docker ALFA.**
