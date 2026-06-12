function wtadd --description "Add a worktree for a branch, tracking origin/<branch> if it exists"
    if test (count $argv) -eq 0
        echo "Usage: wtadd <branch>" >&2
        return 1
    end
    set -l branch $argv[1]

    # Worktrees live under the repo root (the folder holding the shared .git),
    # so this works from the root or inside any existing worktree
    set -l gitdir (git rev-parse --path-format=absolute --git-common-dir); or return
    set -l root (path dirname $gitdir)

    # Refresh origin/* so a branch pushed elsewhere is picked up; offline is fine
    git -C $root fetch origin --quiet

    if git -C $root show-ref --verify --quiet refs/heads/$branch
        git -C $root worktree add $branch $branch; or return
        # Bare clones copy remote branches into refs/heads without upstreams
        if not git -C $root config --get branch.$branch.merge >/dev/null
            and git -C $root show-ref --verify --quiet refs/remotes/origin/$branch
            git -C $root/$branch branch --set-upstream-to=origin/$branch $branch
        end
    else if git -C $root show-ref --verify --quiet refs/remotes/origin/$branch
        git -C $root worktree add --track -b $branch $branch origin/$branch
    else
        git -C $root worktree add -b $branch $branch
    end
end
