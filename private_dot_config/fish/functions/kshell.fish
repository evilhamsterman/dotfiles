function kshell --description "Create a temporary pod in the current K8S cluster and exec to it" --wraps "kubectl"

  if test $USER = dmills
    set -f image qcr.corp.qumulo.com/it/network-multitool:latest
  else
    set -f image ghcr.io/evilhamsterman/network-multitool:latest
  end

  set -f pod_name "$(random)-dmills-kshell"
  set -f svc_acct_name "$pod_name-svc"

  set -f namespace (kubectl config view --minify --output 'jsonpath={..namespace}')

  set -f manifests "
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $svc_acct_name
  namespace: $namespace
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: $svc_acct_name
subjects:
  - kind: ServiceAccount
    name: $svc_acct_name
    namespace: $namespace
roleRef:
  kind: ClusterRole
  name: cluster-admin
---
apiVersion: v1
kind: Pod
metadata:
  name: $pod_name
  namespace: $namespace
spec:
  serviceAccountName: $svc_acct_name
  containers:
    - name: $pod_name
      image: $image
"

  echo $manifests | kubectl create -f -

  echo " Waiting for $pod_name to start"
  kubectl wait --for=condition=Ready pod/$pod_name
  echo "󱘖 Connecting to $pod_name"
  kubectl exec -it $pod_name -- /usr/bin/fish -l -i

  echo $manifests | kubectl delete -f -

end
