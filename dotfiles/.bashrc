case $- in
*i*) ;; # Interactive
*) return ;;
esac

# ------------------------- Platform Detection -------------------------

export PLATFORM
if grep -q "microsoft" /proc/version &>/dev/null; then
  # There is no ideal way to detect WSL but this is often used:
  # https://github.com/microsoft/WSL/issues/423
  PLATFORM=wsl
else
  # Here I set it to Unix, but it's a big simplification. It's mainly done as
  # you usually don't want to compare strings in Bash when they can be empty.
  PLATFORM=unix
fi

# -------------------------- Theme Detection ---------------------------

export THEME
_get_theme() {
  if [[ "$PLATFORM" == 'wsl' ]]; then
    local winRoot='/mnt/c'
    local regKey='HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    local themeCmd="/c reg query $regKey /v AppsUseLightTheme"

    # - xargs is called to strip output from whitespace
    # - awk is used to select the last column of output
    # - '0x1'* is a partial match, as powershell also returns a newline
    #   along with 1 or 0
    if [[ $(cd $winRoot && /mnt/c/Windows/system32/cmd.exe "$themeCmd" | xargs | awk '{print $NF}') == '0x1'* ]]; then
      echo light
    else
      echo dark
    fi
  else  # Always return light on Unix which is good enough for now
    # This is currently treated as MacOS
    echo light
  fi
}
THEME=$(_get_theme)
unset -f _get_theme

# ---------------------- Local Utility Functions -----------------------

_have() { type "$1" &> /dev/null; }
_source_if() { test -r "$1" && . "$1"; }

,pathappend() {
  declare arg
  for arg in "$@"; do
    test -d "$arg" || continue
    PATH=${PATH//":$arg:"/:}
    PATH=${PATH/#"$arg:"/}
    PATH=${PATH/%":$arg"/}
    export PATH="${PATH:+"$PATH:"}$arg"
  done
} && export -f ,pathappend

,pathprepend() {
  for arg in "$@"; do
    test -d "$arg" || continue
    PATH=${PATH//:"$arg:"/:}
    PATH=${PATH/#"$arg:"/}
    PATH=${PATH/%":$arg"/}
    export PATH="$arg${PATH:+":${PATH}"}"
  done
} && export -f ,pathprepend

# ----------------------- Environment Variables ------------------------

# Use already set user or whoami output
# https://unix.stackexchange.com/a/286428/460142
export USER="${USER:-$(whoami)}"
export GITUSER=tpwo
export REPOS="$HOME/ws"
export USER="${USER:-$(whoami)}"
export GOPATH="$HOME/go"

# -------------------------------- PATH --------------------------------

_homebrew_prefix=/opt/homebrew

# Remember that the last arg will be first in PATH
,pathprepend \
  '/usr/local/texlive/2021/bin/x86_64-linux' \
  '/usr/local/go/bin' \
  '/opt/nvim-linux64/bin' \
  "$GOPATH/bin" \
  "$HOME/.cargo/bin" \
  "$HOME/.local/bin" \
  "$_homebrew_prefix/opt/coreutils/libexec/gnubin" \
  "$_homebrew_prefix/opt/findutils/libexec/gnubin" \
  "$_homebrew_prefix/opt/gnu-sed/libexec/gnubin" \
  "$_homebrew_prefix/bin" \
  :

# -------------------------------- EDITOR --------------------------------

# To see nvim installed with homebrew it has be be added to PATH first
if _have nvim; then
  export EDITOR=nvim
  export VISUAL=nvim
  export OPENER=nvim
elif _have vim; then
  export EDITOR=vim
  export VISUAL=vim
  export OPENER=vim
else
  export EDITOR=vi
  export VISUAL=vi
  export OPENER=vi
fi

# -------------------------------- GPG ---------------------------------

# Turn on GPG password prompt in terminal. Otherwise it cannot show a
# prompt, and signing fails on some platforms (e.g. WSL)
GPG_TTY=$(tty)
export GPG_TTY

# ----------------------------- dircolors ------------------------------

if _have dircolors; then
  if test -r ~/.dircolors; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
fi

# ------------------------- Bash Shell Options -------------------------

# Expand '**' to represent one or *more* directories
#
# MacOS ships with Bash v3.2 which doesn't work with it, so do an extra version
# check. I noticed that sometimes due to *various* reasons MacOS spawns Bash
# v3.2 process and without this check it hangs the shell (usually somewhere in
# the background). I noticed it in VS Code especially.
#
if [[ ${BASH_VERSINFO[0]} -ge 4 ]]; then
    shopt -s globstar
fi

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Set variable identifying the chroot you work in (used in the prompt below)
if [[ -z "${debian_chroot:-}" ]] && [[ -r /etc/debian_chroot ]]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
  WINDOWTITLE="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h:\w\a\]"
  ;;
*)
  ;;
esac

# -------------------------- Terminal Options --------------------------

stty stop undef # Disable <C-s> from freezing the terminal

# ------------------------------ History -------------------------------

HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# Update history with every new command:
# https://askubuntu.com/a/673283/1138715
PROMPT_COMMAND='history -a;history -n'

HISTSIZE=-1
HISTFILESIZE=-1

# ----------------------------- Completion -----------------------------

# Enable programmable completion features
if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    . /etc/bash_completion
  fi
fi

# MacOS completion installed via homebrew
#   brew install bash-completion@2
_source_if "$_homebrew_prefix/opt/bash-completion@2/etc/profile.d/bash_completion.sh"

if _have just; then
  eval "$(just --completions bash)"
fi

# --------------------------- Command Prompt ---------------------------

# High intensity green
_usercolor='\[\e[92m\]'

PS1=$WINDOWTITLE                # Set window title
PS1="$PS1"$_usercolor           # Set user@host color
PS1="$PS1"'\u@\h'               # User@host
PS1="$PS1"'\[\e[00m\]'          # Change to white
PS1="$PS1"':'                   # Colon
PS1="$PS1"'\[\e[36m\]'          # Change to cyan
PS1="$PS1"'\w '                 # Current working directory<space>
PS1="$PS1"'\[\e[91m\]'          # Change color to high intensity red

# Choose a better git branch parse mechanism. Also, make it bulletproof to
# `sudo su`, as switching to root starts with a clean shell, but doesn't clean
# PS1 env var resulting in errors like `sh: __git_ps1: command not found`
if _have __git_ps1; then
    PS1="$PS1"'$(type __git_ps1 &>/dev/null && __git_ps1 %s)'
else
    # This also works pretty well on modern versions of git, but __git_ps1 is
    # better during rebases where it shows on which commit are we, and how many
    # are to go.
    __parse_git_branch() {
         git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
    }
    PS1="$PS1"'$(type __parse_git_branch &>/dev/null && __parse_git_branch %s)'
fi

PS1="$PS1"'\[\e[00m\]'$'\n'     # New line with special syntax:
                                # https://stackoverflow.com/q/35897021/14458327
PS1="$PS1"'$ '                  # Prompt: always $

# ------------------------------- Pager --------------------------------

# Make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

if _have nvim; then
  export MANPAGER="nvim --clean --cmd 'set clipboard=unnamedplus' +Man!"
elif _have vim; then
  export MANPAGER="vim --clean --cmd 'set clipboard=unnamedplus' -M +MANPAGER -"
fi

# ------------------------------ Aliases -------------------------------

# Typos I make way too often
alias sl=ls
alias gti=git

if _have vim; then
  alias vi=vim
fi

if _have nvim; then
  alias vi=nvim
  alias vim=nvim
fi

if _have log2ram; then
  alias ,log2ram-stats='df -hT \
  | grep log2ram \
  | awk '\''{print " Name: " $1 "\nMount: " $7 "\n Type: " $2 "\nUsage: " $6 "\n Size: " $3 "\n Used: " $4 "\n Free: " $5}'\'''
fi

alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -v'
alias mkdir='mkdir -pv'

alias ls='ls --color=auto --group-directories-first'
alias ll='ls -alFh'
alias la='ls -A'
alias ,lm='ls -t -1'
alias ,lt='ls -hsSF -1'
alias ,l='ls -CF'

alias grep='grep --color=auto'

alias diff='git diff --no-index'
alias wdiff='git diff --no-index --word-diff'

alias untar='tar -vxzf'
alias sha='shasum -a 256'

alias zulu='date -u +%Y%m%d%H%M%S'

# Automatically fix cursor which is broken after quitting nvim.
# I observed it on macOS and WSL, and this solution works.
alias ,fix-cursor='printf "\e[5 q"'
export PS1="$(,fix-cursor)$PS1"

# Alias for freeing cached RAM:
# - option 3 does the kernel release pagecache, dentries and inodes
# - option 1 is only released pagecache, 2 inodes and frees pagecache
#
# More info for WSL2:
# https://devblogs.microsoft.com/commandline/memory-reclaim-in-the-windows-subsystem-for-linux-2/
alias ,drop-caches='sudo sysctl vm.drop_caches=3'

alias ,source-bashrc='. ~/.bashrc'
alias ,.=,source-bashrc

# Unix, macOS and WSL aliases
alias tmux='tmux -u'
alias ac='. venv/bin/activate'

alias up='sudo apt update && sudo apt upgrade -y'

# WSL only
if [[ "$PLATFORM" == 'wsl' ]]; then
  alias ssh='/mnt/c/Windows/System32/OpenSSH/ssh.exe'
  alias exp='/mnt/c/Windows/explorer.exe .'
  alias code='/mnt/c/Program\ Files/Microsoft\ VS\ Code/bin/code'
fi

# ----------------------------- Functions ------------------------------

,dedup-hist() {
  # Removes duplicates from .bash_history file.
  #
  # Based on https://unix.stackexchange.com/a/78846/460142
  #
  # - 'tac' is used to invert input, so only the *last* entry is preserved
  # - 'sed' is used to strip whitespace so similar entries can be merged together
  #
  set -euo pipefail

  \mkdir -p ~/.local/state/dedup-hist

  local timestamp=$(date -u '+%Y-%m-%d_%H:%M:%S')
  local bkpfile=~/.local/state/dedup-hist/bash_history_"$timestamp".bkp
  local tempfile=~/.local/state/dedup-hist/bash_history_"$timestamp".dedup.tmp


  echo 'Before:'
  wc --lines $HISTFILE

  \cp $HISTFILE $bkpfile
  touch $tempfile

  tac $HISTFILE | sed 's/\s*$//' | awk '!x[$0]++' | tac > $tempfile
  \cp $tempfile $HISTFILE

  echo 'After:'
  wc --lines $HISTFILE

  set +euo pipefail
} && export -f ,dedup-hist

,add-last-commit-to-ignore-revs() {
  # Adds last commit with its title to `.git-blame-ignore-revs` file used by
  # Git blame to ignore certain revisions. It's a good idea to include bigger
  # noisy changes like formatting updates or renames etc. in this file.
  #
  # File is named like that by convention.
  #
  file='.git-blame-ignore-revs'
  echo >> $file
  echo -n '# ' >> $file
  git show -s --format='%s' >> $file
  git show -s --format='%H' >> $file
  git add $file
  git commit --message 'Update ignored revs'
  git show
}

,install-just() {
  curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin
}

,install-golang() {
  # Get the newest version tag from:
  # https://go.dev/dl
  local version='1.23.2'
  local filename=go"$version".linux-amd64.tar.gz
  set -euxo pipefail
  curl --location --remote-name --silent \
    https://go.dev/dl/$filename
  sudo rm -rf /usr/local/go
  sudo tar --directory /usr/local -xzf $filename
  rm $filename
  set +euxo pipefail
}

,install-nvim() {
  local filename='nvim-linux64.tar.gz'
  set -euxo pipefail
  curl --location --remote-name --silent \
    https://github.com/neovim/neovim/releases/latest/download/$filename
  sudo rm -rf /opt/${filename%'.tar.gz'}
  sudo tar --directory /opt -xzf $filename
  rm $filename
  set +euxo pipefail
}

if _have pyzet; then
  eval "$(register-python-argcomplete pyzet)"

  alias ,pzg='pyzet grep -it'
  ,pzgx() { pyzet grep -it "$@" -- -B 999 -A 999; }

  alias ,todo=",pzgx '#todo'"
  alias ,remember=",pzgx '#remember'"
  alias ,diary=",pzgx '#diary'"
  alias ,tags='pyzet tags -r | less'
  alias ,quotes=",pzgx 'Quote: '"
fi

if _have all-repos-clone; then
  ,all-repos-clone-private() {
    all-repos-clone --jobs 0 --config-filename "$REPOS/private/all-repos.json"
  } && export -f ,all-repos-clone-private
fi

if _have hexdump; then
  ,hd() {
    hexdump \
      --one-byte-char \
      --format "\"%07.7_Ax\n\"" \
      --format "\"%07.7_ax \" 16/1 \" %02x \" " \
      --format "\"  |\" 16/1 \"%_p\" \"|\\n\"" \
      "$@"
  } && export -f ,hd
fi

if _have ffmpeg; then
  ,rotate-video() {
    # Based on https://stackoverflow.com/a/31683689/14458327
    filename=$1
    angle=$2
    ffmpeg -i "$filename" \
      -map_metadata 0 -metadata:s:v rotate="$angle" \
      -codec copy rotated_by_"$angle"_deg_"$filename"
  } && export -f ,rotate-video
fi

cry() { echo ":'("; }

# ------------------------------- Python -------------------------------

if _have aactivator; then
  eval "$(aactivator init)"
  ,aactivator-init() {
    local py='venv/bin/python'
    if [[ -x "$py" ]]; then
      ln -s venv/bin/activate .activate.sh
      echo 'Created .activate.sh'
      echo 'deactivate' > .deactivate.sh
      echo 'Created .deactivate.sh'
    else
      echo "'$py' not found. Aborting..."
      return 1
    fi
  } && export -f ,aactivator-init
fi

if _have ctags; then
  ,ctags-python() {
    ctags --recurse --languages=python --exclude=venv --exclude=.tox
  } && export -f ,ctags-python
fi

# ---------------------------- Common Lisp -----------------------------

if _have sbcl && _have rlwrap; then
  alias sbcl='rlwrap sbcl'
fi

# --------------------- Personalized Configuration ---------------------

_source_if "$HOME/.bash_personal"
_source_if "$HOME/.bash_private"
_source_if "$HOME/.bash_work"

# ------------------------- Cleanup namespace --------------------------

# Remove variables
unset -v _homebrew_prefix

# Remove functions
unset -f _have
unset -f _source_if
