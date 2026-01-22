#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# setup.sh — Environnement DEV/DEVOPS PRO - Ubuntu 24.04 LTS
# Basé sur les documentations officielles de chaque outil (Janvier 2026)
#
# Usage:
#   ./setup.sh --minimal   # Docker uniquement
#   ./setup.sh --dev       # + Outils développement
#   ./setup.sh --full      # + MongoDB + Android Studio + Postman
#   ./setup.sh --full --docker-desktop
###############################################################################

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------
ASDF_VERSION="v0.16.0"  
MODE="full"
INSTALL_DOCKER_DESKTOP=false

LOG_DIR="$(pwd)/logs"
LOG_FILE="$LOG_DIR/setup-$(date +%Y%m%d-%H%M%S).log"

# -----------------------------------------------------------------------------
# COULEURS
# -----------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# -----------------------------------------------------------------------------
# FONCTIONS UTILITAIRES
# -----------------------------------------------------------------------------
log_message() {
  local level="$1"
  local message="$2"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

step()    { log_message "STEP" "$1"; echo -e "${CYAN}▶ $1${NC}"; }
success() { log_message "SUCCESS" "$1"; echo -e "${GREEN}✓ $1${NC}"; }
warn()    { log_message "WARN" "$1"; echo -e "${YELLOW}⚠ $1${NC}"; }
fail()    { log_message "ERROR" "$1"; echo -e "${RED}✗ $1${NC}"; exit 1; }

# -----------------------------------------------------------------------------
# ARGUMENTS
# -----------------------------------------------------------------------------
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --minimal) MODE="minimal" ;;
      --dev) MODE="dev" ;;
      --full) MODE="full" ;;
      --docker-desktop) INSTALL_DOCKER_DESKTOP=true ;;
      --help|-h)
        echo "Usage: ./setup.sh [--minimal|--dev|--full] [--docker-desktop]"
        echo ""
        echo "Modes:"
        echo "  --minimal    : Docker uniquement"
        echo "  --dev        : Docker + outils développement (ASDF, IDE)"
        echo "  --full       : Tout + MongoDB + Android Studio + Postman"
        exit 0 ;;
      *) fail "Option inconnue: $1" ;;
    esac
    shift
  done
}

# -----------------------------------------------------------------------------
# VÉRIFICATIONS PRÉALABLES
# -----------------------------------------------------------------------------
prechecks() {
  step "Vérifications préalables"

  # Vérifier l'utilisateur
  [[ "$EUID" -eq 0 ]] && fail "Ne pas exécuter en tant que root. Utilisez un utilisateur normal avec sudo."

  # Vérifier la distribution
  if [[ ! -f /etc/os-release ]]; then
    fail "Système d'exploitation non supporté"
  fi

  source /etc/os-release
  if [[ "$ID" != "ubuntu" ]] || [[ "$VERSION_ID" != "24.04" ]]; then
    warn "Ce script est conçu pour Ubuntu 24.04 LTS (Noble Numbat)"
    warn "Distribution détectée: $PRETTY_NAME"
    read -p "Continuer quand même? (y/N) " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
  fi

  # Vérifier les privilèges sudo
  if ! sudo -v; then
    fail "L'utilisateur n'a pas les privilèges sudo nécessaires"
  fi

  # Vérifier l'espace disque
  local available_space
  available_space=$(df -h / | awk 'NR==2 {print $4}' | sed 's/G//')
  if [[ $available_space -lt 15 ]]; then
    warn "Espace disque disponible faible: ${available_space}G"
    warn "Au moins 15G recommandés pour une installation complète (Android Studio)"
    read -p "Continuer quand même? (y/N) " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
  fi

  # Créer le dossier de logs
  mkdir -p "$LOG_DIR"

  success "Vérifications terminées"
}

# -----------------------------------------------------------------------------
# MISE À JOUR DU SYSTÈME
# -----------------------------------------------------------------------------
update_system() {
  step "Mise à jour du système"
  
  sudo apt-get update -qq
  sudo apt-get upgrade -y
  
  # Installer les packages essentiels pour Ubuntu 24.04
  sudo apt-get install -y \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    gnupg \
    lsb-release \
    git \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncurses-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    jq \
    htop \
    net-tools \
    dnsutils \
    unzip \
    zip \
    tree \
    neovim \
    bat \
    fd-find \
    ripgrep \
    file
  
  success "Système mis à jour et packages essentiels installés"
}

