# dots-server/.zshrc
# Server-optimized ZSH config matching Fish functionality
# For Ubuntu 24.04 servers with developer tools

# Disable greeting (ZSH doesn't have one by default)

# Set default editor
export EDITOR=nvim
export VISUAL=nvim

# Add local bin to PATH
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

## ------------------------------------------------------------------------
## ZSH Options & History
## ------------------------------------------------------------------------

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select

## ------------------------------------------------------------------------
## Themes
## ------------------------------------------------------------------------

# Source TokyoNight theme if it exists
[[ -f ~/.config/zsh/themes/tokyonight_night.zsh ]] && source ~/.config/zsh/themes/tokyonight_night.zsh

# FZF TokyoNight theme
export FZF_DEFAULT_OPTS="--color=bg+:#1a1b26,bg:#1a1b26,spinner:#f7768e,hl:#f7768e,fg:#c0caf5,header:#f7768e,info:#7aa2f7,pointer:#f7768e,marker:#f7768e,fg+:#c0caf5,prompt:#7aa2f7,hl+:#f7768e"

## ------------------------------------------------------------------------
## General : Aliases & Abbreviations
## ------------------------------------------------------------------------

# Navigation aliases
alias c="clear"
alias d="z"
alias cf="z ~/.config/"

# File listing with eza
alias l='eza -lh --icons=auto'
alias ls='eza -1 --icons=auto'
alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
alias ld='eza -lhD --icons=auto'
alias lr='eza -l --sort=modified'
alias lt='eza --icons=auto --tree'

# Editor aliases
alias nv="nvim"
alias vim="nvim"

# Utility aliases
alias ff="fastfetch"

# Server-specific aliases
alias nginx-reload="sudo systemctl reload nginx"
alias nginx-restart="sudo systemctl restart nginx"
alias nginx-status="sudo systemctl status nginx"
alias php-restart="sudo systemctl restart php8.3-fpm"
alias php-status="sudo systemctl status php8.3-fpm"
alias logs-nginx="sudo tail -f /var/log/nginx/error.log"
alias logs-php="sudo tail -f /var/log/php8.3-fpm.log"
alias perf="sudo /usr/local/bin/check-performance.sh"

# System monitoring
alias df="df -h"
alias du="du -h"
alias free="free -h"

# Directory navigation shortcuts (ZSH equivalent of Fish abbreviations)
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
alias mkdir='mkdir -p'

# Quick edits
alias envim='sudo nvim /etc/nginx/sites-available/default'
alias ephp='sudo nvim /etc/php/8.3/fpm/pool.d/www.conf'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

## ------------------------------------------------------------------------
## Functions
## ------------------------------------------------------------------------

# Function to check what's using a port
port() {
    sudo lsof -i :$1
}

# Function to extract various archives
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Function to create a directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Function to backup a file with timestamp
backup() {
    cp "$1"{,.backup-$(date +%Y%m%d-%H%M%S)}
}

# Function to update dotfiles from GitHub
dots-update() {
    echo -e "\033[0;32mUpdating dotfiles from GitHub...\033[0m"
    
    # Save current directory
    local current_dir=$(pwd)
    
    # Go to dots-server directory
    cd ~/dots-server || {
        echo -e "\033[0;31mError: ~/dots-server not found!\033[0m"
        echo "Run: git clone https://github.com/yourusername/dots-server.git ~/dots-server"
        return 1
    }
    
    # Fetch latest changes
    echo "Fetching latest changes..."
    git fetch origin
    
    # Check if there are updates
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u})
    
    if [ "$LOCAL" = "$REMOTE" ]; then
        echo -e "\033[1;33m✓ Already up to date!\033[0m"
    else
        # Pull latest changes
        echo "Pulling updates..."
        git pull origin main
        
        # Re-run install script to ensure any new files are linked
        if [[ -f ./install.sh ]]; then
            echo "Running install script..."
            bash ./install.sh
        fi
        
        echo -e "\033[0;32m✓ Dotfiles updated successfully!\033[0m"
        echo "Reloading shell configuration..."
        source ~/.zshrc
    fi
    
    # Return to original directory
    cd "$current_dir"
}

# Shorter aliases for the update function
alias dots='dots-update'

## ------------------------------------------------------------------------
## Plugins
## ------------------------------------------------------------------------

# Load ZSH plugins if available
[[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ZSH autosuggestions configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#565f89"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
bindkey '^[[Z' autosuggest-accept  # Shift+Tab to accept suggestion

## ------------------------------------------------------------------------
## Initializations
## ------------------------------------------------------------------------

# Initialize zoxide if available
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# Initialize Atuin if available (with --disable-up-arrow to prevent interference)
if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh --disable-up-arrow)"
fi

# Initialize Starship if available
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# Initialize fzf if available
if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --zsh)" 2>/dev/null || true
fi

## ------------------------------------------------------------------------
## Environment Variables
## ------------------------------------------------------------------------

# Set language for proper UTF-8 support (important for SSH)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Set pager
export PAGER=less

# Colors for ls (if not using eza)
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# Disable telemetry for various tools
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export HOMEBREW_NO_ANALYTICS=1
export SAM_CLI_TELEMETRY=0

## ------------------------------------------------------------------------
## SSH Agent (if needed)
## ------------------------------------------------------------------------

# Start SSH agent if not running
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" >/dev/null 2>&1
fi

## ------------------------------------------------------------------------
## Key Bindings
## ------------------------------------------------------------------------

# Emacs-style key bindings (for consistency)
bindkey -e

# Better history search
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^P' up-line-or-search
bindkey '^N' down-line-or-search

# Word navigation
bindkey '^[[1;5C' forward-word  # Ctrl+Right
bindkey '^[[1;5D' backward-word # Ctrl+Left

# Home/End keys
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

## ------------------------------------------------------------------------
## Auto-update check (Optional - runs on login)
## ------------------------------------------------------------------------

# Check for dotfiles updates on login
if [[ -d ~/dots-server ]]; then
    (cd ~/dots-server && git fetch origin --quiet)
    LOCAL=$(cd ~/dots-server && git rev-parse @ 2>/dev/null)
    REMOTE=$(cd ~/dots-server && git rev-parse @{u} 2>/dev/null)
    if [[ -n "$LOCAL" && -n "$REMOTE" && "$LOCAL" != "$REMOTE" ]]; then
        echo -e "\033[1;33m⚠ Dotfiles updates available! Run 'dots' to update.\033[0m"
    fi
fi
