# Setup common plugins and theme
# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=* r:|=*'
zstyle :compinstall filename '/Users/dmills/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install

antibody bundle < $DOTFILES/common.d/zsh_plugins
source $DOTFILES/spaceshiprc
bindkey '^ ' autosuggest-accept

# Add $HOME/bin to $PATH
export PATH=$PATH:$HOME/bin

# Set vim as editor by default
export EDITOR='vim'

# Common aliases
alias df="df -h"
alias sedit="sudoedit"

# Setup shortcuts for 1Password

which op > /dev/null 2>&1
if [[ $? == 0 ]]; then
  OPSESSION_FILE=$HOME/.opsession
  if [ -f $OPSESSION_FILE ]
  then
    echo "Using existing 1Password Session"
    source $OPSESSION_FILE
  fi
  function loginop()
  {
    op signin qumulo > $OPSESSION_FILE
    chmod go-rwx $OPSESSION_FILE
    source $OPSESSION_FILE
  }
fi