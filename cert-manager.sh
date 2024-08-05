function install_fn() {
    helm repo add jetstack https://charts.jetstack.io
    helm --kube-context ${kubecontext} upgrade --install \
    cert-manager jetstack/cert-manager \
    --set crds.enabled=true \
    -n cert-manager \
    --create-namespace
    # kubectl --context ${kubecontext} -n cert-manager wait --for-condition=Ready
    cat <<-EOF | kubectl --context ${kubecontext} -n cert-manager apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
    name: selfSigned-root-issuer
spec:
    selfSigned: {}
EOF
}

function uninstall_fn() {
    helm --kube-context ${kubecontext} uninstall cert-manager
}

source <(curl https://raw.githubusercontent.com/mintlime-in/kube-infra/main/installer.sh 2>/dev/null) $@