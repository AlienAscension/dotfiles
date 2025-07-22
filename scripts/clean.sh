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

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

log_info "Starting cleanup process..."

# Clean up backup files
log_info "Cleaning up backup files..."
find "$HOME" -name "*.bak" -type f -path "$HOME/.*" 2>/dev/null | while read -r file; do
    log_info "Found backup file: $file"
    read -p "Remove $file? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "$file"
        log_success "Removed: $file"
    fi
done

# Clean up old dotfiles backups (older than 30 days)
log_info "Cleaning up old dotfiles backups..."
find "$HOME" -name ".dotfiles-backup-*" -type d -mtime +30 2>/dev/null | while read -r dir; do
    log_info "Found old backup directory: $dir"
    read -p "Remove $dir? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$dir"
        log_success "Removed: $dir"
    fi
done

# Clean up neovim cache and logs
if command_exists nvim; then
    log_info "Cleaning up neovim cache..."
    
    # Clean lazy.nvim cache
    if [ -d "$HOME/.local/share/nvim/lazy" ]; then
        log_info "Cleaning lazy.nvim cache..."
        rm -rf "$HOME/.local/share/nvim/lazy/cache"
        log_success "Cleaned lazy.nvim cache"
    fi
    
    # Clean neovim logs
    if [ -d "$HOME/.local/state/nvim" ]; then
        log_info "Cleaning neovim logs..."
        rm -f "$HOME/.local/state/nvim/log"
        log_success "Cleaned neovim logs"
    fi
    
    # Clean neovim swap files
    if [ -d "$HOME/.local/state/nvim/swap" ]; then
        log_info "Cleaning neovim swap files..."
        rm -f "$HOME/.local/state/nvim/swap"/*
        log_success "Cleaned neovim swap files"
    fi
fi

# Clean up tmux logs and temporary files
if command_exists tmux; then
    log_info "Cleaning up tmux temporary files..."
    
    # Clean tmux server logs
    rm -f /tmp/tmux-*/default 2>/dev/null || true
    
    # Clean old tmux sessions
    if [ -d "$HOME/.tmux" ]; then
        find "$HOME/.tmux" -name "*.log" -type f -mtime +7 -delete 2>/dev/null || true
        log_success "Cleaned tmux logs"
    fi
fi

# Clean up shell history duplicates
log_info "Cleaning up shell history..."
if [ -f "$HOME/.bash_history" ]; then
    # Remove duplicates from bash history
    awk '!seen[$0]++' "$HOME/.bash_history" > "$HOME/.bash_history.tmp" && mv "$HOME/.bash_history.tmp" "$HOME/.bash_history"
    log_success "Cleaned bash history duplicates"
fi

# Clean up git cache
if command_exists git; then
    log_info "Cleaning up git cache..."
    git gc --auto 2>/dev/null || true
    log_success "Cleaned git cache"
fi

# Clean up package manager caches
log_info "Cleaning up package manager caches..."

# Clean pacman cache (Arch Linux)
if command_exists pacman; then
    log_info "Found pacman, cleaning package cache..."
    sudo pacman -Sc --noconfirm 2>/dev/null || true
    log_success "Cleaned pacman cache"
fi

# Clean apt cache (Ubuntu/Debian)
if command_exists apt; then
    log_info "Found apt, cleaning package cache..."
    sudo apt autoremove -y 2>/dev/null || true
    sudo apt autoclean 2>/dev/null || true
    log_success "Cleaned apt cache"
fi

# Clean up temporary files
log_info "Cleaning up temporary files..."
rm -rf /tmp/nvim.* 2>/dev/null || true
rm -rf /tmp/tmux-* 2>/dev/null || true

# Clean up broken symlinks
log_info "Checking for broken symlinks..."
find "$HOME" -maxdepth 3 -type l ! -exec test -e {} \; -print 2>/dev/null | while read -r link; do
    log_warning "Found broken symlink: $link"
    read -p "Remove broken symlink $link? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "$link"
        log_success "Removed broken symlink: $link"
    fi
done

# Clean up empty directories
log_info "Cleaning up empty directories..."
find "$HOME/.config" -type d -empty -delete 2>/dev/null || true
find "$HOME/.local/share" -type d -empty -delete 2>/dev/null || true
find "$HOME/.cache" -type d -empty -delete 2>/dev/null || true

log_success "Cleanup completed successfully!"
log_info "Your system has been cleaned up and optimized."