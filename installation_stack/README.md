# 🚀 Installation Stack - Kotlin & Kobweb (ASDF)

> Installation automatisée via **ASDF** - Simple, Maintenable, Scalable  
> **Optimisé pour Ubuntu 24.04 LTS (Noble Numbat)**

## 🎯 Pourquoi cette approche ?

### ✅ Avantages ASDF

- **Simple** : Un seul outil pour gérer toutes les versions
- **Maintenable** : Versions centralisées dans `.tool-versions`
- **Scalable** : Ajouter un outil = 3 lignes de code
- **Reproductible** : Même env sur toutes les machines
- **Pas de conflits** : Isolation complète par projet

### 🆚 Comparaison
```
| Aspect                        | Approche manuelle | **ASDF**       |
|-------------------------------|-------------------|----------------|
| Scripts                       | 15+ fichiers      | **1 fichier**  |
| Maintenance                   | Complexe          | **Simple**     |
| Ajouter outil                 | 50+ lignes        | **3 lignes**   |
| Conflits versions             | Fréquents         | **Jamais**     |
| Versions par projet           | Difficile         | **Automatique**|
```
---

## 📁 Structure du projet

```
installation_stack/
├── setup.sh              # 🎯 Script unique (ASDF)
├── .tool-versions        # 📋 Versions centralisées
├── logs/                 # 📝 Logs d'installation
└── README.md             # 📖 Ce fichier
```

---

## 🛠️ Options d'installation

### Installation complète (par défaut)

rendre le script executable
```bash
chmod +x setup.sh

```

```bash
./setup.sh
```

Installe :
- ✅ ASDF
- ✅ Java 21, Kotlin 2.0, Gradle 8.8, Node.js 22, Python 3.12
- ✅ Docker 26+
- ✅ VS Code + IntelliJ IDEA Community

### Installation minimale

```bash
./setup.sh --minimal
```

Installe uniquement ASDF + outils de développement.

### Sans Docker

```bash
./setup.sh --skip-docker
```

### Sans IDEs

```bash
./setup.sh --skip-ide
```

### Combinaisons

```bash
./setup.sh --skip-docker --skip-ide  # ASDF + tools seulement
```

---

## 📋 Versions installées

Les versions sont définies dans `.tool-versions` :

```bash
cat .tool-versions

# Sortie:
java openjdk-21.0.3
kotlin 2.0.0
gradle 8.8
nodejs 22.2.0
python 3.12.3
```

---

## 🔧 Gestion des versions avec ASDF

### Commandes essentielles

```bash
# Voir les versions actives
asdf current

# Lister toutes les versions disponibles d'un outil
asdf list all java
asdf list all kotlin

# Installer une version spécifique
asdf install java 21.0.4
asdf install kotlin 2.0.10

# Changer la version globale (toute la machine)
asdf global java 21.0.4

# Définir une version locale (projet actuel uniquement)
asdf local kotlin 2.0.10  # Crée/modifie .tool-versions

# Mettre à jour un plugin
asdf plugin update java

# Désinstaller une version
asdf uninstall kotlin 1.9.22
```

### Vérifier l'installation

```bash
# Via ASDF
asdf current

# Vérification manuelle
java -version
kotlin -version
gradle --version
node --version
python3 --version
```

---

## ➕ Ajouter un nouvel outil

C'est **ultra simple** avec ASDF ! Exemple : ajouter Golang

### Étape 1 : Ajouter le plugin dans `setup.sh`

```bash
# Dans la section "ASDF PLUGINS", ajouter:
[golang]="https://github.com/asdf-community/asdf-golang.git"
```

### Étape 2 : Ajouter la version dans `.tool-versions`

```bash
echo "golang 1.22.3" >> .tool-versions
```

### Étape 3 : Installer

```bash
asdf plugin-add golang https://github.com/asdf-community/asdf-golang.git
asdf install golang 1.22.3
```

**C'est tout !** 🎉 Golang est installé et géré par ASDF.

### Outils disponibles

Plus de 500 plugins disponibles : https://github.com/asdf-vm/asdf-plugins

Populaires :
- `ruby`, `python`, `nodejs`, `java`, `kotlin`, `golang`
- `rust`, `elixir`, `php`, `lua`, `terraform`
- `kubectl`, `helm`, `awscli`, `gcloud`

---

## 🔄 Workflow par projet

### Projet A : Kotlin 1.9 + Node 18

```bash
cd ~/projects/projet-A
echo "kotlin 1.9.24" > .tool-versions
echo "nodejs 18.20.0" >> .tool-versions
asdf install
```

### Projet B : Kotlin 2.0 + Node 22

```bash
cd ~/projects/projet-B
echo "kotlin 2.0.0" > .tool-versions
echo "nodejs 22.2.0" >> .tool-versions
asdf install
```

