# My dotfiles

This repo manages my dotfiles using **GNU Stow**.

The core idea is to keep configuration files in a central repository (e.g., `~/repos/dotfiles`) and symlink only the contents of the [dotfiles](dotfiles) directory to `$HOME`.

## Quick Start

1. Ensure you have `stow` and `just` installed.

2. Clone this repository to your preferred location:

   ```bash
   git clone https://github.com/tpwo/dotfiles.git ~/ws/private/repos/tpwo/dotfiles
   cd ~/ws/private/repos/tpwo/dotfiles
   ```

3. Run `just dry-run` to see if stow works correctly and see what will be done.

4. Use `just adopt` to symlink dotfiles stored in this repo while preserving any changes you might have locally.

5. Run `git status` to see if any of the files in the repo were affected. They are now reflecting what you had back at your `$HOME`.

   > [!WARNING]
   > `stow` already symlinked your `$HOME`, so editing files in `dotfiles` folder now affects files at your `$HOME`.

6. Voilà! All files from [dotfiles](dotfiles) folder should now be symlinked into your `$HOME`.

## Workflow

When you add any new dotfile to this repo, you can sync it with `just sync `.

Get rid of symlinks with `just clean`.

> [!IMPORTANT]
> `just clean` only deletes the symlinks, so you have to manually add your dotfiles back into $HOME.

## Machine-specific overrides

### Git

Create a `~/.gitconfig.local` file. It will be automatically imported by [.gitconfig](dotfiles/.gitconfig) stored in this repo.
