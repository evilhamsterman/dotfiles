

function sc --description 'SSH to a coder workspace'
    set -f helpmsg "
Usage: sc [options] <workspace>
Options:
  -h, --help    Show this message
  -l, --list    List all workspaces
"
    if test (count $argv) -eq 0
        echo $helpmsg
        return 1
    end

    argparse -s 'h/help' 'l/list' -- $argv
    or return
    if set -q _flag_help
        echo $helpmsg
        return
    end

    set -f coder_prefix "coder-$USER"
    set -f workspaces (tailscale status --self=false | string match -a -e $coder_prefix | string split -n -f 2 ' ' )

    if set -q _flag_list
        if test (count $workspaces) -gt 0
            printf "%s\n" $workspaces
            return
        else
            return 1
        end
    end

    set -f workspace $argv[1]
    set -f workspace_name (string split - $workspace)[-1]
    set -e argv[1]

    if not string match -a $workspace $workspaces >> /dev/null
        echo "$workspace is not a valid workspace"
        return 1
    end

    set -f state (coder ls --search "$USER/$workspace_name" -o json | jq -r '.[0].latest_build.status')
    if test $state != "running"
        echo "Starting $workspace"
        coder start $workspace_name
    end

    # # Create a temporary file for the known hosts
    set -f known_hosts (mktemp --suffix coder_hosts)

    # # Add host keys for hostname to file
    printf "$workspace %s\n" (tailscale status --json | jq ".Peer[] | select(.HostName == \"$workspace\") | .sshHostKeys[]" -r) >> $known_hosts

    # Connect to the workspace
    ssh -o UserKnownHostsFile=$known_hosts $argv $workspace

    # Clean up
    rm $known_hosts

end
