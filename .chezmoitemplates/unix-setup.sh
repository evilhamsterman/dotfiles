{{ if (eq .chezmoi.os "linux") }}
    {{ if (eq .chezmoi.osRelease.id "arch" "archarm" "cachyos" ) }}
# Arch Linux setup
# Check for and install yay
if ! command -v yay &> /dev/null
then
    echo "Installing YAY"
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
fi

# Install other packages
PKGS="starship fish tmux mosh fzf pre-commit eza zoxide socat github-cli jq yq kubectx task uv"
yay -S $PKGS --noconfirm --needed

    {{ else if (eq .chezmoi.osRelease.id "debian" "ubuntu") }}
# Debian
# Add eza repo
curl -sS https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo tee /etc/apt/trusted.gpg.d/gierens.asc >/dev/null
echo "deb http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null

# Install apt packages
sudo apt-get update && sudo apt-get install -y tmux fzf fish unzip eza socat pre-commit zoxide kubectx
if command -v snap &> /dev/null
then
    for package in "yq" "jq"; do
        sudo snap install $package
    done
    for package in "task"; do
        sudo snap install $package --classic
    done
fi

# All of these either have issues with the version in apt/snap or don't exist at all

# Install starship
curl -sS https://starship.rs/install.sh | sh -s -- -y -b $HOME/.local/bin >/dev/null

# Install zoxide
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# Install uv
if ! command -v uv &> /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

    {{ end }}

# Make sure shell is set to fish
# if ! getent passwd $USER | awk -F: '{print $NF}' | grep -q fish
# then
#     {{ if not .remote }}
#     chsh --shell /usr/bin/fish
#     echo "Shell changed relogin"
#     {{ end }}
# fi

{{ else if (eq .chezmoi.os "darwin") }}
# MacOS Setup
# Install Homebrew
if ! command -v brew &> /dev/null
then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

brew bundle --no-lock --file=/dev/stdin << EOF
tap "buo/cask-upgrade"
tap "homebrew/bundle"
tap "homebrew/cask"
tap "homebrew/cask-fonts"
tap "homebrew/core"
brew "bitwarden-cli"
brew "fish"
brew "fisher"
brew "fzf"
brew "gh"
brew "ipcalc"
brew "mas"
brew "mosh"
brew "mtr"
brew "pre-commit"
brew "starship"
brew "step"
brew "tmux"
brew "zoxide"
cask "font-fira-code-nerd-font"
cask "google-chrome"
cask "iterm2"
cask "powershell"
cask "signal"
cask "visual-studio-code"
mas "Yubico Authenticator", id: 1497506650
EOF

FISH_PATH=/usr/local/bin/fish

if ! grep -q $FISH_PATH /etc/shells
then
    echo $FISH_PATH | sudo tee -a /etc/shells > /dev/null
fi

USER_SHELL=`dscl . -read $HOME | grep UserShell | awk '{print $NF}'`

{{ end }}
