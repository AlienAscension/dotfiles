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

# Detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/redhat-release ]; then
        echo "rhel"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    else
        echo "unknown"
    fi
}

# Get package manager
get_package_manager() {
    local os="$1"
    case "$os" in
        arch|manjaro) echo "pacman" ;;
        ubuntu|debian|pop) echo "apt" ;;
        fedora|rhel|centos) echo "dnf" ;;
        opensuse*) echo "zypper" ;;
        *) echo "unknown" ;;
    esac
}

# Get install command
get_install_cmd() {
    local pm="$1"
    case "$pm" in
        pacman) echo "sudo pacman -S" ;;
        apt) echo "sudo apt install" ;;
        dnf) echo "sudo dnf install" ;;
        zypper) echo "sudo zypper install" ;;
        *) echo "unknown" ;;
    esac
}

log_info "Checking system dependencies..."

OS=$(detect_os)
PM=$(get_package_manager "$OS")
INSTALL_CMD=$(get_install_cmd "$PM")

log_info "Detected OS: $OS"
log_info "Package manager: $PM"

echo ""

# Required dependencies
log_info "Checking required dependencies..."

declare -A REQUIRED_DEPS=(
    ["git"]="git"
    ["bash"]="bash"
)

declare -A RECOMMENDED_DEPS=(
    ["nvim"]="neovim"
    ["tmux"]="tmux"
    ["starship"]="starship"
    ["curl"]="curl"
    ["wget"]="wget"
)

declare -A OPTIONAL_DEPS=(
    ["rg"]="ripgrep"
    ["fd"]="fd"
    ["bat"]="bat"
    ["exa"]="exa"
    ["fzf"]="fzf"
    ["tree"]="tree"
    ["htop"]="htop"
    ["jq"]="jq"
)

# Check required dependencies
missing_required=()
for cmd in "${!REQUIRED_DEPS[@]}"; do
    if command_exists "$cmd"; then
        log_success "✓ $cmd (${REQUIRED_DEPS[$cmd]})"
    else
        log_error "✗ $cmd (${REQUIRED_DEPS[$cmd]}) - REQUIRED"
        missing_required+=("${REQUIRED_DEPS[$cmd]}")
    fi
done

echo ""

# Check recommended dependencies
missing_recommended=()
for cmd in "${!RECOMMENDED_DEPS[@]}"; do
    if command_exists "$cmd"; then
        log_success "✓ $cmd (${RECOMMENDED_DEPS[$cmd]})"
    else
        log_warning "⚠ $cmd (${RECOMMENDED_DEPS[$cmd]}) - RECOMMENDED"
        missing_recommended+=("${RECOMMENDED_DEPS[$cmd]}")
    fi
done

echo ""

# Check optional dependencies
missing_optional=()
for cmd in "${!OPTIONAL_DEPS[@]}"; do
    if command_exists "$cmd"; then
        log_success "✓ $cmd (${OPTIONAL_DEPS[$cmd]})"
    else
        log_info "○ $cmd (${OPTIONAL_DEPS[$cmd]}) - OPTIONAL"
        missing_optional+=("${OPTIONAL_DEPS[$cmd]}")
    fi
done

echo ""

# Installation suggestions
if [ ${#missing_required[@]} -gt 0 ]; then
    log_error "Missing required dependencies!"
    echo "Install with: $INSTALL_CMD ${missing_required[*]}"
    echo ""
fi

if [ ${#missing_recommended[@]} -gt 0 ]; then
    log_warning "Missing recommended dependencies:"
    echo "Install with: $INSTALL_CMD ${missing_recommended[*]}"
    echo ""
fi

if [ ${#missing_optional[@]} -gt 0 ]; then
    log_info "Optional dependencies that enhance the experience:"
    echo "Install with: $INSTALL_CMD ${missing_optional[*]}"
    echo ""
fi

# Special installation notes
log_info "Special installation notes:"

# Starship
if ! command_exists starship; then
    echo "• Starship: Install via curl -sS https://starship.rs/install.sh | sh"
fi

# Neovim version check
if command_exists nvim; then
    nvim_version=$(nvim --version | head -n1 | grep -o 'v[0-9]\+\.[0-9]\+' | sed 's/v//')
    required_version="0.9"
    if [ "$(printf '%s\n' "$required_version" "$nvim_version" | sort -V | head -n1)" = "$required_version" ]; then
        log_success "Neovim version $nvim_version is compatible"
    else
        log_warning "Neovim version $nvim_version may be too old (recommend $required_version+)"
    fi
fi

# Node.js for some neovim plugins
if ! command_exists node; then
    echo "• Node.js: Some neovim plugins require Node.js"
    echo "  Install via your package manager or https://nodejs.org/"
fi

# Python for some neovim plugins
if ! command_exists python3; then
    echo "• Python 3: Some neovim plugins require Python 3"
    echo "  Install via your package manager"
fi

echo ""

# Summary
if [ ${#missing_required[@]} -eq 0 ]; then
    log_success "All required dependencies are installed!"
    if [ ${#missing_recommended[@]} -eq 0 ]; then
        log_success "All recommended dependencies are installed!"
        log_info "You're ready to install the dotfiles!"
    else
        log_warning "Some recommended dependencies are missing, but you can proceed with installation."
    fi
else
    log_error "Please install the missing required dependencies before proceeding."
    exit 1
fi