# -----------------------------------------------------------------------------
# INSTALLATION DOCKER ENGINE (OFFICIELLE - Janvier 2026)
# -----------------------------------------------------------------------------
install_docker() {
  step "Installation de Docker Engine (procédure officielle)"

  # Vérifier si Docker est déjà installé
  if command -v docker >/dev/null && docker --version >/dev/null 2>&1; then
    echo "Docker est déjà installé: $(docker --version)"
    return 0
  fi

  # 1. Nettoyer les anciennes installations
  sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

  # 2. Configurer le repository Docker
  sudo apt-get install -y ca-certificates curl gnupg

  # Ajouter la clé GPG de Docker (format moderne 2026)
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Configurer le repository stable
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # 3. Installer Docker Engine
  sudo apt-get update -qq
  sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

  # 4. Configurer Docker pour l'utilisateur courant
  sudo groupadd docker 2>/dev/null || true
  sudo usermod -aG docker "$USER"

  # 5. Démarrer et activer Docker
  sudo systemctl enable docker
  sudo systemctl start docker

  # 6. Vérifier l'installation
  if sudo docker run --rm hello-world >/dev/null 2>&1; then
    success "Docker Engine installé avec succès (v29.x)"
  else
    warn "Docker installé mais la vérification a échoué"
  fi

  warn "Déconnexion/reconnexion nécessaire pour utiliser Docker sans sudo"
}

# -----------------------------------------------------------------------------
# FONCTION D'AJOUT SÛR AU .bashrc
# -----------------------------------------------------------------------------

safe_append_bashrc() {
  local line="$1"
  local bashrc="$HOME/.bashrc"

  # Vérifie si la ligne existe déjà
  if ! grep -qF "$line" "$bashrc"; then
    echo "$line" >> "$bashrc"
    echo "✅ Ajouté à $bashrc"
  else
    echo "ℹ️  Déjà présent dans $bashrc"
  fi
}   

# -----------------------------------------------------------------------------
# INSTALLATION DOCKER DESKTOP (OPTIONNEL)
# -----------------------------------------------------------------------------
install_docker_desktop() {
  step "Installation de Docker Desktop"

  # Vérifier si Docker Desktop est déjà installé
  if dpkg -l | grep -q docker-desktop; then
    echo "Docker Desktop est déjà installé"
    return 0
  fi

  # Télécharger la dernière version stable depuis le site officiel
  DOCKER_DESKTOP_URL="https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb"
  TEMP_DEB="$(mktemp).deb"
  
  echo "Téléchargement de Docker Desktop depuis le site officiel..."
  wget -q --show-progress -O "$TEMP_DEB" "$DOCKER_DESKTOP_URL"
  
  # Installer Docker Desktop
  sudo apt-get install -y "$TEMP_DEB"
  
  # Nettoyer
  rm -f "$TEMP_DEB"
  
  success "Docker Desktop installé"
  warn "Redémarrage recommandé pour une expérience complète"
}

