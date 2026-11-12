#!/usr/bin/env bash
# Claude Code status line: dir, git branch, model, context usage
input=$(cat)
dir=$(jq -r '.workspace.current_dir // .cwd // ""' <<<"$input")
model=$(jq -r '.model.display_name // ""' <<<"$input")
ctx=$(jq -r '.context_window.used_percentage // empty' <<<"$input")

out="\033[34m${dir/#$HOME/\~}\033[0m"
branch=$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null)
[ -n "$branch" ] && out+=" \033[94m $branch\033[0m"
[ -n "$model" ] && out+=" \033[2m· $model\033[0m"
[ -n "$ctx" ] && out+=" \033[2m· ctx $(printf '%.0f' "$ctx")%\033[0m"
printf '%b' "$out"
