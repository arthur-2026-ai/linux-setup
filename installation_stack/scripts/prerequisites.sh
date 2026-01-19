#!/bin/bash

################################################################################
# Script: prerequisites.sh
# Description: Installation des prérequis système pour Ubuntu 24.04 LTS
# Auteur: DevOps Team
# Version: 1.0.0
################################################################################

set -e

# Détection du répertoire du script
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${SCRIPT_DIR}/../logs/prerequisites-$(date +%Y%m%d-%H%M%S).log"

# Couleurs
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# Logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

print_step() {
    echo -e "\n${YELLOW}▶ $1${NC}" | tee -a "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}✗ $1${NC}" | tee -a "$LOG_FILE"
}

# Fonction pour vérifier si un paquet est installé
is_package_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

# Fonction pour installer un paquet avec gestion d'erreur
install_package() {
    local pkg_name="$1"
    local description="$2"
    
    if is_package_installed "$pkg_name"; then
        print_success "$description déjà installé"
        return 0
    fi
    
    print_step "Installation de $description..."
    
    if sudo apt-get install -y "$pkg_name" 2>&1 | tee -a "$LOG_FILE"; then
        print_success "$description installé"
        return 0
    else
        print_error "Échec de l'installation de $description"
        return 1
    fi
}

# Fonction principale
main() {
    print_step "Mise à jour des dépôts APT"
    log "Mise à jour des paquets disponibles"
    
    # Mise à jour des dépôts
    if ! sudo apt-get update 2>&1 | tee -a "$LOG_FILE"; then
        print_error "Échec de la mise à jour des dépôts"
        return 1
    fi
    print_success "Dépôts mis à jour"
    
    # Upgrade des paquets existants
    print_step "Mise à niveau des paquets existants"
    if ! sudo apt-get upgrade -y 2>&1 | tee -a "$LOG_FILE"; then
        print_warning "Certains paquets n'ont pas pu être mis à jour"
    fi
    print_success "Paquets mis à niveau"
    
    # Installation des prérequis essentiels
    print_step "Installation des prérequis de base"
    
    local base_packages=(
        "build-essential"
        "curl"
        "wget"
        "git"
        "unzip"
        "zip"
        "software-properties-common"
        "apt-transport-https"
        "ca-certificates"
        "gnupg"
        "lsb-release"
    )
    
    for pkg in "${base_packages[@]}"; do
        install_package "$pkg" "$pkg"
    done
    
    # Outils de développement supplémentaires (spécifiques Ubuntu 24.04)
    print_step "Installation des outils de développement"
    
    local dev_tools=(
        "python3"
        "python3-pip"
        "python3-venv"
        "nodejs"  # Version par défaut (souvent 18.x)
        "npm"
        "jq"
        "yq"
        "htop"
        "net-tools"
        "dnsutils"
        "tree"
        "tmux"
        "zsh"
        "fzf"
        "ripgrep"
        "fd-find"
        "bat"
        "exa"
    )
    
    for tool in "${dev_tools[@]}"; do
        install_package "$tool" "$tool"
    done
    
    # Installation de pip pour Python 3
    print_step "Configuration de Python"
    if ! is_package_installed "python3-pip"; then
        sudo apt-get install -y python3-pip 2>&1 | tee -a "$LOG_FILE"
        print_success "pip installé"
    fi
    
    # Mise à jour de pip
    python3 -m pip install --upgrade pip 2>&1 | tee -a "$LOG_FILE"
    print_success "pip mis à jour"
    
    # Installation de snap si non présent
    if ! command -v snap &> /dev/null; then
        print_step "Installation de Snap"
        sudo apt-get install -y snapd 2>&1 | tee -a "$LOG_FILE"
        sudo systemctl enable --now snapd.socket
        print_success "Snap installé et activé"
    fi
    
    # Installation de Flatpak
    print_step "Installation de Flatpak"
    if ! command -v flatpak &> /dev/null; then
        sudo apt-get install -y flatpak 2>&1 | tee -a "$LOG_FILE"
        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        print_success "Flatpak installé"
    fi
    
    # Configuration Git
    print_step "Configuration de Git"
    if command -v git &> /dev/null; then
        git config --global user.name "DevOps User"
        git config --global user.email "devops@example.com"
        git config --global core.editor "code --wait"
        git config --global init.defaultBranch "main"
        print_success "Git configuré"
    fi
    
    # Installation des polices Powerline
    print_step "Installation des polices pour terminaux"
    sudo apt-get install -y fonts-powerline 2>&1 | tee -a "$LOG_FILE"
    print_success "Polices Powerline installées"
    
    # Configuration du shell
    print_step "Configuration de l'environnement shell"
    if [ -f ~/.bashrc ]; then
        # Ajout d'alias utiles
        cat >> ~/.bashrc << 'EOF'

# ============================================
# ALIAS UTILES POUR DEVOPS
# ============================================

# Commandes raccourcies
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'
alias h='history'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Git shortcuts
alias gs='git status'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate'
alias gco='git checkout'
alias gb='git branch'
alias gr='git remote -v'

# Docker shortcuts
alias d='docker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dim='docker images'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias dcr='docker-compose restart'

# System monitoring
alias cpu='htop'
alias mem='free -h'
alias disk='df -h'
alias temp='sensors'

# Network
alias ports='netstat -tulpn'
alias myip='curl ifconfig.me'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Utilitaires
alias weather='curl wttr.in'
alias cheat='curl cheat.sh'
alias extract='tar -zxvf'

# ============================================
# FONCTIONS UTILES
# ============================================

# Créer un répertoire et y entrer
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Trouver un fichier
ff() {
    find . -type f -name "*$1*"
}

# Trouver un répertoire
fd() {
    find . -type d -name "*$1*"
}

# Vider l'historique
clearhist() {
    history -c
    history -w
}

# Taille des répertoires
ds() {
    du -sh * | sort -h
}

# Processus en cours
psg() {
    ps aux | grep -v grep | grep -i "$1"
}

# Mettre à jour le système
update() {
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
}

# Vérifier les ports ouverts
ports() {
    sudo lsof -i -P -n | grep LISTEN
}

# Générer un mot de passe
genpass() {
    openssl rand -base64 32
}

# ============================================
# VARIABLES D'ENVIRONNEMENT
# ============================================

# Langue
export LANG=fr_FR.UTF-8
export LC_ALL=fr_FR.UTF-8

# Editor par défaut
export EDITOR=code
export VISUAL=code

# Configuration Java (si installé)
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin

# Configuration Gradle (si installé)
export GRADLE_HOME=/opt/gradle
export PATH=$PATH:$GRADLE_HOME/bin

# Configuration Kotlin (si installé)
export KOTLIN_HOME=/opt/kotlin
export PATH=$PATH:$KOTLIN_HOME/bin

# Node.js
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Alias pour Python
alias python='python3'
alias pip='pip3'

# Prompt personnalisé
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Historique plus long
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups

# Auto-complétion Git
if [ -f /usr/share/bash-completion/completions/git ]; then
    . /usr/share/bash-completion/completions/git
fi

# Auto-complétion Docker
if [ -f /usr/share/bash-completion/completions/docker ]; then
    . /usr/share/bash-completion/completions/docker
fi

echo "✅ Environnement DevOps configuré pour Ubuntu 24.04"
EOF
        print_success "Configuration shell ajoutée"
    fi
    
    # Nettoyage
    print_step "Nettoyage des paquets inutiles"
    sudo apt-get autoremove -y 2>&1 | tee -a "$LOG_FILE"
    sudo apt-get clean 2>&1 | tee -a "$LOG_FILE"
    print_success "Nettoyage terminé"
    
    print_step "Résumé de l'installation"
    echo "========================================="
    echo "✅ Prérequis installés avec succès"
    echo "📦 Paquets de base: ✓"
    echo "🔧 Outils de développement: ✓"
    echo "🐍 Python 3.12: ✓"
    echo "📁 Git configuré: ✓"
    echo "🎨 Configuration shell: ✓"
    echo "🧹 Nettoyage effectué: ✓"
    echo "========================================="
    echo ""
    echo "Prochaines étapes:"
    echo "1. Redémarrer le terminal: source ~/.bashrc"
    echo "2. Vérifier l'installation: ./scripts/verify-installation.sh"
    echo "3. Continuer avec: ./setup.sh --all"
    
    return 0
}

# Exécution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi