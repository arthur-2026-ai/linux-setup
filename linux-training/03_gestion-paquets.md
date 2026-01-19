# 📦 Module 3 : Gestion des Paquets Linux

## 🎯 Objectifs de ce module

À la fin de ce module, vous saurez :
- ✅ Comprendre le système de paquets Ubuntu (APT)
- ✅ Installer/mettre à jour/supprimer des logiciels
- ✅ Gérer les dépôts personnalisés (PPA)
- ✅ Installer TOUS les outils pour Kotlin/Kobweb
- ✅ Résoudre les problèmes de dépendances

---

## 📊 Pourquoi gérer les paquets ?

En tant que développeur Kotlin, vous aurez besoin de :
```

| Outil           | Pourquoi ?          | Comment l'installer          |
|-----------------|---------------------|------------------------------|
| **JDK**         | Exécuter Kotlin/JVM | `apt install openjdk-17-jdk` |
| **Git**         | Versionnage         | `apt install git`            |
| **Node.js**     | Kobweb/outils web   | Via PPA ou nvm               |
| **Build tools** | Gradle, etc.        | `apt install gradle`         |
| **Utilitaires** | curl, wget, unzip   | `apt install curl`           |
```
---

## 🧩 Les bases d'APT (Advanced Package Tool)

Dans Linux,
APT (pour Advanced Packaging Tool) est un système de gestion de paquets puissant et simple d'utilisation, principalement utilisé par les distributions basées sur Debian (comme Ubuntu, Mint) pour rechercher, installer, mettre à jour et supprimer des logiciels et leurs dépendances via la ligne de commande

### Mise à jour des listes de paquets
```bash
sudo apt update        # Met à jour la liste des paquets disponibles
sudo apt upgrade       # Met à jour les paquets installés
sudo apt full-upgrade  # Met à jour + gère les dépendances complexes
```
* `apt install <paquet>` : Installe un paquet (et ses dépendances).
* `apt remove <paquet>` : Supprime un paquet en gardant la configuration.
* `apt purge <paquet>` : Supprime un paquet + sa configuration.
* `apt search <mot_clé>` : Recherche des paquets.
* `apt show <paquet>` : Affiche des informations détaillées.
* `apt clean` / `apt autoclean` : Nettoie le cache APT.
* Gestion des dépôts : `/etc/apt/sources.list` et `/etc/apt/sources.list.d/`
* Ajout sécurisé d'un dépôt : clé GPG + dépôt avec option `signed-by`.

👉 Documentation complète :
[https://blog.stephane-robert.info/docs/admin-serveurs/linux/apt/](https://blog.stephane-robert.info/docs/admin-serveurs/linux/apt/)

---

## 🛠️ Exercices

### Exercice 1 : Mettre à jour la liste des paquets

* **Fichier fourni** : aucun
* **Action** :

  1. Exécutez la commande `sudo apt update`.
  2. Observez les lignes de sortie.

👉 **Explication** : Cette commande interroge tous les dépôts pour mettre à jour
le cache local (dans `/var/lib/apt/lists`). Elle ne modifie pas le système
lui-même.

### Exercice 2 : Installer et supprimer un paquet

* **Fichier fourni** : aucun
* **Action** :

  1. Installez le paquet `htop`.

     ```bash
     sudo apt install htop
     ```

  2. Vérifiez son installation avec :

     ```bash
     htop --version
     ```

  3. Supprimez-le sans effacer la configuration :

     ```bash
     sudo apt remove htop
     ```

  4. Installez-le package `curl` :

     ```bash
      sudo apt install curl -y
      ```

👉 **Explication** : `install` ajoute le paquet et ses dépendances ; `remove`
garde la config pour une réinstallation future.

### Exercice 3 : Nettoyer l'espace disque

* **Action** :

  1. Listez les fichiers présents dans `/var/cache/apt/archives/`.
  2. Exécutez :

     ```bash
     sudo apt clean
     ```

  3. Vérifiez que le cache est vidé.

👉 **Explication** : `apt clean` supprime tous les fichiers `.deb` téléchargés,
utile pour libérer de l'espace disque.

### Exercice 4 : Explorer un paquet

* **Action** :

  1. Utilisez `apt search` pour trouver le package install le serveur ssh.
  2. Affichez ses détails avec :

     ```bash
     apt show <nom_du_paquet>
     ```

👉 **Explication** : `search` parcourt la base locale des paquets et `show`
affiche toutes les infos : dépendances, description, etc.

### Exercice 5 : Ajouter un dépôt et mettre à jour

* **Action** :

  1. Editez le fichier dans `/etc/apt/sources.list.d/docker.list` :

     ```bash
     sudo vi /etc/apt/sources.list.d/docker.list
     ```

  2. Ajoutez la ligne suivante :

     ```bash
     deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu   noble stable
     ```

  3. Ajoutez la clé GPG :

     ```bash
     sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
     sudo chmod a+r /etc/apt/keyrings/docker.asc
     ```

  4. Mettez à jour la liste des paquets :

     ```bash
     sudo apt update
     ```

  5. Installez le paquet `docker-ce` :

     ```bash
     sudo apt install docker-ce
     ```

👉 **Explication** : APT détecte automatiquement les nouveaux dépôts ajoutés
dans `sources.list.d`. La clé GPG assure l'intégrité des paquets et la sécurité
de l'installation. La commande `apt update` met à jour la liste des paquets
disponibles, y compris ceux du dépôt Docker. L'installation de `docker-ce`
permet d'utiliser Docker sur votre système. Vous pouvez vérifier son
installation avec :

  ```bash
  docker --version
  ```

---

✅ Bon courage et amusez-vous avec APT 😄