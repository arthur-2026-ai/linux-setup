# 🖥️ Guide d'Installation Ubuntu 24.04 LTS (Noble Numbat)

> **Objectif :** Installer Ubuntu 24.04 LTS de manière professionnelle  
> **Niveau :** Débutant à Intermédiaire  
> **Durée :** 30 minutes à 2 heures selon la méthode

---

## 🆕 Pourquoi Ubuntu 24.04 LTS ?

**Ubuntu 24.04 LTS** est la version **recommandée pour les développeurs** en 2024/2025 :

✅ **Support jusqu'en 2029** (5 ans de mises à jour)  
✅ **Kernel 6.8** - Meilleur support matériel  
✅ **Python 3.12** - +20% de performance  
✅ **GCC 13** - Support C++23 complet  
✅ **Performance** - 15% plus rapide au boot  
✅ **Sécurité renforcée** - AppArmor 4.0  
✅ **Docker natif** - Meilleure intégration  

**C'est LA version pour les équipes de développement professionnelles ! 🚀**

---

## 📋 Table des matières

1. [Prérequis et préparation](#prérequis)
2. [Option 1 : Installation complète ](#recommandé)
3. [Configuration post-installation](#post-installation)
4. [Dépannage](#dépannage)

---
<a name="prérequis"></a>
## ⚙️ Prérequis et préparation

### Matériel requis

**Minimum officiel :**
- Processeur : 2 GHz dual-core
- RAM : 4 GB
- Disque : 25 GB
- USB : 4 GB minimum

**Recommandé pour le développement :**
- Processeur : Intel i5/i7 Gen 8+ ou AMD Ryzen 5/7
- RAM : 16 GB (8 GB minimum)
- Disque : 256 GB SSD NVMe
- USB : 8 GB
- Connexion Internet pendant l'installation

### ⚠️ TRÈS IMPORTANT : Sauvegarder tes données !

Avant TOUTE installation, sauvegarde :

```
✅ Documents
✅ Photos/Vidéos
✅ Code source (pousse sur Git !)
✅ Configurations importantes (~/.bashrc, ~/.ssh, etc.)
✅ Favoris navigateur
✅ Clés SSH/GPG
✅ Base de données locales
```

**Moyens de sauvegarde :**
- Disque dur externe
- Cloud (Google Drive, Dropbox)
- Clé USB (plusieurs si nécessaire)
- GitHub/GitLab pour le code

### 📥 Télécharger Ubuntu 24.04 LTS

1. Va sur : **https://ubuntu.com/download/desktop**
2. Télécharge **Ubuntu 24.04 LTS** (fichier .iso)
3. Taille : environ 5.7 GB

**Vérifie le téléchargement :**

```bash
# Sur Linux/Mac
sha256sum ubuntu-24.04-desktop-amd64.iso

# Sur Windows (PowerShell)
Get-FileHash ubuntu-24.04-desktop-amd64.iso -Algorithm SHA256
```

Compare le résultat avec la somme officielle sur le site Ubuntu.

---

<a name="option-1"></a>
## 🚀 Option 1 : Installation complète (Recommandé)

### Étape 1 : Créer une clé USB bootable

#### Sous Windows

**Avec Rufus (recommandé) :**

1. Télécharge **Rufus** : https://rufus.ie/
2. Insère ta clé USB (elle sera effacée !)
3. Lance Rufus
4. Configuration :
   ```
   Périphérique : [Ta clé USB]
   Type de démarrage : Image disque
   Sélectionner : [ubuntu-24.04-desktop-amd64.iso]
   Schéma de partition : GPT
   Système de destination : UEFI
   ```
5. Clique sur **Démarrer**
6. Attends 5-10 minutes

**⚡ Nouveau :** Rufus détecte automatiquement Ubuntu 24.04 !

#### Sous Linux

```bash
# Trouve le nom de ta clé USB
lsblk

# Exemple de sortie :
# sdb      8:16   1  14.9G  0 disk
# └─sdb1   8:17   1  14.9G  0 part

# Crée la clé bootable (remplace /dev/sdX par ton périphérique)
sudo dd if=ubuntu-24.04-desktop-amd64.iso of=/dev/sdX bs=4M status=progress && sync
```

⚠️ **ATTENTION** : Vérifie bien le nom du périphérique ! dd efface tout sans confirmation.

#### Sous macOS

1. Télécharge **balenaEtcher** : https://www.balena.io/etcher/
2. Lance Etcher
3. Sélectionne l'ISO Ubuntu 24.04
4. Sélectionne ta clé USB
5. Clique sur **Flash!**

### Étape 2 : Configurer le BIOS/UEFI

1. **Redémarre** ton ordinateur
2. **Pendant le démarrage**, appuie sur la touche pour entrer dans le BIOS/UEFI :
   - Dell : `F2` ou `F12`
   - HP : `Esc` ou `F10`
   - Lenovo : `F1` ou `F2`
   - ASUS : `F2` ou `Del`
   - Acer : `F2` ou `Del`

3. **Désactive le Secure Boot** :
   ```
   Security → Secure Boot → Disabled
   ```

4. **Change l'ordre de boot** :
   ```
   Boot → Boot Order → USB en premier
   ```

5. **Sauvegarde et redémarre** (`F10` généralement)

### Étape 3 : Démarrer sur la clé USB

1. Ton PC redémarre
2. Tu vois l'écran de démarrage Ubuntu (nouveau design 24.04 !)
3. Sélectionne **"Try or Install Ubuntu"**
4. Attends le chargement (1-2 minutes)

### Étape 4 : Installation guidée - NOUVEAU dans 24.04 ! 🎉

Ubuntu 24.04 introduit un **nouvel installateur Flutter** plus rapide et moderne !

#### Écran de bienvenue

```
┌─────────────────────────────────┐
│   Welcome to Ubuntu 24.04 LTS   │
│         Noble Numbat            │
│                                 │
│   Choose your language:         │
│   • English                     │
│   • Français                    │
│   • Deutsch                     │
│   ...                           │
│                                 │
│   [Try Ubuntu] [Install Ubuntu] │
└─────────────────────────────────┘
```

1. **Langue** : Choisis ta langue
2. Clique sur **"Install Ubuntu"**


```
┌──────────────────────────────────┐
│ Connect to Internet              │
│                                  │
│ ○ Use WiFi                       │
│   [Select network...]            │
│                                  │
│ ○ Use wired connection           │
│                                  │
│ ○ I don't want to connect now    │
└──────────────────────────────────┘
```

**Recommandation :** Connecte-toi maintenant pour :
- Télécharger les mises à jour pendant l'installation
- Installer les codecs propriétaires
- Configurer les comptes en ligne

#### Type d'installation

```
┌──────────────────────────────────────────┐
│ Installation type                        │
│                                          │
│ ○ Normal installation                    │
│   (Recommended for most users)           │
│   - Web browser, utilities, office       │
│   - Games, media players                 │
│                                          │
│ ○ Minimal installation                   │
│   - Web browser and basic utilities      │
│                                          │
│ Additional options:                      │
│ ☑ Download updates while installing      │
│ ☑ Install third-party software           │
│   (Graphics, WiFi, codecs)               │
└──────────────────────────────────────────┘
```

#### Partitionnement (IMPORTANT !)

**Pour installation complète :**

```
┌──────────────────────────────────────────┐
│ Installation type                        │
│                                          │
│ ○ Erase disk and install Ubuntu          │ ← CHOISIS CELLE-CI
│                                          │
│ ○ Manual partitioning (Advanced)         │
│                                          │
│ ⚠️  This will delete all data!           │
│                                          │
│ Disk: /dev/sda (500 GB SSD)              │
└──────────────────────────────────────────┘
```

**⚡ NOUVEAU :** Interface plus claire avec visualisation du disque !

1. Sélectionne **"Erase disk and install Ubuntu"**
2. Vérifie bien que c'est le bon disque !
3. **Continue**

#### Confirmation

```
┌──────────────────────────────────────┐
│ Write the changes to disk?           │
│                                      │
│ The following will be formatted:     │
│ • /dev/sda                           │
│                                      │
│ ⚠️  THIS CANNOT BE UNDONE!           │
│                                      │
│ [Go Back] [Continue]                 │
└──────────────────────────────────────┘
```

**Dernière chance !** Vérifie que tu as sauvegardé tes données.

Clique **"Continue"**

#### Fuseau horaire

**⚡ NOUVEAU :** Détection automatique via IP !

```
┌─────────────────────────────────────┐
│ Where are you?                      │
│                                     │
│ [    World Map Interactive    ]     │
│                                     │
│ Detected: Yaoundé, Cameroon        │
│ Timezone: Africa/Douala (WAT)      │
│                                     │
│ [Change] [Continue]                 │
└─────────────────────────────────────┘
```

Clique **"Continue"** si correct.

#### Création de l'utilisateur

```
┌─────────────────────────────────────┐
│ Who are you?                        │
│                                     │
│ Your name:     [claude fotso]       │
│ Computer name: [fotso-dev]          │
│ Username:      [fotso]              │
│ Password:      [••••••••]          │
│ Confirm:       [••••••••]          │
│                                     │
│ ○ Log in automatically              │
│ ● Require password to log in       │ ← Recommandé
│ ☐ Use Active Directory             │ ← Nouveau !
└─────────────────────────────────────┘
```
 continue avec l'instali

1. Entre ton **nom d'utilisateur**
2. Entre ton **mot de passe** (invisible quand tu tapes)
3. Appuie sur `Entrée`

**🎉 Bienvenue dans Ubuntu 24.04 LTS ! 🎉**



### Étape 1 : Mise à jour du système

```bash
# Mettre à jour la liste des paquets
sudo apt update

# Installer les mises à jour
sudo apt upgrade -y

# Mettre à jour le firmware (nouveau dans 24.04)
sudo fwupdmgr refresh
sudo fwupdmgr update

# Nettoyer
sudo apt autoremove -y
sudo apt autoclean
```

⏱️ Durée : 5-15 minutes

### Étape 2 : Activer les dépôts universe et multiverse

```bash
# Activer universe (logiciels maintenus par la communauté)
sudo add-apt-repository universe

# Activer multiverse (logiciels propriétaires)
sudo add-apt-repository multiverse

# Mettre à jour
sudo apt update
```

### Étape 3 : Installer les outils de base

```bash
# Outils essentiels développement
sudo apt install -y \
    curl \
    wget \
    git \
    vim \
    neovim \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    net-tools \
    htop \
    tree \
    zip \
    unzip
```

### Étape 4 : Configurer Git

```bash
# Ton nom
git config --global user.name "Ton Nom"

# Ton email
git config --global user.email "ton.email@example.com"

# Éditeur par défaut
git config --global core.editor vim

# Branche par défaut
git config --global init.defaultBranch main

# Vérifier
git config --list
```

### Étape 5 : Configurer le firewall

```bash
# Activer UFW (Uncomplicated Firewall)
sudo ufw enable

# Autoriser SSH (si besoin)
sudo ufw allow ssh

# Autoriser les ports dev courants
sudo ufw allow 3000:9000/tcp  # Ports dev web

# Voir le statut
sudo ufw status verbose
```

### Étape 6 : Optimisations pour développeurs

#### Augmenter les watchers (pour Node.js, React, etc.)

```bash
echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

#### Améliorer les performances SSD

```bash
# Vérifier si TRIM est actif
sudo systemctl status fstrim.timer

# Activer si nécessaire
sudo systemctl enable fstrim.timer
```

#### Configurer Swappiness (optionnel)

```bash
# Réduire l'utilisation du swap (bon pour SSD)
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### Étape 7 : Personnaliser l'apparence (optionnel)

```bash
# Installer Gnome Tweaks
sudo apt install gnome-tweaks gnome-shell-extensions

# Installer des thèmes populaires
sudo apt install yaru-theme-gtk yaru-theme-icon

# Lancer
gnome-tweaks
```

---

<a name="dépannage"></a>
## 🔧 Dépannage Ubuntu 24.04

### Problème : "Secure Boot" empêche le démarrage

**Solution :**
1. Redémarre et entre dans le BIOS
2. Security → Secure Boot → **Disabled**
3. Sauvegarde et redémarre

### Problème : Écran noir après l'installation (Nvidia)

**Solution 24.04 :**
1. Au menu GRUB, appuie sur `e`
2. Trouve la ligne avec `quiet splash`
3. Ajoute `nomodeset` après
4. `Ctrl + X` pour démarrer

**Puis installe les drivers Nvidia :**
```bash
# 24.04 a un meilleur support Nvidia !
sudo ubuntu-drivers list
sudo ubuntu-drivers install

# Ou spécifique
sudo apt install nvidia-driver-550

sudo reboot
```

### Problème : WiFi ne fonctionne pas

**Solution 24.04 :**
```bash
# Vérifier la carte réseau
lspci | grep -i network

# Installer les drivers manquants
sudo apt install linux-firmware
sudo apt install firmware-realtek  # Si Realtek
sudo apt install firmware-iwlwifi  # Si Intel

sudo reboot
```

### Problème : Son ne fonctionne pas

**Solution 24.04 :**
```bash
# 24.04 utilise PipeWire par défaut
sudo apt install pipewire pipewire-audio-client-libraries

# Redémarrer PipeWire
systemctl --user restart pipewire pipewire-pulse

# Si ça ne marche toujours pas
sudo alsa force-reload
```

### Problème : Trackpad ne fonctionne pas

**Solution :**
```bash
# Installer les drivers Synaptics
sudo apt install xserver-xorg-input-synaptics

# Ou libinput (plus moderne)
sudo apt install xserver-xorg-input-libinput

sudo reboot
```

---

## 📚 Ressources supplémentaires

### Documentation officielle
- **Ubuntu 24.04 Release Notes** : https://wiki.ubuntu.com/NobleNumbat/ReleaseNotes
- **Ubuntu Desktop Guide** : https://help.ubuntu.com/
- **Ubuntu Wiki** : https://wiki.ubuntu.com/

### Communautés
- **Ask Ubuntu** : https://askubuntu.com/
- **Ubuntu Forums** : https://ubuntuforums.org/
- **r/Ubuntu** : https://reddit.com/r/Ubuntu

### Nouveautés Ubuntu 24.04
- **What's New** : https://ubuntu.com/blog/ubuntu-24-04-noble-numbat

---
