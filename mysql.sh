
function build_fn() {
  echo "building ${scriptName}..."
}

source <(curl https://raw.githubusercontent.com/mintlime-in/kube-infra/main/installer.sh) $@