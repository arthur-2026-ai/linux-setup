#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# setup.sh — Environnement DEV/DEVOPS - Ubuntu 24.04 LTS
# Installation directe des outils sans gestionnaire de versions
#
# Usage:
#   ./setup.sh --minimal   # Docker uniquement
#   ./setup.sh --dev       # + Outils développement
#   ./setup.sh --full      # + MongoDB + Android Studio
###############################################################################

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------
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
        echo "  --dev        : Docker + IDE + langages"
        echo "  --full       : Tout + MongoDB + Android Studio"
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

  [[ "$EUID" -eq 0 ]] && fail "Ne pas exécuter en tant que root"

  if [[ ! -f /etc/os-release ]]; then
    fail "Système d'exploitation non supporté"
  fi

  source /etc/os-release
  if [[ "$ID" != "ubuntu" ]] || [[ "$VERSION_ID" != "24.04" ]]; then
    warn "Ce script est conçu pour Ubuntu 24.04 LTS"
    warn "Distribution détectée: $PRETTY_NAME"
    read -p "Continuer? (y/N) " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
  fi

  if ! sudo -v; then
    fail "Privilèges sudo nécessaires"
  fi

  local available_space
  available_space=$(df -h / | awk 'NR==2 {print $4}' | sed 's/G//')
  if [[ $available_space -lt 15 ]]; then
    warn "Espace disque faible: ${available_space}G (15G recommandés)"
    read -p "Continuer? (y/N) " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
  fi

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
    jq \
    htop \
    net-tools \
    unzip \
    zip \
    tree \
    vim \
    bat \
    ripgrep
  
  success "Système mis à jour"
}

# -----------------------------------------------------------------------------
# INSTALLATION DOCKER
# -----------------------------------------------------------------------------
install_docker() {
  step "Installation de Docker Engine"

  if command -v docker >/dev/null 2>&1; then
    echo "Docker déjà installé: $(docker --version)"
    return 0
  fi

  sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
  sudo apt-get install -y ca-certificates curl gnupg

  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update -qq
  sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

  sudo groupadd docker 2>/dev/null || true
  sudo usermod -aG docker "$USER"
  sudo systemctl enable docker
  sudo systemctl start docker

  if sudo docker run --rm hello-world >/dev/null 2>&1; then
    success "Docker installé"
  else
    warn "Docker installé mais vérification échouée"
  fi

  warn "Déconnexion/reconnexion nécessaire pour Docker sans sudo"
}

# -----------------------------------------------------------------------------
# INSTALLATION DOCKER DESKTOP (OPTIONNEL)
# -----------------------------------------------------------------------------
install_java() {
  step "Installation Java 21 (APT)"

  # Installer Java si absent
  if ! command -v java >/dev/null 2>&1; then
    log_message "INFO" "Java absent, installation..."
    sudo apt-get update -y
    sudo apt-get install -y openjdk-21-jdk
  fi

  # Forcer Java 21 comme défaut
  sudo update-alternatives --set java \
    /usr/lib/jvm/java-21-openjdk-amd64/bin/java 2>/dev/null || true

  # Déterminer JAVA_HOME proprement
  JAVA_PATH="$(readlink -f "$(command -v java)")"
  JAVA_HOME_PATH="$(dirname "$(dirname "$JAVA_PATH")")"

  # Nettoyage anciennes configs
  sed -i '/^export JAVA_HOME=/d' ~/.bashrc
  sed -i '/JAVA_HOME\/bin/d' ~/.bashrc
  sed -i '/# Java/d' ~/.bashrc

  # Ajout propre
  {
    echo ""
    echo "# Java"
    echo "export JAVA_HOME=\"$JAVA_HOME_PATH\""
    echo 'export PATH="$PATH:$JAVA_HOME/bin"'
  } >> ~/.bashrc

  # Appliquer immédiatement
  export JAVA_HOME="$JAVA_HOME_PATH"
  export PATH="$PATH:$JAVA_HOME/bin"

  success "Java prêt — $(java -version 2>&1 | head -n1)"
}


