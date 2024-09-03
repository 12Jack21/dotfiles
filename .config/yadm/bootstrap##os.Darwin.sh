#!/bin/sh

system_type=$(uname -s)

if [ "$system_type" = "Darwin" ]; then

	# install homebrew if it's missing
	if ! command -v brew >/dev/null 2>&1; then
		echo "Installing homebrew"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		# /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	fi

	if [ -f "$HOME/.Brewfile" ]; then
		echo "Updating homebrew bundle"
		brew bundle --global
	fi

fi

echo "Updating the yadm repo origin URL"
yadm remote set-url origin "git@github.com:MyUser/dotfiles.git"
