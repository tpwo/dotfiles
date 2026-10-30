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

Many custom functions and bash aliases are prefixed with a comma (`,`) for easy discovery and to avoid name collisions. These are defined in [dotfiles/.bashrc](dotfiles/.bashrc).

## Development Conventions

- **Branching**: The `main` branch should be the only branch used in the wild

### Commit message format

Use [Conventional Commits](https://www.conventionalcommits.org/) formatting:

- Start the subject line with a type prefix: `docs:`, `fix:`, `chore:`, `test:`, `refactor:`, `feat:`, etc.
- Optionally scope the prefix (e.g., `refactor(fig):`, `fix(nvim):`); if the changes affect a single aspect, use the aspect name as the scope.
- The rest of the subject line should start with a verb in the imperative form; ie. "add", "teach", "fix" etc.
- Keep subject lines under 72 columns.
- In the commit body, hard-wrap to 80 columns.
- Use Markdown formatting for _bold_, _italics_, `code`, and fenced code blocks.
- Describe _what_ changed as concisely as possible; fit it in the subject if you can, but feel free to continue concisely in the body if fitting it all in the subject is not possible.
- Use the body to explain the motivation for the change was made and why the particular approach was chosen; you should include info on the alternatives considered, and why they were not chosen.

## Markup languages

When writing Markdown or AsciiDoc, do not hard-wrap long lines.
