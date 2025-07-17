function __completions
        # Capture the full command line as an array
        set -l args (commandline -opc)
        set -l current (commandline -ct)
    COMPLETION_MODE=1 $args $current
end

# Setup Fish to use the function for completions for ''
complete -c coder -f -a '(__completions)'
