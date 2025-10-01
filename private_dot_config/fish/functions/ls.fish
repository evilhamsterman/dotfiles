function ll --wraps='eza -l --color=always --group-directories-first --icons' --description 'alias ll=eza -l --color=always --group-directories-first --icons'
    eza -l --color=always --group-directories-first --icons $argv
end

function ls --wraps='eza -al --color=always --group-directories-first --icons' --description 'alias ls=eza -al --color=always --group-directories-first --icons'
    eza -al --color=always --group-directories-first --icons $argv
end
