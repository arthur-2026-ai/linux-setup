
# 📘 Formation Linux (Ubuntu) - Introduction

>**Public cible :** Développeurs de l'équipe, quel que soit leur niveau d'expertise.
>**Temps de lecture estimé :** 30 à 45 minutes.
>**Prérequis :** Aucun, On part de zero!.

---

## 🎯 Bienvenue dans la formation Linux !

Cette formation a pour but de vous donner les moyens de bien comprendre Ubuntu et de devenir autonome dans votre environnement de développement.

Aucune expérience préalable avec Linux n'est nécessaire. Nous procéderons pas à pas.

---

## 🤔 Pourquoi Linux ? Pourquoi Ubuntu ?

### Qu'est-ce que Linux ?

Linux est un système d'exploitation (comme Windows ou macOS), mais il a des caractéristiques distinctives :

✅ **Open Source** : Le code source est accessible, modifiable gratuitement.    
✅ **Efficace** : Fonctionne sur la majorité des serveurs web.    
✅ **Fiable** : Réduit les erreurs et les arrêts.    
✅ **Sûr** : Moins sensible aux logiciels malveillants.    
✅ **Adapté aux développeurs** : Fournit des outils de développement natifs.

### Pourquoi privilégier Ubuntu ?

Ubuntu est une distribution Linux (une version de Linux). Nous l'avons retenue pour les raisons suivantes :

🎯 **Support à long terme (LTS)** : Cinq ans de mises à jour garanties.    
🎯 **Importante communauté** : Vaste base d'utilisateurs, ce qui simplifie l'accès à l'assistance.    
🎯 **Stabilité et sécurité** : Idéal pour un usage professionnel.    
🎯 **Documentation** : Documentation exhaustive.    
🎯 **Compatibilité** : Prend en charge la majorité des logiciels professionnels.    

---

## 🎯 Objectif général

Permettre à **tous les développeurs et stagiaires** de :

* Être **autonomes sur Ubuntu Linux**
* Travailler dans un **environnement homogène**
* Comprendre ce qu’ils font (pas juste exécuter des commandes)
* Être opérationnels sur la stack **Kotlin + Kobweb**

---

## 🧭 Organisation de la formation

* **Durée totale** : 2 à 3 semaines (en parallèle du travail)
* **Format** :

  * Auto-formation guidée (README + exercices)
  * Démo rapide en réunion
  * Validation par des commandes à exécuter
* **Pré-requis** : aucun (niveau débutant accepté)

---

## 🧱 MODULE 0 – Bases obligatoires (Avant de commencer)

### Objectif

Comprendre **pourquoi Linux** et poser le cadre commun.

### Contenu

* Pourquoi Ubuntu en startup
* Différence Windows / macOS / Linux
* Terminal ≠ danger
* Structure globale d’un système Linux

### Validation

* Expliquer à l’oral :

  * ce qu’est une distribution
  * ce qu’est le terminal

---

## 🖥️ MODULE 1 – Prise en main d’Ubuntu

### Objectif

Être à l’aise avec l’interface et le terminal.

### Compétences

* Ouvrir le terminal
* Comprendre le prompt
* Naviguer dans le système

### Commandes clés

```bash
pwd
ls
ls -la
cd
clear
```

### Exercice

* ouvrez le terminal (CTRL+ALT+T)
* Naviguer jusqu’au dossier personnel
* Lister les fichiers cachés

---

## 📁 MODULE 2 – Système de fichiers Linux

### Objectif

Comprendre où sont les choses et pourquoi.

### Contenu

* /home, /etc, /var, /usr
* Dossiers projet
* Bonnes pratiques

### Commandes

```bash
mkdir
rm -r
cp
mv
tree
```

### Exercice

* Créer un dossier `workspace`
* Créer un projet `kobweb-demo`

---

## 🔐 MODULE 3 – Permissions et sécurité (ESSENTIEL)

### Objectif

Éviter les erreurs graves et comprendre sudo.

### Contenu

* Utilisateur vs root
* Permissions rwx
* chmod, chown

### Commandes

```bash
whoami
chmod
chown
sudo
```

### Exercice

* Rendre un script exécutable
* Comprendre une erreur "Permission denied"

---

## ⚙️ MODULE 4 – Processus & services

### Objectif

Comprendre ce qui tourne sur la machine.

### Contenu

* Processus
* Ports
* Services

### Commandes

```bash
ps aux
top
htop
kill
lsof -i
```

### Exercice

* Trouver un processus Java
* Identifier un port utilisé

---

## 🌐 MODULE 5 – Réseau & outils développeur

### Objectif

Diagnostiquer rapidement un problème réseau.

### Commandes

```bash
ip a
ping
curl
wget
netstat -tuln
```

### Exercice

* Tester une API locale
* Vérifier un port Kobweb

---

## 🧰 MODULE 6 – Git en ligne de commande

### Objectif