# -----------------------------------------------------------------------------
# INSTALLATION NODE.JS
# -----------------------------------------------------------------------------
install_nodejs() {
  step "Installation de Node.js LTS"

  if command -v node >/dev/null 2>&1; then
    echo "Node.js déjà installé: $(node --version)"
    return 0
  fi

  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt-get install -y nodejs

  success "Node.js LTS installé"
}

# -----------------------------------------------------------------------------
# INSTALLATION PYTHON
# -----------------------------------------------------------------------------
install_python() {
  step "Installation de Python 3.12"

  if command -v python3.12 >/dev/null 2>&1; then
    echo "Python 3.12 déjà installé"
    return 0
  fi

  sudo add-apt-repository -y ppa:deadsnakes/ppa
  sudo apt-get update -qq
  sudo apt-get install -y \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    python3-pip

  success "Python 3.12 installé"
}

# -----------------------------------------------------------------------------
# INSTALLATION KOTLIN
# -----------------------------------------------------------------------------
install_kotlin() {
  step "Installation de Kotlin"

  if command -v kotlin >/dev/null 2>&1; then
    echo "Kotlin déjà installé"
    return 0
  fi

  sudo snap install kotlin --classic
  success "Kotlin installé"
}

# -----------------------------------------------------------------------------
# INSTALLATION GRADLE
# -----------------------------------------------------------------------------
install_gradle() {
  step "Installation de Gradle"

  if command -v gradle >/dev/null 2>&1; then
    echo "Gradle déjà installé: $(gradle --version | head -n 1)"
    return 0
  fi

  GRADLE_VERSION="8.11.1"
  wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
  sudo unzip -q -d /opt/gradle gradle-${GRADLE_VERSION}-bin.zip
  rm gradle-${GRADLE_VERSION}-bin.zip

  if ! grep -q "gradle" ~/.bashrc; then
    echo '' >> ~/.bashrc
    echo '# Gradle' >> ~/.bashrc
    echo "export PATH=\"\$PATH:/opt/gradle/gradle-${GRADLE_VERSION}/bin\"" >> ~/.bashrc
  fi

  success "Gradle ${GRADLE_VERSION} installé"
}

