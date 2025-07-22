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

log_info "Starting dotfiles update..."

# Update tmux plugins
if command_exists tmux && [ -d "$HOME/.tmux/plugins/tpm" ]; then
    log_info "Updating tmux plugins..."
    "$HOME/.tmux/plugins/tpm/bin/update_plugins" all
    log_success "Tmux plugins updated"
else
    log_warning "Tmux or TPM not found, skipping tmux plugin update"
fi

# Update neovim plugins
if command_exists nvim; then
    log_info "Updating neovim plugins..."
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || {
        log_warning "Failed to update neovim plugins automatically"
        log_info "Please open neovim and run :Lazy sync manually"
    }
    log_success "Neovim plugins updated"
else
    log_warning "Neovim not found, skipping plugin update"
fi

# Update starship if installed via package manager
if command_exists starship; then
    log_info "Starship is installed, consider updating it via your package manager"
fi

# Update other tools if they exist
if command_exists fzf; then
    log_info "FZF is installed, consider updating it via your package manager"
fi

if command_exists ripgrep || command_exists rg; then
    log_info "Ripgrep is installed, consider updating it via your package manager"
fi

if command_exists fd; then
    log_info "Fd is installed, consider updating it via your package manager"
fi

if command_exists bat; then
    log_info "Bat is installed, consider updating it via your package manager"
fi

if command_exists exa; then
    log_info "Exa is installed, consider updating it via your package manager"
fi

# Reload shell configuration
log_info "Reloading shell configuration..."
if [ -f "$HOME/.bashrc" ]; then
    log_info "Please run 'source ~/.bashrc' or restart your shell to apply updates"
fi

log_success "Update completed successfully!"
log_info "Next steps:"
log_info "  1. Restart your terminal or run: source ~/.bashrc"
log_info "  2. Open tmux and verify plugins are working"
log_info "  3. Open neovim to verify plugins are working"