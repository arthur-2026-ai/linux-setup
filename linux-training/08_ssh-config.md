# 🔐 Module 07 — SSH : Première connexion à un serveur Linux

## 📌 Contexte du module
SSH (Secure Shell) est le **moyen standard et sécurisé** pour se connecter à un serveur distant.

Dans notre environnement startup / produit :
- tous les serveurs sont administrés via SSH
- aucune connexion graphique n’est utilisée
- la sécurité repose sur des **clés SSH**, pas des mots de passe

👉 Ce module explique **comment se connecter proprement à un serveur pour la première fois**.

---

## 🎯 Objectifs pédagogiques
À la fin de ce module, le développeur doit être capable de :

- Expliquer ce qu’est SSH
- Comprendre le principe client ↔ serveur
- Générer une paire de clés SSH
- Se connecter à un serveur Linux en SSH
- Comprendre et éviter les erreurs courantes
- Appliquer les bonnes pratiques de sécurité

---

## 🧠 Prérequis
- Ubuntu installé
- Terminal fonctionnel
- Accès à un serveur Linux (VPS, cloud, serveur interne)
- Adresse IP ou nom de domaine du serveur

---

## 1️⃣ Qu’est-ce que SSH ?

SSH = **Secure Shell**

C’est un protocole qui permet :
- une connexion distante
- chiffrée
- sécurisée
- via le terminal

### Exemple
```text
Ton PC (client)  --->  Serveur distant (Linux)
```
2️⃣ Vérifier que SSH est installé (client)

Sur Ubuntu, SSH client est généralement déjà installé.
```bash
ssh -V
```
Si absent :
```bash
sudo apt update
sudo apt install -y openssh-client
```
### 3️⃣ Syntaxe de base d’une connexion SSH

ssh utilisateur@ip_du_serveur


Exemple :
```bash
ssh ubuntu@192.168.1.50
```

Ou avec un domaine :
```bash
ssh root@mon-serveur.com
```
### 4️⃣ Première connexion (avec mot de passe)

Lors de la première connexion, le serveur va demander confirmation :

The authenticity of host '...' can't be established.
Are you sure you want to continue connecting (yes/no)?

👉 Taper :

yes


Puis entrer le mot de passe du serveur.

⚠️ Le mot de passe ne s’affiche pas quand tu tapes.

### 5️⃣ Comprendre le message "known_hosts"

Une fois connecté, l’empreinte du serveur est enregistrée dans :
~/.ssh/known_hosts


➡️ Cela empêche les attaques de type man-in-the-middle.

### 6️⃣ Pourquoi utiliser des clés SSH ? (TRÈS IMPORTANT)

❌ Mot de passe :

moins sécurisé

attaquable par force brute

partage dangereux

✅ Clés SSH :

beaucoup plus sûres

pas de mot de passe transmis

standard professionnel

👉 Dans l’équipe, les clés SSH sont obligatoires.

### 7️⃣ Générer une clé SSH (CÔTÉ CLIENT)

ssh-keygen -t ed25519 -C "prenom.nom@entreprise.com"

Appuyer sur Entrée pour :

    emplacement par défaut

    passphrase (optionnelle mais recommandée)

Fichiers générés :
```text
~/.ssh/id_ed25519       (clé privée ❌ À NE JAMAIS PARTAGER)
~/.ssh/id_ed25519.pub   (clé publique ✅)
```
### 8️⃣ Copier la clé publique sur le serveur

🔹 Méthode recommandée (automatique)
```bash
ssh-copy-id utilisateur@ip_du_serveur
```

Exemple :
```bash
ssh-copy-id ubuntu@192.168.1.50
```

### 9️⃣ Connexion SSH avec clé (SANS mot de passe)
ssh utilisateur@ip_du_serveur


👉 Si tout est correct :

connexion directe

aucun mot de passe demandé