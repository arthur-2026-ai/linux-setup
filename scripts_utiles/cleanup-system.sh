#!/bin/bash

# 🧹 Cleanup System - Nettoyage intelligent de l'environnement de développement
# Version 1.0 - Optimisé pour Kotlin/Kobweb

set -e  # Arrêter en cas d'erreur critique

# Couleurs pour une meilleure lisibilité
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction de log
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Fonction pour demander confirmation
confirm_action() {
    read -p "$1 (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# 📊 Analyse initiale
echo "========================================"
echo "🧹  CLEANUP SYSTEM - Analyse du système"
echo "========================================"

log_info "Analyse de l'état actuel..."
echo ""

# 1. Nettoyage des processus de développement orphelins
clean_dev_processes() {
    log_info "Recherche des processus de développement orphelins..."
    
    # Liste des processus à vérifier
    DEV_PROCESSES=("gradle" "kotlin" "kobweb" "java.*\.jar" "npm" "node.*serve" "maven")
    
    for process in "${DEV_PROCESSES[@]}"; do
        count=$(pgrep -f "$process" 2>/dev/null | wc -l)
        if [ "$count" -gt 0 ]; then
            log_warning "Trouvé $count processus pour: $process"
            
            if confirm_action "Voulez-vous voir les détails ?"; then
                ps aux | grep -E "$process" | grep -v grep | head -5
            fi
            
            if confirm_action "Arrêter ces processus ?"; then
                pkill -f "$process"
                log_success "Processus $process arrêtés"
            fi
        fi
    done
}

# 2. Nettoyage des builds temporaires
clean_build_dirs() {
    log_info "Recherche des répertoires de build..."
    
    # Trouver les dossiers build/ target/ node_modules/ volumineux
    find ~/ -type d \( -name "build" -o -name "target" -o -name "node_modules" \) \
        -exec du -sh {} \; 2>/dev/null | sort -hr | head -10 > /tmp/build_dirs.txt
    
    if [ -s /tmp/build_dirs.txt ]; then
        echo ""
        log_warning "Dossiers temporaires volumineux trouvés:"
        cat /tmp/build_dirs.txt
        
        if confirm_action "Supprimer certains dossiers ?"; then
            echo ""
            echo "1. Supprimer TOUS (dangereux)"
            echo "2. Supprimer sélectivement"
            echo "3. Passer"
            read -p "Choix [1-3]: " choice
            
            case $choice in
                1)
                    find ~/ -type d \( -name "build" -o -name "target" \) -exec rm -rf {} \; 2>/dev/null
                    log_success "Tous les dossiers build/ supprimés"
                    ;;
                2)
                    while read -r line; do
                        dir=$(echo "$line" | awk '{print $2}')
                        size=$(echo "$line" | awk '{print $1}')
                        if confirm_action "Supprimer $dir ($size) ?"; then
                            rm -rf "$dir"
                            log_success "Supprimé: $dir"
                        fi
                    done < /tmp/build_dirs.txt
                    ;;
            esac
        fi
    fi
}

# 3. Nettoyage du cache système
clean_system_cache() {
    log_info "Nettoyage du cache système..."
    
    # Mémoire avant
    MEM_BEFORE=$(free -h | awk '/^Mem:/ {print $3}')
    
    # Nettoyage APT
    sudo apt clean 2>/dev/null && log_success "Cache APT nettoyé"
    
    # Nettoyage cache utilisateur
    rm -rf ~/.cache/*/* 2>/dev/null
    log_success "Cache utilisateur nettoyé"
    
    # Nettoyage cache navigateurs (sélectif)
    if confirm_action "Nettoyer le cache des navigateurs ?"; then
        # Chrome
        rm -rf ~/.cache/google-chrome/Default/Cache/* 2>/dev/null && log_success "Cache Chrome nettoyé"
        
        # Firefox
        rm -rf ~/.cache/mozilla/firefox/*.default-release/cache2/* 2>/dev/null && log_success "Cache Firefox nettoyé"
    fi
    
    # Libération de la mémoire
    sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
    
    # Mémoire après
    MEM_AFTER=$(free -h | awk '/^Mem:/ {print $3}')
    log_success "Mémoire libérée: $MEM_BEFORE → $MEM_AFTER"
}

# 4. Nettoyage des logs volumineux
clean_logs() {
    log_info "Analyse des fichiers log volumineux..."
    
    find /var/log -type f -name "*.log" -size +10M 2>/dev/null | head -5 > /tmp/big_logs.txt
    
    if [ -s /tmp/big_logs.txt ]; then
        echo ""
        log_warning "Logs volumineux trouvés:"
        while read -r log; do
            size=$(du -h "$log" 2>/dev/null | awk '{print $1}')
            echo "  - $log ($size)"
        done < /tmp/big_logs.txt
        
        if confirm_action "Vider certains logs ?"; then
            echo "1. Vider journalctl (systemd)"
            echo "2. Vider logs spécifiques"
            echo "3. Passer"
            read -p "Choix [1-3]: " choice
            
            case $choice in
                1)
                    sudo journalctl --vacuum-time=7d
                    log_success "Logs systemd nettoyés (gardés 7 jours)"
                    ;;
                2)
                    while read -r log; do
                        if confirm_action "Vider $log ?"; then
                            sudo truncate -s 0 "$log"
                            log_success "Vidé: $log"
                        fi
                    done < /tmp/big_logs.txt
                    ;;
            esac
        fi
    fi
}

# 5. Nettoyage Docker (si installé)
clean_docker() {
    if command -v docker &> /dev/null; then
        log_info "Nettoyage Docker..."
        
        # Arrêter tous les conteneurs
        if [ "$(docker ps -q)" ]; then
            if confirm_action "Arrêter tous les conteneurs Docker ?"; then
                docker stop $(docker ps -q)
                log_success "Conteneurs Docker arrêtés"
            fi
        fi
        
        # Nettoyage des ressources Docker
        docker system prune -f 2>/dev/null && log_success "Ressources Docker nettoyées"
    fi
}

# 6. Optimisation du système
optimize_system() {
    log_info "Optimisations système..."
    
    # Réduire la swappiness si beaucoup de RAM
    RAM_TOTAL=$(free -g | awk '/^Mem:/ {print $2}')
    if [ "$RAM_TOTAL" -ge 16 ]; then
        if confirm_action "Réduire swappiness (RAM: ${RAM_TOTAL}G) ?"; then
            echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
            sudo sysctl vm.swappiness=10
            log_success "Swappiness réduit à 10"
        fi
    fi
    
    # Optimisation des inotify watches (utile pour les devs)
    echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
    log_success "Limite inotify augmentée"
}

# 7. Rapport final
generate_report() {
    echo ""
    echo "========================================"
    echo "📊  RAPPORT FINAL DE NETTOYAGE"
    echo "========================================"
    
    # Mémoire
    echo -e "${BLUE}📈 Utilisation mémoire:${NC}"
    free -h | awk 'NR<=2 {print "  "$0}'
    
    # Disque
    echo -e "${BLUE}💾 Espace disque:${NC}"
    df -h /home | awk 'NR==2 {print "  Utilisé: "$3"/"$2" ("$5")"}'
    
    # Processus
    echo -e "${BLUE}🔄 Processus en cours:${NC}"
    echo "  Chrome: $(pgrep -c chrome)"
    echo "  Firefox: $(pgrep -c firefox)"
    echo "  Java/Kotlin: $(pgrep -c java)"
    
    # Recommandations
    echo ""
    echo -e "${YELLOW}💡 Recommandations:${NC}"
    
    if [ "$(pgrep -c chrome)" -gt 10 ]; then
        echo "  - 🌐 Chrome a trop de processus. Fermez des onglets ou utilisez 'chrome://system/'"
    fi
    
    if [ "$(du -sh ~/.cache 2>/dev/null | awk '{print $1}' | sed 's/[A-Za-z]*//g')" -gt 500 ]; then
        echo "  - 🗑️  Cache utilisateur > 500M. Nettoyez régulièrement avec ce script"
    fi
    
    echo "  - 🔄 Exécutez ce script chaque vendredi pour maintenir le système propre"
}

# Menu principal
main_menu() {
    echo ""
    echo "========================================"
    echo "🧹  MENU DE NETTOYAGE"
    echo "========================================"
    echo "1. Nettoyage complet (recommandé)"
    echo "2. Nettoyage processus seulement"
    echo "3. Nettoyage cache seulement"
    echo "4. Nettoyage Docker seulement"
    echo "5. Analyse seulement (pas de nettoyage)"
    echo "6. Quitter"
    echo ""
    
    read -p "Votre choix [1-6]: " choice
    
    case $choice in
        1)
            clean_dev_processes
            clean_build_dirs
            clean_system_cache
            clean_logs
            clean_docker
            optimize_system
            ;;
        2)
            clean_dev_processes
            ;;
        3)
            clean_system_cache
            ;;
        4)
            clean_docker
            ;;
        5)
            # Analyse seulement
            log_info "Mode analyse seulement"
            clean_dev_processes
            clean_build_dirs
            clean_logs
            ;;
        6)
            exit 0
            ;;
        *)
            log_error "Choix invalide"
            main_menu
            ;;
    esac
    
    generate_report
}

# Exécution
main_menu

# Nettoyage des fichiers temporaires
rm -f /tmp/build_dirs.txt /tmp/big_logs.txt

echo ""
log_success "Nettoyage terminé avec succès ! 🎉"
