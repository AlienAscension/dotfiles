#!/usr/bin/env bash
set -e

echo "Starting dotfiles install..."

# Base directory of your dotfiles repo
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to create symlink if not exists or update if needed
link_file() {
  local src="$1"
  local dest="$2"

  if [ -L "$dest" ]; then
    echo "Symlink $dest already exists."
  elif [ -e "$dest" ]; then
    echo "Backing up existing file $dest to ${dest}.bak"
    mv "$dest" "${dest}.bak"
    ln -s "$src" "$dest"
    echo "Linked $src -> $dest"
  else
    ln -s "$src" "$dest"
    echo "Linked $src -> $dest"
  fi
}

# 1. Symlink tmux config
link_file "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# 2. Symlink bashrc
link_file "$DOTFILES_DIR/bashrc/.bashrc" "$HOME/.bashrc"

# 3. Symlink kitty config
link_file "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"

# 4. Symlink starship config
link_file "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

# 5. Symlink nvim config folder (assuming you want to use ~/.config/nvim)
if [ -d "$HOME/.config" ]; then
  mkdir -p "$HOME/.config"
  if [ -L "$HOME/.config/nvim" ]; then
    echo "Symlink ~/.config/nvim already exists."
  elif [ -e "$HOME/.config/nvim" ]; then
    echo "Backing up existing ~/.config/nvim to ~/.config/nvim.bak"
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
    ln -s "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
    echo "Linked nvim config folder."
  else
    ln -s "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
    echo "Linked nvim config folder."
  fi
else
  echo "~/.config does not exist. Creating and linking nvim config."
  mkdir -p "$HOME/.config"
  ln -s "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
fi

# 6. Install TPM (tmux plugin manager) if not installed
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "Installing TPM plugin manager..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
  echo "TPM already installed."
fi

echo "Dotfiles install complete."
