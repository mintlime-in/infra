#!/bin/bash

function usage() {
  cat <<-EOF
  Usage: bash $0 [options]
    options:
      -c  kubecontext
      -b  build
      -i  install
      -u  uninstall
      -h  help
EOF
}

scriptName=$(basename $0 | cut -d"." -f1)

function builder_fn() {
  echo "building ${scriptName}"
  build_fn
}

function installer_fn() {
  echo "installing ${scriptName}"
  install_fn
}

function uninstaller_fn() {
  echo "uninstalling ${scriptName}"
  uninstall_fn
}

build=0
install=0
uninstall=0
while getopts ":ic:buh" opt; do
  case ${opt} in
    c)
      kubecontext=${OPTARG}
    ;;
    b)
      build=1
    ;;
    i)
      install=1
    ;;
    u)
      uninstall=1
    ;;
    h)
      usage
      exit 0
    ;;
  esac
done

[[ ${kubecontext} == "" ]] && usage && exit 1

echo "kubecontext: ${kubecontext}"

[ ${build} -eq 1 ] && builder_fn
[ ${install} -eq 1 ] && installer_fn
[ ${uninstall} -eq 1 ] && uninstaller_fn

# helm repo add mysql-operator https://mysql.github.io/mysql-operator/
# helm repo update

# helm upgrade --install my-mysql-operator mysql-operator/mysql-operator --namespace mysql --create-namespace

# helm --kube-context ${kubecontext} upgrade --install my-mysql-innodbcluster mysql-operator/mysql-innodbcluster \
# --set credentials.root.password="password" \
# --set tls.useSelfSigned=true \
# --set serverInstances=1 \
# -n mysql --create-namespace

# cat <<-EOF | kubectl --context ${kubecontext} --namespace mysql apply -f -
# apiVersion: v1
# kind: Service
# metadata:
#   name: mysql-nodeport
# spec:
#   type: NodePort
#   selector:
#     component: mysqld
#     mysql.oracle.com/cluster: my-mysql-innodbcluster
#     mysql.oracle.com/instance-type: group-member
#     tier: mysql
#   ports:
#     - name: mysql
#       protocol: TCP
#       port: 3306
#       targetPort: 3306
#       nodePort: 30007
# EOF