#!/bin/bash

kubecontext="docker-desktop"

cat <<-EOF
    Using '${kubecontext}' kube-context
    ENSURE YOU HAVE CONFIGURED STATIC IP FROM YOUR ROUTER
EOF
read -p "What is your machine static ip? " ip

if [[ $ip != "" ]]; then
helm repo add metallb https://metallb.github.io/metallb
helm --kube-context ${kubecontext} upgrade --install metallb metallb/metallb \
--namespace metallb-system --create-namespace
sleep 15
# kubectl -n metallb-system wait --for=condition=Ready pod/busybox1
cat <<-EOF | kubectl --context ${kubecontext} --namespace metallb-system apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - ${ip}/32
EOF

else
  echo "Metallb loadbalancer Not configured"
fi

helm --kube-context ${kubecontext} upgrade --install ingress-nginx ingress-nginx \
--repo https://kubernetes.github.io/ingress-nginx \
--namespace ingress-nginx --create-namespace

# An example Ingress that makes use of the controller:
#   apiVersion: networking.k8s.io/v1
#   kind: Ingress
#   metadata:
#     name: example
#     namespace: foo
#   spec:
#     ingressClassName: nginx
#     rules:
#       - host: www.example.com
#         http:
#           paths:
#             - pathType: Prefix
#               backend:
#                 service:
#                   name: exampleService
#                   port:
#                     number: 80
#               path: /
#     # This section is only required if TLS is to be enabled for the Ingress
#     tls:
#       - hosts:
#         - www.example.com
#         secretName: example-tls

# If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

#   apiVersion: v1
#   kind: Secret
#   metadata:
#     name: example-tls
#     namespace: foo
#   data:
#     tls.crt: <base64 encoded cert>
#     tls.key: <base64 encoded key>
#   type: kubernetes.io/tls