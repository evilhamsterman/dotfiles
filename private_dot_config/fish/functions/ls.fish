function ll --wraps='eza -l --color=always --group-directories-first --icons=auto' --description 'alias ll=eza -l --color=always --group-directories-first --icons=auto'
    eza -l --color=always --group-directories-first --icons=auto $argv
end

function ls --wraps='eza -al --color=always --group-directories-first --icons=auto' --description 'alias ls=eza -al --color=always --group-directories-first --icons=auto'
    eza -al --color=always --group-directories-first --icons=auto $argv
end
