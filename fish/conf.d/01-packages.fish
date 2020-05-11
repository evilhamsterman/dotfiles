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
if not functions -q fisher
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end
