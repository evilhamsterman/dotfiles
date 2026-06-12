function wtclone --description "Bare-clone a repo set up for worktrees, with a worktree for the default branch"
    if test (count $argv) -eq 0
        echo "Usage: wtclone <owner/repo | url> [directory]" >&2
        return 1
    end

    # Full URLs (scheme:// or scp-style user@host:) pass through,
    # anything else is treated as a GitHub owner/repo shorthand
    set -l url $argv[1]
    if not string match -qr '^[a-z][a-z0-9+.-]*://' -- $url
        and not string match -qr '^[^/]+@[^:/]+:' -- $url
        set url "https://github.com/$url.git"
    end

    set -l dir $argv[2]
    if test -z "$dir"
        set dir (string replace -r '\.git$' '' (path basename $url))
    end

    git clone --bare $url $dir; or return

    # Bare clones skip the fetch refspec, so origin/* tracking refs never update
    git -C $dir config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
    git -C $dir fetch origin; or return

    set -l branch (git -C $dir symbolic-ref --short HEAD)
    git -C $dir worktree add $branch $branch; or return
    git -C $dir/$branch branch --set-upstream-to=origin/$branch $branch
end
