#!/bin/bash

################################################################################
# Script principal d'installation - setup.sh
# Orchestrateur de tous les scripts d'installation
# Optimisé pour Ubuntu 24.04 LTS (Noble Numbat)
#
# Usage: ./setup.sh [options]
#
# Options:
#   --all         Installation complète (par défaut)
#   --minimal     Installation minimale (JDK + Kotlin + Gradle)
#   --tools-only  Outils uniquement
#   --skip-docker Sauter l'installation Docker
#   --help        Afficher cette aide
################################################################################

set -e  # Arrêt en cas d'erreur

# Détection du répertoire du script
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPTS_DIR="${SCRIPT_DIR}/scripts"
readonly LOG_DIR="${SCRIPT_DIR}/logs"
readonly LOG_FILE="${LOG_DIR}/setup-$(date +%Y%m%d-%H%M%S).log"

# Couleurs
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly NC='\033[0m'

# Variables de configuration
INSTALL_MODE="all"
SKIP_DOCKER=false
INTERACTIVE=true

# Version Ubuntu requise
readonly UBUNTU_VERSION="24.04"

################################################################################
# Fonctions d'affichage
################################################################################

print_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║        🚀 INSTALLATION ENVIRONNEMENT KOTLIN & KOBWEB 🚀         ║
║                                                                  ║
║              Environnement de Développement Unifié               ║
║                    Ubuntu 24.04 LTS (Noble)                      ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}\n"
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

