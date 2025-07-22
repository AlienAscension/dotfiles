# Dotfiles

A comprehensive collection of configuration files for a productive development environment on Linux.

## Features

- **Neovim**: LazyVim-based configuration with modern plugins
- **Tmux**: Feature-rich terminal multiplexer with plugins
- **Kitty**: GPU-accelerated terminal emulator
- **Starship**: Cross-shell prompt with git integration
- **Bash**: Enhanced shell with aliases and functions
- **Git**: Global configuration and ignore patterns

## Quick Install

```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
```

## Manual Install

```bash
./install.sh
```

## What's Included

### Terminal & Shell
- **Kitty**: Modern terminal with ligatures and themes
- **Bash**: Custom `.bashrc` with aliases, functions, and environment setup
- **Starship**: Beautiful cross-shell prompt

### Development Tools
- **Neovim**: LazyVim configuration with LSP, treesitter, and modern plugins
- **Tmux**: Configured with useful plugins and keybindings
- **Git**: Global configuration with aliases and ignore patterns

### Key Features
- Neovim set as default editor (`$EDITOR` and `v` alias)
- Automatic backup of existing configurations
- Cross-platform compatibility
- Plugin management automation
- Sync capabilities for multiple machines

## Configuration Details

### Neovim
- Based on LazyVim for modern Neovim experience
- LSP support for multiple languages
- Treesitter for syntax highlighting
- Telescope for fuzzy finding
- Which-key for keybinding discovery

### Tmux
- Prefix key: `Ctrl-A`
- Mouse support enabled
- Plugin manager (TPM) with useful plugins
- Session management with sessionx
- Floating terminal with floax

### Aliases & Functions
- `v` - Opens Neovim (default editor)
- `ll`, `la`, `l` - Enhanced ls commands
- Git shortcuts and utilities
- Development workflow helpers

## Commands

```bash
make install    # Install all configurations
make backup     # Backup current configurations
make update     # Update configurations and plugins
make uninstall  # Remove symlinks and restore backups
make sync       # Sync with remote repository
make validate   # Validate configurations
```

## Dependencies

### Required
- Git
- Bash
- Neovim (>= 0.9.0)

### Optional
- Tmux
- Kitty terminal
- Starship prompt
- Ripgrep (for better search)
- Fd (for better find)

## Customization

1. Fork this repository
2. Modify configurations in respective directories
3. Update `install.sh` if adding new configurations
4. Test with `make validate`

## Backup & Restore

Existing configurations are automatically backed up with `.bak` extension during installation. To restore:

```bash
make uninstall  # Removes symlinks and restores backups
```

## Troubleshooting

### Common Issues
- **Permission denied**: Ensure scripts are executable (`chmod +x install.sh`)
- **Missing dependencies**: Install required tools listed above
- **Symlink conflicts**: Use `make backup` before installation

### Validation
Run `make validate` to check configuration integrity.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see LICENSE file for details.