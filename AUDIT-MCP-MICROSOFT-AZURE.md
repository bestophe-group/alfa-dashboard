# AUDIT MCP - Outils Microsoft/Azure

**Date**: 2026-01-12  
**Status**: ⏳ En cours

---

## 📋 OBJECTIF

Vérifier si des outils MCP sont disponibles pour accéder aux données Microsoft/Azure :
- Emails (Microsoft 365 / Exchange)
- Teams (messages, conversations)
- Autres données Azure

---

## 🔍 VÉRIFICATIONS

### 1. Liste Ressources MCP

**Méthode** : `list_mcp_resources()`

**Résultat** : À analyser

### 2. Recherche dans RAG

**Requête SQL** :
```sql
SELECT 
  server_name,
  tool_name,
  description_short,
  category
FROM rag.mcp_tools
WHERE 
  LOWER(description_short) LIKE '%microsoft%' OR
  LOWER(description_short) LIKE '%azure%' OR
  LOWER(description_short) LIKE '%365%' OR
  LOWER(description_short) LIKE '%teams%' OR
  LOWER(description_short) LIKE '%exchange%' OR
  LOWER(description_short) LIKE '%outlook%'
ORDER BY server_name, tool_name;
```

### 3. Serveurs MCP Disponibles

**Requête SQL** :
```sql
SELECT 
  name,
  description,
  version,
  status,
  tool_count
FROM rag.list_mcp_servers()
ORDER BY name;
```

---

## 📊 RÉSULTATS

**À compléter après vérification**

---

**AUDIT en cours le**: 2026-01-12
