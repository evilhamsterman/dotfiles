# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="hamster"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$HOME/.dotfiles/zsh_custom/

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

# Default plugins
plugins=(colored-man rsync python)

# Add plugins if the appropriate executable exists
# example: add_plugin <exec> <plugin>
function add_plugin(){
  which $1 > /dev/null 2>&1
  if [[ $? == 0 ]]; then
    plugins=($plugins $2)
  fi
}
add_plugin git git
add_plugin pacman archlinux
add_plugin systemctl systemd
add_plugin pip pip
add_plugin virtualenvwrapper.sh virtualenvwrapper
add_plugin sudo sudo
add_plugin brew brew
add_plugin sw_vers osx
add_plugin yum yum
add_plugin mosh mosh
add_plugin docker docker

echo "Loaded Plugins $plugins"


# User configuration

export PATH=$PATH:$HOME/bin

# Set options depending if we are in a GUI or not
# Check if Linux GUI
if [[ -n "$DESKTOP_SESSION" ]]; then
  export EDITOR='code --wait'
  eval $(gnome-keyring-daemon --start)
  export SSH_AUTH_SOCK
# Check if OSX
elif [[ -f /usr/bin/sw_vers ]]; then
  export EDITOR='code --wait'
# assume we are in a terminal
else
  add_plugin ssh-agent ssh-agent
  export EDITOR='vim'
fi

# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
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