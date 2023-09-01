function cu --description "Update dotfiles and set the day updated"
    chezmoi update --apply
    set --universal __last_chezmoi_update (date %Y%j)
end