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
    # Capture credentials and VS Code specific settings from copied config
    GIT_USER_NAME=$(git config --global user.name 2>/dev/null || echo "")
    GIT_USER_EMAIL=$(git config --global user.email 2>/dev/null || echo "")
    
    # Capture all safe.directory entries (there can be multiple)
    SAFE_DIRS=()
    while IFS= read -r dir; do
        [ -n "$dir" ] && SAFE_DIRS+=("$dir")
    done < <(git config --global --get-all safe.directory 2>/dev/null || true)
    
    # Capture credential.helper
    CRED_HELPER=$(git config --global credential.helper 2>/dev/null || echo "")
    
    if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then
        echo -e "${GREEN}✓ Captured from host: $GIT_USER_NAME <$GIT_USER_EMAIL>${NC}"
    fi
    
    if [ ${#SAFE_DIRS[@]} -gt 0 ]; then
        echo -e "${GREEN}✓ Captured ${#SAFE_DIRS[@]} safe.directory entries${NC}"
    fi
    
    if [ -n "$CRED_HELPER" ]; then
        echo -e "${GREEN}✓ Captured credential.helper${NC}"
    fi
    
    # Now overwrite with our dotfiles gitconfig
    if [ -f "$DOTFILES_DIR/.gitconfig" ]; then
        cp "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
        echo -e "${GREEN}✓ Applied dotfiles .gitconfig${NC}"
        
        # Re-apply user credentials
        if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then
            git config --global user.name "$GIT_USER_NAME"
            git config --global user.email "$GIT_USER_EMAIL"
            echo -e "${GREEN}✓ Restored user credentials${NC}"
        fi
        
        # Re-apply safe.directory entries
        for dir in "${SAFE_DIRS[@]}"; do
            git config --global --add safe.directory "$dir"
        done
        if [ ${#SAFE_DIRS[@]} -gt 0 ]; then
            echo -e "${GREEN}✓ Restored ${#SAFE_DIRS[@]} safe.directory entries${NC}"
        fi
        
        # Re-apply credential.helper
        if [ -n "$CRED_HELPER" ]; then
            git config --global credential.helper "$CRED_HELPER"
            echo -e "${GREEN}✓ Restored credential.helper${NC}"
        fi
    fi
else
    echo -e "${RED}Warning: VS Code did not copy .gitconfig${NC}"
fi
