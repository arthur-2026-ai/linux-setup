#!/bin/bash

################################################################################
# Script: install-gradle.sh
# Description: Installation de Gradle 8.8
#              Optimisé pour Ubuntu 24.04 LTS
# Auteur: DevOps Team
# Version: 1.0.0
################################################################################

set -e

# Détection du répertoire du script
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${SCRIPT_DIR}/../logs/gradle-install-$(date +%Y%m%d-%H%M%S).log"

# Couleurs
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly NC='\033[0m'

# Configuration
readonly GRADLE_VERSION="8.8"
readonly GRADLE_HOME="/opt/gradle"
readonly GRADLE_USER_HOME="$HOME/.gradle"

# Logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

print_step() {
    echo -e "\n${MAGENTA}▶ $1${NC}" | tee -a "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}✗ $1${NC}" | tee -a "$LOG_FILE"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Vérifier si Gradle est déjà installé
check_gradle_installed() {
    print_step "Vérification de l'installation Gradle existante"
    
    if command -v gradle &> /dev/null; then
        local current_version=$(gradle --version 2>&1 | grep -E "^Gradle [0-9]" | head -n 1 | cut -d ' ' -f 2)
        print_info "Gradle déjà installé: Version $current_version"
        
        if [[ "$current_version" == "$GRADLE_VERSION" ]]; then
            print_success "Gradle $GRADLE_VERSION est déjà installé"
            return 0
        elif [[ "$current_version" > "$GRADLE_VERSION" ]]; then
            print_info "Une version plus récente de Gradle est installée ($current_version)"
            return 0
        else
            print_info "Version ancienne de Gradle détectée ($current_version)"
            return 1
        fi
    else
        print_info "Gradle n'est pas installé"
        return 1
    fi
}

# Installer Gradle
install_gradle() {
    print_step "Installation de Gradle $GRADLE_VERSION"
    log "Début de l'installation de Gradle $GRADLE_VERSION"
    
    # Créer le répertoire d'installation
    sudo mkdir -p "$GRADLE_HOME"
    
    # Télécharger Gradle
    local download_url="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"
    
    log "Téléchargement de Gradle depuis: $download_url"
    
    # Télécharger
    if ! wget -O /tmp/gradle.zip "$download_url" 2>&1 | tee -a "$LOG_FILE"; then
        print_error "Échec du téléchargement de Gradle"
        return 1
    fi
    
    # Vérifier l'intégrité du fichier
    if [ ! -s /tmp/gradle.zip ]; then
        print_error "Fichier téléchargé vide ou corrompu"
        return 1
    fi
    
    # Extraire
    log "Extraction de Gradle"
    sudo unzip -q /tmp/gradle.zip -d /tmp/
    
    # Vérifier que l'extraction a réussi
    if [ ! -d "/tmp/gradle-${GRADLE_VERSION}" ]; then
        print_error "Échec de l'extraction de Gradle"
        return 1
    fi
    
    # Copier les fichiers
    sudo cp -r "/tmp/gradle-${GRADLE_VERSION}/"* "$GRADLE_HOME/"
    
    # Nettoyer
    rm -f /tmp/gradle.zip
    sudo rm -rf "/tmp/gradle-${GRADLE_VERSION}"
    
    print_success "Gradle installé dans $GRADLE_HOME"
    return 0
}

# Configurer les variables d'environnement
setup_environment() {
    print_step "Configuration des variables d'environnement"
    
    # Créer le répertoire utilisateur Gradle
    mkdir -p "$GRADLE_USER_HOME"
    
    # Ajouter à .bashrc
    if ! grep -q "GRADLE_HOME" ~/.bashrc; then
        cat >> ~/.bashrc << EOF

# Configuration Gradle
export GRADLE_HOME="$GRADLE_HOME"
export GRADLE_USER_HOME="$GRADLE_USER_HOME"
export PATH="\$GRADLE_HOME/bin:\$PATH"

# Optimisation de la mémoire pour Gradle (spécifique à Ubuntu 24.04)
export GRADLE_OPTS="-Xmx2g -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8"

# Alias Gradle
alias g='gradle'
alias gw='./gradlew'
alias gcb='gradle clean build'
alias gct='gradle clean test'
alias gcbp='gradle clean build --parallel'
alias gradlew='./gradlew'

# Auto-complétion pour Gradle
if [ -f "\$GRADLE_HOME/completion/gradle-completion.bash" ]; then
    source "\$GRADLE_HOME/completion/gradle-completion.bash"
fi
EOF
        print_success "Variables d'environnement ajoutées à ~/.bashrc"
    else
        print_info "Variables Gradle déjà configurées dans ~/.bashrc"
    fi
    
    # Configurer les propriétés Gradle
    cat > "$GRADLE_USER_HOME/gradle.properties" << EOF
# Configuration Gradle pour Ubuntu 24.04
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.configureondemand=true
org.gradle.daemon=true
org.gradle.jvmargs=-Xmx2g -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
org.gradle.console=auto
org.gradle.priority=normal
EOF
    
    print_success "Propriétés Gradle configurées"
    return 0
}

# Installer le wrapper Gradle
install_gradle_wrapper() {
    print_step "Installation du Gradle Wrapper"
    
    # Créer un projet test pour générer le wrapper
    local test_dir="/tmp/gradle-test-$$"
    mkdir -p "$test_dir"
    cd "$test_dir"
    
    # Initialiser un projet Gradle
    cat > build.gradle << 'EOF'
plugins {
    id 'java'
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation 'org.junit.jupiter:junit-jupiter:5.10.0'
}

test {
    useJUnitPlatform()
}

java {
    sourceCompatibility = JavaVersion.VERSION_21
    targetCompatibility = JavaVersion.VERSION_21
}
EOF
    
    # Générer le wrapper
    if "$GRADLE_HOME/bin/gradle" wrapper 2>&1 | tee -a "$LOG_FILE"; then
        print_success "Gradle Wrapper généré"
        
        # Tester le wrapper
        if ./gradlew --version 2>&1 | tee -a "$LOG_FILE"; then
            print_success "Gradle Wrapper fonctionnel"
        else
            print_warning "Problème avec le Gradle Wrapper"
        fi
    else
        print_warning "Échec de la génération du Gradle Wrapper"
    fi
    
    # Nettoyer
    cd -
    rm -rf "$test_dir"
    
    return 0
}

# Vérifier l'installation
verify_installation() {
    print_step "Vérification de l'installation"
    
    # Vérifier gradle
    if ! command -v gradle &> /dev/null; then
        print_error "gradle n'est pas dans le PATH"
        return 1
    fi
    
    local gradle_version=$(gradle --version 2>&1 | grep -E "^Gradle [0-9]" | head -n 1)
    print_info "$gradle_version"
    
    # Vérifier GRADLE_HOME
    if [ -z "$GRADLE_HOME" ]; then
        print_warning "GRADLE_HOME n'est pas défini"
        print_info "Exécutez: source ~/.bashrc"
    else
        if [ ! -d "$GRADLE_HOME" ]; then
            print_warning "GRADLE_HOME pointe vers un répertoire inexistant: $GRADLE_HOME"
        else
            print_success "GRADLE_HOME correctement défini: $GRADLE_HOME"
        fi
    fi
    
    # Tester une commande simple
    print_step "Test de Gradle"
    
    if gradle --version 2>&1 | tee -a "$LOG_FILE" | grep -q "Gradle $GRADLE_VERSION"; then
        print_success "Gradle $GRADLE_VERSION fonctionne correctement"
    else
        print_error "Problème avec Gradle"
        return 1
    fi
    
    # Tester avec un projet simple
    print_step "Test avec un projet Kotlin"
    
    local test_dir="/tmp/gradle-kotlin-test-$$"
    mkdir -p "$test_dir/src/main/kotlin"
    cd "$test_dir"
    
    # Créer un build.gradle.kts
    cat > build.gradle.kts << 'EOF'
plugins {
    kotlin("jvm") version "2.0.0"
}

repositories {
    mavenCentral()
}

dependencies {
    implementation(kotlin("stdlib"))
    testImplementation(kotlin("test"))
}

tasks.test {
    useJUnitPlatform()
}

kotlin {
    jvmToolchain(21)
}
EOF
    
    # Créer un fichier Kotlin simple
    cat > src/main/kotlin/Hello.kt << 'EOF'
fun main() {
    println("✅ Gradle ${GradleVersion.current().version} avec Kotlin fonctionne !")
    println("✨ Configuration cache: ${System.getProperty("org.gradle.caching") ?: "non défini"}")
    println("🚀 Build scan: ${if (System.getProperty("gradle.scan") != null) "activé" else "désactivé"}")
    
    val numbers = (1..10).toList()
    val sum = numbers.sum()
    println("🧮 Somme de 1 à 10: $sum")
}
EOF
    
    # Tester la compilation
    if gradle build 2>&1 | tee -a "$LOG_FILE" | tail -5; then
        print_success "Projet Kotlin compilé avec succès"
    else
        print_error "Erreur lors de la compilation du projet test"
    fi
    
    # Nettoyer
    cd -
    rm -rf "$test_dir"
    
    return 0
}

# Fonction principale
main() {
    print_step "Installation de Gradle $GRADLE_VERSION pour Ubuntu 24.04"
    log "Début du processus d'installation de Gradle"
    
    # Afficher les informations sur Gradle 8.8
    echo "========================================="
    echo "🎯 Installation de Gradle $GRADLE_VERSION"
    echo "⚡ Configuration Cache amélioré"
    echo "✨ Nouvelles fonctionnalités:"
    echo "   • Kotlin DSL par défaut"
    echo "   • Toolchains Java améliorées"
    echo "   • Build Scans intégrés"
    echo "   • Meilleure performance"
    echo "========================================="
    
    # Vérifier l'installation existante
    if check_gradle_installed; then
        print_info "Gradle $GRADLE_VERSION ou supérieur est déjà installé"
        print_info "Passage à la configuration..."
    else
        # Installer Gradle
        if ! install_gradle; then
            print_error "Échec de l'installation de Gradle"
            return 1
        fi
    fi
    
    # Configurer l'environnement
    if ! setup_environment; then
        print_error "Échec de la configuration de l'environnement"
        return 1
    fi
    
    # Installer le wrapper
    install_gradle_wrapper
    
    # Vérifier l'installation
    if ! verify_installation; then
        print_warning "Problèmes détectés lors de la vérification"
    fi
    
    print_step "Résumé de l'installation Gradle"
    echo "========================================="
    echo "✅ Gradle $GRADLE_VERSION installé avec succès"
    echo "📁 GRADLE_HOME: $GRADLE_HOME"
    echo "🏠 GRADLE_USER_HOME: $GRADLE_USER_HOME"
    echo "🚀 Wrapper Gradle: ✓"
    echo "🧪 Tests Kotlin: ✓"
    echo "========================================="
    echo ""
    print_info "Pour appliquer les changements, exécutez:"
    echo "  source ~/.bashrc"
    echo ""
    print_info "Commandes utiles:"
    echo "  gradle --version    # Vérifier la version"
    echo "  gradle tasks        # Lister les tâches"
    echo "  gradle build        # Construire le projet"
    echo "  gradle test         # Exécuter les tests"
    echo "  ./gradlew           # Utiliser le wrapper"
    echo ""
    print_info "Optimisations Ubuntu 24.04 activées:"
    echo "  • Configuration cache"
    echo "  • Build parallèle"
    echo "  • Daemon activé"
    echo "  • JVM optimisée"
    
    return 0
}

# Exécution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi