#!/bin/bash

# 🛠️ Installation des outils de base pour le développement Kotlin

set -e

# ========== CONFIGURATION ==========
print_step() { echo -e "\n\033[0;35m▶ $1...\033[0m"; }
print_success() { echo -e "\033[0;32m✓ $1\033[0m"; }

# ========== INSTALLATION ASDF ==========
install_asdf() {
    print_step "Installation d'ASDF (gestionnaire de versions)"
    
    if [ -d "$HOME/.asdf" ]; then
        print_success "ASDF déjà installé"
        return
    fi
    
    # Cloner ASDF
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.18.0
    
    # Ajouter au shell
    echo -e '\n# ASDF Version Manager' >> ~/.bashrc
    echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
    echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc
    
    # Charger immédiatement
    . "$HOME/.asdf/asdf.sh"
    . "$HOME/.asdf/completions/asdf.bash"
    
    print_success "ASDF installé"
}

# ========== OUTILS SYSTÈME ==========
install_system_tools() {
    print_step "Installation des outils système"
    
    sudo apt update
    
    # Outils de base
    sudo apt install -y \
        build-essential \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg-agent \
        curl \
        wget \
        git \
        unzip \
        zip \
        tar \
        gzip \
        bzip2 \
        xz-utils \
        jq \
        yq \
        tree \
        htop \
        neofetch \
        ncdu \
        bat \
        exa \
        fd-find \
        ripgrep \
        fzf \
        tmux \
        zsh \
        fish \
        rsync \
        sshfs \
        openssh-client \
        net-tools \
        dnsutils \
        iputils-ping \
        traceroute \
        nmap \
        tcpdump \
        httpie \
        python3 \
        python3-pip \
        python3-venv \
        ruby \
        perl
    
    # Outils de monitoring
    sudo apt install -y \
        iotop \
        iftop \
        nethogs \
        bmon \
        slurm \
        vnstat
    
    print_success "Outils système installés"
}

# ========== OUTILS DE DÉVELOPPEMENT ==========
install_dev_tools() {
    print_step "Installation des outils de développement"
    
    # Version control
    sudo apt install -y \
        git-extras \
        git-flow \
        tig \
        hub
    
    # Build tools
    sudo apt install -y \
        cmake \
        ninja-build \
        meson \
        pkg-config \
        autoconf \
        automake \
        libtool \
        checkinstall
    
    # Libraries de développement
    sudo apt install -y \
        libssl-dev \
        libffi-dev \
        zlib1g-dev \
        libreadline-dev \
        libsqlite3-dev \
        libxml2-dev \
        libxslt1-dev \
        libcurl4-openssl-dev \
        libncurses5-dev \
        libedit-dev \
        llvm \
        libncursesw5-dev
    
    # Databases clients
    sudo apt install -y \
        postgresql-client \
        mysql-client \
        sqlite3 \
        redis-tools \
        mongodb-clients
    
    print_success "Outils de développement installés"
}

# ========== OUTILS RÉSEAU ==========
install_network_tools() {
    print_step "Installation des outils réseau"
    
    # HTTP/API testing
    sudo apt install -y \
        httpie \
        curl \
        wget
    
    # Alternative: télécharger les binaires récents
    # HTTPie
    if ! command -v http &> /dev/null; then
        pip3 install --upgrade httpie
    fi
    
    # Insomnia (alternative à Postman)
    echo "deb [trusted=yes arch=amd64] https://download.konghq.com/insomnia-ubuntu/ default all" | \
        sudo tee -a /etc/apt/sources.list.d/insomnia.list
    
    sudo apt update
    sudo apt install -y insomnia
    
    # grpcurl pour gRPC
    go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
    
    print_success "Outils réseau installés"
}

# ========== OUTILS CONTAINERS ==========
install_container_tools() {
    print_step "Installation des outils de conteneurisation"
    
    # Podman (alternative à Docker)
    sudo apt install -y podman podman-docker
    
    # Kubernetes tools
    # kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    
    # k9s
    wget https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz
    tar xvf k9s_Linux_amd64.tar.gz
    sudo mv k9s /usr/local/bin/
    rm k9s_Linux_amd64.tar.gz
    
    # helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    
    print_success "Outils de conteneurisation installés"
}

# ========== OUTILS DE PRODUCTIVITÉ ==========
install_productivity_tools() {
    print_step "Installation des outils de productivité"
    
    # Terminal multiplexer amélioré
    sudo apt install -y tmux
    
    # Configuration TMUX
    cat > ~/.tmux.conf << 'EOF'
# TMUX Configuration
set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g history-limit 10000
set -g default-terminal "screen-256color"
set -g status-interval 1
set -g status-right "#(date '+%Y-%m-%d %H:%M')"

# Key bindings
bind-key -n C-a send-prefix
bind-key -r C-h select-window -t :-
bind-key -r C-l select-window -t :+

# Colors
set -g status-bg black
set -g status-fg white
EOF
    
    # zsh et oh-my-zsh
    sudo apt install -y zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Plugins zsh
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    
    # Configuration zsh
    cat > ~/.zshrc << 'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# ASDF
. "$HOME/.asdf/asdf.sh"
fpath=(${ASDF_DIR}/completions $fpath)

# Aliases
alias ll='ls -la'
alias gs='git status'
alias k='kubectl'
EOF
    
    print_success "Outils de productivité installés"
}

# ========== CONFIGURATION FINALE ==========
configure_environment() {
    print_step "Configuration de l'environnement"
    
    # Créer la structure de dossiers
    mkdir -p ~/projects
    mkdir -p ~/tools
    mkdir -p ~/.local/bin
    mkdir -p ~/scripts
    
    # Ajouter au PATH
    cat >> ~/.bashrc << 'EOF'

# ========================================
# Custom Development Environment
# ========================================

# Local binaries
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/tools/bin:$PATH"
export PATH="$HOME/scripts:$PATH"

# Go
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# Python
export PYTHONPATH="$HOME/.local/lib/python3.12/site-packages:$PYTHONPATH"

# Editor
export EDITOR=nano
export VISUAL=code

# History
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth
export HISTTIMEFORMAT="%F %T "

# Aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'
alias e='exit'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias mkdir='mkdir -p'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps aux'
alias top='htop'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gb='git branch'
alias gl='git log --oneline --graph --all'
alias gd='git diff'
alias gps='git push'
alias gpl='git pull'
alias gst='git stash'
alias gr='git remote -v'

# System info
alias sysinfo='neofetch'
alias diskusage='df -h | grep -v tmpfs'
alias largest='du -h . | sort -rh | head -20'

# Network
alias myip='curl ifconfig.me'
alias ports='sudo lsof -i -P -n | grep LISTEN'
EOF
    
    print_success "Environnement configuré"
}

# ========== FONCTION PRINCIPALE ==========
main() {
    echo -e "\n\033[0;36m🛠️  Installation des outils de développement\033[0m"
    echo "══════════════════════════════════════════════════"
    
    install_asdf
    install_system_tools
    install_dev_tools
    install_network_tools
    install_container_tools
    install_productivity_tools
    configure_environment
    
    echo -e "\n\033[0;32m✅ Outils de développement installés avec succès!\033[0m"
}

# Exécuter
main "$@"