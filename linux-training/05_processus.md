# 🔄 Module 4 : Gestion des Processus Linux

## 🎯 Objectifs de ce module

À la fin de ce module, vous saurez :
- ✅ Comprendre ce qu'est un processus Linux
- ✅ Lancer, surveiller et arrêter des processus
- ✅ Gérer les services système (systemd)
- ✅ Optimiser l'utilisation des ressources
- ✅ Démarrer/arrêter des applications Kotlin

---

## 📊 Qu'est-ce qu'un processus ?

Un processus est **une instance d'un programme en cours d'exécution**.

En tant que développeur Kotlin, vous travaillez avec :
- **Processus de compilation** : `kotlinc`, `gradle`, `kobweb`
- **Serveurs de développement** : Serveurs web, bases de données
- **Outils d'IDE** : IntelliJ IDEA, VS Code
- **Services système** : Docker, PostgreSQL

---

## 🔍 Voir les processus en cours

### `ps` - Process Status (basique)
```bash
ps            # Vos processus dans le terminal actuel
ps aux        # TOUS les processus du système
ps -ef        # Format étendu
ps -u $USER   # Seulement vos processus
```
```
top           # Vue interactive classique
htop          # Version améliorée (installer avec: sudo apt install htop)
```
## Dans htop, utilisez :

    F4 : Filtrer par nom (ex: "java")

    F5 : Vue en arborescence

    F6 : Trier par colonne

    F9 : Tuer un processus

    q : Quitter

## 🆔 Identifiants de processus

Chaque processus a :

    PID : Process ID (unique)

    PPID : Parent Process ID

    UID : User ID (qui l'a lancé)

    # 1. Trouver le processus
 ´´´
ps aux | grep nom-application
 ´´´

# 2. Tuer gentiment
 ´´´
kill PID
 ´´´
# 3. Si ça ne fonctionne pas après 10 secondes
 ´´´
kill -9 PID
 ´´´