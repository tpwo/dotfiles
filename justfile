# Show this help message
_help:
	just --list

# See changes which would be done by `just adopt`
dry-run: _check-stow
	stow --verbose=2 --simulate --adopt --target=$HOME dotfiles

# Move existing dotfiles from $HOME into this repo and symlink them back into $HOME
adopt: _check-stow
	stow --verbose=2 --adopt --target=$HOME dotfiles

# Sync dotfiles to $HOME
sync: _check-stow
	stow --verbose=2 --target=$HOME dotfiles

# Remove symlinks from $HOME; NOTE that you have to manually add your dotfiles back into $HOME
clean: _check-stow
	stow --verbose=2 --delete --target=$HOME dotfiles

# Check for GNU Stow installation
_check-stow:
	@command -v stow >/dev/null 2>&1 || { \
		echo "Error: GNU Stow is not installed."; \
		echo "Install it using:"; \
		echo "  macOS: brew install stow"; \
		echo "  Linux: sudo apt install stow"; \
		exit 1; \
	}
