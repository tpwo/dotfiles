# Default recipe: show help
help:
	just --list

# Sync dotfiles to $HOME using GNU Stow
sync: _check-stow
	stow --target=$HOME dotfiles

# Remove symlinks from $HOME
clean: _check-stow
	stow --delete --target=$HOME dotfiles

# Internal check for GNU Stow installation
_check-stow:
	@command -v stow >/dev/null 2>&1 || { \
		echo "Error: GNU Stow is not installed."; \
		echo "Install it using:"; \
		echo "  macOS: brew install stow"; \
		echo "  Linux: sudo apt install stow"; \
		exit 1; \
	}
