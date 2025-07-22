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

# Create backup directory with timestamp
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

log_info "Creating backup directory: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Files to backup
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

# Backup existing files
for file in "${FILES[@]}"; do
    if [ -e "$file" ]; then
        log_info "Backing up: $file"
        
        # Create directory structure in backup
        backup_path="$BACKUP_DIR$(dirname "$file")"
        mkdir -p "$backup_path"
        
        # Copy file or directory
        if [ -d "$file" ]; then
            cp -r "$file" "$backup_path/"
        else
            cp "$file" "$backup_path/"
        fi
        
        log_success "Backed up: $file"
    else
        log_warning "File not found, skipping: $file"
    fi
done

# Create backup manifest
cat > "$BACKUP_DIR/manifest.txt" << EOF
Dotfiles Backup Manifest
========================
Created: $(date)
Backup Directory: $BACKUP_DIR

Files backed up:
EOF

for file in "${FILES[@]}"; do
    if [ -e "$file" ]; then
        echo "✓ $file" >> "$BACKUP_DIR/manifest.txt"
    else
        echo "✗ $file (not found)" >> "$BACKUP_DIR/manifest.txt"
    fi
done

log_success "Backup completed successfully!"
log_info "Backup location: $BACKUP_DIR"
log_info "To restore from backup, run: ./scripts/restore.sh $BACKUP_DIR"