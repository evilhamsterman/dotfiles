# Kubernetes shortcuts
if type -q kubectl
    alias k=kubectl
    alias kshell="kubectl run shell --rm -it --image digitalocean/doks-debug:latest -- /bin/sh"
    alias ka="kubectl apply --server-side"
    if not test -d $HOME/.krew
        set -x; set temp_dir (mktemp -d); cd "$temp_dir" &&
        set OS (uname | tr '[:upper:]' '[:lower:]') &&
        set ARCH (uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/') &&
        set KREW krew-$OS"_"$ARCH &&
        curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/$KREW.tar.gz" &&
        tar zxvf $KREW.tar.gz &&
        ./$KREW install krew &&
        set -e KREW temp_dir &&
        cd -
    end
    fish_add_path $HOME/.krew/bin
end

if type -q kubectx
    alias kns="kubens"
    alias kctx="kubectx"
end

if type -q talosctl
    alias t=talosctl
end

if type -q flux
    alias f=flux
end