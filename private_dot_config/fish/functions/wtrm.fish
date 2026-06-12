function wtrm --description "Remove a worktree and prune empty parent folders"
    if test (count $argv) -eq 0
        echo "Usage: wtrm <branch> [git worktree remove options, e.g. --force]" >&2
        return 1
    end
    set -l branch $argv[1]

    set -l gitdir (git rev-parse --path-format=absolute --git-common-dir); or return
    set -l root (path dirname $gitdir)

    git -C $root worktree remove $argv[2..] $branch; or return

    # Clean up now-empty parents from nested branch names like feat/branch;
    # rmdir refuses non-empty dirs, which ends the walk
    set -l parent (path dirname $root/$branch)
    while test "$parent" != "$root"; and rmdir $parent 2>/dev/null
        set parent (path dirname $parent)
    end
end
