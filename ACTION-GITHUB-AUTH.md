# ACTION REQUISE : Authentification GitHub

## 🔐 Étape manuelle rapide (30 secondes)

Le token MCP GitHub n'a pas les droits de création de repo.

### Option A : Via gh CLI (recommandé)

Exécute dans ton terminal :

```bash
gh auth login
```

Puis sélectionne :
1. `GitHub.com`
2. `HTTPS`
3. `Login with a web browser`
4. Copie le code affiché
5. Valide dans le navigateur

### Option B : Via SSH

```bash
# Générer clé SSH pour GitHub
ssh-keygen -t ed25519 -C "ton-email@example.com" -f ~/.ssh/github

# Ajouter au ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/github

# Afficher la clé publique à copier dans GitHub
cat ~/.ssh/github.pub
```

Puis ajoute la clé sur : https://github.com/settings/keys

---

## ⏳ EN ATTENDANT

Je prépare tout le projet localement. Dès que tu es authentifié, je push.

**Dis-moi "OK" quand c'est fait.**
