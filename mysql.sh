#!/bin/bash

kubecontext="docker-desktop"

cat <<-EOF
    Using '${kubecontext}' kube-context
EOF

helm repo add mysql-operator https://mysql.github.io/mysql-operator/
helm repo update

helm upgrade --install my-mysql-operator mysql-operator/mysql-operator --namespace mysql --create-namespace

helm --kube-context ${kubecontext} upgrade --install my-mysql-innodbcluster mysql-operator/mysql-innodbcluster \
--set credentials.root.password="password" \
--set tls.useSelfSigned=true \
--set serverInstances=1 \
-n mysql --create-namespace

cat <<-EOF | kubectl --context ${kubecontext} --namespace mysql apply -f -
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