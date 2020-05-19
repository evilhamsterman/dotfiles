###############################
# Setup environment variables #
###############################

# Set XDG values if they aren't set
set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config

# Disable fish greeting
set fish_greeting

# Add $HOME/.local/bin to PATH and make sure it exists
# if test
set -l local_bin $HOME/.local/bin
set -gx PATH $local_bin $PATH
if not test -d $local_bin
    mkdir -p $local_bin
end

# Load check for fzf for enhancd
set fzf_installed false
if not type -q fzf
    echo "Install fzf for full cd fun"
    set -gx ENHANCD_COMMAND ecd
end

# Disable enhancd on .. - and blank cd
set -gx ENHANCD_DISABLE_DOT 1
set -gx ENHANCD_DISABLE_HOME 1

# Connect to Windows ssh-agent if running in WSL
if not test -z $WSL_DISTRO_NAME
    set -gx SSH_AUTH_SOCK "$HOME/.ssh/agent.sock"
    if not ss -a | grep -q $SSH_AUTH_SOCK
        rm -f $SSH_AUTH_SOCK
        setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"/mnt/c/Users/dan/.local/bin/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &
    end
end