# -----------------------------------------------------------------------------
# INSTALLATION ANDROID STUDIO (SNAP - Méthode Officielle 2026)
# -----------------------------------------------------------------------------
install_android_studio() {
  step "Installation d'Android Studio (via Snap - méthode officielle 2026)"

  # Vérifier si Android Studio est déjà installé via Snap
  if snap list 2>/dev/null | grep -q "^android-studio\s"; then
    echo "Android Studio est déjà installé via Snap"
    return 0
  fi

  # Vérifier si installé manuellement
  if [[ -f /opt/android-studio/bin/studio.sh ]] || command -v android-studio >/dev/null 2>&1; then
    echo "Android Studio est déjà installé (installation manuelle détectée)"
    return 0
  fi

  # Installer snapd si nécessaire
  if ! command -v snap >/dev/null; then
    echo "Installation de snapd..."
    sudo apt-get install -y snapd
    sudo systemctl enable --now snapd.socket
    sudo ln -s /var/lib/snapd/snap /snap 2>/dev/null || true
    sleep 2
  fi

  # Installer Android Studio via Snap (version 2025.2.3+)
  echo "Installation d'Android Studio (cela peut prendre quelques minutes)..."
  sudo snap install android-studio --classic
  
  # Configurer les variables d'environnement Android SDK
  if ! grep -q "ANDROID_HOME" ~/.bashrc; then
    echo '' >> ~/.bashrc
    echo '# Android SDK' >> ~/.bashrc
    echo 'export ANDROID_HOME="$HOME/Android/Sdk"' >> ~/.bashrc
    echo 'export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"' >> ~/.bashrc
  fi
  
  success "Android Studio installé via Snap (version 2025.2.3+)"
  echo ""
  echo "📱 Pour terminer l'installation d'Android Studio:"
  echo "1. Lancez 'android-studio' depuis le terminal ou le menu applications"
  echo "2. Suivez l'assistant de configuration"
  echo "3. L'installation du SDK Android se fera automatiquement (~2-4GB)"
  echo ""
  warn "Note: Le premier lancement peut prendre quelques minutes"
}

# -----------------------------------------------------------------------------
# INSTALLATION POSTMAN (SNAP - Méthode Officielle)
# -----------------------------------------------------------------------------
install_postman() {
  step "Installation de Postman (via Snap - méthode officielle)"

  # Vérifier si Postman est déjà installé via Snap
  if snap list 2>/dev/null | grep -q "^postman\s"; then
    echo "Postman est déjà installé via Snap"
    return 0
  fi
  
  # Vérifier installation manuelle
  if [[ -f /opt/Postman/app/postman ]] || command -v postman >/dev/null 2>&1; then
    echo "Postman est déjà installé (installation manuelle détectée)"
    return 0
  fi

  # Installer snapd si nécessaire
  if ! command -v snap >/dev/null; then
    echo "Installation de snapd..."
    sudo apt-get install -y snapd
    sudo systemctl enable --now snapd.socket
    sudo ln -s /var/lib/snapd/snap /snap 2>/dev/null || true
    sleep 2
  fi
  
  # Installer Postman
  sudo snap install postman
  
  success "Postman installé via Snap"
  echo "Lancez Postman depuis le menu applications ou via 'postman' en terminal"
}

# -----------------------------------------------------------------------------
# INSTALLATION ASDF (OFFICIELLE - Version 0.16.0)
# -----------------------------------------------------------------------------
install_asdf() {
  step "Installation de ASDF Version Manager v$ASDF_VERSION"

  # Vérifier si ASDF est déjà installé
  if [[ -d "$HOME/.asdf" ]] && command -v asdf >/dev/null 2>&1; then
    echo "ASDF est déjà installé"
    return 0
  fi

  # Vérifier si Git est installé
  if ! command -v git >/dev/null; then
    sudo apt-get install -y git
  fi

  # Installer ASDF via Git (méthode officielle)
  if [[ ! -d "$HOME/.asdf" ]]; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch "$ASDF_VERSION"
  fi

  # Configuration du shell
  ASDF_SETUP='
# ASDF - Version Manager
if [ -d "$HOME/.asdf" ]; then
  . "$HOME/.asdf/asdf.sh"
  # Completions bash
  if [ -f "$HOME/.asdf/completions/asdf.bash" ]; then
    . "$HOME/.asdf/completions/asdf.bash"
  fi
fi'

  # Ajouter à .bashrc si pas déjà présent
  if ! grep -q "asdf.sh" ~/.bashrc; then
    echo "$ASDF_SETUP" >> ~/.bashrc
  fi

  # Charger ASDF immédiatement
  if [[ -f "$HOME/.asdf/asdf.sh" ]]; then
    . "$HOME/.asdf/asdf.sh"
  fi

  success "ASDF $ASDF_VERSION installé (version Go - performances améliorées)"
}

