
function install_fn() {
  echo "${kubecontext}"

    helm repo add mysql-operator https://mysql.github.io/mysql-operator/
    helm repo update

    helm --kube-context ${kubecontext} upgrade --install my-mysql-operator mysql-operator/mysql-operator -n mysql --create-namespace

    helm --kube-context ${kubecontext} upgrade --install my-mysql-innodbcluster mysql-operator/mysql-innodbcluster \
    --set credentials.root.password="password" \
    --set tls.useSelfSigned=true \
    --set serverInstances=1 \
    -n mysql --create-namespace

cat <<-EOF | kubectl --context ${kubecontext} -n mysql apply -f -
apiVersion: v1
kind: Service
metadata:
  name: mysql-nodeport
spec:
  type: NodePort
  selector:
    component: mysqld
    mysql.oracle.com/cluster: my-mysql-innodbcluster
    mysql.oracle.com/instance-type: group-member
    tier: mysql
  ports:
    - name: mysql
      protocol: TCP
      port: 3306
      targetPort: 3306
      nodePort: 30007
EOF
}

function uninstall_fn() {
    kubectl --context ${kubecontext} -n mysql svc mysql-nodeport
    helm --kube-context ${kubecontext} -n mysql delete my-mysql-operator
    helm --kube-context ${kubecontext} -n mysql delete my-mysql-innodbcluster
}

source <(curl https://raw.githubusercontent.com/mintlime-in/kube-infra/main/installer.sh 2>/dev/null) $@