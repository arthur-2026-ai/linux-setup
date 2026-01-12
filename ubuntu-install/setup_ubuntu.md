# 🖥️ Guide d'Installation Ubuntu 22.04 LTS

> **Objectif :** Installer Ubuntu 22.04 LTS de manière professionnelle  
> **Niveau :** Débutant à Intermédiaire  
> **Durée :** 30 minutes à 2 heures selon la méthode

---

## 📋 Table des matières

1. [Prérequis et préparation](#prérequis)
2. [Option 1 : Installation complète (recommandé)](#option-1)
5. [Configuration post-installation](#post-installation)
6. [Dépannage](#dépannage)

---


<a name="prérequis"></a>
## ⚙️ Prérequis et préparation

### Matériel requis

**Minimum :**
- Processeur : 2 GHz dual-core
- RAM : 4 GB
- Disque : 25 GB
- USB : 4 GB minimum

**Recommandé pour le développement :**
- Processeur : Intel i5/i7 ou AMD Ryzen 5/7
- RAM : 8-16 GB
- Disque : 256 GB SSD
- USB : 8 GB

### ⚠️ TRÈS IMPORTANT : Sauvegarder tes données !

Avant TOUTE installation, sauvegarde :

```
✅ Documents
✅ Photos/Vidéos
✅ Code source (pousse sur Git !)
✅ Configurations importantes
✅ Favoris navigateur
✅ Clés SSH/GPG
```

**Moyens de sauvegarde :**
- Disque dur externe
- Cloud (Google Drive, Dropbox)
- Clé USB

### 📥 Télécharger Ubuntu 22.04 LTS

1. Va sur : **https://ubuntu.com/download/desktop**
2. Télécharge **Ubuntu 22.04.3 LTS** (fichier .iso)
3. Taille : environ 4.5 GB

**Vérifie le téléchargement :**

```bash
# Sur Linux/Mac
sha256sum ubuntu-22.04.3-desktop-amd64.iso

# Sur Windows (PowerShell)
Get-FileHash ubuntu-22.04.3-desktop-amd64.iso -Algorithm SHA256
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
   Sélectionner : [ubuntu-22.04.3-desktop-amd64.iso]
   Schéma de partition : GPT
   Système de destination : UEFI
   ```
5. Clique sur **Démarrer**
6. Attends 5-10 minutes

#### Sous Linux

```bash
# Trouve le nom de ta clé USB
lsblk

# Exemple de sortie :
# sdb      8:16   1  14.9G  0 disk
# └─sdb1   8:17   1  14.9G  0 part

# Crée la clé bootable (remplace /dev/sdX par ton périphérique)
sudo dd if=ubuntu-22.04.3-desktop-amd64.iso of=/dev/sdX bs=4M status=progress && sync
```

⚠️ **ATTENTION** : Vérifie bien le nom du périphérique ! dd efface tout sans confirmation.

#### Sous macOS

1. Télécharge **balenaEtcher** : https://www.balena.io/etcher/
2. Lance Etcher
3. Sélectionne l'ISO Ubuntu
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
2. Tu vois l'écran de démarrage Ubuntu (logo violet)
3. Sélectionne **"Try or Install Ubuntu"**
4. Attends le chargement (1-2 minutes)

### Étape 4 : Installation guidée

#### Écran de bienvenue

```
┌─────────────────────────────────┐
│   Welcome to Ubuntu 22.04       │
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

#### Disposition du clavier

1. Sélectionne ta disposition (ex: French - French)
2. Teste dans la zone de texte
3. **Continue**

#### Mises à jour et autres logiciels

```
Type d'installation :
○ Installation normale        ← CHOISIS CELLE-CI
○ Installation minimale

Autres options :
☑ Télécharger les mises à jour pendant l'installation
☑ Installer logiciels tiers (drivers, codecs)
```

**Recommandation :** Coche les deux options

#### Type d'installation (IMPORTANT !)

```
┌──────────────────────────────────────────┐
│ Type d'installation                      │
│                                          │
│ ○ Effacer le disque et installer Ubuntu │ ← Pour installation complète
│                                          │
│ ○ Autre chose (avancé)                  │
│                                          │
│ ⚠️  ATTENTION : Cela effacera tout !     │
└──────────────────────────────────────────┘
```

**Pour installation complète :**
1. Sélectionne **"Effacer le disque et installer Ubuntu"**
2. Vérifie bien que c'est le bon disque !
3. **Continue**

#### Partitionnement automatique

Ubuntu propose :
```
/dev/sda
  ├─ EFI System Partition (512 MB)
  ├─ ext4 / (tout le reste)
  └─ swap (optionnel)
```

Clique **"Installer maintenant"**

#### Confirmation

```
┌──────────────────────────────────────┐
│ Les modifications suivantes vont     │
│ être appliquées :                    │
│                                      │
│ Le disque /dev/sda sera formaté     │
│                                      │
│ ⚠️  IMPOSSIBLE À ANNULER !           │
│                                      │
│ [Retour] [Continuer]                │
└──────────────────────────────────────┘
```

**Dernière chance !** Vérifie que tu as sauvegardé tes données.

Clique **"Continuer"**

#### Fuseau horaire

1. Sélectionne ta ville (ex: Yaoundé, Cameroun)
2. **Continue**

#### Création de l'utilisateur

```
┌─────────────────────────────────────┐
│ Qui êtes-vous ?                     │
│                                     │
│ Votre nom : [Claude fotso]          │
│ Nom de l'ordinateur : [fotso-DevOps]│
│ Nom d'utilisateur : [claude]        │
│ Mot de passe : [••••••••]           │
│ Confirmer : [••••••••]              │
│                                     │
│ ○ Se connecter automatiquement      │
│ ● Demander mon mot de passe         │ ← Recommandé
└─────────────────────────────────────┘
```

**Conseils pour le mot de passe :**
- Minimum 8 caractères
- Mélange lettres/chiffres/symboles
- Note-le quelque part de sûr !

Clique **"Continue"**

### Étape 5 : Installation en cours

```
┌────────────────────────────────────┐
│ Installation d'Ubuntu              │
│                                    │
│ [████████████████░░░░░] 75%        │
│                                    │
│ Installation des fichiers...       │
│ Temps restant : environ 10 min     │
│                                    │
│ Le saviez-vous ?                   │
│ Ubuntu signifie "humanité"...      │
└────────────────────────────────────┘
```

⏱️ **Durée :** 15-30 minutes selon ton matériel

**Pendant ce temps :**
- Ne touche à rien
- Garde l'ordi branché
- Prépare-toi un café ☕

### Étape 6 : Finalisation

```
┌────────────────────────────────────┐
│ Installation terminée !            │
│                                    │
│ ✅ Ubuntu 22.04 LTS est installé   │
│                                    │
│ Redémarrez pour utiliser le        │
│ nouveau système.                   │
│                                    │
│ [Continuer à tester] [Redémarrer]  │
└────────────────────────────────────┘
```

1. Clique **"Redémarrer maintenant"**
2. Quand demandé, **retire la clé USB**
3. Appuie sur `Entrée`

### Étape 7 : Premier démarrage

```
Ubuntu 22.04 LTS fotso-DevOps tty1

fotso-DevOps login: _
```

1. Entre ton **nom d'utilisateur**
2. Entre ton **mot de passe** (invisible quand tu tapes)
3. Appuie sur `Entrée`

**Bienvenue dans Ubuntu ! 🎉**

---

<a name="dépannage"></a>
## 🔧 Dépannage

### Problème : "Secure Boot" empêche le démarrage

**Solution :**
1. Redémarre et entre dans le BIOS
2. Security → Secure Boot → **Disabled**
3. Sauvegarde et redémarre

### Problème : Écran noir après l'installation

**Solution (Nvidia) :**
1. Au menu GRUB, appuie sur `e`
2. Trouve la ligne avec `quiet splash`
3. Ajoute `nomodeset` après
4. `Ctrl + X` pour démarrer

**Puis installe les drivers Nvidia :**
```bash
sudo ubuntu-drivers autoinstall
sudo reboot
```

### Problème : WiFi ne fonctionne pas

**Solution :**
```bash
# Vérifier la carte réseau
lspci | grep -i network

# Installer les drivers manquants
sudo apt install linux-firmware
sudo reboot
```
### Problème : Son ne fonctionne pas

**Solution :**
```bash
# Réinstaller les pilotes audio
sudo apt remove --purge alsa-base pulseaudio
sudo apt install alsa-base pulseaudio
sudo alsa force-reload
```

### Problème : Résolution d'écran incorrecte (VM)

**Solution :**
```bash
# Installer Guest Additions
sudo apt install virtualbox-guest-utils virtualbox-guest-x11
sudo reboot
```

---

## 📚 Ressources supplémentaires

### Documentation officielle
- **Ubuntu Desktop Guide** : https://help.ubuntu.com/
- **Ubuntu Wiki** : https://wiki.ubuntu.com/

### Communautés
- **Ask Ubuntu** : https://askubuntu.com/
- **Ubuntu Forums** : https://ubuntuforums.org/
- **r/Ubuntu** : https://reddit.com/r/Ubuntu

### Vidéos (YouTube)
- Recherche : "Ubuntu 22.04 LTS installation tutorial"

---

## ✅ Checklist finale

Vérifie que tout est en place :

- [ ] Ubuntu démarre correctement
- [ ] Connexion Internet fonctionne
- [ ] Compte utilisateur configuré
- [ ] Système à jour (`sudo apt update && sudo apt upgrade`)
- [ ] Git installé et configuré
- [ ] Firewall activé

**Si tout est coché : Félicitations ! 🎉**

---

## 🚀 Prochaine étape

Maintenant que Ubuntu est installé, passe à :

👉 **[Installation de l'environnement de développement](../installation_stack/setup_stack.sh)**

Ou continue avec :

👉 **[Module 2 : Commandes de base Linux](01-commandes-base.md)**

---

**Guide créé pour l'équipe - Version 1.0**

*En cas de problème : demande de l'aide  a votre mentor*