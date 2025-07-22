#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to remove symlink and restore backup
restore_file() {
    local file="$1"
    local backup="${file}.bak"
    
    if [ -L "$file" ]; then
        log_info "Removing symlink: $file"
        rm "$file"
        
        if [ -e "$backup" ]; then
            log_info "Restoring backup: $backup -> $file"
            mv "$backup" "$file"
            log_success "Restored: $file"
        else
            log_warning "No backup found for: $file"
        fi
    elif [ -e "$file" ]; then
        log_warning "File exists but is not a symlink: $file"
        log_warning "Skipping to avoid data loss"
    else
        log_info "File not found: $file"
    fi
}

log_info "Starting dotfiles uninstallation..."

# Files to uninstall
declare -a FILES=(
    "$HOME/.bashrc"
    "$HOME/.aliases"
    "$HOME/.functions"
    "$HOME/.exports"
    "$HOME/.tmux.conf"
    "$HOME/.gitconfig"
    "$HOME/.gitignore_global"
    "$HOME/.ssh/config"
    "$HOME/.config/kitty/kitty.conf"
    "$HOME/.config/starship.toml"
    "$HOME/.config/nvim"
)

# Remove symlinks and restore backups
for file in "${FILES[@]}"; do
    restore_file "$file"
done

# Clean up empty directories
log_info "Cleaning up empty directories..."
rmdir "$HOME/.config/kitty" 2>/dev/null || true
rmdir "$HOME/.config" 2>/dev/null || true

log_success "Dotfiles uninstallation completed!"
log_info "Your original configurations have been restored from .bak files"
log_warning "Please restart your shell or source your restored .bashrc"