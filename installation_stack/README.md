# 🚀 Setup Environnement DEV/DEVOPS - Ubuntu 24.04 LTS

Script d'installation automatique pour configurer un environnement de développement complet sur Ubuntu 24.04 LTS.

---

## 📋 Table des matières

- [Prérequis](#-prérequis)
- [Installation rapide](#-installation-rapide)
- [Modes d'installation](#-modes-dinstallation)
- [Dépannage](#-dépannage)

---

## ✅ Prérequis

- **Système d'exploitation :** Ubuntu 24.04 LTS (Noble Numbat)
- **Droits :** Utilisateur avec privilèges sudo (ne PAS exécuter en root)
- **Espace disque :** 
  - Minimal : 1 GB
  - Dev : 3 GB
  - Full : 15 GB (recommandé)
- **Connexion internet** : Requise

---

## 🚀 Installation rapide

### 1. Télécharger le script

```bash
# Cloner le repository (ou télécharger setup.sh)
git clone https://github.com/Orion-237/Setup_Linux.git
cd installation_stack/
```

### 2. Rendre le script exécutable

```bash
chmod +x setup.sh
chmod +x verify_install.sh
```

### 3. Lancer l'installation apres avoir installer le systeme

```bash
# Installation complète (recommandée)
./setup.sh --full
```

**⏱️ Temps d'installation :** 5-15 minutes selon votre connexion

---

## 📦 Modes d'installation

Le script propose 3 modes d'installation :

### Mode 1 : Minimal (Docker uniquement)

```bash
./setup.sh --minimal
```

**Installe :**
- Docker Engine
- Docker Compose

**Espace requis :** ~1 GB

---

### Mode 2 : Dev (Développement)

```bash
./setup.sh --dev
```

**Installe :**
- Docker Engine + Docker Compose
- ASDF Version Manager (Java, Node.js, Python, Kotlin, Gradle)
- Visual Studio Code
- IntelliJ IDEA Community
- Postman

**Espace requis :** ~3 GB

---

### Mode 3 : Full (Complet) 🌟 RECOMMANDÉ

```bash
./setup.sh --full
```

**Installe tout ce qui est dans Dev, plus :**
- Android Studio
- MongoDB 8.0
- Outils DevOps supplémentaires (nmap, httpie, shellcheck, eza, etc.)

**Espace requis :** ~15 GB (incluant SDK Android)

---

### Option : Docker Desktop

```bash
# Ajouter Docker Desktop à n'importe quel mode
./setup.sh --full --docker-desktop
```
---

## 📂 Structure des fichiers

```
.
├── setup.sh              # Script principal
├── README.md             # Ce fichier
└── logs/                 # Logs d'installation (créé automatiquement)
    └── setup-YYYYMMDD-HHMMSS.log
```

---

## 📝 Logs d'installation

Les logs détaillés sont sauvegardés automatiquement :

```bash
# Voir les logs
ls -lt logs/

# Lire le dernier log
cat logs/setup-*.log | tail -100

# Rechercher des erreurs
grep -i "error" logs/setup-*.log
```

---

## 🔧 Dépannage

### Problème : "Permission denied" avec Docker

**Solution :**
```bash
# Vérifier que vous êtes dans le groupe docker
groups | grep docker

# Si absent, ajouter et redémarrer
sudo usermod -aG docker $USER
sudo reboot
```

---

### Problème : "asdf: command not found"

**Solution :**
```bash
# Recharger la configuration bash
source ~/.bashrc

# Ou se déconnecter/reconnecter
```

---

### Problème : MongoDB ne démarre pas

**Solution :**
```bash
# Démarrer le service
sudo systemctl start mongod

# Activer au démarrage
sudo systemctl enable mongod

# Voir les erreurs
sudo journalctl -u mongod -n 50
```

---

### Problème : Espace disque insuffisant

**Solution :**
```bash
# Vérifier l'espace disponible
df -h

# Nettoyer si nécessaire
sudo apt-get autoremove
sudo apt-get clean
docker system prune -a  # Nettoie Docker (attention : supprime images)
```

---

### Problème : Installation échoue sur un paquet

**Solution :**
```bash
# Mettre à jour la liste des paquets
sudo apt-get update

# Relancer l'installation
./setup.sh --full
```

---

## 🆘 Besoin d'aide ?

1. **Consulter les logs :** `cat logs/setup-*.log`
2. **Vérifier l'espace disque :** `df -h`
3. **Vérifier la connexion internet :** `ping -c 3 google.com`
4. **Réexécuter le script :** Le script est idempotent, vous pouvez le relancer sans risque

---

## 🎯 Prochaines étapes recommandées

1. **Configurer Git**
   ```bash
   git config --global user.name "Votre Nom"
   git config --global user.email "votre@email.com"
   ```

2. **Installer des versions de langages avec ASDF**
   ```bash
   asdf install nodejs latest
   asdf install java openjdk-21
   asdf install python 3.12.1
   ```

3. **Installer des extensions VS Code**
   ```bash
   code --install-extension ms-python.python
   code --install-extension ms-vscode.java-pack
   code --install-extension dbaeumer.vscode-eslint
   ```

4. **Télécharger des images Docker utiles**
   ```bash
   docker pull ubuntu:24.04
   docker pull node:lts
   docker pull python:3.12
   docker pull mongo:8.0
   ```

---

## 📚 Ressources officielles

- **Docker :** https://docs.docker.com/
- **ASDF :** https://asdf-vm.com/
- **VS Code :** https://code.visualstudio.com/docs
- **IntelliJ IDEA :** https://www.jetbrains.com/help/idea/
- **Android Studio :** https://developer.android.com/studio
- **MongoDB :** https://www.mongodb.com/docs/v8.0/

---

## 📄 Licence

Ce script est fourni "tel quel" sans garantie. Utilisez-le à vos propres risques.

---

## 👥 Support

Pour signaler un problème ou suggérer une amélioration :
1. Consultez les logs d'installation
2. Vérifiez la section [Dépannage](#-dépannage)
3. Ouvrez une issue sur le repository

---

**Version :** 2026.1  
**Dernière mise à jour :** 22 janvier 2026  
**Système supporté :** Ubuntu 24.04 LTS (Noble Numbat)