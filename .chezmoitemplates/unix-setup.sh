{{ if (eq .chezmoi.os "linux") }}
    {{ if (eq .chezmoi.osRelease.id "arch" "archarm" ) }}
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
PKGS="direnv starship fish tmux mosh fzf bitwarden-cli python-pre-commit exa fisher zoxide socat github-cli"
yay -S $PKGS --noconfirm --needed

    {{ else if (eq .chezmoi.osRelease.id "debian" "ubuntu") }}
# Debian container setup
# Install apt packages
sudo apt-get update && sudo apt-get install -y tmux exa fzf direnv fish

# Install fisher
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"

# Install starship
curl -sS https://starship.rs/install.sh | sh -s -- -y >/dev/null

# Install zoxide
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

    {{ end }}

# Make sure shell is set to fish
if ! getent passwd $USER | awk -F: '{print $NF}' | grep -q fish
then
    chsh -s /usr/bin/fish
    echo "Shell changed relogin"
fi

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
brew "direnv"
brew "exa"
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
mas "Microsoft Remote Desktop", id: 1295203466
mas "Yubico Authenticator", id: 1497506650
EOF

FISH_PATH=/usr/local/bin/fish

if ! grep -q $FISH_PATH /etc/shells
then
    echo $FISH_PATH | sudo tee -a /etc/shells > /dev/null
fi

USER_SHELL=`dscl . -read $HOME | grep UserShell | awk '{print $NF}'`

if [[ $USER_SHELL != $FISH_PATH ]];
then
    chsh -s $FISH_PATH
fi

{{ end }}