# -----------------------------------------------------------------------------
# INSTALLATION KOBWEB (Framework Kotlin Web)
# -----------------------------------------------------------------------------
install_kobweb() {
  step "Installation de Kobweb CLI"

  # Vérifier que JAVA_HOME est correct
  if [[ -z "${JAVA_HOME:-}" ]] || [[ ! -d "${JAVA_HOME:-}" ]]; then
    echo "Configuration de JAVA_HOME pour Kobweb..."
    JAVA_PATH=$(update-alternatives --query java | grep 'Value:' | cut -d' ' -f2)
    export JAVA_HOME=$(dirname $(dirname "$JAVA_PATH"))
    echo "JAVA_HOME défini: $JAVA_HOME"
  fi

  if command -v kobweb >/dev/null 2>&1; then
    # Vérifier si Kobweb fonctionne correctement
    if kobweb version >/dev/null 2>&1; then
      echo "Kobweb déjà installé: $(kobweb version)"
      return 0
    else
      echo "Kobweb présent mais non fonctionnel, réinstallation..."
    fi
  fi

  # Installation via SDKMAN (méthode officielle recommandée)
  if command -v sdk >/dev/null 2>&1; then
    echo "Installation via SDKMAN..."
    sdk install kobweb
    success "Kobweb installé via SDKMAN"
    return 0
  fi

  # Alternative: Téléchargement direct depuis GitHub
  KOBWEB_VERSION="0.9.21"
  KOBWEB_URL="https://github.com/varabyte/kobweb-cli/releases/download/v${KOBWEB_VERSION}/kobweb-${KOBWEB_VERSION}.zip"
  TEMP_DIR="$(mktemp -d)"
  
  echo "Téléchargement de Kobweb ${KOBWEB_VERSION}..."
  wget -q --show-progress -O "$TEMP_DIR/kobweb.zip" "$KOBWEB_URL"
  
  # Extraire dans /opt
  sudo unzip -q "$TEMP_DIR/kobweb.zip" -d /opt/
  rm -rf "$TEMP_DIR"
  
  # Ajouter au PATH
  if ! grep -q "/opt/kobweb-${KOBWEB_VERSION}/bin" ~/.bashrc; then
    # Supprimer les anciennes entrées Kobweb
    sed -i '/# Kobweb$/d' ~/.bashrc 2>/dev/null || true
    sed -i '/kobweb.*\/bin/d' ~/.bashrc 2>/dev/null || true
    
    echo '' >> ~/.bashrc
    echo '# Kobweb' >> ~/.bashrc
    echo "export PATH=\"\$PATH:/opt/kobweb-${KOBWEB_VERSION}/bin\"" >> ~/.bashrc
  fi
  
  # Créer un lien symbolique pour faciliter l'accès
  sudo ln -sf /opt/kobweb-${KOBWEB_VERSION}/bin/kobweb /usr/local/bin/kobweb 2>/dev/null || true
  
  # Charger immédiatement pour la session actuelle
  export PATH="$PATH:/opt/kobweb-${KOBWEB_VERSION}/bin"
  
  success "Kobweb ${KOBWEB_VERSION} installé"
  echo ""
  echo "ℹ️  Test: kobweb version"
  if command -v kobweb >/dev/null 2>&1 && kobweb version >/dev/null 2>&1; then
    echo "✓ Kobweb fonctionne: $(kobweb version)"
  else
    warn "Kobweb installé mais nécessite une reconnexion pour fonctionner"
  fi
  echo "📚 Documentation: https://kobweb.varabyte.com/"
}

# -----------------------------------------------------------------------------
# INSTALLATION VS CODE
# -----------------------------------------------------------------------------
install_vscode() {
  step "Installation de Visual Studio Code"

  if command -v code >/dev/null 2>&1; then
    echo "VS Code déjà installé"
    return 0
  fi

  # Ajouter la clé GPG Microsoft
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor > packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg \
    /etc/apt/keyrings/packages.microsoft.gpg
  rm packages.microsoft.gpg
  
  # Ajouter le repository
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] \
https://packages.microsoft.com/repos/code stable main" | \
sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
  
  # Installer VS Code en mode non-interactif
  sudo apt-get update -qq
  DEBIAN_FRONTEND=noninteractive sudo apt-get install -y code
  
  success "VS Code installé"
}

# -----------------------------------------------------------------------------
# INSTALLATION INTELLIJ IDEA
# -----------------------------------------------------------------------------
install_intellij() {
  step "Installation d'IntelliJ IDEA Community"

  if snap list 2>/dev/null | grep -q "intellij-idea"; then
    echo "IntelliJ IDEA déjà installé"
    return 0
  fi

  if ! command -v snap >/dev/null; then
    sudo apt-get install -y snapd
    sudo systemctl enable --now snapd.socket
    sleep 2
  fi

  sudo snap install intellij-idea-community --classic
  success "IntelliJ IDEA installé"
}

# -----------------------------------------------------------------------------
# INSTALLATION POSTMAN
# -----------------------------------------------------------------------------
install_postman() {
  step "Installation de Postman"

  if snap list 2>/dev/null | grep -q "postman"; then
    echo "Postman déjà installé"
    return 0
  fi

  sudo snap install postman
  success "Postman installé"
}

