# check if we're in a desktop environment
if [[ -n "$DESKTOP_SESSION" ]]; then
  export EDITOR='code --wait'
  eval $(gnome-keyring-daemon --start)
  export SSH_AUTH_SOCK
else
  antibody bundle < $DOTFILES/linux.d/console_zsh_plugins
fi