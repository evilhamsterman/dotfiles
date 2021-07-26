#################
# Load packages #
#################

# Load Starship Prompt if available
set starship_installed false
if not type -q starship
    curl -fsSL https://starship.rs/install.sh | bash -s -- --yes --bin-dir=$local_bin
    and set starship_installed true
else
    set starship_installed true
end

if $starship_installed
    starship init fish | source
end

# Load fish packages
if status is-interactive && ! functions --query fisher
    curl --silent --location https://git.io/fisher | source && fisher install jorgebucaran/fisher
end

