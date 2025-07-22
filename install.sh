#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Base directory of your dotfiles repo
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    
    local missing_deps=()
    
    if ! command_exists git; then
        missing_deps+=("git")
    fi
    
    if ! command_exists nvim; then
        log_warning "Neovim not found. Install it for full functionality."
    fi
    
    if ! command_exists tmux; then
        log_warning "Tmux not found. Install it for terminal multiplexing."
    fi
    
    if ! command_exists starship; then
        log_warning "Starship not found. Install it for enhanced prompt."
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_error "Please install them and run the script again."
        exit 1
    fi
    
    log_success "Dependencies check completed"
}

# Function to create symlink if not exists or update if needed
link_file() {
    local src="$1"
    local dest="$2"
    local dest_dir="$(dirname "$dest")"

    # Create destination directory if it doesn't exist
    if [ ! -d "$dest_dir" ]; then
        log_info "Creating directory: $dest_dir"
        mkdir -p "$dest_dir"
    fi

    if [ -L "$dest" ]; then
        local current_target="$(readlink "$dest")"
        if [ "$current_target" = "$src" ]; then
            log_info "Symlink $dest already points to correct target"
            return 0
        else
            log_warning "Symlink $dest points to different target: $current_target"
            log_info "Updating symlink to point to: $src"
            rm "$dest"
            ln -s "$src" "$dest"
            log_success "Updated symlink: $src -> $dest"
        fi
    elif [ -e "$dest" ]; then
        log_warning "File exists: $dest"
        log_info "Backing up to: ${dest}.bak"
        mv "$dest" "${dest}.bak"
        ln -s "$src" "$dest"
        log_success "Linked: $src -> $dest"
    else
        ln -s "$src" "$dest"
        log_success "Linked: $src -> $dest"
    fi
}

# Function to link directory
link_directory() {
    local src="$1"
    local dest="$2"
    local dest_parent="$(dirname "$dest")"

    # Create parent directory if it doesn't exist
    if [ ! -d "$dest_parent" ]; then
        log_info "Creating directory: $dest_parent"
        mkdir -p "$dest_parent"
    fi

    if [ -L "$dest" ]; then
        local current_target="$(readlink "$dest")"
        if [ "$current_target" = "$src" ]; then
            log_info "Directory symlink $dest already points to correct target"
            return 0
        else
            log_warning "Directory symlink $dest points to different target: $current_target"
            log_info "Updating symlink to point to: $src"
            rm "$dest"
            ln -s "$src" "$dest"
            log_success "Updated directory symlink: $src -> $dest"
        fi
    elif [ -e "$dest" ]; then
        log_warning "Directory exists: $dest"
        log_info "Backing up to: ${dest}.bak"
        mv "$dest" "${dest}.bak"
        ln -s "$src" "$dest"
        log_success "Linked directory: $src -> $dest"
    else
        ln -s "$src" "$dest"
        log_success "Linked directory: $src -> $dest"
    fi
}

main() {
    log_info "Starting dotfiles installation..."
    
    # Check dependencies first
    check_dependencies
    
    # 1. Symlink tmux config
    log_info "Setting up tmux configuration..."
    link_file "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
    
    # 2. Symlink bashrc
    log_info "Setting up bash configuration..."
    link_file "$DOTFILES_DIR/bashrc/.bashrc" "$HOME/.bashrc"
    
    # 3. Symlink shell aliases and functions
    if [ -f "$DOTFILES_DIR/shell/aliases" ]; then
        link_file "$DOTFILES_DIR/shell/aliases" "$HOME/.aliases"
    fi
    
    if [ -f "$DOTFILES_DIR/shell/functions" ]; then
        link_file "$DOTFILES_DIR/shell/functions" "$HOME/.functions"
    fi
    
    if [ -f "$DOTFILES_DIR/shell/exports" ]; then
        link_file "$DOTFILES_DIR/shell/exports" "$HOME/.exports"
    fi
    
    # 4. Symlink kitty config
    log_info "Setting up kitty configuration..."
    link_file "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
    
    # 5. Symlink starship config
    log_info "Setting up starship configuration..."
    link_file "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
    
    # 6. Symlink nvim config folder
    log_info "Setting up neovim configuration..."
    link_directory "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
    
    # 7. Symlink git config
    if [ -f "$DOTFILES_DIR/git/.gitconfig" ]; then
        log_info "Setting up git configuration..."
        link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
    fi
    
    if [ -f "$DOTFILES_DIR/git/.gitignore_global" ]; then
        link_file "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global"
    fi
    
    # 8. Symlink SSH config
    if [ -f "$DOTFILES_DIR/ssh/config" ]; then
        log_info "Setting up SSH configuration..."
        link_file "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"
        chmod 600 "$HOME/.ssh/config" 2>/dev/null || true
    fi
    
    # 9. Install TPM (tmux plugin manager) if not installed
    if command_exists tmux; then
        if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
            log_info "Installing TPM (Tmux Plugin Manager)..."
            git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
            log_success "TPM installed successfully"
        else
            log_info "TPM already installed"
        fi
    fi
    
    # 10. Source bashrc to apply changes
    log_info "Applying bash configuration changes..."
    if [ -f "$HOME/.bashrc" ]; then
        # Note: This only affects the current shell, user needs to restart or source manually
        log_info "Please run 'source ~/.bashrc' or restart your shell to apply changes"
    fi
    
    log_success "Dotfiles installation completed successfully!"
    log_info "Next steps:"
    log_info "  1. Restart your terminal or run: source ~/.bashrc"
    log_info "  2. Open tmux and press prefix + I to install tmux plugins"
    log_info "  3. Open neovim to let LazyVim install plugins automatically"
}

# Run main function
main "$@"
