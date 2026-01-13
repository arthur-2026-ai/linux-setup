# 🗂️ Module 2 : Système de Fichiers Linux

## 🎯 Objectifs de ce module

À la fin de ce module, vous saurez :
- ✅ Comprendre la hiérarchie des fichiers Linux
- ✅ Naviguer efficacement dans l'arborescence
- ✅ Créer, supprimer et gérer fichiers/dossiers
- ✅ Utiliser les chemins absolus et relatifs
- ✅ Rechercher des fichiers

---

## 📊 La hiérarchie standard Linux (FHS)

Linux organise les fichiers de manière logique :

/ (racine)
├── bin/ → Commandes essentielles (ls, cp, mv...)
├── etc/ → Fichiers de configuration
├── home/ → Dossiers personnels des utilisateurs
├── usr/ → Applications et programmes utilisateur
├── var/ → Fichiers variables (logs, bases de données)
├── tmp/ → Fichiers temporaires
├── opt/ → Logiciels optionnels/packages tiers
├── dev/ → Périphériques matériels
└── proc/ → Informations système et processus

💡 **Pour le développement Kotlin** :
- Votre code va dans `~/` (votre dossier home)
- Les outils (JDK, Kotlin) sont dans `/usr/` ou `/opt/`
- La configuration est souvent dans `~/.config/`

---

## 🧭 Navigation : les commandes essentielles

### `pwd` - Print Working Directory
```bash
pwd
# Affiche : /home/votre_nom

ls - List files

ls          # Liste simple
ls -l       # Liste détaillée (permissions, taille, date)
ls -la      # Liste détaillée + fichiers cachés
ls -lh      # Tailles lisibles par humains (Ko, Mo, Go)
ls -lt      # Tri par date (plus récent en premier)

cd - Change Directory

cd /chemin/absolu      # Aller à un chemin absolu
cd dossier_relatif      # Aller à un dossier relatif
cd ~                   # Retour au dossier home
cd ..                  # Remonter d'un niveau
cd -                   # Retourner au dossier précédent
cd /                   # Aller à la racine

✨ **Création et gestion** 

mkdir - Make Directory

mkdir mon-projet                          # Créer un dossier
mkdir -p mon-projet/src/main/kotlin       # Créer une arborescence
mkdir projet{1,2,3}                       # Créer plusieurs dossiers

touch - Créer/modifier date fichier

touch Main.kt                      # Créer un fichier vide
touch fichier1.txt fichier2.txt    # Créer plusieurs fichiers
touch -t 202401121200 fichier.txt  # Modifier la date

touch - Créer/modifier date fichier
bash

touch Main.kt                      # Créer un fichier vide
touch fichier1.txt fichier2.txt    # Créer plusieurs fichiers
touch -t 202401121200 fichier.txt  # Modifier la date

cp - Copy
bash

cp source.txt destination.txt              # Copier un fichier
cp -r dossier_source dossier_destination   # Copier un dossier récursivement
cp *.kt backup/                           # Copier tous les fichiers .kt

mv - Move/Rename
bash

mv ancien_nom.kt nouveau_nom.kt    # Renommer
mv fichier.kt dossier/             # Déplacer
mv *.kt archive/                   # Déplacer plusieurs fichiers

rm - Remove

⚠️ DANGER : Pas de corbeille en ligne de commande !
bash

rm fichier.txt                     # Supprimer un fichier
rm -r dossier/                     # Supprimer un dossier récursivement
rm -rf dossier/                    # Forcer la suppression sans confirmation

🔒 Bonnes pratiques :
bash

# TOUJOURS vérifier avant de supprimer récursivement
ls -la dossier/
# Puis seulement
rm -r dossier/

📍 Chemins absolus vs relatifs
Chemin absolu

Commence toujours par /
bash

cd /home/ton_nom/projets/kotlin
ls /usr/bin/java

Chemin relatif

Départ depuis le dossier courant
bash

# Si je suis dans /home/ton_nom
cd projets/kotlin          # = /home/ton_nom/projets/kotlin
cd ../autre-projet         # Remonte puis redescend
cd ./sous-dossier          # Le . est optionnel mais clair

Symboles spéciaux
bash

.      # Dossier courant
..     # Dossier parent
~      # Dossier home de l'utilisateur
-      # Dossier précédent

🔍 Recherche de fichiers
find - Recherche puissante
bash

# Rechercher par nom
find . -name "*.kt"                    # Tous les fichiers Kotlin
find ~/projets -name "Main.kt"         # Rechercher dans projets
find / -type f -name "*.java" 2>/dev/null  # Recherche système

# Rechercher par type
find . -type f                         # Fichiers seulement
find . -type d                         # Dossiers seulement

# Rechercher par taille
find . -size +100M                     > 100 Mo
find . -size -10k                      < 10 Ko

# Rechercher par date
find . -mtime -7                       # Modifié dans les 7 derniers jours
find . -mtime +30                      # Modifié il y a plus de 30 jours

locate - Recherche rapide (base de données)
bash

sudo updatedb          # Mettre à jour la base de données
locate .kt             # Très rapide mais moins précis
locate -i main.kt      # Insensible à la casse

Vérifier l'espace disque
bash

df -h                  # Espace disque disponible
du -sh *               # Taille de chaque dossier
du -sh .               # Taille du dossier courant