# 📚 Module 7 : Git - Les Bases Essentielles

## 🎯 Objectifs de ce module

À la fin de ce module, vous saurez :
- ✅ Installer et configurer Git correctement
- ✅ Maîtriser le workflow Git de base
- ✅ Travailler avec les branches efficacement
- ✅ Collaborer sur des projets Kotlin/Kobweb
- ✅ Résoudre les problèmes Git courants

---

## 📊 Pourquoi Git est essentiel pour le développement ?

Git est le système de contrôle de version **standard** pour :
                     
| Besoin                        | Solution Git                                       |
|-------------------------------------------------------------|
| Sauvegarder votre code        | `git commit`                |
| Travailler à plusieurs        | `git push`, `git pull`      |
| Essayer des idées sans risque | `git branch`, `git checkout`|
| Retourner en arrière          | `git revert`, `git reset`   |
| Collaborer sur Kobweb         | Pull Requests, Code Review  |

---

## 🚀 Installation et configuration

### Installation sur Ubuntu
```bash
sudo apt update
sudo apt install -y git gitk git-gui
```
# Vérifier
git --version  # Doit afficher git version 2.25+

### Configuration initiale (À FAIRE IMMÉDIATEMENT)
# Configuration globale (une seule fois)
```
git config --global user.name "Votre Nom"
git config --global user.email "votre.email@entreprise.com"
```
# veririfier
```
git config --list
```
### 1️⃣ Qu’est-ce que Git ?

Git est un système de `contrôle de version distribué`.

Il permet :

de sauvegarder des versions du code (commits)

de collaborer efficacement

de travailler hors ligne

de sécuriser le projet

### 2️⃣ Concepts fondamentaux (À COMPRENDRE ABSOLUMENT)
🔹 Dépôt (Repository)
Dossier suivi par Git.

🔹 Commit
Snapshot du projet à un instant donné.

🔹 Branche (Branch)
Ligne de développement indépendante.

🔹 Dépôt distant
Version du projet sur GitHub / GitLab.

### 3️⃣ Créer un dépôt Git
🔹 Initialiser un dépôt local
```bash
git init
```
🔹 Vérifier l’état du dépôt
```bash
git status
```
### 4️⃣ Le cycle de base Git
Fichier modifié
   ↓
git add
   ↓
git commit

🔹 Ajouter des fichiers au staging
```bash
git add fichier.txt
git add .
```
🔹 Créer un commit
```bash
git commit -m "Message clair et descriptif"
```
### 5️⃣ Consulter l’historique
```bash
git log
git log --oneline
```
### 6️⃣ Ignorer des fichiers (IMPORTANT)

Créer un fichier .gitignore :
```bash
nano .gitignore
```

Exemple :
```text
node_modules/
.env
build/
.idea/
.vscode/
```
### 7️⃣ Travailler avec un dépôt distant (GitHub)
🔹 Ajouter un dépôt distant
git remote add origin https://github.com/user/projet.git


Vérifier :
```bash
git remote -v
```
🔹 Envoyer le code
```bash
git branch -M main
git push -u origin main
```
🔹 Récupérer les changements
```bash
git pull
```
### 8️⃣ Les branches (BASE)
🔹 Lister les branches
```bash
git branch
```
🔹 Créer une branche
```bash
git branch feature-login
```
🔹 Changer de branche

```bash
git checkout [nomlelabranche]
```
ou (recommandé)

```bash
git switch feature-login
```
### 9️⃣ Fusionner une branche (merge)
```bash
git checkout main
git merge feature-ui
```
🔟 Résolution de conflits (bases)

Un conflit survient quand Git ne sait pas quoi garder

```bash

<<<<<<< HEAD
code actuel
=======
nouveau code
>>>>>>> feature
```

👉 Corriger manuellement puis :

```bash
git add fichier
git commit
```