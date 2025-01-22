# This doesn't accept files
complete -c sc -f

complete -c sc -s h -l help -d "Print the help"
complete -c sc -s l -l list -d "List workspaces"
complete -c sc -a "(sc --list)"