#!/bin/bash
# dots-server/.bashrc
# Server-optimized Bash config (converted from ZSH)
# For Ubuntu 24.04 servers with developer tools
# Minimal RAM usage while maintaining functionality

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# Set default editor
export EDITOR=nvim
export VISUAL=nvim

# Add local bin to PATH
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

## ------------------------------------------------------------------------
## Bash Options & History
## ------------------------------------------------------------------------

# History configuration
HISTFILE=~/.bash_history
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE="ls:ps:history"
HISTTIMEFORMAT="%F %T "

# Append to history, don't overwrite
shopt -s histappend

# Check window size after each command
shopt -s checkwinsize

# Enable ** for recursive globbing
shopt -s globstar 2>/dev/null

# Correct minor spelling errors in cd
shopt -s cdspell

# Allow cd to variables
shopt -s cdable_vars

# Extended pattern matching
shopt -s extglob

## ------------------------------------------------------------------------
## Prompt & Colors
## ------------------------------------------------------------------------

# Enable color support
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Simple colored prompt (if not using starship)
if ! command -v starship >/dev/null 2>&1; then
  PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi

## ------------------------------------------------------------------------
## General : Aliases & Abbreviations
## ------------------------------------------------------------------------

# Navigation aliases
alias c="clear"
alias d="z" # If zoxide is installed
alias cf="cd ~/.config/"

# File listing with eza (fallback to ls if eza not available)
if command -v eza >/dev/null 2>&1; then
  alias l='eza -lh --icons=auto'
  alias ls='eza -1 --icons=auto'
  alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
  alias ld='eza -lhD --icons=auto'
  alias lr='eza -l --sort=modified'
  alias lt='eza --icons=auto --tree'
else
  alias l='ls -lh'
  alias ll='ls -lha'
  alias lr='ls -lhtr'
fi

# Editor aliases
alias nv="nvim"
alias vim="nvim"

# Utility aliases
if command -v fastfetch >/dev/null 2>&1; then
  alias ff="fastfetch"
fi

# Server-specific aliases
alias nginx-reload="sudo systemctl reload nginx"
alias nginx-restart="sudo systemctl restart nginx"
alias nginx-status="sudo systemctl status nginx"
alias php-restart="sudo systemctl restart php8.2-fpm"
alias php-status="sudo systemctl status php8.2-fpm"
alias logs-nginx="sudo tail -f /var/log/nginx/error.log"
alias logs-php="sudo tail -f /var/log/php8.2-fpm.log"

# Cache management (for development)
alias cache-clear="sudo rm -rf /var/cache/nginx/* && sudo systemctl reload nginx"
alias cache-status="du -sh /var/cache/nginx/"

# System monitoring
alias df="df -h"
alias du="du -h"
alias free="free -h"
alias mem='free -h | grep "^Mem"'
alias cpu='top -bn1 | grep "Cpu(s)"'

# Directory navigation shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
alias mkdir='mkdir -p'

# Quick edits
alias envim='sudo nvim /etc/nginx/sites-available/default'
alias ephp='sudo nvim /etc/php/8.2/fpm/pool.d/www.conf'
alias ebash='nvim ~/.bashrc'
alias sbash='source ~/.bashrc'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -10'
alias gd='git diff'

# Grep with color
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Make fd work as fdfind (Ubuntu packages fd-find as fdfind)
if command -v fdfind >/dev/null 2>&1; then
  alias fd='fdfind'
  # Also set up for use in scripts
  export FD_COMMAND='fdfind'
elif command -v fd >/dev/null 2>&1; then
  export FD_COMMAND='fd'
fi

# Helpful fd shortcuts
alias fdd='fd --type d'    # Find directories only
alias fdf='fd --type f'    # Find files only
alias fdh='fd --hidden'    # Include hidden files
alias fde='fd --extension' # Search by extension (usage: fde php)

## ------------------------------------------------------------------------
## Functions
## ------------------------------------------------------------------------

# Function to check what's using a port
port() {
  sudo lsof -i :${1:?Port number required}
}

# Function to extract various archives
extract() {
  if [ -f "$1" ]; then
    case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.rar) unrar x "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xf "$1" ;;
    *.tbz2) tar xjf "$1" ;;
    *.tgz) tar xzf "$1" ;;
    *.zip) unzip "$1" ;;
    *.Z) uncompress "$1" ;;
    *.7z) 7z x "$1" ;;
    *) echo "'$1' cannot be extracted" ;;
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

