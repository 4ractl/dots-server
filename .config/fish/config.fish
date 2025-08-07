# Server-optimized config.fish
# For Ubuntu 24.04 servers with developer tools

# Disable greeting
set -g fish_greeting

# Set default editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# Add local bin to PATH
set -gx PATH $HOME/.local/bin /usr/local/bin $PATH

## ------------------------------------------------------------------------
## General : Aliases & Abbreviations
## ------------------------------------------------------------------------

# Navigation aliases
alias c="clear"
alias d="z"
alias cf="z ~/.config/"

# File listing with eza
alias l='eza -lh --icons=auto' # long list
alias ls='eza -1 --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias lr='eza -l --sort=modified' # most recent displayed at the bottom
alias lt='eza --icons=auto --tree' # list folder as tree

# Editor aliases
alias nv="nvim"
alias vim="nvim"

# Server-specific aliases
alias nginx-reload="sudo systemctl reload nginx"
alias nginx-restart="sudo systemctl restart nginx"
alias nginx-status="sudo systemctl status nginx"
alias php-restart="sudo systemctl restart php8.3-fpm"
alias php-status="sudo systemctl status php8.3-fpm"
alias logs-nginx="sudo tail -f /var/log/nginx/error.log"
alias logs-php="sudo tail -f /var/log/php8.3-fpm.log"
alias perf="sudo /usr/local/bin/check-performance.sh"

# Git aliases
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline"

# System monitoring
alias htop="btop"
alias df="df -h"
alias du="du -h"
alias free="free -h"

# Abbreviations
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .3 'cd ../../..'
abbr .4 'cd ../../../..'
abbr .5 'cd ../../../../..'
abbr mkdir 'mkdir -p' # creates each folder in the path

# Quick edits
abbr envim 'sudo nvim /etc/nginx/sites-available/default'
abbr ephp 'sudo nvim /etc/php/8.3/fpm/pool.d/www.conf'

## ------------------------------------------------------------------------
## Functions
## ------------------------------------------------------------------------

# Function to check what's using a port
function port
    sudo lsof -i :$argv
end

# Function to extract various archives
function extract
    if test -f $argv
        switch $argv
            case '*.tar.bz2'
                tar xjf $argv
            case '*.tar.gz'
                tar xzf $argv
            case '*.bz2'
                bunzip2 $argv
            case '*.rar'
                unrar x $argv
            case '*.gz'
                gunzip $argv
            case '*.tar'
                tar xf $argv
            case '*.tbz2'
                tar xjf $argv
            case '*.tgz'
                tar xzf $argv
            case '*.zip'
                unzip $argv
            case '*.Z'
                uncompress $argv
            case '*.7z'
                7z x $argv
            case '*'
                echo "'$argv' cannot be extracted"
        end
    else
        echo "'$argv' is not a valid file"
    end
end

# Function to create a directory and cd into it
function mkcd
    mkdir -p $argv && cd $argv
end

# Function to backup a file with timestamp
function backup
    cp $argv{,.backup-(date +%Y%m%d-%H%M%S)}
end

## ------------------------------------------------------------------------
## Initializations
## ------------------------------------------------------------------------

# Initialize zoxide if available
if command -v zoxide >/dev/null
    zoxide init fish | source
end

# Initialize Atuin if available (with --disable-up-arrow to prevent interference)
if command -v atuin >/dev/null
    atuin init fish --disable-up-arrow | source
end

# Initialize Starship if available
if command -v starship >/dev/null
    starship init fish | source
end

# Initialize fzf if available
if command -v fzf >/dev/null
    fzf --fish | source 2>/dev/null || true
end

## ------------------------------------------------------------------------
## Environment Variables
## ------------------------------------------------------------------------

# Set language for proper UTF-8 support (important for SSH)
set -x LANG en_US.UTF-8
set -x LC_ALL en_US.UTF-8

# Set pager
set -x PAGER less

# Colors for ls (if not using eza)
set -x LS_COLORS 'di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# Disable telemetry for various tools
set -x DOTNET_CLI_TELEMETRY_OPTOUT 1
set -x HOMEBREW_NO_ANALYTICS 1
set -x SAM_CLI_TELEMETRY 0

## ------------------------------------------------------------------------
## SSH Agent (if needed)
## ------------------------------------------------------------------------

# Start SSH agent if not running
if not set -q SSH_AUTH_SOCK
    eval (ssh-agent -c) >/dev/null
end