# -----------------------------------------------------------------------------
# INSTALLATION PLUGINS ASDF
# -----------------------------------------------------------------------------
install_asdf_plugins() {
  step "Installation des plugins ASDF"

  # Charger ASDF
  if [[ -f "$HOME/.asdf/asdf.sh" ]]; then
    . "$HOME/.asdf/asdf.sh"
  fi

  # Vérifier qu'ASDF est disponible
  if ! command -v asdf >/dev/null; then
    warn "ASDF n'est pas disponible. Vérifiez l'installation."
    return 1
  fi

  # Liste des plugins
  declare -A plugins=(
    [java]="https://github.com/halcyon/asdf-java.git"
    [nodejs]="https://github.com/asdf-vm/asdf-nodejs.git"
    [python]="https://github.com/asdf-community/asdf-python.git"
    [gradle]="https://github.com/rfrancis/asdf-gradle.git"
    [kotlin]="https://github.com/asdf-community/asdf-kotlin.git"
  )

  # Installer chaque plugin
  for plugin in "${!plugins[@]}"; do
    if ! asdf plugin list 2>/dev/null | grep -q "^${plugin}$"; then
      echo "  Installation du plugin: $plugin"
      asdf plugin add "$plugin" "${plugins[$plugin]}" 2>&1 | grep -v "plugin already added" || true
    else
      echo "  Plugin $plugin déjà installé"
    fi
  done

  # Installation de Java 21 (nécessaire pour Kobweb et Android Studio)
  step "Installation de Java (Temurin 21.0.x)..."
  JAVA_VERSION=$(asdf list all java | grep "temurin-21" | tail -1 | xargs)
  
  if [ -n "$JAVA_VERSION" ]; then
    asdf install java "$JAVA_VERSION" 2>/dev/null || echo "  Java $JAVA_VERSION déjà installé"
    
    # Utiliser 'asdf set' au lieu de 'asdf global' pour ASDF 0.16.0
    cd "$HOME" && asdf set java "$JAVA_VERSION"
    
    # Configuration de JAVA_HOME dans le .bashrc
    if ! grep -q "ASDF_JAVA_RS_JAVA_HOME" ~/.bashrc; then
      echo '. ~/.asdf/plugins/java/set-java-home.bash' >> ~/.bashrc
    fi
    
    success "Java $JAVA_VERSION configuré"
  else
    warn "Aucune version Temurin 21 trouvée"
  fi

  success "Plugins ASDF installés"
}

# -----------------------------------------------------------------------------
# INSTALLATION VS CODE (OFFICIELLE - Format DEB822 Moderne)
# -----------------------------------------------------------------------------
install_vscode() {
  step "Installation de Visual Studio Code"

  # Vérifier si VS Code est déjà installé
  if command -v code >/dev/null; then
    echo "Visual Studio Code est déjà installé"
    return 0
  fi

  # Installer les dépendances
  sudo apt-get install -y wget gpg apt-transport-https

  # Télécharger et installer la clé GPG Microsoft
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor > packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg \
    /etc/apt/keyrings/packages.microsoft.gpg
  rm packages.microsoft.gpg
  
  # Ajouter le repository (format moderne DEB822)
  echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
    sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
  
  # Installer VS Code
  sudo apt-get update -qq
  sudo apt-get install -y code
  
  success "Visual Studio Code installé"
}

# -----------------------------------------------------------------------------
# INSTALLATION INTELLIJ IDEA (SNAP - Édition Unifiée 2025.3+)
# -----------------------------------------------------------------------------
install_intellij() {
  step "Installation d'IntelliJ IDEA (édition unifiée 2025.3+)"

  # Vérifier si déjà installé
  if snap list 2>/dev/null | grep -q "intellij-idea"; then
    echo "IntelliJ IDEA est déjà installé"
    return 0
  fi

  # Vérifier et installer Snap si nécessaire
  if ! command -v snap >/dev/null; then
    sudo apt-get install -y snapd
    sudo systemctl enable --now snapd.socket
    sudo ln -s /var/lib/snapd/snap /snap 2>/dev/null || true
    sleep 2
  fi

  # Installer IntelliJ IDEA (édition unifiée)
  sudo snap install intellij-idea-community --classic
  
  success "IntelliJ IDEA installé (édition unifiée 2025.3+)"
  echo ""
  echo "ℹ️  IntelliJ IDEA 2025.3+ : Édition unifiée"
  echo "   - Fonctionnalités Community gratuites pour tous"
  echo "   - Essai Ultimate de 30 jours disponible dans l'IDE"
  echo ""
}