# -----------------------------------------------------------------------------
# INSTALLATION ANDROID STUDIO
# -----------------------------------------------------------------------------
install_android_studio() {
  step "Installation d'Android Studio"

  if snap list 2>/dev/null | grep -q "android-studio"; then
    echo "Android Studio déjà installé"
    return 0
  fi

  if [[ -f /opt/android-studio/bin/studio.sh ]]; then
    echo "Android Studio déjà installé (manuel)"
    return 0
  fi

  sudo snap install android-studio --classic
  
  if ! grep -q "ANDROID_HOME" ~/.bashrc; then
    echo '' >> ~/.bashrc
    echo '# Android SDK' >> ~/.bashrc
    echo 'export ANDROID_HOME="$HOME/Android/Sdk"' >> ~/.bashrc
    echo 'export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"' >> ~/.bashrc
  fi
  
  success "Android Studio installé"
}

# -----------------------------------------------------------------------------
# INSTALLATION MONGODB
# -----------------------------------------------------------------------------
install_mongodb() {
  step "Installation de MongoDB 8.0"

  if command -v mongod >/dev/null 2>&1; then
    echo "MongoDB déjà installé"
    if sudo systemctl is-active --quiet mongod; then
      echo "  Service actif"
    fi
    return 0
  fi

  sudo apt-get install -y gnupg curl
  
  curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
    sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
  
  echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] \
https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | \
sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
  
  sudo apt-get update -qq
  sudo apt-get install -y mongodb-org
  sudo systemctl enable mongod
  sudo systemctl start mongod
  
  success "MongoDB 8.0 installé"
}

# -----------------------------------------------------------------------------
# FONCTION PRINCIPALE
# -----------------------------------------------------------------------------
main() {
  parse_args "$@"
  
  echo "=============================================="
  echo "  SETUP ENVIRONNEMENT DEV"
  echo "  Ubuntu 24.04 LTS"
  echo "  Mode: $MODE"
  echo "  Logs: $LOG_FILE"
  echo "=============================================="
  
  prechecks
  update_system
  install_docker
  
  case "$MODE" in
    "minimal")
      # Docker seulement
      ;;
      
    "dev")
      install_java
      install_nodejs
      install_python
      install_kotlin
      install_gradle
      install_kobweb
      install_vscode
      install_intellij
      install_postman
      ;;
      
    "full")
      install_java
      install_nodejs
      install_python
      install_kotlin
      install_gradle
      install_kobweb
      install_vscode
      install_intellij
      install_postman
      install_android_studio
      install_mongodb
      ;;
  esac
  
  [[ "$INSTALL_DOCKER_DESKTOP" == true ]] && install_docker_desktop
  
  echo ""
  echo "=============================================="
  echo "  INSTALLATION TERMINÉE ✓"
  echo "=============================================="
  echo ""
  echo "📦 Outils installés:"
  
  case "$MODE" in
    "minimal")
      echo "  ✓ Docker Engine"
      ;;
    "dev"|"full")
      echo "  ✓ Docker Engine"
      echo "  ✓ Java 21 (OpenJDK)"
      echo "  ✓ Node.js LTS"
      echo "  ✓ Python 3.12"
      echo "  ✓ Kotlin"
      echo "  ✓ Gradle"
      echo "  ✓ Kobweb CLI"
      echo "  ✓ Visual Studio Code"
      echo "  ✓ IntelliJ IDEA Community"
      echo "  ✓ Postman"
      [[ "$MODE" == "full" ]] && echo "  ✓ Android Studio"
      [[ "$MODE" == "full" ]] && echo "  ✓ MongoDB 8.0"
      ;;
  esac
  
  echo ""
  echo "⚠️  IMPORTANT: Déconnectez-vous et reconnectez-vous"
  echo ""
  echo "Vérifications après reconnexion:"
  echo "  docker --version"
  [[ "$MODE" != "minimal" ]] && echo "  java --version"
  [[ "$MODE" != "minimal" ]] && echo "  node --version"
  [[ "$MODE" != "minimal" ]] && echo "  python3.12 --version"
  [[ "$MODE" != "minimal" ]] && echo "  gradle --version"
  [[ "$MODE" != "minimal" ]] && echo "  kobweb version"
  echo ""
  
  success "Installation terminée à $(date)"
}

trap 'fail "Erreur ligne $LINENO"' ERR
main "$@"