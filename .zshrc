# Set Dotfile dir
export DOTFILES=~/.dotfiles

# Load bashcompletion
autoload -Uz compinit
compinit

# Initialize antibody
source <(antibody init)

# Setup common features
source $DOTFILES/common.d/source.sh

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
