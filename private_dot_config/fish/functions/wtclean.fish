function wtclean --description "Remove worktrees and local branches that are merged or deleted upstream"
    argparse n/dry-run -- $argv; or return

    set -l gitdir (git rev-parse --path-format=absolute --git-common-dir); or return
    set -l root (path dirname $gitdir)

    git -C $root fetch --prune --quiet origin; or return

    set -l default (git -C $root symbolic-ref --short HEAD)

    # Branches whose history is fully merged into the upstream default branch
    set -l merged
    if git -C $root show-ref --verify --quiet refs/remotes/origin/$default
        set merged (git -C $root for-each-ref refs/heads --merged origin/$default --format '%(refname:short)')
    end
    # Branches whose upstream was deleted, e.g. squash-merged then removed on GitHub
    set -l gone (git -C $root for-each-ref refs/heads --format '%(refname:short)%09%(upstream:track)' | string match -r '^(.*)\t\[gone\]$' --groups-only)

    set -l victims
    for b in $merged $gone
        if test "$b" != "$default"; and not contains -- $b $victims
            set -a victims $b
        end
    end

    if test (count $victims) -eq 0
        echo "Nothing to clean"
        return 0
    end

    for b in $victims
        if set -ql _flag_dry_run
            echo "Would remove: $b"
            continue
        end

        # Find the worktree holding this branch, if any
        set -l wtpath
        set -l cur
        for line in (git -C $root worktree list --porcelain)
            if string match -qr '^worktree ' -- $line
                set cur (string replace 'worktree ' '' -- $line)
            else if test "$line" = "branch refs/heads/$b"
                set wtpath $cur
                break
            end
        end

        if test -n "$wtpath"
            if not git -C $root worktree remove $wtpath
                echo "Skipping $b: could not remove worktree (dirty? use wtrm $b --force)" >&2
                continue
            end
            set -l parent (path dirname $wtpath)
            while test "$parent" != "$root"; and rmdir $parent 2>/dev/null
                set parent (path dirname $parent)
            end
        end

        # -D because squash-merged branches are never ancestors of the default branch
        git -C $root branch -q -D $b; and echo "Removed $b"
    end
end