**Pas de conflit !** Chaque projet a ses versions isolées. 🎯

---

## ✅ Vérification complète

```bash
# Versions ASDF
asdf current

# Outils système
java -version      # openjdk 21.0.3
kotlin -version    # Kotlin version 2.0.0
gradle --version   # Gradle 8.8
node --version     # v22.2.0
python3 --version  # Python 3.12.3

# Docker (si installé)
docker --version

# IDEs (si installés)
code --version
snap list | grep intellij
```

---

## 🐛 Dépannage

### Problème : Commande non trouvée après installation

**Solution :**
```bash
source ~/.bashrc
# ou
exec bash
```

### Problème : Version incorrecte utilisée

**Solution :**
```bash
# Vérifier quelle version est active
asdf current

# Forcer reshim
asdf reshim

# Définir la version globale
asdf global kotlin 2.0.0
```

### Problème : Plugin ne s'installe pas

**Solution :**
```bash
# Mettre à jour la liste des plugins
asdf plugin update --all

# Réinstaller le plugin
asdf plugin remove kotlin
asdf plugin add kotlin https://github.com/asdf-community/asdf-kotlin.git
```

### Problème : Java non trouvé malgré ASDF

**Solution :**
```bash
# Vérifier l'installation
asdf list java

# Réinstaller si nécessaire
asdf install java openjdk-21.0.3

# Définir comme global
asdf global java openjdk-21.0.3

# Recharger
source ~/.bashrc
```

---

## 🔄 Migration depuis installation manuelle

Si tu as déjà des outils installés manuellement :

```bash
# 1. Désinstaller les versions manuelles (optionnel)
sudo apt remove openjdk-* gradle kotlin

# 2. Nettoyer les configurations
rm -rf ~/.gradle ~/.kotlin ~/.m2

# 3. Lancer setup.sh
./setup.sh

# 4. ASDF prend le relais !
```

---

## 📊 Avantages Ubuntu 24.04 LTS
```
| Feature        | Bénéfice                             |
|----------------|--------------------------------------|
| **Kernel 6.8** | Support matériel 2024 (WiFi 7, USB4) |
| **Python 3.12**| +20% performance native              |
| **GCC 13**     | C++23 complet                        |
| **Support LTS**| Jusqu'en 2029 (5 ans)                |
| **PipeWire**   | Audio moderne                        |
```
---

## 🎓 Ressources

### Documentation ASDF
- Site officiel : https://asdf-vm.com/
- Guide démarrage : https://asdf-vm.com/guide/getting-started.html
- Plugins : https://github.com/asdf-vm/asdf-plugins

### Documentation interne
- **Formation Linux** : `../formation-linux/`
- **Conventions équipe** : `../docs/CONVENTIONS.md`
- **Workflow Git** : `../docs/GIT_WORKFLOW.md`

### Support
- **Slack** : #dev-help
- **Logs** : `logs/setup-*.log`

---

## 🎯 Exemples concrets

### Créer un projet Kotlin

```bash
# 1. Créer le dossier
mkdir my-kotlin-app && cd my-kotlin-app

# 2. Définir les versions locales
cat > .tool-versions << EOF
java openjdk-21.0.3
kotlin 2.0.0
gradle 8.8
EOF

# 3. Installer les versions
asdf install

# 4. Vérifier
asdf current

# 5. Créer le projet
gradle init --type kotlin-application
```

### Tester différentes versions

```bash
# Terminal 1 : Projet avec Kotlin 1.9
cd projet-ancien
asdf local kotlin 1.9.24
kotlin -version  # 1.9.24

# Terminal 2 : Projet avec Kotlin 2.0
cd projet-nouveau
asdf local kotlin 2.0.0
kotlin -version  # 2.0.0
```

Pas de conflit ! 🎉

---

## 📝 Checklist post-installation

- [ ] `./setup.sh` exécuté avec succès
- [ ] `source ~/.bashrc` fait
- [ ] `asdf current` affiche les bonnes versions
- [ ] `java -version` fonctionne
- [ ] `kotlin -version` fonctionne
- [ ] `gradle --version` fonctionne
- [ ] Premier projet créé et testé

**Tout est coché ? Prêt à développer ! 🚀**

---

## 🤝 Contribuer

Pour améliorer ce setup :

1. Fork le projet
2. Crée une branche : `git checkout -b feature/mon-amelioration`
3. Teste sur Ubuntu 24.04 propre
4. Soumets une PR

---

## 📄 Licence

MIT License - Libre d'utilisation

---

**Version:** 1.0 (ASDF + Ubuntu 24.04 LTS ORION)  
**Dernière mise à jour:** Janvier 2026  
**Maintenu par:** L'équipe de développement D'ORION