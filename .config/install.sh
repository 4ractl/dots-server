#!/bin/bash
# dots-server/install.sh

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Installing server dotfiles...${NC}"

# Get the directory where this script is located
DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Backup existing configs (only if not already symlinks)
[[ -f ~/.zshrc && ! -L ~/.zshrc ]] && mv ~/.zshrc ~/.zshrc.backup
[[ -f ~/.config/starship.toml && ! -L ~/.config/starship.toml ]] && mv ~/.config/starship.toml ~/.config/starship.toml.backup

# Create necessary directories
mkdir -p ~/.config

# Create symlinks (not copies) so updates are automatic
ln -sf "$DOTS_DIR/.zshrc" ~/.zshrc
ln -sf "$DOTS_DIR/.config/starship.toml" ~/.config/starship.toml

# Install Starship if not present
if ! command -v starship &>/dev/null; then
  echo -e "${YELLOW}Installing Starship...${NC}"
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

echo -e "${GREEN}✓ Dotfiles installed!${NC}"
echo "Restart your shell or run: source ~/.zshrc"