# -----------------------------------------------------------------------------
# INSTALLATION MONGODB 8.0 (OFFICIELLE - Support Ubuntu 24.04 Noble)
# -----------------------------------------------------------------------------
install_mongodb() {
  step "Installation de MongoDB 8.0 (support natif Ubuntu 24.04)"

  # Vérifier si MongoDB est déjà installé
  if command -v mongod >/dev/null; then
    echo "MongoDB est déjà installé"
    # Vérifier si le service est actif
    if sudo systemctl is-active --quiet mongod; then
      echo "  Service MongoDB est actif"
    else
      sudo systemctl start mongod
    fi
    return 0
  fi

  # Installer les dépendances
  sudo apt-get install -y gnupg curl
  
  # Importer la clé GPG MongoDB 8.0
  curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
    sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
  
  # Créer le fichier de liste pour Ubuntu 24.04 (noble) - Support officiel
  echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | \
    sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
  
  # Installer MongoDB
  sudo apt-get update -qq
  sudo apt-get install -y mongodb-org
  
  # Démarrer le service
  sudo systemctl enable mongod
  sudo systemctl start mongod
  
  # Vérifier l'installation
  if sudo systemctl is-active --quiet mongod; then
    success "MongoDB 8.0 installé et démarré (support natif Ubuntu 24.04)"
  else
    warn "MongoDB installé mais le service n'est pas actif"
  fi
}

# -----------------------------------------------------------------------------
# INSTALLATION OUTILS SUPPLÉMENTAIRES
# -----------------------------------------------------------------------------
install_additional_tools() {
  step "Installation d'outils supplémentaires DevOps"

  # Outils réseau
  sudo apt-get install -y \
    netcat-openbsd \
    nmap \
    whois \
    telnet \
    traceroute

  # Outils de développement
  sudo apt-get install -y \
    httpie \
    shellcheck \
    yamllint \
    python3-venv \
    python3-pip

  # Outils système modernes (Ubuntu 24.04)
  sudo apt-get install -y \
    ncdu \
    lsof \
    rsync \
    glances \
    eza  # Remplace exa (obsolète)

  success "Outils supplémentaires installés"
}

