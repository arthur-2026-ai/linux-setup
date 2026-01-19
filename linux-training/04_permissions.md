# 🛡️ Module 04 — Permissions & Sécurité Linux (Essentiel Dev)

## 🎯 Objectifs du module
À la fin de ce module, le développeur doit être capable de :
- Comprendre **qui peut faire quoi** sur un système Linux
- Lire et modifier correctement les **permissions fichiers**
- Utiliser `sudo` **sans mettre le système en danger**
- Éviter les **erreurs de sécurité courantes** en environnement dev
- Travailler en équipe **sans casser les droits des autres**

---

## 1️⃣ Pourquoi la sécurité est CRITIQUE en Linux

Sous Linux :
- Tout est **fichier**
- Tout a un **propriétaire**
- Tout a des **permissions**

👉 Une seule mauvaise permission peut :
- bloquer un projet
- exposer des données
- casser un serveur

Linux ne protège pas contre les erreurs → **il te fait confiance**.

---

## 2️⃣ Utilisateurs et groupes

### 🔹 Utilisateur
Un utilisateur = une identité

```bash
whoami
id
```

---

### 🔹 Groupes

Les groupes permettent de partager des droits proprement.

groups


👉 Bonne pratique :

Un projet = un groupe

Les devs = membres du groupe

Les fichiers = appartenant au groupe

## 3️⃣ Lire les permissions (ls -l)

```
ls -l

```


Exemple :

-rwxr-x---

Décomposition
Partie	Signification
-	type (- fichier, d dossier)
rwx	propriétaire
r-x	groupe
---	autres
Valeurs
Lettre	Droit
r	lire
w	écrire
x	exécuter
## 4️⃣ Permissions numériques (TRÈS IMPORTANT)
Valeur	Droit
4	read
2	write
1	execute
Exemple
```
chmod 755 script.sh
```
Chiffre	Qui
7	propriétaire (rwx)
5	groupe (r-x)
5	autres (r-x)

👉 755 = standard pour scripts
👉 644 = fichiers code
👉 700 = données sensibles

## 5️⃣ Modifier les permissions
🔹 chmod (droits)
```
chmod 644 fichier.txt
chmod +x script.sh
```

🔹 chown (propriétaire)
```
sudo chown user:group fichier
```

🔹 chgrp (groupe uniquement)
```
sudo chgrp dev projet/
```

## 6️⃣ Permissions sur les dossiers (⚠️ piège fréquent)

Sur un dossier :

r → lister

w → créer / supprimer

x → entrer dans le dossier

⚠️ Sans x, le dossier est inutilisable

## 7️⃣ sudo : pouvoir absolu (discipline requise)
```
sudo commande
```

Règles d’or

* ❌ sudo rm -rf /
* ❌ sudo chmod -R 777 .
* ❌ coder avec sudo
* ❌ installer des libs globales inutilement

👉 sudo = administration, pas développement.

## 8️⃣ Erreurs de sécurité classiques (INTERDITES)

* ❌ chmod 777
* ❌ chmod -R 777
* ❌ travailler en root
* ❌ donner tous les droits “pour aller vite”

👉 Anti-patterns professionnels.

 ## 9️⃣ Bonnes pratiques startup / équipe

* Structure recommandée :

/home/dev/workspace


* Propriétaire : utilisateur

Groupe : dev

* Permissions projet :

```
chmod -R 775 projet
```

* Scripts :
```
chmod +x *.sh
```
## 🔟 Sécurité minimale côté dev

Verrouiller la session

SSH par clé (pas de mot de passe)

Clés privées protégées
```
chmod 600 ~/.ssh/id_rsa
```
## 🧪 Exercices pratiques (OBLIGATOIRES)
### Exercice 1 — Permissions fichier
```
mkdir secure-test
cd secure-test
touch test.txt
chmod 640 test.txt
ls -l
```

### Exercice 2 — Script exécutable
```
nano hello.sh
```
```
#!/bin/bash
echo "Hello secure world"
```
```
chmod +x hello.sh
./hello.sh
```
### Exercice 3 — Projet partagé

* Créer un dossier projet

* Appliquer 775

* Expliquer pourquoi ce choix

* justifier pourquoi 777 est dangereux



