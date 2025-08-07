set -g fish_greeting
set -Ux TERMINAL foot

if status is-interactive
    starship init fish | source
end

### Themes
# source ~/dotfiles/config/fish/.config/fish/themes/tokyonight_night.theme
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
alias ncf='nvim /etc/nixos/configuration.nix' # nix : config
alias nhd='nvim /etc/nixos/home/default.nix' # nix : home default
alias ndf='nvim /etc/nixos/modules/dotfiles.nix' # nix : dotfiles
alias ndfcli='nvim /etc/nixos/modules/dotfiles-cli.nix' # nix : dotfiles
alias nfl='nvim /etc/nixos/flake.nix' # nix : dotfiles
alias ng='sudo nix-env --profile /nix/var/nix/profiles/system --list-generations'
alias nrbb="sudo nixos-rebuild switch --flake /etc/nixos/.#base --impure"
alias nrbd="sudo nixos-rebuild switch --flake /etc/nixos/.#dev --impure"
alias nrbc="sudo nixos-rebuild switch --flake /etc/nixos/.#cli --impure"
alias ns="sudo arp-scan --localnet" # network scanner
alias nse="sudo EDITOR=/home/nyc/.nix-profile/bin/nvim SOPS_AGE_KEY_FILE=/etc/sops/age/keys.txt sops /etc/nixos/secrets/secrets.yaml"
alias nseo="SOPS_AGE_KEY_FILE=/etc/sops/age/keys.txt sops /etc/nixos/secrets/secrets.yaml"
alias nv="nvim"
alias sres="xrandr | grep '*'" # check screen res
alias vim="nvim"

# Abbreviations
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .3 'cd ../../..'
abbr .4 'cd ../../../..'
abbr .5 'cd ../../../../..'

# abbr paci 'sudo pacman -S'
# abbr pacs 'sudo pacman -Ss'
# abbr pacr 'sudo pacman -Rns'
# abbr pacq 'sudo pacman -Qs'
# abbr pacsyu 'sudo pacman -Syu'
# abbr pari 'paru -S'
# abbr pars 'paru -Ss'
# abbr parr 'paru -Rns'
# abbr parq 'paru -Qs'
# abbr parsyu 'paru -Syu'
abbr mkdir 'mkdir -p' # creates each folder in the path

## ------------------------------------------------------------------------
## General : Dotfile Directories & Config Files
## ------------------------------------------------------------------------
# Aliases : Dotfile Directories  ------------------------------------------
alias dff="z ~/dotfiles/config/"
alias dfbg="z ~/dotfiles/config/wallpapers/"
alias dfbt="z ~/dotfiles/config/btop/"
alias dfff="z ~/dotfiles/config/fastfetch/"
alias dffi="z ~/dotfiles/config/fish/"
alias dfft="z ~/dotfiles/config/foot/"
alias dfgo="z ~/dotfiles/config/ghostty/"
alias dfhy="z ~/dotfiles/config/hypr/"
alias dfnv="z ~/dotfiles/config/nvim/"
alias dfsp="z ~/dotfiles/config/spicetify/"
alias dfss="z ~/dotfiles/config/"
alias dftm="nvim ~/dotfiles/config/.tmux.conf"
alias dfwb="z ~/dotfiles/config/waybar/"

# Aliases : Directories  --------------------------------------------------
alias didl="z $HOME/Downloads/" # downloads folder
alias didt="z $HOME/Desktop/" # desktop folder
alias dido="z $HOME/base/sync/doom/" # doom
alias diom="z $HOME/base/sync/org/" # orgmode
alias dihl=" $HOME/dotfiles/config/hypr/"
alias dirp="z $HOME/Downloads/repos/" # downloads folder
# Aliases : Config Files  -------------------------------------------------
alias cfff="nvim $HOME/dotfiles/config/fastfetch/config.jsonc"
alias cffi="nvim $HOME/dotfiles/config/fish/config.fish"
alias cffifu="nvim $HOME/dotfiles/config/fish/functions.fish"
alias cfdo="nvim $HOME/base/git/doom/config.el"
alias cfpa="nvim $HOME/base/doom/packages.el"
alias cfhl="nvim $HOME/dotfiles/config/hypr/hyprland.conf"
alias cfkt="nvim $HOME/dotfiles/config/kitty/kitty.conf"
alias cfwb="nvim $HOME/dotfiles/config/waybar/config.jsonc"
alias cfwbs="nvim $HOME/dotfiles/config/waybar/style.css"
alias cfbt="nvim $HOME/dotfiles/config/btop/btop.conf"
alias cfhi="nvim $HOME/dotfiles/config/hypr/hypridle.conf"
alias cfhlk="nvim $HOME/dotfiles/config/hypr/hyprlock.conf"
alias cfhp="nvim $HOME/dotfiles/config/hypr/hyprpaper.conf"
# alias cfsp="nvim $HOME/dotfiles/config/spicetify/.config/spicetify"
alias cfss="nvim $HOME/dotfiles/config/starship/starship.toml"
alias cdoom "wl-copy < $HOME/.config/doom/config.el" # copy contents of entire file

### SyncThing
alias dist="z $HOME/base/sync/"

## Hyprland

### Resets  -----------------------------------------------
alias rekeeb="$HOME/base/git/scripts/resetKeeb.sh" # reset Keeb bluetooth connection.
alias refi="source $HOME/dotfiles/config/fish/config.fish"
alias redo="doom sync"

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
