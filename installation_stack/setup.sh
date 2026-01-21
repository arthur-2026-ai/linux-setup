#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# setup.sh - Environnement DevOps Dev Unifié (ASDF Go)
# Ubuntu 24.04 LTS
#
# Usage: ./setup.sh [--minimal]
###############################################################################

# -----------------------------------------------------------------------------
# CONFIG
# -----------------------------------------------------------------------------
ASDF_VERSION="v0.18.0"
LOG_DIR="$(pwd)/logs"
LOG_FILE="$LOG_DIR/setup-$(date +%Y%m%d-%H%M%S).log"
MINIMAL_MODE=false

BIN_DIR="$HOME/.local/bin"

# -----------------------------------------------------------------------------
# COLORS
# -----------------------------------------------------------------------------
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# -----------------------------------------------------------------------------
# UTILS
# -----------------------------------------------------------------------------
log() { echo "[$(date '+%F %T')] $1" | tee -a "$LOG_FILE"; }
step() { echo -e "\n${CYAN}▶ $1${NC}" | tee -a "$LOG_FILE"; }
success() { echo -e "${GREEN}✓ $1${NC}" | tee -a "$LOG_FILE"; }
warn() { echo -e "${YELLOW}⚠ $1${NC}" | tee -a "$LOG_FILE"; }
fail() { echo -e "${RED}✗ $1${NC}" | tee -a "$LOG_FILE"; exit 1; }
info() { echo -e "${CYAN}[INFO] $1${NC}" | tee -a "$LOG_FILE"; }

# -----------------------------------------------------------------------------
# PARSE ARGUMENTS
# -----------------------------------------------------------------------------
parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --minimal)
        MINIMAL_MODE=true
        shift
        ;;
      --help|-h)
        echo "Usage: ./setup.sh [--minimal]"
        exit 0
        ;;
      *)
        warn "Option inconnue: $1"
        exit 1
        ;;
    esac
  done
}

# -----------------------------------------------------------------------------
# PRECHECKS
# -----------------------------------------------------------------------------
prechecks() {
  step "Vérifications préalables"
  [[ "$EUID" -eq 0 ]] && fail "Ne pas lancer le script en root"
  command -v curl >/dev/null || fail "curl requis"
  command -v git >/dev/null || fail "git requis"
  mkdir -p "$LOG_DIR"
  success "Préchecks OK"
}

# -----------------------------------------------------------------------------
# INSTALL SYSTEM PACKAGES
# -----------------------------------------------------------------------------
install_system_packages() {
  step "Installation des dépendances système"
  sudo apt update -qq
  sudo apt install -y git curl wget unzip zip build-essential \
    libssl-dev libreadline-dev zlib1g-dev ca-certificates \
    htop tree vim neovim net-tools iputils-ping
  success "Dépendances système installées"
}

# -----------------------------------------------------------------------------
# INSTALL GO (si absent)
# -----------------------------------------------------------------------------
install_go() {
  if command -v go >/dev/null 2>&1; then
    success "Go déjà installé ($(go version))"
    return
  fi
  step "Installation de Go"
  sudo apt install -y golang-go
  success "Go installé ($(go version))"
}

# -----------------------------------------------------------------------------
# INSTALL ASDF (Go install)
# -----------------------------------------------------------------------------
install_asdf() {
  step "Installation ASDF ${ASDF_VERSION} via Go"
  mkdir -p "$BIN_DIR"

  if command -v asdf >/dev/null 2>&1; then
    success "ASDF déjà installé ($(asdf version))"
    return
  fi

  # Installer ASDF via Go
  install_go
  export PATH="$HOME/go/bin:$PATH"
  go install github.com/asdf-vm/asdf/cmd/asdf@"$ASDF_VERSION"

  success "ASDF ${ASDF_VERSION} installé via Go"
}

# -----------------------------------------------------------------------------
# CONFIGURE SHELL
# -----------------------------------------------------------------------------
configure_shell() {
  step "Configuration du shell"
  if ! grep -q "export PATH.*asdf" "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" << 'EOF'

# ASDF Version Manager
export PATH="$HOME/go/bin:$PATH"
EOF
    success ".bashrc mis à jour avec ASDF PATH"
  else
    info "ASDF PATH déjà présent dans .bashrc"
  fi
  source "$HOME/.bashrc"
}

# -----------------------------------------------------------------------------
# ASDF PLUGINS & TOOLS
# -----------------------------------------------------------------------------
install_asdf_plugins() {
  step "Installation des plugins ASDF"
  source "$HOME/go/bin/asdf" >/dev/null 2>&1 || true

  declare -A plugins=(
    [java]="https://github.com/halcyon/asdf-java.git"
    [kotlin]="https://github.com/asdf-community/asdf-kotlin.git"
    [gradle]="https://github.com/rfrancis/asdf-gradle.git"
    [nodejs]="https://github.com/asdf-vm/asdf-nodejs.git"
    [python]="https://github.com/asdf-community/asdf-python.git"
  )

  for plugin in "${!plugins[@]}"; do
    if asdf plugin list | grep -q "^${plugin}$"; then
      info "Plugin $plugin déjà installé"
    else
      asdf plugin add "$plugin" "${plugins[$plugin]}" || warn "Échec plugin $plugin"
    fi
  done
  success "Plugins ASDF configurés"
}

install_asdf_tools() {
  step "Installation des outils depuis .tool-versions"
  [[ -f .tool-versions ]] || fail ".tool-versions manquant"
  asdf install
  asdf reshim
  success "Outils ASDF installés"
}

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------
main() {
  parse_args "$@"
  prechecks
  install_system_packages
  install_asdf
  configure_shell
  install_asdf_plugins

  if [[ "$MINIMAL_MODE" = false ]]; then
    install_asdf_tools
  fi

  success "Setup final terminé ✅"
  echo "Relancez votre terminal ou 'source ~/.bashrc' pour prendre en compte ASDF"
}

# -----------------------------------------------------------------------------
# EXECUTION
# -----------------------------------------------------------------------------
trap 'fail "Erreur à la ligne $LINENO"' ERR
main "$@"
>>>>>>> 0336aee (modification  de setup.sh)
