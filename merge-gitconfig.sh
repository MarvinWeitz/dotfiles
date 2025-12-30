#!/bin/bash
# merge-gitconfig.sh - Merge host gitconfig with dotfiles gitconfig
# This is needed for devcontainer scenarios where a host gitconfig should be copied into the container first
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}Merging git configuration...${NC}"

# At this point, VS Code has copied the host's .gitconfig to ~/.gitconfig
# We need to extract user.name and user.email, then apply our dotfiles config

if [ -f "$HOME/.gitconfig" ]; then
    # Capture credentials from VS Code's copied config
    GIT_USER_NAME=$(git config --global user.name 2>/dev/null || echo "")
    GIT_USER_EMAIL=$(git config --global user.email 2>/dev/null || echo "")
    
    if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then
        echo -e "${GREEN}✓ Captured from host: $GIT_USER_NAME <$GIT_USER_EMAIL>${NC}"
        
        # Now overwrite with our dotfiles gitconfig
        if [ -f "$DOTFILES_DIR/.gitconfig" ]; then
            cp "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
            echo -e "${GREEN}✓ Applied dotfiles .gitconfig${NC}"
            
            # Re-apply user credentials
            git config --global user.name "$GIT_USER_NAME"
            git config --global user.email "$GIT_USER_EMAIL"
            echo -e "${GREEN}✓ Restored user credentials${NC}"
        fi
    else
        echo -e "${RED}Warning: No git credentials found in copied config${NC}"
    fi
else
    echo -e "${RED}Warning: VS Code did not copy .gitconfig${NC}"
fi
