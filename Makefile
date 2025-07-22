.PHONY: help install backup update uninstall sync validate clean test

# Default target
help: ## Show this help message
	@echo "Dotfiles Management"
	@echo "=================="
	@echo ""
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Install all dotfiles configurations
	@echo "Installing dotfiles..."
	@./install.sh

backup: ## Backup existing configurations
	@echo "Creating backup of existing configurations..."
	@./scripts/backup.sh

update: ## Update configurations and plugins
	@echo "Updating dotfiles and plugins..."
	@git pull origin main
	@./scripts/update.sh

uninstall: ## Remove symlinks and restore backups
	@echo "Uninstalling dotfiles..."
	@./scripts/uninstall.sh

sync: ## Sync with remote repository
	@echo "Syncing with remote repository..."
	@git add -A
	@git status
	@echo "Run 'git commit -m \"message\"' and 'git push' to sync changes"

validate: ## Validate configurations
	@echo "Validating configurations..."
	@./scripts/validate.sh

clean: ## Clean up temporary files and caches
	@echo "Cleaning up..."
	@./scripts/clean.sh

test: ## Test configurations in a safe environment
	@echo "Testing configurations..."
	@./scripts/test.sh

# Development targets
dev-setup: ## Set up development environment
	@echo "Setting up development environment..."
	@chmod +x install.sh
	@chmod +x scripts/*.sh

# Plugin management
tmux-plugins: ## Install/update tmux plugins
	@echo "Installing tmux plugins..."
	@if [ -d "$$HOME/.tmux/plugins/tpm" ]; then \
		$$HOME/.tmux/plugins/tpm/bin/install_plugins; \
		$$HOME/.tmux/plugins/tpm/bin/update_plugins all; \
	else \
		echo "TPM not installed. Run 'make install' first."; \
	fi

nvim-plugins: ## Update neovim plugins
	@echo "Updating neovim plugins..."
	@nvim --headless "+Lazy! sync" +qa

# System-specific targets
arch: ## Install on Arch Linux with system packages
	@echo "Installing system packages for Arch Linux..."
	@sudo pacman -S --needed neovim tmux kitty git starship ripgrep fd bat exa
	@make install

ubuntu: ## Install on Ubuntu with system packages
	@echo "Installing system packages for Ubuntu..."
	@sudo apt update
	@sudo apt install -y neovim tmux git curl
	@make install

# Maintenance
check-deps: ## Check for required dependencies
	@echo "Checking dependencies..."
	@./scripts/check-deps.sh

doctor: ## Run comprehensive health check
	@echo "Running dotfiles health check..."
	@make validate
	@make check-deps

# Quick actions
quick-install: ## Quick install without backups (dangerous!)
	@echo "WARNING: This will overwrite existing configs without backup!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	@SKIP_BACKUP=1 ./install.sh

# Git helpers
commit: ## Add all changes and commit
	@git add -A
	@git status
	@echo "Enter commit message:"
	@read msg && git commit -m "$$msg"

push: ## Push changes to remote
	@git push origin main

pull: ## Pull latest changes
	@git pull origin main

status: ## Show git status
	@git status

# Documentation
docs: ## Generate documentation
	@echo "Generating documentation..."
	@./scripts/generate-docs.sh