print_step() {
    echo -e "\n${BLUE}▶ $1${NC}" | tee -a "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}" | tee -a "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}✗ $1${NC}" | tee -a "$LOG_FILE"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

print_section() {
    echo -e "\n${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}   $1${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}\n"
}

################################################################################
# Fonctions utilitaires
################################################################################

show_help() {
    cat << EOF
Usage: ./setup.sh [OPTIONS]

Installation automatique de l'environnement Kotlin & Kobweb
Optimisé pour Ubuntu 24.04 LTS (Noble Numbat)

Options:
  --all              Installation complète (défaut)
  --minimal          Installation minimale (JDK, Kotlin, Gradle uniquement)
  --tools-only       Outils de développement uniquement
  --skip-docker      Ne pas installer Docker
  --non-interactive  Mode non-interactif (utilise les valeurs par défaut)
  --help             Afficher cette aide

Exemples:
  ./setup.sh                    # Installation complète
  ./setup.sh --minimal          # Installation minimale
  ./setup.sh --skip-docker      # Installation sans Docker
  ./setup.sh --tools-only       # Outils uniquement

Composants installés selon le mode:
  
  MINIMAL:
    • Prérequis système (build-essential, curl, git, etc.)
    • JDK 21 (LTS avec support jusqu'en 2029)
    • Kotlin 2.0 (nouveau compilateur K2)
    • Gradle 8.8
  
  ALL (défaut):
    • Tout le mode MINIMAL
    • Node.js 22 (LTS)
    • Kobweb (dernière version)
    • Docker 26+ (meilleur support 24.04)
    • Outils de développement
    • Configuration IDE
  
  TOOLS-ONLY:
    • Git avancé
    • Outils CLI
    • Utilitaires développeur

Nouveautés Ubuntu 24.04:
  ✓ Kernel 6.8 - Meilleur support matériel
  ✓ Python 3.12 - +20% de performance
  ✓ GCC 13 - Support C++23 complet
  ✓ PipeWire - Audio moderne
  ✓ Meilleur support ARM/RISC-V

EOF
}

check_prerequisites() {
    print_section "VÉRIFICATIONS PRÉALABLES"
    
    # Root check
    if [[ "$EUID" -eq 0 ]]; then
        print_error "Ne pas exécuter ce script en tant que root"
        print_info "Utilisez: ./setup.sh (sans sudo)"
        exit 1
    fi
    
    # Ubuntu version - CRITIQUE pour 24.04
    print_step "Vérification de la version Ubuntu"
    if ! grep -q "$UBUNTU_VERSION" /etc/os-release 2>/dev/null; then
        local detected_version=$(lsb_release -rs 2>/dev/null || echo "Inconnue")
        print_error "Ce script est conçu pour Ubuntu $UBUNTU_VERSION LTS"
        print_warning "Version détectée: Ubuntu $detected_version"
        print_info ""
        print_info "Ubuntu 24.04 LTS apporte des améliorations importantes:"
        print_info "  • JDK 21 natif (vs JDK 17 dans 22.04)"
        print_info "  • Python 3.12 (+20% performance)"
        print_info "  • Kernel 6.8 (meilleur support matériel)"
        print_info "  • GCC 13 (C++23 complet)"
        print_info ""
        
        if [ "$INTERACTIVE" = true ]; then
            read -p "Continuer quand même sur Ubuntu $detected_version ? (y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_info "Installation annulée"
                print_info "Veuillez installer Ubuntu 24.04 LTS: https://ubuntu.com/download"
                exit 0
            fi
            print_warning "Certaines fonctionnalités peuvent ne pas fonctionner correctement"
        else
            print_error "Version Ubuntu incorrecte en mode non-interactif"
            exit 1
        fi
    else
        print_success "Ubuntu $UBUNTU_VERSION LTS détecté ✓"
    fi
    
    # Vérifier que c'est bien LTS
    if ! grep -q "LTS" /etc/os-release 2>/dev/null; then
        print_warning "Cette version d'Ubuntu ne semble pas être une LTS"
        print_info "Recommandé: Utiliser Ubuntu 24.04 LTS pour un support à long terme"
    fi
    
    # Internet
    print_step "Vérification connexion Internet"
    if ! ping -c 1 -W 2 google.com &> /dev/null; then
        print_error "Pas de connexion Internet"
        print_info "Une connexion Internet est requise pour télécharger les paquets"
        exit 1
    fi
    print_success "Connexion Internet OK"
    
    # Espace disque (plus d'espace requis pour 24.04)
    print_step "Vérification espace disque"
    local available=$(df / | awk 'NR==2 {print $4}')
    local required=$((8 * 1024 * 1024))  # 8 GB pour 24.04 (vs 5 GB pour 22.04)
    
    if (( available < required )); then
        print_error "Espace disque insuffisant"
        print_info "Requis: 8 GB | Disponible: $((available / 1024 / 1024)) GB"
        print_info "Ubuntu 24.04 nécessite plus d'espace que 22.04"
        exit 1
    fi
    print_success "Espace disque: $((available / 1024 / 1024)) GB disponibles"
    
    # Vérifier les capacités du système pour 24.04
    print_step "Vérification des capacités système"
    
    # RAM
    local total_ram=$(free -g | awk '/^Mem:/{print $2}')
    if (( total_ram < 4 )); then
        print_warning "RAM faible: ${total_ram}GB détectés (4GB+ recommandé)"
        print_info "Ubuntu 24.04 peut être lent avec moins de 4GB de RAM"
    else
        print_success "RAM: ${total_ram}GB (suffisant)"
    fi
    
    # CPU
    local cpu_cores=$(nproc)
    if (( cpu_cores < 2 )); then
        print_warning "CPU: ${cpu_cores} cœur détecté (2+ recommandé)"
    else
        print_success "CPU: ${cpu_cores} cœurs (suffisant)"
    fi
    
    # Scripts présents
    print_step "Vérification des scripts"
    local missing_scripts=()
    
    local required_scripts=(
        "prerequisites.sh"
        "install-jdk.sh"
        "install-kotlin.sh"
        "install-gradle.sh"
        "verify-installation.sh"
    )
    
    for script in "${required_scripts[@]}"; do
        if [ ! -f "${SCRIPTS_DIR}/${script}" ]; then
            missing_scripts+=("$script")
        fi
    done
    
    if [ ${#missing_scripts[@]} -gt 0 ]; then
        print_error "Scripts manquants:"
        for script in "${missing_scripts[@]}"; do
            echo "  - $script"
        done
        print_info "Veuillez vous assurer que tous les scripts sont présents dans ${SCRIPTS_DIR}/"
        exit 1
    fi
    print_success "Tous les scripts requis sont présents"
}

create_log_dir() {
    mkdir -p "$LOG_DIR"
    log "═══════════════════════════════════════════════════════"
    log "Installation pour Ubuntu 24.04 LTS - Mode: $INSTALL_MODE"
    log "Date: $(date '+%Y-%m-%d %H:%M:%S')"
    log "Utilisateur: $USER"
    log "Hostname: $(hostname)"
    log "═══════════════════════════════════════════════════════"
}

show_installation_plan() {
    print_section "PLAN D'INSTALLATION"
    
    echo -e "${CYAN}Mode sélectionné: ${YELLOW}${INSTALL_MODE^^}${NC}"
    echo -e "${CYAN}Système cible: ${GREEN}Ubuntu 24.04 LTS${NC}\n"
    
    case "$INSTALL_MODE" in
        minimal)
            echo "Composants à installer:"
            echo "  1. ✓ Prérequis système (GCC 13, Python 3.12, etc.)"
            echo "  2. ✓ JDK 21 (LTS, support jusqu'en 2029)"
            echo "  3. ✓ Kotlin 2.0 (nouveau compilateur K2)"
            echo "  4. ✓ Gradle 8.8"
            ;;
        tools-only)
            echo "Composants à installer:"
            echo "  1. ✓ Outils de développement"
            echo "  2. ✓ Utilitaires CLI modernes"
            echo "  3. ✓ Git avec configurations avancées"
            ;;
        all)
            echo "Composants à installer:"
            echo "  1. ✓ Prérequis système (build-essential, curl, git, etc.)"
            echo "  2. ✓ JDK 21 (LTS, virtual threads, pattern matching)"
            echo "  3. ✓ Kotlin 2.0 (+25% vitesse compilation)"
            echo "  4. ✓ Gradle 8.8 (config cache amélioré)"
            echo "  5. ✓ Node.js 22 (ES2024, V8 optimisé)"
            echo "  6. ✓ Kobweb (framework web Kotlin)"
            if [ "$SKIP_DOCKER" = false ]; then
                echo "  7. ✓ Docker 26+ (meilleur support 24.04)"
            else
                echo "  7. ✗ Docker (ignoré)"
            fi
            echo "  8. ✓ Outils de développement"
            echo "  9. ✓ Configuration IDE (IntelliJ IDEA)"
            ;;
    esac
    
    echo -e "\n${CYAN}Durée estimée: ${YELLOW}15-25 minutes${NC}"
    echo -e "${CYAN}Espace requis: ${YELLOW}~3-5 GB${NC}"
    
    
    if [ "$INTERACTIVE" = true ]; then
        echo ""
        read -p "Continuer avec ce plan ? (Y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            print_info "Installation annulée"
            exit 0
        fi
    fi
}

run_script() {
    local script_name="$1"
    local script_path="${SCRIPTS_DIR}/${script_name}"
    local description="$2"
    
    if [ ! -f "$script_path" ]; then
        print_warning "Script ${script_name} non trouvé, ignoré"
        log "SKIPPED: ${script_name} - File not found"
        return 0
    fi
    
    print_step "$description"
    log "RUNNING: ${script_name}"
    
    # Rendre exécutable
    chmod +x "$script_path"
    
    # Exécuter et capturer le code de sortie
    if bash "$script_path" 2>&1 | tee -a "$LOG_FILE"; then
        print_success "✓ ${description} terminé"
        log "SUCCESS: ${script_name}"
        return 0
    else
        local exit_code=$?
        print_error "✗ ${description} a échoué (code: $exit_code)"
        log "FAILED: ${script_name} - Exit code: $exit_code"
        
        if [ "$INTERACTIVE" = true ]; then
            read -p "Continuer malgré l'erreur ? (y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log "Installation aborted by user after error in ${script_name}"
                exit $exit_code
            fi
            log "Continuing after error in ${script_name} (user choice)"
        else
            log "Installation aborted (non-interactive mode)"
            exit $exit_code
        fi
    fi
}

install_minimal() {
    print_section "INSTALLATION MODE MINIMAL"
    
    run_script "prerequisites.sh" "Installation des prérequis système Ubuntu 24.04"
    run_script "install-jdk.sh" "Installation du JDK 21"
    run_script "install-kotlin.sh" "Installation de Kotlin 2.0"
    run_script "install-gradle.sh" "Installation de Gradle 8.8"
}

install_full() {
    print_section "INSTALLATION COMPLÈTE"
    
    # Core
    run_script "prerequisites.sh" "Installation des prérequis système Ubuntu 24.04"
    run_script "install-jdk.sh" "Installation du JDK 21"
    run_script "install-kotlin.sh" "Installation de Kotlin 2.0"
    run_script "install-gradle.sh" "Installation de Gradle 8.8"
    
    # Web
    run_script "install-nodejs.sh" "Installation de Node.js 22"
    run_script "install-kobweb.sh" "Installation de Kobweb"
    
    # Docker
    if [ "$SKIP_DOCKER" = false ]; then
        run_script "install-docker.sh" "Installation de Docker 26+"
    else
        print_info "Docker ignoré (--skip-docker)"
        log "SKIPPED: Docker installation (user flag)"
    fi
    
    # Tools
    run_script "install-tools.sh" "Installation des outils de développement"
    run_script "install-ide.sh" "Configuration IDE"
}

install_tools_only() {
    print_section "INSTALLATION OUTILS UNIQUEMENT"
    
    run_script "install-tools.sh" "Installation des outils de développement"
}

post_installation() {
    print_section "POST-INSTALLATION"
    
    run_script "post-install.sh" "Configuration post-installation"
}

verify_installation() {
    print_section "VÉRIFICATION DE L'INSTALLATION"
    
    run_script "verify-installation.sh" "Vérification des composants"
}

show_summary() {
    print_section "RÉSUMÉ DE L'INSTALLATION"
    
    echo -e "${GREEN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║              🎉 Installation terminée ! 🎉                  ║
║                                                              ║
║              Ubuntu 24.04 LTS - Prêt pour dev               ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}\n"
    
    print_info "Pour appliquer les changements:"
    echo -e "  ${YELLOW}source ~/.bashrc${NC}"
    echo -e "  ${CYAN}ou redémarrez votre terminal${NC}\n"
    
    print_info "Logs disponibles:"
    echo -e "  ${CYAN}${LOG_FILE}${NC}\n"
    
    print_info "Avantages Ubuntu 24.04 installés:"
    echo "  ✓ JDK 21 avec virtual threads et pattern matching"
    echo "  ✓ Kotlin 2.0 avec compilateur K2 (+25% vitesse)"
    echo "  ✓ Python 3.12 (+20% performance)"
    echo "  ✓ GCC 13 avec support C++23"
    echo "  ✓ Kernel 6.8 avec meilleur support matériel"
    echo ""
    
    print_info "Prochaines étapes:"
    echo "  1. Vérifier: ./scripts/verify-installation.sh"
    echo "  2. Premier projet: kobweb create my-app"
    echo "  3. Tester Kotlin 2.0: kotlinc -version"
    echo "  4. Documentation: ../docs/"
    echo "  5. Aide équipe: #dev-help sur Slack"
    
    echo -e "\n${GREEN}Bon développement sur Ubuntu 24.04 LTS ! 🚀${NC}\n"
    log "Installation completed successfully"
}

