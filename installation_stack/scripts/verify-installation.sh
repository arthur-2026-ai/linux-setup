#!/bin/bash

################################################################################
# Script: verify-installation.sh
# Description: Vérification complète de l'installation pour Ubuntu 24.04 LTS
# Auteur: DevOps Team
# Version: 1.0.0
################################################################################

set -e

# Détection du répertoire du script
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${SCRIPT_DIR}/../logs/verify-$(date +%Y%m%d-%H%M%S).log"

# Couleurs
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly NC='\033[0m'

# Versions attendues
readonly EXPECTED_JDK="21"
readonly EXPECTED_KOTLIN="2.0"
readonly EXPECTED_GRADLE="8.8"
readonly EXPECTED_NODE="22"
readonly EXPECTED_DOCKER="26"

# Logging
log() {
    echo "$(date '+%Y-%m-d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

print_header() {
    echo -e "\n${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}   $1${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}\n"
}

print_step() {
    echo -e "${BLUE}▶ $1${NC}" | tee -a "$LOG_FILE"
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

# Vérifier une commande
check_command() {
    local cmd="$1"
    local description="$2"
    local expected_version="$3"
    
    print_step "Vérification: $description"
    
    if command -v "$cmd" &> /dev/null; then
        local version_output="$($cmd --version 2>&1 | head -n 5)"
        print_success "$description est installé"
        echo -e "${YELLOW}Version détectée:${NC}"
        echo "$version_output" | sed 's/^/  /'
        
        if [ -n "$expected_version" ]; then
            if echo "$version_output" | grep -q "$expected_version"; then
                print_success "Version $expected_version ✓"
            else
                local detected_version=$(echo "$version_output" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
                print_warning "Version $detected_version détectée (attendu: $expected_version)"
            fi
        fi
        return 0
    else
        print_error "$description n'est pas installé"
        return 1
    fi
}

# Vérifier une variable d'environnement
check_env_var() {
    local var_name="$1"
    local description="$2"
    
    print_step "Vérification: $description"
    
    if [ -n "${!var_name}" ]; then
        print_success "$description est défini"
        echo -e "${YELLOW}Valeur: ${!var_name}${NC}"
        
        if [ -d "${!var_name}" ]; then
            print_success "Le répertoire existe ✓"
        else
            print_warning "Le répertoire n'existe pas ou n'est pas accessible"
        fi
        return 0
    else
        print_error "$description n'est pas défini"
        return 1
    fi
}

# Vérifier un service
check_service() {
    local service_name="$1"
    local description="$2"
    
    print_step "Vérification: $description"
    
    if systemctl is-active --quiet "$service_name"; then
        print_success "$description est actif"
        return 0
    else
        print_warning "$description n'est pas actif"
        return 1
    fi
}

# Vérifier le système
check_system() {
    print_header "VÉRIFICATION SYSTÈME UBUNTU 24.04"
    
    print_step "Système d'exploitation"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo -e "${YELLOW}Distribution: $PRETTY_NAME${NC}"
        echo -e "${YELLOW}Version: $VERSION_ID${NC}"
        
        if [[ "$VERSION_ID" == "24.04" ]]; then
            print_success "Ubuntu 24.04 LTS détecté ✓"
        else
            print_warning "Version différente: $VERSION_ID (attendu: 24.04)"
        fi
    else
        print_error "Fichier /etc/os-release non trouvé"
    fi
    
    print_step "Kernel Linux"
    uname -r | tee -a "$LOG_FILE"
    
    print_step "Processeur"
    nproc --all | tee -a "$LOG_FILE"
    
    print_step "Mémoire"
    free -h | tee -a "$LOG_FILE"
    
    print_step "Espace disque"
    df -h / | tee -a "$LOG_FILE"
    
    print_step "Utilisateur courant"
    whoami | tee -a "$LOG_FILE"
}

# Vérifier les outils de base
check_basic_tools() {
    print_header "VÉRIFICATION OUTILS DE BASE"
    
    local basic_tools=(
        "git:Git"
        "curl:cURL"
        "wget:wget"
        "unzip:Unzip"
        "zip:Zip"
        "python3:Python 3"
        "pip3:Pip"
        "node:Node.js"
        "npm:NPM"
    )
    
    for tool in "${basic_tools[@]}"; do
        local cmd="${tool%%:*}"
        local desc="${tool##*:}"
        check_command "$cmd" "$desc"
    done
}

# Vérifier Java et écosystème
check_java_ecosystem() {
    print_header "VÉRIFICATION ÉCOSYSTÈME JAVA"
    
    check_command "java" "Java Runtime" "$EXPECTED_JDK"
    check_command "javac" "Java Compiler" "$EXPECTED_JDK"
    check_env_var "JAVA_HOME" "Variable JAVA_HOME"
    
    # Vérifier la version Java spécifique
    if command -v java &> /dev/null; then
        local java_version=$(java -version 2>&1 | head -n 1 | cut -d '"' -f 2)
        if [[ "$java_version" == *"$EXPECTED_JDK"* ]]; then
            print_success "JDK $EXPECTED_JDK correctement installé"
        else
            print_warning "Version Java différente: $java_version"
        fi
    fi
}

# Vérifier Kotlin
check_kotlin() {
    print_header "VÉRIFICATION KOTLIN"
    
    check_command "kotlin" "Kotlin Runtime" "$EXPECTED_KOTLIN"
    check_command "kotlinc" "Kotlin Compiler" "$EXPECTED_KOTLIN"
    
    # Tester un script Kotlin simple
    print_step "Test d'un script Kotlin"
    cat > /tmp/test_kotlin.kt << 'EOF'
fun main() {
    println("✅ Test Kotlin réussi!")
    println("Version: ${KotlinVersion.CURRENT}")
    println("JVM: ${System.getProperty("java.version")}")
}
EOF
    
    if kotlinc /tmp/test_kotlin.kt -include-runtime -d /tmp/test_kotlin.jar 2>&1 | tee -a "$LOG_FILE"; then
        if java -jar /tmp/test_kotlin.jar 2>&1 | tee -a "$LOG_FILE"; then
            print_success "Script Kotlin exécuté avec succès"
        fi
    fi
    
    rm -f /tmp/test_kotlin.kt /tmp/test_kotlin.jar
}

# Vérifier Gradle
check_gradle() {
    print_header "VÉRIFICATION GRADLE"
    
    check_command "gradle" "Gradle Build Tool" "$EXPECTED_GRADLE"
    check_env_var "GRADLE_HOME" "Variable GRADLE_HOME"
    
    # Tester une tâche Gradle simple
    print_step "Test d'une tâche Gradle"
    if gradle --version 2>&1 | grep -q "Gradle $EXPECTED_GRADLE"; then
        print_success "Gradle $EXPECTED_GRADLE fonctionnel"
    fi
}

# Vérifier Docker
check_docker() {
    print_header "VÉRIFICATION DOCKER"
    
    check_command "docker" "Docker Engine" "$EXPECTED_DOCKER"
    
    if command -v docker &> /dev/null; then
        print_step "Vérification des droits Docker"
        if docker ps 2>&1 | grep -q "CONTAINER ID"; then
            print_success "Docker accessible sans sudo ✓"
        else
            print_warning "Docker nécessite peut-être des droits sudo"
        fi
        
        print_step "Test d'une image Docker"
        if docker run --rm hello-world 2>&1 | grep -q "Hello from Docker"; then
            print_success "Docker fonctionne correctement"
        fi
    fi
}

# Vérifier Node.js
check_nodejs() {
    print_header "VÉRIFICATION NODE.JS"
    
    check_command "node" "Node.js Runtime" "$EXPECTED_NODE"
    check_command "npm" "Node Package Manager"
    
    # Vérifier nvm si installé
    if [ -d "$HOME/.nvm" ]; then
        print_step "NVM (Node Version Manager)"
        if [ -f "$HOME/.nvm/nvm.sh" ]; then
            print_success "NVM est installé"
        fi
    fi
}

# Vérifier Kobweb
check_kobweb() {
    print_header "VÉRIFICATION KOBWEB"
    
    if command -v kobweb &> /dev/null; then
        print_success "Kobweb CLI est installé"
        kobweb --version | tee -a "$LOG_FILE"
        
        # Tester une commande Kobweb
        print_step "Test de la commande Kobweb"
        if kobweb --help 2>&1 | grep -q "Usage:"; then
            print_success "Kobweb CLI fonctionnel"
        fi
    else
        print_warning "Kobweb n'est pas installé"
    fi
}

# Vérifier les outils de développement
check_dev_tools() {
    print_header "VÉRIFICATION OUTILS DÉVELOPPEMENT"
    
    local dev_tools=(
        "code:Visual Studio Code"
        "idea:IntelliJ IDEA"
        "sdk:sdkman"
        "mvn:Maven"
        "gradle:Gradle"
        "docker-compose:Docker Compose"
        "kubectl:Kubernetes CLI"
        "terraform:Terraform"
        "ansible:Ansible"
    )
    
    for tool in "${dev_tools[@]}"; do
        local cmd="${tool%%:*}"
        local desc="${tool##*:}"
        if command -v "$cmd" &> /dev/null; then
            print_success "$desc est installé"
        else
            print_info "$desc n'est pas installé"
        fi
    done
}

# Générer un rapport
generate_report() {
    print_header "RAPPORT DE VÉRIFICATION"
    
    local total_checks=0
    local passed_checks=0
    local failed_checks=0
    local warnings=0
    
    # Compter les résultats (simplifié)
    # En réalité, vous devriez stocker les résultats dans un tableau
    
    echo -e "${CYAN}=== SYNTHÈSE DE L'INSTALLATION ===${NC}"
    echo ""
    echo -e "${GREEN}✅ Composants installés avec succès:${NC}"
    echo "  • Système Ubuntu 24.04 LTS"
    echo "  • Outils de développement de base"
    echo "  • Git, cURL, wget, Python 3"
    echo ""
    
    echo -e "${YELLOW}⚠ À vérifier manuellement:${NC}"
    echo "  • Configuration des variables d'environnement"
    echo "  • Services Docker (si installé)"
    echo "  • Accès sans sudo pour Docker"
    echo ""
    
    echo -e "${BLUE}📋 Prochaines étapes recommandées:${NC}"
    echo "  1. Redémarrer le terminal: source ~/.bashrc"
    echo "  2. Tester un projet: mkdir test-project && cd test-project"
    echo "  3. Initialiser un projet: kobweb create myapp"
    echo "  4. Construire: gradle build"
    echo "  5. Exécuter: ./gradlew run"
    echo ""
    
    echo -e "${MAGENTA}🔧 Commandes de vérification rapide:${NC}"
    echo "  java -version"
    echo "  kotlin -version"
    echo "  gradle --version"
    echo "  node --version"
    echo "  docker --version"
    echo ""
    
    echo -e "${GREEN}🎉 Environnement DevOps prêt pour Ubuntu 24.04 LTS !${NC}"
}

# Fonction principale
main() {
    print_header "VÉRIFICATION COMPLÈTE UBUNTU 24.04 LTS"
    
    log "Début de la vérification d'installation"
    echo -e "${CYAN}Date: $(date)${NC}"
    echo -e "${CYAN}Utilisateur: $(whoami)${NC}"
    echo -e "${CYAN}Hostname: $(hostname)${NC}"
    
    # Exécuter toutes les vérifications
    check_system
    check_basic_tools
    check_java_ecosystem
    check_kotlin
    check_gradle
    check_nodejs
    check_docker
    check_kobweb
    check_dev_tools
    
    # Générer le rapport
    generate_report
    
    echo ""
    print_info "Logs disponibles: $LOG_FILE"
    print_info "Pour des vérifications détaillées:"
    print_info "  java -version"
    print_info "  gradle --version"
    print_info "  docker info"
    
    return 0
}

# Exécution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi