# Setup common plugins and theme
# The following lines were added by compinstall

# Add $HOME/bin to $PATH
export PATH=$HOME/.local/bin:$HOME/bin:$PATH

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=* r:|=*'
zstyle :compinstall filename "$HOME/.zshrc"

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

# Fix home, end, and delete
bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}" end-of-line
bindkey "${terminfo[kdch1]}" delete-char

# smart backward search
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search # Up
bindkey "^[OB" down-line-or-beginning-search # Down


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

# Add Kubernetes autocompletion
if [ $commands[kubectl] ]; then
  source <(kubectl completion zsh)
fi

# Add minikube autocompletion
if [ $commands[minikube] ]; then
  source <(minikube completion zsh)
fi