function cu --description "Update dotfiles and set the day updated"
    # Only run if the shell is interactive to avoid automation from stalling
    if status --is-interactive
        chezmoi update --apply
        set --universal __last_chezmoi_update (date +%Y%j)
    end
end