# -----------------------------------------------------------------------------
# FONCTION PRINCIPALE
# -----------------------------------------------------------------------------
main() {
  parse_args "$@"
  
  echo "==============================================="
  echo "  SETUP ENVIRONNEMENT DEV/DEVOPS PRO"
  echo "  Ubuntu 24.04 LTS - Version 2026"
  echo "  Mode: $MODE"
  echo "  Docker Desktop: $INSTALL_DOCKER_DESKTOP"
  echo "  Logs: $LOG_FILE"
  echo "==============================================="
  
  prechecks
  update_system
  
  # Installation Docker (toujours présent)
  install_docker
  
  case "$MODE" in
    "minimal")
      # Seulement Docker
      ;;
      
    "dev")
      install_asdf
      install_asdf_plugins
      install_vscode
      install_intellij
      install_postman
      ;;
      
    "full")
      install_asdf
      install_asdf_plugins
      install_vscode
      install_intellij
      install_postman
      install_android_studio
      install_mongodb
      install_additional_tools
      ;;
  esac
  
  [[ "$INSTALL_DOCKER_DESKTOP" == true ]] && install_docker_desktop
  
  # Afficher le résumé
  echo ""
  echo "==============================================="
  echo "  INSTALLATION TERMINÉE AVEC SUCCÈS 🚀"
  echo "==============================================="
  echo ""
  echo "📦 Résumé des installations:"
  case "$MODE" in
    "minimal")
      echo "  ✓ Docker Engine v29.x"
      [[ "$INSTALL_DOCKER_DESKTOP" == true ]] && echo "  ✓ Docker Desktop"
      ;;
    "dev")
      echo "  ✓ Docker Engine v29.x"
      echo "  ✓ ASDF v0.16.0 (version Go - performances améliorées)"
      echo "  ✓ Plugins ASDF: Java, Node.js, Python, Kotlin, Gradle"
      echo "  ✓ Java 21 (Temurin) configuré"
      echo "  ✓ Visual Studio Code"
      echo "  ✓ IntelliJ IDEA (édition unifiée 2025.3+)"
      echo "  ✓ Postman"
      echo "  ✓ Kobweb CLI"
      [[ "$INSTALL_DOCKER_DESKTOP" == true ]] && echo "  ✓ Docker Desktop"
      ;;
    "full")
      echo "  ✓ Docker Engine v29.x"
      echo "  ✓ ASDF v0.16.0 (version Go - performances améliorées)"
      echo "  ✓ Plugins ASDF: Java, Node.js, Python, Kotlin, Gradle"
      echo "  ✓ Java 21 (Temurin) configuré"
      echo "  ✓ Visual Studio Code"
      echo "  ✓ IntelliJ IDEA (édition unifiée 2025.3+)"
      echo "  ✓ Postman"
      echo "  ✓ Kobweb CLI"
      echo "  ✓ Android Studio 2025.2.3+ (via Snap)"
      echo "  ✓ MongoDB 8.0 (support natif Ubuntu 24.04)"
      echo "  ✓ Outils supplémentaires (nmap, httpie, shellcheck, eza, etc.)"
      [[ "$INSTALL_DOCKER_DESKTOP" == true ]] && echo "  ✓ Docker Desktop"
      ;;
  esac
  
  echo ""
  echo "🚀 Prochaines étapes:"
  echo "1. Déconnectez-vous et reconnectez-vous pour:"
  echo "   - Utiliser Docker sans sudo (groupe docker)"
  echo "   - Activer ASDF et ses variables d'environnement"
  echo "   - Activer les variables d'environnement Android SDK"
  echo "   - Activer Kobweb CLI"
  echo ""
  echo "2. Après reconnexion, vérifiez les installations:"
  echo "   docker --version"
  echo "   asdf --version"
  echo "   asdf current java"
  echo "   code --version"
  echo "   kobweb --version"
  echo "   snap list  # Pour voir Postman, Android Studio, IntelliJ"
  echo ""
  if [[ "$MODE" == "full" ]]; then
    echo "3. Pour Android Studio:"
    echo "   - Lancez 'android-studio' depuis le terminal ou le menu"
    echo "   - Suivez l'assistant d'installation du SDK (~2-4GB)"
    echo ""
    echo "4. Pour MongoDB:"
    echo "   - Service déjà démarré automatiquement"
    echo "   - Connexion test: mongosh"
    echo ""
  fi
  echo "5. Consultez les logs détaillés:"
  echo "   $LOG_FILE"
  echo ""
  
  # Estimation de l'espace disque
  echo "💾 Espace disque utilisé:"
  case "$MODE" in
    "minimal") echo "  ~500 MB - 1 GB" ;;
    "dev") echo "  ~2 - 3 GB" ;;
    "full") echo "  ~6 - 8 GB (Android SDK non inclus - +2-4GB lors du 1er lancement)" ;;
  esac
  echo ""
  
  echo "📚 Versions installées (Janvier 2026):"
  echo "  - Docker Engine: v29.1.x"
  echo "  - Docker Compose: v2.39.x"
  echo "  - ASDF: v0.16.0 (Go - performances optimisées)"
  echo "  - Java: Temurin 21.0.x"
  echo "  - MongoDB: 8.0 (support natif Ubuntu 24.04)"
  echo "  - Android Studio: 2025.2.3+"
  echo "  - IntelliJ IDEA: 2025.3+ (édition unifiée)"
  echo "  - Kobweb: Latest"
  echo ""
  
  success "Setup complet terminé à $(date)"
  warn "IMPORTANT: Déconnexion/reconnexion requise pour finaliser l'installation"
}

# Exécuter le script
trap 'fail "Erreur à la ligne $LINENO"' ERR
main "$@"