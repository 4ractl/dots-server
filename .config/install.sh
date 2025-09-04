#!/bin/bash
# dots-server install script for Ubuntu 24.04 servers
# Sets up Bash with all configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_message() {
  echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"
}

error_exit() {
  echo -e "${RED}ERROR: $1${NC}" >&2
  exit 1
}

# Check if running from dots-server directory
if [[ ! -f .bashrc ]] || [[ ! -d .config ]]; then
  error_exit "Please run this script from the dots-server directory"
fi

DOTS_DIR=$(pwd)

log_message "Starting dotfiles installation..."

# Create necessary directories
log_message "Creating config directories..."
mkdir -p ~/.config
mkdir -p ~/.local/bin
mkdir -p ~/.cache

# Link Bash configuration
log_message "Setting up Bash configuration..."
if [[ -f ~/.bashrc ]]; then
  log_message "Backing up existing .bashrc to .bashrc.backup"
  cp ~/.bashrc ~/.bashrc.backup
fi
ln -sf "$DOTS_DIR/.bashrc" ~/.bashrc

# Link Starship configuration (works with Bash)
if [[ -d "$DOTS_DIR/.config/starship" ]] || [[ -f "$DOTS_DIR/.config/starship.toml" ]]; then
  log_message "Setting up Starship prompt..."
  mkdir -p ~/.config

  # Handle both directory and single file configs
  if [[ -d "$DOTS_DIR/.config/starship" ]]; then
    ln -sf "$DOTS_DIR/.config/starship" ~/.config/
  elif [[ -f "$DOTS_DIR/.config/starship.toml" ]]; then
    ln -sf "$DOTS_DIR/.config/starship.toml" ~/.config/starship.toml
  fi
fi

# Link Neovim configuration
if [[ -d "$DOTS_DIR/.config/nvim" ]]; then
  log_message "Setting up Neovim configuration..."
  ln -sf "$DOTS_DIR/.config/nvim" ~/.config/
fi

# Link tmux configuration
if [[ -f "$DOTS_DIR/.tmux.conf" ]]; then
  log_message "Setting up tmux configuration..."
  ln -sf "$DOTS_DIR/.tmux.conf" ~/.tmux.conf
fi

# Link git configuration
if [[ -f "$DOTS_DIR/.gitconfig" ]]; then
  log_message "Setting up git configuration..."
  ln -sf "$DOTS_DIR/.gitconfig" ~/.gitconfig
fi

# Link other config directories
log_message "Linking other configurations..."
for config_dir in "$DOTS_DIR"/.config/*; do
  if [[ -d "$config_dir" ]]; then
    config_name=$(basename "$config_dir")

    # Skip already handled configs
    if [[ "$config_name" == "nvim" ]] || [[ "$config_name" == "starship" ]]; then
      continue
    fi

    log_message "Linking $config_name..."
    ln -sf "$config_dir" ~/.config/
  fi
done

# Set up local bin scripts if they exist
if [[ -d "$DOTS_DIR/.local/bin" ]]; then
  log_message "Setting up local bin scripts..."
  for script in "$DOTS_DIR"/.local/bin/*; do
    if [[ -f "$script" ]]; then
      script_name=$(basename "$script")
      ln -sf "$script" ~/.local/bin/"$script_name"
      chmod +x ~/.local/bin/"$script_name"
    fi
  done
fi

# Create alias for fd if on Ubuntu (where it's fdfind)
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  log_message "Creating fd alias for fdfind..."
  echo '#!/bin/bash' >~/.local/bin/fd
  echo 'exec fdfind "$@"' >>~/.local/bin/fd
  chmod +x ~/.local/bin/fd
fi

# Initialize git submodules if any
if [[ -f "$DOTS_DIR/.gitmodules" ]]; then
  log_message "Initializing git submodules..."
  (cd "$DOTS_DIR" && git submodule update --init --recursive)
fi

# Source the new bashrc
log_message "Loading new Bash configuration..."
source ~/.bashrc 2>/dev/null || true

# Check what's installed and working
echo ""
echo "========================================="
echo -e "${GREEN}Dotfiles Installation Complete!${NC}"
echo "========================================="
echo ""
echo "Checking installed tools:"

check_tool() {
  if command -v "$1" >/dev/null 2>&1; then
    echo -e "✅ $1 is installed"
    return 0
  else
    echo -e "❌ $1 is not installed"
    return 1
  fi
}

check_tool "bash"
check_tool "nvim"
check_tool "tmux"
check_tool "starship"
check_tool "fzf"
check_tool "zoxide"
check_tool "eza"
check_tool "bat"
check_tool "ripgrep" || check_tool "rg"
check_tool "fd" || check_tool "fdfind"

echo ""
echo "Configuration files linked:"
echo "  ~/.bashrc -> $DOTS_DIR/.bashrc"
[[ -L ~/.config/nvim ]] && echo "  ~/.config/nvim -> $DOTS_DIR/.config/nvim"
[[ -L ~/.config/starship.toml ]] && echo "  ~/.config/starship.toml -> $DOTS_DIR/.config/starship.toml"
[[ -L ~/.tmux.conf ]] && echo "  ~/.tmux.conf -> $DOTS_DIR/.tmux.conf"

echo ""
echo -e "${YELLOW}Note: Restart your shell or run 'source ~/.bashrc' to apply changes${NC}"
echo ""
echo "Quick commands:"
echo "  dots  - Update dotfiles from git"
echo "  fd    - Find files (aliased to fdfind)"
echo "  ll    - List files with icons"
echo "  nv    - Open Neovim"
echo "  perf  - Check server performance"
echo ""

log_message "Installation complete!"
