# Dotfiles

This repository manages my dotfiles using **GNU Stow**.

The core idea is to keep configuration files in a central repository (e.g., `~/ws/dotfiles`) and symlink only the contents of the `dotfiles/` directory to `$HOME`.

## Quick Start

1. Clone this repository to your preferred location:
   ```bash
   git clone https://github.com/tpwo/dotfiles.git ~/ws/private/repos/tpwo/dotfiles
   cd ~/ws/private/repos/tpwo/dotfiles
   ```
2. Ensure you have `stow` and `just` installed.
3. Deploy the dotfiles:
   ```bash
   just sync
   ```

## Workflow

- **Sync**: Run `just sync` to create symlinks from the `dotfiles/` directory to your `$HOME`.
- **Clean**: Run `just clean` to remove the symlinks from `$HOME`.
- **Help**: Run `just` to see available recipes.
- **Git Config**: To add machine-specific Git overrides (e.g., disabling GPG signing on a server), create a `~/.gitconfig.local` file. It will be automatically included by `dotfiles/.gitconfig`.

## Structure

- `dotfiles/`: Contains the actual configuration files (mirrored to `$HOME`).
- `justfile`: Automation for managing the symlinks.
- Root level helpers (`README.md`, `LICENSE`, etc.) stay isolated in the repository and do not clutter your `$HOME`.
