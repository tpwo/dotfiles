# Project Overview

This repository manages **dotfiles** using **GNU Stow**. It's designed to be used across multiple platforms, including **macOS**, **WSL2**, and **Linux**.

The core idea is to keep configuration files in a central repository and symlink only the contents of the `dotfiles/` directory to the user's `$HOME`.

## Project Structure

- `justfile`: Automation for syncing and cleaning symlinks.
- `dotfiles/`: Contains the actual configuration files that are symlinked to `$HOME`.

## Building and Running (Setup)

To set up the dotfiles on a new Unix-like system:
1. Clone the repository to your preferred workspace (e.g., `~/ws/private/repos/tpwo/dotfiles`).
2. Ensure `stow` and `just` are installed.
3. Run `just dry-run` from the repository root to see planned changes.
4. Run `just adopt` to create symlinks in `$HOME` and adopt any local changes.
5. Run `just sync` to sync any new symlinks.
6. Run `just clean` to clean all symlinks (they have to be recreated at `$HOME`).

## Key Utilities

`just` targets:

```shell
$ just --list
Available recipes:
    adopt   # Move existing dotfiles from $HOME into this repo and symlink them back into $HOME
    clean   # Remove symlinks from $HOME; NOTE that you have to manually add your dotfiles back into $HOME
    dry-run # See changes which would be done by `just adopt`
    sync    # Sync dotfiles to $HOME
```

Many custom functions and bash aliases are prefixed with a comma (`,`) for easy discovery and to avoid name collisions:

## Development Conventions

- **Branching**: The `main` branch should be the only branch used in the wild
- **Commit Messages**: Use **Conventional Commits** (`feat:`, `fix:`, `chore:`, etc.) with proper scope narrowing e.g. `fix(bash)`, `feat(git)`
