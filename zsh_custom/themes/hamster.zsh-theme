# hamster.zsh-theme
# Based on af-magic
# Repo: https://github.com/andyfleming/oh-my-zsh
# Direct Link: https://github.com/andyfleming/oh-my-zsh/blob/master/themes/af-magic.zsh-theme

if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

# Color Variables
# Check if we are on a remote connection or local
if [[ "${SSH_CONNECTION+1}" ]]; then
	eval my_fg='$FG[002]'
else
	eval my_fg='$FG[032]'
fi

eval my_gray='$FG[237]'
eval my_orange='$FG[214]'


# primary prompt
PROMPT='$my_fg%2~$(git_prompt_info) $FG[105]%(!.#.»)%{$reset_color%} '
PROMPT2='%{$FG[red]%}\ %{$reset_color%}'
RPS1='${return_code}'

# right prompt
if type "virtualenv_prompt_info" > /dev/null
then
	RPROMPT='$(virtualenv_prompt_info)$my_fg%n@%m%{$reset_color%}%'
else
	RPROMPT='$my_fg%n@%m%{$reset_color%}%'
fi

# git settings
ZSH_THEME_GIT_PROMPT_PREFIX="$FG[075](branch:"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY="$my_orange*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="$FG[075])%{$reset_color%}"
