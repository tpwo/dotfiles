# Dotfiles

**For my actual dotfiles check git branches.**

My solution uses Git repo which is set directly in the home directory
which is very simple to setup, and I can easily update the files without
the need to pull the changes later.

I have one main configuration which is based on WSL2 and other
configurations which are commits added after the newest commit on WSL2
branch. With each new commit on WSL2 there are many rebases and force
pushes which I automated a bit.

This solution has its issues, but was pretty easy to set up, and that's
why we're here...

## Basic config

*Adopted from the article from [Arch
Wiki](https://wiki.archlinux.org/index.php/Dotfiles)*

By configuring the Git according to the above article it is possible to
have the home directory in Git with only explicitly added files and
use alias `,cfg` to perform common Git commands.

Run `setup` to configure it and switch to wsl branch.

The remaining part is adding to your `.bashrc`:

```bash
alias ,cfg='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

## Windows config

The configuration for Windows is different as setting up a working alias
requires defining a function inside user's
`~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1`. Also,
Powershell doesn't support comma as a prefix, and that's why we use
`config` instead. Put the following to your PowerShell profile:

```powershell
function config {
    git --git-dir=$HOME\.dotfiles\ --work-tree=$HOME $args
}
```
