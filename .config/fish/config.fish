set -g fish_greeting
set -Ux TERMINAL foot

if status is-interactive
    starship init fish | source
end

### Themes
source ~/.config/fish/themes/tokyonight_night.fish # fish
source ~/.config/fzf/themes/tokyonight_night.fish # fzf
## ------------------------------------------------------------------------
## General : Aliases & Abbreviations
## ------------------------------------------------------------------------
# Aliases
alias b="z ~/base/"
alias c="clear"
alias cf="z ~/.config/"
alias cpa="wl-copy <" # copy the contents of an entire file
alias d="z"
alias en="z /etc/nixos/"
alias esr="pkill -f espanso-monitor.sh; systemctl --user restart espanso; sleep 2; esm"
alias ff="fastfetch"
alias l='eza -lh --icons=auto' # long list
alias ls='eza -1 --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias lr='eza -l --sort=modified' # most recent displayed at the bottom
alias lt='eza --icons=auto --tree' # list folder as tree
alias ns="sudo arp-scan --localnet" # network scanner
alias nv="nvim"
alias sres="xrandr | grep '*'" # check screen res
alias vim="nvim"

# Abbreviations
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .3 'cd ../../..'
abbr .4 'cd ../../../..'
abbr .5 'cd ../../../../..'

abbr mkdir 'mkdir -p' # creates each folder in the path
### Resets  -----------------------------------------------
alias refi="source $HOME/dotfiles/config/fish/config.fish"

###  Functions  -----------------------------------------------
source $HOME/.config/fish/functions.fish

### Initializations  -----------------------------------------------
zoxide init fish | source
starship init fish | source
fzf --fish | source

### Mosh Settings
set -x LANG en_US.UTF-8
set -x PATH /usr/local/bin $PATH

# Created by `pipx` on 2025-02-19 04:25:38
set PATH $PATH $HOME/.local/bin
export PATH="$HOME/.local/bin:$PATH"
# Auto-start Hyprland on TTY1 for base system
if test (tty) = /dev/tty1 -a -z "$WAYLAND_DISPLAY"
    exec Hyprland
end
set -x BW_SESSION "I3GAjvlByaNE8isXY6xyonrHhL9/WWWSLRwvYeUCMn+D72df1F858GRKyrU63gyB3i5aaqmDCcH2KWdXTeVlqg"
set -x PATH $HOME/base/git/scripts $PATH
set -gx PATH $HOME/.npm-global/bin $PATH
