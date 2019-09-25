# Set Dotfile dir
export DOTFILES=~/.dotfiles

# Load bashcompletion
autoload -Uz compinit
compinit

# Initialize antibody
source <(antibody init)


# Set options depending on environment
OS=`uname`

case "$OS" in
  Linux)
    source $DOTFILES/linux.d/source.sh
  ;;
  Darwin)
    source $DOTFILES/osx.d/source.sh
  ;;
esac

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /home/danmills/.local/bin/vault vault

# Setup common features
source $DOTFILES/common.d/source.sh