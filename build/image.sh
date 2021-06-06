#!/usr/bin/env bash

set -e

source $(dirname "${BASH_SOURCE[0]}")/libs.sh

export PLATFORM=$1
K8S_VERSIOIN=$2
CRICTL_VERSION=$3
CRI_TOOLS_BIN_PATH=$4
ALPINE_VERSION=$5

lib::build_image kube-node-base "" kube-node-base.dockerfile
lib::build_image alpine-iptables "12.1.2" alpine-iptables/Dockerfile
PLATFORM= lib::build_image kubernetes-source "${K8S_VERSIOIN}" kubernetes-src.dockerfile
lib::build_image kube-node-binaries "${K8S_VERSIOIN}" kube-node-binaries.dockerfile
TARGET=kubelet-only lib::overwrite_image kubelet "${K8S_VERSIOIN}" kubelet.dockerfile
TARGET=with-cni lib::overwrite_image kubelet "${K8S_VERSIOIN}-cni" kubelet.dockerfile
TARGET=with-kubeadm lib::overwrite_image kubelet "${K8S_VERSIOIN}-kubeadm" kubelet.dockerfile
TARGET=kubeadm-cni lib::overwrite_image kubelet "${K8S_VERSIOIN}-kubeadm-cni" kubelet.dockerfile
TARGET=with-flannel lib::overwrite_image kubelet "${K8S_VERSIOIN}-flannel" kubelet.dockerfile
lib::overwrite_image kube-proxy "${K8S_VERSIOIN}" kube-proxy.dockerfile

set +e