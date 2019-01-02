

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
  export EDITOR='vim'
fi

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