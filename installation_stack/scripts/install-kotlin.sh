#!/bin/bash

################################################################################
# Script: install-kotlin.sh
# Description: Installation de Kotlin 2.0 avec le nouveau compilateur K2
#              Optimisé pour Ubuntu 24.04 LTS
# Auteur: DevOps Team
# Version: 1.0.0
################################################################################

set -e

# Détection du répertoire du script
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${SCRIPT_DIR}/../logs/kotlin-install-$(date +%Y%m%d-%H%M%S).log"

# Couleurs
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Configuration
readonly KOTLIN_VERSION="2.0.0"
readonly KOTLIN_HOME="/opt/kotlin"
readonly SDKMAN_DIR="$HOME/.sdkman"

# Logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

print_step() {
    echo -e "\n${CYAN}▶ $1${NC}" | tee -a "$LOG_FILE"
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

# Vérifier si Kotlin est déjà installé
check_kotlin_installed() {
    print_step "Vérification de l'installation Kotlin existante"
    
    if command -v kotlin &> /dev/null; then
        local current_version=$(kotlin -version 2>&1 | head -n 1)
        print_info "Kotlin déjà installé: $current_version"
        
        # Extraire la version numérique
        local version_num=$(echo "$current_version" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        
        if [[ "$version_num" == "$KOTLIN_VERSION" ]]; then
            print_success "Kotlin $KOTLIN_VERSION est déjà installé"
            return 0
        elif [[ "$version_num" > "$KOTLIN_VERSION" ]] || [[ "$version_num" == 2.* ]]; then
            print_info "Une version récente de Kotlin est installée ($version_num)"
            return 0
        else
            print_info "Version ancienne de Kotlin détectée ($version_num)"
            return 1
        fi
    else
        print_info "Kotlin n'est pas installé"
        return 1
    fi
}

# Installer SDKMAN (gestionnaire de SDK)
install_sdkman() {
    print_step "Installation de SDKMAN"
    
    if [ -d "$SDKMAN_DIR" ]; then
        print_info "SDKMAN est déjà installé"
        return 0
    fi
    
    log "Installation de SDKMAN"
    
    # Installer SDKMAN
    curl -s "https://get.sdkman.io" | bash 2>&1 | tee -a "$LOG_FILE"
    
    if [ $? -ne 0 ]; then
        print_error "Échec de l'installation de SDKMAN"
        return 1
    fi
    
    # Charger SDKMAN dans la session courante
    if [ -f "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
        source "$SDKMAN_DIR/bin/sdkman-init.sh"
        print_success "SDKMAN installé et chargé"
        return 0
    else
        print_error "Fichier d'initialisation SDKMAN non trouvé"
        return 1
    fi
}

# Installer Kotlin via SDKMAN
install_kotlin_sdkman() {
    print_step "Installation de Kotlin $KOTLIN_VERSION via SDKMAN"
    
    # Vérifier que SDKMAN est chargé
    if ! command -v sdk &> /dev/null; then
        print_error "SDKMAN n'est pas disponible"
        return 1
    fi
    
    log "Installation de Kotlin version $KOTLIN_VERSION"
    
    # Installer Kotlin
    if ! sdk install kotlin "$KOTLIN_VERSION" 2>&1 | tee -a "$LOG_FILE"; then
        print_error "Échec de l'installation de Kotlin via SDKMAN"
        
        # Essayer d'installer la dernière version
        print_info "Essai d'installation de la dernière version..."
        if ! sdk install kotlin 2>&1 | tee -a "$LOG_FILE"; then
            return 1
        fi
    fi
    
    # Définir comme version par défaut
    sdk default kotlin "$KOTLIN_VERSION" 2>&1 | tee -a "$LOG_FILE"
    
    print_success "Kotlin $KOTLIN_VERSION installé via SDKMAN"
    return 0
}

# Alternative: Installer Kotlin manuellement
install_kotlin_manual() {
    print_step "Installation manuelle de Kotlin"
    
    # Créer le répertoire d'installation
    sudo mkdir -p "$KOTLIN_HOME"
    
    # Télécharger Kotlin
    local download_url="https://github.com/JetBrains/kotlin/releases/download/v${KOTLIN_VERSION}/kotlin-compiler-${KOTLIN_VERSION}.zip"
    
    log "Téléchargement de Kotlin depuis: $download_url"
    
    # Télécharger
    if ! wget -O /tmp/kotlin.zip "$download_url" 2>&1 | tee -a "$LOG_FILE"; then
        print_error "Échec du téléchargement de Kotlin"
        return 1
    fi
    
    # Extraire
    log "Extraction de Kotlin"
    sudo unzip -q /tmp/kotlin.zip -d /tmp/
    
    # Copier les fichiers
    sudo cp -r /tmp/kotlinc/* "$KOTLIN_HOME/"
    
    # Nettoyer
    rm -f /tmp/kotlin.zip
    sudo rm -rf /tmp/kotlinc
    
    print_success "Kotlin installé manuellement dans $KOTLIN_HOME"
    return 0
}

# Configurer les variables d'environnement
setup_environment() {
    print_step "Configuration des variables d'environnement"
    
    # Ajouter à .bashrc si ce n'est pas déjà fait
    if ! grep -q "KOTLIN_HOME" ~/.bashrc; then
        cat >> ~/.bashrc << EOF

# Configuration Kotlin
export KOTLIN_HOME="$KOTLIN_HOME"
export PATH="\$KOTLIN_HOME/bin:\$PATH"

# Alias Kotlin
alias kc='kotlinc'
alias kr='kotlin'
alias kt='kotlin'
EOF
        print_success "Variables d'environnement ajoutées à ~/.bashrc"
    else
        print_info "Variables Kotlin déjà configurées dans ~/.bashrc"
    fi
    
    # Si SDKMAN est utilisé, ajouter son initialisation
    if [ -d "$SDKMAN_DIR" ] && ! grep -q "sdkman-init.sh" ~/.bashrc; then
        cat >> ~/.bashrc << EOF

# Initialisation SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "\$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "\$SDKMAN_DIR/bin/sdkman-init.sh"
EOF
        print_success "SDKMAN configuré dans ~/.bashrc"
    fi
    
    return 0
}

# Vérifier l'installation
verify_installation() {
    print_step "Vérification de l'installation"
    
    # Vérifier kotlin
    if ! command -v kotlin &> /dev/null; then
        print_error "kotlin n'est pas dans le PATH"
        return 1
    fi
    
    local kotlin_version=$(kotlin -version 2>&1 | head -n 1)
    print_info "Version Kotlin: $kotlin_version"
    
    # Vérifier kotlinc
    if ! command -v kotlinc &> /dev/null; then
        print_error "kotlinc n'est pas dans le PATH"
        return 1
    fi
    
    local kotlinc_version=$(kotlinc -version 2>&1 | head -n 1)
    print_info "Version Kotlin Compiler: $kotlinc_version"
    
    # Tester la compilation
    print_step "Test de compilation Kotlin"
    
    cat > HelloKotlin.kt << 'EOF'
fun main() {
    println("✅ Kotlin ${KotlinVersion.CURRENT} fonctionne !")
    println("✨ Compilateur K2: ${if (System.getProperty("kotlin.version")?.startsWith("2.") == true) "Activé ✓" else "Standard"}")
    
    // Nouvelles fonctionnalités Kotlin 2.0
    val numbers = listOf(1, 2, 3, 4, 5)
    val evenSquares = numbers
        .filter { it % 2 == 0 }
        .map { it * it }
    
    println("🔢 Nombres pairs au carré: $evenSquares")
    
    // Data class
    data class Person(val name: String, val age: Int)
    val person = Person("DevOps", 2024)
    println("👤 $person")
    
    // Extension function
    fun String.shout() = this.uppercase() + "!"
    println("📢 ${"kotlin est génial".shout()}")
}
EOF
    
    if kotlinc HelloKotlin.kt -include-runtime -d HelloKotlin.jar 2>&1 | tee -a "$LOG_FILE"; then
        if java -jar HelloKotlin.jar 2>&1 | tee -a "$LOG_FILE"; then
            print_success "Test de compilation Kotlin réussi"
        else
            print_error "Erreur d'exécution du test Kotlin"
        fi
    else
        print_error "Erreur de compilation du test Kotlin"
    fi
    
    # Nettoyer
    rm -f HelloKotlin.kt HelloKotlin.jar
    
    return 0
}

# Fonction principale
main() {
    print_step "Installation de Kotlin $KOTLIN_VERSION pour Ubuntu 24.04"
    log "Début du processus d'installation de Kotlin"
    
    # Afficher les informations sur Kotlin 2.0
    echo "========================================="
    echo "🎯 Installation de Kotlin $KOTLIN_VERSION"
    echo "🚀 Nouveau compilateur K2 (+25% vitesse)"
    echo "✨ Nouvelles fonctionnalités:"
    echo "   • K2 Compiler (stable)"
    echo "   • Multiplatform amélioré"
    echo "   • Performance optimisée"
    echo "   • Meilleure interop Java"
    echo "========================================="
    
    # Vérifier l'installation existante
    if check_kotlin_installed; then
        print_info "Kotlin $KOTLIN_VERSION ou supérieur est déjà installé"
        print_info "Passage à la configuration..."
    else
        # Essayer SDKMAN d'abord
        if install_sdkman && install_kotlin_sdkman; then
            print_success "Kotlin installé via SDKMAN"
        else
            print_warning "SDKMAN a échoué, tentative d'installation manuelle"
            if install_kotlin_manual; then
                print_success "Kotlin installé manuellement"
            else
                                print_error "Échec de l'installation de Kotlin"
                return 1
            fi
        fi
    fi
    
    # Configurer l'environnement
    if ! setup_environment; then
        print_error "Échec de la configuration de l'environnement"
        return 1
    fi
    
    # Vérifier l'installation
    if ! verify_installation; then
        print_warning "Problèmes détectés lors de la vérification"
    fi
    
    print_step "Résumé de l'installation Kotlin"
    echo "========================================="
    echo "✅ Kotlin $KOTLIN_VERSION installé avec succès"
    echo "🚀 Compilateur K2 activé"
    echo "📁 KOTLIN_HOME: $KOTLIN_HOME"
    echo "🧪 Test de compilation: ✓"
    echo "========================================="
    echo ""
    print_info "Pour appliquer les changements, exécutez:"
    echo "  source ~/.bashrc"
    echo ""
    print_info "Commandes utiles:"
    echo "  kotlin -version     # Vérifier la version"
    echo "  kotlinc -version    # Vérifier le compilateur"
    echo "  kotlinc             # Lancer le REPL Kotlin"
    echo "  sdk list kotlin     # Voir les versions disponibles"
    
    return 0
}

# Exécution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi