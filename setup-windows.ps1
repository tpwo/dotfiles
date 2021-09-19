function config {
	git --git-dir=$HOME\.dotfiles\ --work-tree=$HOME $args
}

git init --bare $HOME/.dotfiles
config config status.showUntrackedFiles no

config remote add origin https://github.com/tpwo/dotfiles.git
config fetch
config checkout win
config status
