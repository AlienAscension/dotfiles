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

# Validation counters
ERRORS=0
WARNINGS=0
CHECKS=0

# Function to check file/symlink
check_file() {
    local file="$1"
    local description="$2"
    
    CHECKS=$((CHECKS + 1))
    
    if [ -L "$file" ]; then
        local target=$(readlink "$file")
        if [ -e "$target" ]; then
            log_success "$description: ✓ (symlink to $target)"
        else
            log_error "$description: ✗ (broken symlink to $target)"
            ERRORS=$((ERRORS + 1))
        fi
    elif [ -e "$file" ]; then
        log_warning "$description: ⚠ (exists but not a symlink)"
        WARNINGS=$((WARNINGS + 1))
    else
        log_error "$description: ✗ (missing)"
        ERRORS=$((ERRORS + 1))
    fi
}

# Function to check command
check_command() {
    local cmd="$1"
    local description="$2"
    
    CHECKS=$((CHECKS + 1))
    
    if command_exists "$cmd"; then
        local version=""
        case "$cmd" in
            nvim) version=$(nvim --version | head -n1) ;;
            tmux) version=$(tmux -V) ;;
            git) version=$(git --version) ;;
            starship) version=$(starship --version) ;;
            *) version="installed" ;;
        esac
        log_success "$description: ✓ ($version)"
    else
        log_warning "$description: ⚠ (not installed)"
        WARNINGS=$((WARNINGS + 1))
    fi
}

log_info "Starting dotfiles validation..."
echo ""

# Check core files
log_info "Checking core configuration files..."
check_file "$HOME/.bashrc" "Bash configuration"
check_file "$HOME/.aliases" "Shell aliases"
check_file "$HOME/.functions" "Shell functions"
check_file "$HOME/.exports" "Environment exports"
check_file "$HOME/.tmux.conf" "Tmux configuration"
check_file "$HOME/.gitconfig" "Git configuration"
check_file "$HOME/.gitignore_global" "Global gitignore"

echo ""

# Check application configs
log_info "Checking application configurations..."
check_file "$HOME/.config/nvim" "Neovim configuration"
check_file "$HOME/.config/kitty/kitty.conf" "Kitty configuration"
check_file "$HOME/.config/starship.toml" "Starship configuration"
check_file "$HOME/.ssh/config" "SSH configuration"

echo ""

# Check commands
log_info "Checking required commands..."
check_command "bash" "Bash shell"
check_command "git" "Git"
check_command "nvim" "Neovim"
check_command "tmux" "Tmux"
check_command "starship" "Starship prompt"

echo ""

# Check optional commands
log_info "Checking optional commands..."
check_command "rg" "Ripgrep"
check_command "fd" "Fd find"
check_command "bat" "Bat (better cat)"
check_command "exa" "Exa (better ls)"
check_command "fzf" "FZF fuzzy finder"

echo ""

# Check tmux plugins
log_info "Checking tmux plugins..."
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    log_success "TPM (Tmux Plugin Manager): ✓"
    
    # Check for some common plugins
    if [ -d "$HOME/.tmux/plugins/tmux-sensible" ]; then
        log_success "tmux-sensible plugin: ✓"
    else
        log_warning "tmux-sensible plugin: ⚠ (not installed)"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    log_error "TPM (Tmux Plugin Manager): ✗"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# Check neovim setup
log_info "Checking neovim setup..."
if command_exists nvim; then
    # Check if LazyVim is set up
    if [ -f "$HOME/.config/nvim/lua/config/lazy.lua" ]; then
        log_success "LazyVim configuration: ✓"
    else
        log_warning "LazyVim configuration: ⚠ (not found)"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    # Check neovim version
    nvim_version=$(nvim --version | head -n1 | grep -o 'v[0-9]\+\.[0-9]\+')
    if [[ "$nvim_version" > "v0.8" ]]; then
        log_success "Neovim version: ✓ ($nvim_version)"
    else
        log_warning "Neovim version: ⚠ ($nvim_version, recommend v0.9+)"
        WARNINGS=$((WARNINGS + 1))
    fi
fi

echo ""

# Check environment variables
log_info "Checking environment variables..."
if [ "$EDITOR" = "nvim" ]; then
    log_success "EDITOR environment variable: ✓ (set to nvim)"
else
    log_warning "EDITOR environment variable: ⚠ (not set to nvim, current: ${EDITOR:-unset})"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# Summary
log_info "Validation Summary"
echo "=================="
echo "Total checks: $CHECKS"
if [ $ERRORS -eq 0 ]; then
    log_success "Errors: $ERRORS"
else
    log_error "Errors: $ERRORS"
fi

if [ $WARNINGS -eq 0 ]; then
    log_success "Warnings: $WARNINGS"
else
    log_warning "Warnings: $WARNINGS"
fi

echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    log_success "All validations passed! Your dotfiles are properly configured."
    exit 0
elif [ $ERRORS -eq 0 ]; then
    log_warning "Validation completed with warnings. Your dotfiles are mostly configured correctly."
    exit 0
else
    log_error "Validation failed with errors. Please fix the issues above."
    exit 1
fi