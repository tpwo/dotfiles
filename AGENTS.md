# Project Overview

This repository manages **dotfiles** using **GNU Stow**. It's designed to be used across multiple platforms, including **macOS**, **WSL2**, and **Linux**.

The core idea is to keep configuration files in a central repository (e.g., `~/ws/private/repos/tpwo/dotfiles`) and symlink only the contents of the `dotfiles/` directory to the user's `$HOME`.

## Project Structure

- `justfile`: Automation for syncing and cleaning symlinks.
- `dotfiles/`: Contains the actual configuration files that are symlinked to `$HOME`.
  - `.bashrc`: Core shell configuration with platform detection, theme detection, and many custom utility functions (prefixed with `,`).
  - `.gitconfig`: Global Git configuration with useful aliases (`l`, `lg`, `llg`).
  - `.tmux.conf`, `.vim/vimrc`, `.ideavimrc`: Configurations for terminal multiplexer and editors.
  - `.local/bin/`: Custom scripts and utilities.

## Building and Running (Setup)

To set up the dotfiles on a new Unix-like system:
1. Clone the repository to your preferred workspace (e.g., `~/ws/private/repos/tpwo/dotfiles`).
2. Ensure `stow` and `just` are installed.
3. Run `just sync` from the repository root to create symlinks in `$HOME`.

## Key Utilities

Many custom functions and aliases are prefixed with a comma (`,`) for easy discovery and to avoid name collisions:
- `just sync`: Deploy dotfiles to `$HOME`.
- `just clean`: Remove symlinks from `$HOME`.
- `,pathprepend` / `,pathappend`: Safely modify `$PATH`.
- `,source-bashrc` (or `,.`): Reload shell configuration.
- `,fix-cursor`: Fixes cursor issues after exiting Neovim.

## Development Conventions

- **Branching**: The `wsl` branch is often the main source of truth, with other platform-specific configurations rebased on top of it.
- **Commit Messages**: Use **Conventional Commits** (`feat:`, `fix:`, `chore:`, etc.).
- **GPG Signing**: Git commits and tags are configured to be GPG-signed using SSH keys.
- **Python**: Use type annotations; avoid `typing.Any`.