handle_error() {
    print_error "Une erreur est survenue pendant l'installation"
    print_info "Consultez les logs: $LOG_FILE"
    log "Installation failed with error"
    exit 1
}

################################################################################
# Parsing des arguments
################################################################################

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --all)
                INSTALL_MODE="all"
                shift
                ;;
            --minimal)
                INSTALL_MODE="minimal"
                shift
                ;;
            --tools-only)
                INSTALL_MODE="tools-only"
                shift
                ;;
            --skip-docker)
                SKIP_DOCKER=true
                shift
                ;;
            --non-interactive)
                INTERACTIVE=false
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                print_error "Option inconnue: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

################################################################################
# Fonction principale
################################################################################

main() {
    # Trap les erreurs
    trap handle_error ERR
    
    # Parse arguments
    parse_arguments "$@"
    
    # Bannière
    print_banner
    
    # Création du dossier de logs
    create_log_dir
    
    # Vérifications
    check_prerequisites
    
    # Plan d'installation
    show_installation_plan
    
    # Installation selon le mode
    case "$INSTALL_MODE" in
        minimal)
            install_minimal
            ;;
        tools-only)
            install_tools_only
            ;;
        all)
            install_full
            ;;
    esac
    
    # Post-installation
    post_installation
    
    # Vérification
    verify_installation
    
    # Résumé
    show_summary
}

# Exécution
main "$@"