# Server performance check
perf() {
  echo "=== Server Performance ==="
  echo
  echo "Memory Usage:"
  free -h | grep -E "^Mem|^Swap"
  echo
  echo "Disk Usage:"
  df -h | grep -E "^/dev/|^Filesystem"
  echo
  echo "CPU Load:"
  uptime
  echo
  echo "Top Processes:"
  ps aux --sort=-%mem | head -6
  echo
  echo "Service Status:"
  systemctl status nginx --no-pager | grep -E "Active:"
  systemctl status php8.2-fpm --no-pager | grep -E "Active:"
  systemctl status redis --no-pager 2>/dev/null | grep -E "Active:" || echo "Redis: not installed"
}

# Function to update dotfiles from GitHub
dots-update() {
  echo -e "\033[0;32mUpdating dotfiles from GitHub...\033[0m"

  # Save current directory
  local current_dir=$(pwd)

  # Go to dots-server directory
  cd ~/dots-server || {
    echo -e "\033[0;31mError: ~/dots-server not found!\033[0m"
    echo "Run: git clone https://github.com/4ractl/dots-server.git ~/dots-server"
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
    source ~/.bashrc
  fi

  # Return to original directory
  cd "$current_dir"
}

# Shorter alias for the update function
alias dots='dots-update'

## ------------------------------------------------------------------------
## Bash Completion
## ------------------------------------------------------------------------

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

## ------------------------------------------------------------------------
## Initializations
## ------------------------------------------------------------------------

# Initialize zoxide if available
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

# Initialize Atuin if available (with --disable-up-arrow)
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init bash --disable-up-arrow)"
fi

# Initialize Starship if available
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# Initialize fzf if available
if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
  source /usr/share/doc/fzf/examples/key-bindings.bash
fi
if [ -f /usr/share/doc/fzf/examples/completion.bash ]; then
  source /usr/share/doc/fzf/examples/completion.bash
fi

# FZF configuration
if command -v fzf >/dev/null 2>&1; then
  # TokyoNight theme for FZF
  export FZF_DEFAULT_OPTS="--color=bg+:#1a1b26,bg:#1a1b26,spinner:#f7768e,hl:#f7768e,fg:#c0caf5,header:#f7768e,info:#7aa2f7,pointer:#f7768e,marker:#f7768e,fg+:#c0caf5,prompt:#7aa2f7,hl+:#f7768e"

  # Use fd/fdfind for fzf if available
  if command -v fdfind >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git'
  elif command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
fi

## ------------------------------------------------------------------------
## Environment Variables
## ------------------------------------------------------------------------

# Set language for proper UTF-8 support
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Set pager
export PAGER=less
export LESS='-R --use-color -Dd+r$Du+b'

# Disable telemetry
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export HOMEBREW_NO_ANALYTICS=1
export SAM_CLI_TELEMETRY=0

# Colors for ls (if not using eza)
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

## ------------------------------------------------------------------------
## SSH Agent (if needed)
## ------------------------------------------------------------------------

# Start SSH agent if not running
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" >/dev/null 2>&1
fi

## ------------------------------------------------------------------------
## Auto-update check (runs on login)
## ------------------------------------------------------------------------

# Check for dotfiles updates on login
if [[ -d ~/dots-server ]]; then
  # Run in background to not slow down shell startup
  (
    cd ~/dots-server && git fetch origin --quiet 2>/dev/null
    LOCAL=$(git rev-parse @ 2>/dev/null)
    REMOTE=$(git rev-parse @{u} 2>/dev/null)
    if [[ -n "$LOCAL" && -n "$REMOTE" && "$LOCAL" != "$REMOTE" ]]; then
      echo -e "\033[1;33m⚠ Dotfiles updates available! Run 'dots' to update.\033[0m"
    fi
  ) &
fi

## ------------------------------------------------------------------------
## Welcome Message (minimal for performance)
## ------------------------------------------------------------------------

# Show system info on login (only for interactive shells)
if [[ -n "$PS1" ]] && [[ -z "$TMUX" ]]; then
  # Simple welcome without heavy commands
  echo -e "\033[1;34m$(hostname -f)\033[0m - $(date '+%Y-%m-%d %H:%M')"
  echo "Memory: $(free -h | awk '/^Mem:/ {print $3 " / " $2}')"
  echo
fi

