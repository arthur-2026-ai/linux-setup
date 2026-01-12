
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

## 🎓 Objectifs de cette formation

La formation est structurée en **sept modules**, chacun abordant un aspect différent de Linux :

### **Module 0 : Introduction** *(vous êtes ici)*
- Présentation de Linux et Ubuntu.
- Guide d'installation d'Ubuntu
- Examen de l'interface utilisateur.

### **Module 1 : Commandes de base**
- Navigation dans le système de fichiers.
- Création, édition et suppression de fichiers.
- Introduction au terminal.

### **Module 2 : Système de fichiers**
- Organisation des répertoires sous Linux.
- Distinction entre chemins absolus et relatifs
- Manipulation avancée des fichiers.

### **Module 3 : Gestion des paquets**
- Installation de logiciels avec `apt`.
- résolution des problèmes de dépendances
- Mises à jour du système.

### **Module 4 : Permissions et utilisateurs**
- Gestion des droits d'accès.
- Administration des utilisateurs
- Utilisation correcte de `sudo`.

### **Module 5 : Processus**
- Monitorage des processus actifs.
- Allocation de mémoire et d'unité centrale
- Interruption des processus bloqués.

### **Module 6 : Networking**
- Vérification de la Connectivité.
- résolution basique des problèmes de réseau
- Concepts de base de SSH.

### **Module 7 : les bases de git**
- Initialisation d'un depot.
- faire un commit
- push sur le depot distant

---

## ⏱️ Temps nécessaire
----------------------------------------------------
| Phase                             | Durée Estimée|
|--------------------------------------------------|
| **Lecture des modules**           | 2 à 3 heures |
| **Exercices pratiques**           | 3 à 4 heures |
| **Révision et approfondissement** | 1 à 2 heures |
| **TOTAL**                         | **6 à 9 heures** |
|-------------------------------------------------------
💡 **Note** : Étudiez le matériel à votre rythme pour une bonne compréhension.

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

*Module créé pour l'équipe - Version 1.0*
