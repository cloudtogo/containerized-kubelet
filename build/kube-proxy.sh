#!/usr/bin/env bash

set -x
set -e

source $(dirname "${BASH_SOURCE[0]}")/libs.sh

PLATFORM=$1
K8S_VERSIOIN=$2
CRICTL_VERSION=$3
CRI_TOOLS_BIN_PATH=$4
ALPINE_VERSION=$5

lib::build_image kube-node-base "" kube-node-base.dockerfile
lib::build_image alpine-iptables "12.1.2" alpine-iptables/Dockerfile
lib::build_image kube-node-binaries "${K8S_VERSIOIN}" kube-node-binaries.dockerfile
lib::overwrite_image kube-proxy "${K8S_VERSIOIN}" kube-proxy.dockerfile

set +e
set +x