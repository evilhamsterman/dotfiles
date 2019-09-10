# check if we're in a desktop environment
if [[ -n "$DESKTOP_SESSION" ]]; then
  export EDITOR='code --wait'
  eval $(gnome-keyring-daemon --start)
  export SSH_AUTH_SOCK
else
  antibody bundle < $DOTFILES/linux.d/console_zsh_plugins
fi

# Set virtualenvwrapper python
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3

# Add snaps to PATH
if [ -d "/snap/bin" ]; then
    export PATH=$PATH:/snap/bin
fi
