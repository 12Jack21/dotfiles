#!/bin/bash
## ----------- On a differnt machine, Initialize config with dotfiles ------------------

# Exit immediately if a command exits with a non-zero status
set -e

# Check if the current working directory is ~/.config
if [[ "$(pwd)" != "$HOME/.config" ]]; then
	echo "You are not in the ~/.config directory."
	echo "Please navigate to ~/.config and try again."
	exit 1
fi

# function definition ------------------------------------------------------------
# Function to compare version numbers
version_ge() {
	# Returns 0 (true) if the first version is greater than or equal to the second
	# Uses sort -V to compare versions in a natural way
	[ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}
# Function to install tmux plugins using TPM
install_tmux_plugins() {
	# Get the installed tmux version
	TMUX_VERSION=$(tmux -V | awk '{print $2}')

	# Check if tmux version is >= 3.4
	if version_ge "$TMUX_VERSION" "3.4"; then
		echo "tmux version $TMUX_VERSION is sufficient."
	else
		echo "tmux version $TMUX_VERSION is too old. Please install tmux version 3.4 or newer."
		exit 1
	fi
	# Check if tmux is running
	if tmux info &>/dev/null; then
		echo "Installing tmux plugins in the current session..."
		tmux run-shell "$HOME/.tmux/plugins/tpm/bin/install_plugins"
	else
		echo "Starting a temporary tmux session to install plugins..."
		# Start a new session, install plugins, and then kill the session
		tmux new-session -d -s temp_session
		tmux run-shell "$HOME/.tmux/plugins/tpm/bin/install_plugins"
		tmux kill-session -t temp_session
	fi

	if [[ "$(uname -s)" == "Linux" && -f /etc/lsb-release ]]; then
		rm ~/.tmux.conf
		ln -s ~/.config/tmux/tmux.conf.local ~/.tmux.conf
	fi
}
# Function to install packages with Homebrew on macOS
install_brew_packages() {
	if ! command -v brew &>/dev/null; then
		echo "Homebrew is not installed. Installing Homebrew..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi

	echo "Installing eackages from Brewfile..."
	brew bundle --file=Brewfile
}

# Function to install packages with apt on Ubuntu
install_apt_packages() {
	sudo apt update
	sudo apt upgrade -y

	# build tools for homebrew (or normal dev env)
	sudo apt-get install build-essential procps curl file git

	# Define the input file
	input_file="packages_ubun20.txt"

	# Read the input file
	while IFS= read -r line; do
		# Check if we reached the first ---
		if [[ "$line" == "---" && -z "$section" ]]; then
			section="snap"
			continue
		fi

		# Check if we reached the second ---
		if [[ "$line" == "---" && "$section" == "snap" ]]; then
			section="manual"
			continue
		fi

		# Install with apt
		if [[ -z "$section" ]]; then
			echo "Installing $line with apt............................................................."
			sudo apt-get install -y "$line"

		# Install with snap
		elif [[ "$section" == "snap" ]]; then
			echo "Installing $line with snap............................................................"
			sudo snap install "$line"

		# Prompt the user for manual installation
		elif [[ "$section" == "manual" ]]; then
			echo "You need to manually install $line (e.g., using Homebrew or by building from source)."
		fi

	done <"$input_file"

}

git_configure() {
	# Prompt the user for input
	read -p "Do you need a new git config? (y/n): " user_input

	if [ "$user_input" = "y" ] || [ "$user_input" = "Y" ]; then
		if [ -d ~/.ssh ]; then
			mv ~/.gitconfig ~/.gitconfig_backup
		fi
		ln -s ~/.config/git/config ~/.gitconfig
	fi
}
ubuntu_install_fonts() {
	# Define the URL and the font installation directory
	# check more fonts on https://www.nerdfonts.com/font-downloads
	FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip"
	FONT_DIR="$HOME/.local/share/fonts"

	# Create the font directory if it doesn't exist
	mkdir -p "$FONT_DIR"

	# Check if a file starting with "Hack" does not exist in the directory
	if ! ls "$FONT_DIR"/Hack* 1>/dev/null 2>&1; then
		echo "No file starting with 'Hack' found in $FONT_DIR."

		# Download the Hack Nerd Font
		echo "Downloading Hack Nerd Font..."
		wget -O /tmp/Hack.zip "$FONT_URL"

		# Unzip the font into the font directory
		echo "Installing Hack Nerd Font..."
		unzip /tmp/Hack.zip -d "$FONT_DIR"

		# Clean up the downloaded zip file
		rm /tmp/Hack.zip

	fi

	# Refresh the font cache
	echo "Refreshing font cache..."
	fc-cache -fv
	echo "Hack Nerd Font installed successfully!"
}
ssh_configure() {
	# Prompt the user for input
	read -p "Do you need a new SSH config? (y/n): " user_input

	if [ "$user_input" = "y" ] || [ "$user_input" = "Y" ]; then
		if [ -d ~/.ssh ]; then
			mv ~/.ssh ~/.ssh_backup
		fi
		ln -s ~/.config/ssh ~/.ssh
	fi
}
## ---Software Installation--------------------------------------------------------------

# Determine the package manager
if [[ "$(uname)" == "Darwin" ]]; then
	pkgm="brew"
elif [[ "$(uname -s)" == "Linux" && -f /etc/lsb-release ]]; then
	if grep -q "Ubuntu" /etc/lsb-release; then
		pkgm="apt"
	fi
else
	echo "Unsupported OS."
	exit 1
fi

echo "Using package manager: $pkgm"

echo "1) Software Installation Using $pkgm -----------------------------------------------"

# Install packages based on the package manager
if [[ "$pkgm" == "brew" ]]; then
	install_brew_packages

	if [ -d ~/.ssh ]; then
		mv /Library/Rime /Libary/Rime_bak
	fi
	# copy rime (squirrel) config to /Library/Rime
	cp -r ~/.config/rime_config /Library/Rime
elif [[ "$pkgm" == "apt" ]]; then
	install_apt_packages
fi

echo "Package installation completed!"

## ---Additional Preparation--------------------------------------------------------------
echo "2) Additional Preparation -----------------------------------------------"

echo "Git Configuration"
git_configure

echo "Shell needed font: Hack Nerd Fonts (Mono)"

ubuntu_install_fonts

echo "ZSH plugins configure"
# install Oh-my-zsh first
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
mkdir -p ${ZSH_CUSTOM}/themes
mkdir -p ${ZSH_CUSTOM}/plugins
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
git clone --depth 1 https://github.com/unixorn/fzf-zsh-plugin.git ${ZSH_CUSTOM}/plugins/fzf-zsh-plugin

echo "fzf(fuzzy finder) configure"
if [ -f ~/.fzf.zsh ]; then
	rm ~/.fzf.zsh
fi
ln -s ~/.config/zsh_tools/fzf.zsh ~/.fzf.zsh

echo "clang-format configure"
if [ -f ~/.clang-format ]; then
	mv ~/.clang-format ~/.clang-format_backup
fi
ln -s ~/.config/clang-format ~/.clang-format

echo "Tmux install plugins (tpm)"

mkdir -p ~/.tmux/plugins/tpm
mkdir -p ~/tmux_logs # For tmux log store
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
install_tmux_plugins

echo "SSH config setup"

ssh_configure

echo "Neovim: move to directory(~/.config/nvim), setup with the shell script inside. (Lazy.nvim)"
## ---Symlink  Creation------------------------------------------------------------------
echo "3) Symlink  Creation (bash,zsh) -----------------------------------------------"
# symlink for shell
if [ -f ~/.zshrc ]; then
	mv ~/.zshrc ~/.zshrc_backup
fi
ln -s ~/.config/zshrc ~/.zshrc
# mv ~/.bashrc ~/.bashrc_backup
# ln -s ~/.config/bashrc ~/.bashrc

# In ~/.zshenv
echo "source ~/.config/zshrc" >>~/.zshenv

# In ~/.bash_profile or ~/.profile
cat <<EOF >>~/.bash_profile

if [ -f ~/.config/bashrc ]; then
  . ~/.config/bashrc
fi
EOF

# change default shell
echo "change default shell"
chsh -s $(which zsh)

echo "Pay attention to your locale language, font family and package version !!!"
echo "All initialization finished -----------------------------------------------"
