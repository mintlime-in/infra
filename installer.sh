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
      export kubecontext=${OPTARG}
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