Maîtriser Git **sans dépendre d’un GUI**.

### Commandes

```bash
git clone
git status
git add
git commit
git pull
git push
```

### Règles d’équipe

* Pas de commit sur main
* Messages clairs

---

## ☕ MODULE 7 – Stack Kotlin / Kobweb

### Objectif

Installer et utiliser la stack officielle.

### Contenu

* JDK (version standardisée)
* Gradle
* Kobweb CLI

### Commandes

```bash
java -version
gradle -v
kobweb version
kobweb run
```

---

## 🧪 MODULE 8 – Scripts & automatisation

### Objectif

Standardiser l’environnement.

### Contenu

* Bash de base
* Scripts d’installation
* Variables d’environnement

### Exemple

```bash
#!/bin/bash
echo "Installation en cours..."
```

---

## ✅ MODULE 9 – Validation finale

### Objectif

S’assurer que tout le monde est aligné.

### Validation

* Script `check-env.sh`
* Démarrage d’un projet Kobweb
* Commit de validation

---

## 🏁 Résultat attendu

À la fin :

* Tous les développeurs travaillent sur Ubuntu
* Même stack, mêmes versions
* Moins de bugs "chez moi ça marche"
* Équipe plus autonome et professionnelle

---

---


## 🧭 L'interface Ubuntu : Premiers pas

Une fois Ubuntu installé, vous accéderez à un bureau semblable à celui-ci :

### Éléments importants

```
┌─────────────────────────────────────────┐
│[☰] Ubuntu         🔍  🔊  📶  ⚙️  👤   │ ← Barre supérieure
├─────────────────────────────────────────┤
│📁                                       |
|                                         │
│🌐                                       |
|                                         | 
│📝        Votre bureau (Desktop)         │
│                                         │
│⚙️                                       |
|                                         │          
└─────────────────────────────────────────┘
```

---

## 💻 Le Terminal : Un outil essentiel

### Comment ouvrir le terminal

**Méthodes :**

1. **Raccourci clavier** : `Ctrl + Alt + T` ⚡ (la solution la plus rapide).
2. **Menu Activités** : Cliquez sur `[☰]`, saisissez terminal, puis validez.
3. **Clic droit** : Sur le bureau, sélectionnez Ouvrir un terminal ici.

### Apparence du terminal

```bash
utilisateur@machine:~$ _
```

Signification des éléments :

- `utilisateur` : Votre nom d'utilisateur.
- `@` : Séparateur.
- `machine` : Nom de l'ordinateur.
- `:` : Séparateur.
- `~` : Votre répertoire personnel (home).
- `$` : Indique un utilisateur standard (non root).
- `_` : Curseur, indiquant où vous pouvez taper.

### Importance du terminal

Dans le développement, le terminal est un outil crucial pour plusieurs raisons :

✅ **Rapidité** : Plus efficace que l'interface graphique.  
✅ **Puissance** : Accès à des fonctions non disponibles via l'interface graphique.  
✅ **Automatisation** : Permet la création de scripts.  
✅ **Universalité** : Fonctionne sur tous les serveurs.  
✅ **Standard professionnel** : Outil utilisé par tous les développeurs.

**Exemple pratique :**

Création de 100 fichiers numérotés :
- **Via l'interface graphique** : Processus long et répétitif (15 à 20 minutes). 😫
- **Via le terminal** : Une seule commande, exécution presque instantanée. ⚡

```bash
touch fichier_{1..100}.txt
```

---

## 🎯 Comprendre la philosophie de Linux

Linux repose sur des principes clés :

### 1. Tout est un fichier

Sous Linux, chaque élément est considéré comme un fichier :
- Documents. ✅
- Programmes. ✅
- Disques durs. ✅
- Périphériques (souris, webcam). ✅

Cette approche simplifie la gestion du système.

### 2. La simplicité est une force

Les programmes Linux sont conçus pour exécuter une tâche unique, mais de manière parfaite.

Exemples :
- `ls` : Liste les fichiers.
- `grep` : Recherche du texte.
- `cat` : Affiche le contenu.

Ces programmes peuvent être combinés pour réaliser des opérations complexes.

### 3. Combinaison facile

La liaison des commandes s'effectue à l'aide du symbole `|` (pipe).

```bash
ls -la | grep .txt | wc -l
```

Explication :
1. `ls -la` : Liste de tous les fichiers.
2. `| grep .txt` : Filtre les fichiers contenant .txt.
3. `| wc -l` : Compte le nombre de lignes (donc de fichiers).

Résultat : Nombre de fichiers .txt dans le répertoire.

### 4. L'absence de message est un signe positif

De nombreuses commandes Linux n'affichent pas de message en cas de succès.

```bash
$ rm fichier.txt
$                    ← Pas de message = succès !
```

Les erreurs, elles, sont signalées explicitement.

---

**Bonne formation ! 🚀**

*Module créé pour l'équipe d'ORION - Version 1.0*
