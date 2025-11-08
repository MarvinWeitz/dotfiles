#!/bin/bash

# install.sh - Dotfiles installation script
# This script creates symlinks for dotfiles in the home directory

set -e

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}Installing dotfiles...${NC}"

# Create backup directory if it doesn't exist
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Function to backup and link dotfiles
link_dotfile() {
    local source="$1"
    local target="$2"
    
    # Check if source file exists
    if [ ! -f "$source" ]; then
        echo -e "${RED}Warning: Source file $source does not exist${NC}"
        return 1
    fi
    
    # Backup existing file/symlink if it exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ ! -d "$BACKUP_DIR" ]; then
            mkdir -p "$BACKUP_DIR"
            echo -e "${BLUE}Created backup directory: $BACKUP_DIR${NC}"
        fi
        echo -e "${BLUE}Backing up existing $target${NC}"
        mv "$target" "$BACKUP_DIR/"
    fi
    
    # Create symlink
    ln -s "$source" "$target"
    echo -e "${GREEN}✓ Linked $target -> $source${NC}"
}

# Link dotfiles
link_dotfile "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
link_dotfile "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

echo -e "${GREEN}Dotfiles installation complete!${NC}"

# Check if zsh is installed
if ! command -v zsh &> /dev/null; then
    echo -e "${BLUE}Note: zsh is not installed. Install it with:${NC}"
    echo "  - macOS: brew install zsh"
    echo "  - Ubuntu/Debian: sudo apt install zsh"
    echo "  - Fedora: sudo dnf install zsh"
fi

# Check if Oh My Zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${BLUE}Note: Oh My Zsh not detected. Install with:${NC}"
    echo '  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
fi

# Check if Powerlevel10k is installed
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    echo -e "${BLUE}Note: Powerlevel10k theme not detected. Install with:${NC}"
    echo '  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k'
fi

echo -e "${GREEN}To apply changes, restart your terminal or run: source ~/.zshrc${NC}"
