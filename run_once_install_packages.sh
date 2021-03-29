#!/bin/sh

# Check for and install yay
if ! command -v yay &> /dev/null
then
    echo "Installing YAY"
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
fi

# Install other packages
PKGS="starship fish tmux mosh fzf bitwarden-cli-bin"
yay -S $PKGS --noconfirm --needed

# Make sure shell is set to fish
if ! getent passwd dan | awk -F: '{print $NF}' | grep -q fish
then
    chsh -s /usr/bin/fish
    echo "Shell changed relogin"
fi

