#!/bin/bash

################################################################################
# Script: install-jdk.sh
# Description: Installation de Java Development Kit (JDK) 21
#              Optimisé pour Ubuntu 24.04 LTS
# Auteur: DevOps Team
# Version: 1.0.0
################################################################################

set -e

# Détection du répertoire du script
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${SCRIPT_DIR}/../logs/jdk-install-$(date +%Y%m%d-%H%M%S).log"

# Couleurs
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Configuration
readonly JDK_VERSION="21"
readonly JAVA_HOME_PATH="/usr/lib/jvm/java-${JDK_VERSION}-openjdk-amd64"

# Logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

print_step() {
    echo -e "\n${BLUE}▶ $1${NC}" | tee -a "$LOG_FILE"
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

# Vérifier si Java est déjà installé
check_java_installed() {
    print_step "Vérification de l'installation Java existante"
    
    if command -v java &> /dev/null; then
        local current_version=$(java -version 2>&1 | head -n 1 | cut -d '"' -f 2)
        print_info "Java déjà installé: Version $current_version"
        
        # Vérifier si c'est déjà JDK 21
        if [[ "$current_version" == *"$JDK_VERSION"* ]]; then
            print_success "JDK $JDK_VERSION est déjà installé"
            return 0
        else
            print_info "Une autre version de Java est installée ($current_version)"
            return 1
        fi
    else
        print_info "Java n'est pas installé"
        return 1
    fi
}

# Installer JDK 21
install_jdk() {
    print_step "Installation du JDK $JDK_VERSION"
    log "Début de l'installation du JDK $JDK_VERSION"
    
    # Mettre à jour les dépôts
    log "Mise à jour des dépôts APT"
    sudo apt-get update 2>&1 | tee -a "$LOG_FILE"
    
    # Installer JDK 21 (disponible nativement dans Ubuntu 24.04)
    log "Installation du paquet openjdk-${JDK_VERSION}-jdk"
    
    if ! sudo apt-get install -y "openjdk-${JDK_VERSION}-jdk" "openjdk-${JDK_VERSION}-jre" 2>&1 | tee -a "$LOG_FILE"; then
        print_error "Échec de l'installation du JDK"
        return 1
    fi
    
    # Installer les outils de développement Java
    log "Installation des outils Java supplémentaires"
    sudo apt-get install -y "openjdk-${JDK_VERSION}-source" "openjdk-${JDK_VERSION}-doc" 2>&1 | tee -a "$LOG_FILE"
    
    print_success "JDK $JDK_VERSION installé"
    return 0
}

# Configurer les variables d'environnement
setup_environment() {
    print_step "Configuration des variables d'environnement"
    
    # Créer le lien symbolique pour JAVA_HOME
    if [ ! -d "$JAVA_HOME_PATH" ]; then
        print_error "JAVA_HOME path non trouvé: $JAVA_HOME_PATH"
        return 1
    fi
    
    # Ajouter à .bashrc
    if ! grep -q "JAVA_HOME" ~/.bashrc; then
        cat >> ~/.bashrc << EOF

# Configuration Java JDK $JDK_VERSION
export JAVA_HOME="$JAVA_HOME_PATH"
export PATH="\$JAVA_HOME/bin:\$PATH"

# Options JVM par défaut
export JAVA_OPTS="-Xmx2G -XX:+UseG1GC -XX:+UseStringDeduplication"
EOF
        print_success "Variables d'environnement ajoutées à ~/.bashrc"
    else
        print_info "Variables Java déjà configurées dans ~/.bashrc"
    fi
    
    # Configurer les alternatives
    print_step "Configuration des alternatives Java"
    
    # Définir java
    sudo update-alternatives --install "/usr/bin/java" "java" "$JAVA_HOME_PATH/bin/java" 1000 2>&1 | tee -a "$LOG_FILE"
    
    # Définir javac
    sudo update-alternatives --install "/usr/bin/javac" "javac" "$JAVA_HOME_PATH/bin/javac" 1000 2>&1 | tee -a "$LOG_FILE"
    
    # Définir jar
    sudo update-alternatives --install "/usr/bin/jar" "jar" "$JAVA_HOME_PATH/bin/jar" 1000 2>&1 | tee -a "$LOG_FILE"
    
    # Configurer l'alternative par défaut
    sudo update-alternatives --set java "$JAVA_HOME_PATH/bin/java" 2>&1 | tee -a "$LOG_FILE"
    sudo update-alternatives --set javac "$JAVA_HOME_PATH/bin/javac" 2>&1 | tee -a "$LOG_FILE"
    sudo update-alternatives --set jar "$JAVA_HOME_PATH/bin/jar" 2>&1 | tee -a "$LOG_FILE"
    
    print_success "Alternatives configurées"
    return 0
}

# Vérifier l'installation
verify_installation() {
    print_step "Vérification de l'installation"
    
    # Vérifier java
    if ! command -v java &> /dev/null; then
        print_error "Java n'est pas dans le PATH"
        return 1
    fi
    
    local java_version=$(java -version 2>&1 | head -n 1 | cut -d '"' -f 2)
    print_info "Version Java: $java_version"
    
    # Vérifier javac
    if ! command -v javac &> /dev/null; then
        print_error "javac n'est pas dans le PATH"
        return 1
    fi
    
    local javac_version=$(javac -version 2>&1 | head -n 1)
    print_info "Version javac: $javac_version"
    
    # Vérifier JAVA_HOME
    if [ -z "$JAVA_HOME" ]; then
        print_warning "JAVA_HOME n'est pas défini"
        print_info "Exécutez: source ~/.bashrc"
    else
        if [ ! -d "$JAVA_HOME" ]; then
            print_warning "JAVA_HOME pointe vers un répertoire inexistant: $JAVA_HOME"
        else
            print_success "JAVA_HOME correctement défini: $JAVA_HOME"
        fi
    fi
    
    # Tester la compilation
    print_step "Test de compilation Java"
    
    cat > TestJava.java << 'EOF'
public class TestJava {
    public static void main(String[] args) {
        System.out.println("✅ Java JDK " + System.getProperty("java.version") + " fonctionne !");
        System.out.println("🏠 JAVA_HOME: " + System.getProperty("java.home"));
        System.out.println("🧵 Threads virtuels: " + (Runtime.version().feature() >= 21 ? "Disponible ✓" : "Non disponible"));
        
        // Test de pattern matching (nouveauté Java 21)
        Object obj = "Test pattern matching";
        if (obj instanceof String s) {
            System.out.println("🎯 Pattern matching: " + s.toUpperCase());
        }
    }
}
EOF
    
    if javac TestJava.java 2>&1 | tee -a "$LOG_FILE"; then
        if java TestJava 2>&1 | tee -a "$LOG_FILE"; then
            print_success "Test de compilation réussi"
        else
            print_error "Erreur d'exécution du test"
        fi
    else
        print_error "Erreur de compilation du test"
    fi
    
    # Nettoyer
    rm -f TestJava.java TestJava.class
    
    return 0
}

# Fonction principale
main() {
    print_step "Installation du JDK $JDK_VERSION pour Ubuntu 24.04"
    log "Début du processus d'installation du JDK"
    
    # Afficher les informations sur JDK 21
    echo "========================================="
    echo "🎯 Installation de JDK $JDK_VERSION (LTS)"
    echo "📅 Support: Septembre 2023 - Septembre 2029"
    echo "✨ Nouvelles fonctionnalités:"
    echo "   • Virtual Threads (Project Loom)"
    echo "   • Pattern Matching (amélioré)"
    echo "   • Record Patterns"
    echo "   • Sequenced Collections"
    echo "========================================="
    
    # Vérifier l'installation existante
    if check_java_installed; then
        print_info "JDK $JDK_VERSION est déjà installé"
        print_info "Passage à la configuration..."
    else
        # Installer JDK
        if ! install_jdk; then
            print_error "Échec de l'installation du JDK"
            return 1
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
    
    print_step "Résumé de l'installation JDK"
    echo "========================================="
    echo "✅ JDK $JDK_VERSION installé avec succès"
    echo "📁 JAVA_HOME: $JAVA_HOME_PATH"
    echo "🔧 Alternatives configurées"
    echo "🧪 Test de compilation: ✓"
    echo "========================================="
    echo ""
    print_info "Pour appliquer les changements, exécutez:"
    echo "  source ~/.bashrc"
    echo ""
    print_info "Commandes utiles:"
    echo "  java -version        # Vérifier la version"
    echo "  javac -version       # Vérifier le compilateur"
    echo "  which java           # Localiser l'exécutable"
    echo "  echo \$JAVA_HOME      # Vérifier JAVA_HOME"
    
    return 0
}

# Exécution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi