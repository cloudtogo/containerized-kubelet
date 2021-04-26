#!/usr/bin/env bash

set -x

PLATFORM=$1
K8S_VERSIOIN=$2
CRICTL_VERSION=$3
CRI_TOOLS_BIN_PATH=$4

function ExistsImage() {
  local num=${2:-3}
  local manifests=$(docker manifest inspect $1 | jq '.manifests | length')
  [ "$manifests" == "$num" ] && echo "exist" || echo ""
}

echo "checking docker.io/cloudtogo4edge/kubernetes-source:v${K8S_VERSIOIN}"
if [ "$(ExistsImage docker.io/cloudtogo4edge/kubernetes-source:v${K8S_VERSIOIN} 0)" == "" ]; then
  echo "building image docker.io/cloudtogo4edge/kubernetes-source:v${K8S_VERSIOIN}"
  docker buildx build --push \
    --platform=linux/amd64 \
    --build-arg K8S_VERSIOIN=${K8S_VERSIOIN} \
    --build-arg CRICTL_VERSION=${CRICTL_VERSION} \
    -t docker.io/cloudtogo4edge/kubernetes-source:v${K8S_VERSIOIN} \
    -f kubernetes-src.dockerfile .
fi

echo "checking docker.io/cloudtogo4edge/kube-node-base:alpine-3.13"
if [ "$(ExistsImage docker.io/cloudtogo4edge/kube-node-base:alpine-3.13)" == "" ]; then
  echo "building image docker.io/cloudtogo4edge/kube-node-base:alpine-3.13"
	docker buildx build --push \
		--platform=${PLATFORM} \
		--build-arg K8S_VERSIOIN=${K8S_VERSIOIN} \
		--build-arg CRICTL_VERSION=${CRICTL_VERSION} \
		-t docker.io/cloudtogo4edge/kube-node-base:alpine-3.13 \
		-f kube-node-base-alpine-3.13.dockerfile .
fi

echo "checking docker.io/cloudtogo4edge/kube-node-binaries:v${K8S_VERSIOIN}"
if [ "$(ExistsImage docker.io/cloudtogo4edge/kube-node-binaries:v${K8S_VERSIOIN})" == "" ]; then
  set -e
  echo "building image docker.io/cloudtogo4edge/kube-node-binaries:v${K8S_VERSIOIN}"
	docker buildx build --push --platform=${PLATFORM} \
		--build-arg CRI_TOOLS_BIN_PATH=${CRI_TOOLS_BIN_PATH} \
		--build-arg K8S_VERSIOIN=${K8S_VERSIOIN} \
		--build-arg CRICTL_VERSION=${CRICTL_VERSION} \
		-t docker.io/cloudtogo4edge/kube-node-binaries:v${K8S_VERSIOIN} \
		-f kube-node-binaries-alpine-3.13.dockerfile .
	set +e
fi

set -e
echo "building image docker.io/cloudtogo4edge/kubelet:v${K8S_VERSIOIN}"
docker buildx build --platform=${PLATFORM} \
  --build-arg CRI_TOOLS_BIN_PATH=${CRI_TOOLS_BIN_PATH} \
  --build-arg K8S_VERSIOIN=${K8S_VERSIOIN} \
  --build-arg CRICTL_VERSION=${CRICTL_VERSION} \
  --target kubelet-only \
  -t docker.io/cloudtogo4edge/kubelet:v${K8S_VERSIOIN} \
  -f alpine-3.13.dockerfile --push .
echo "building image docker.io/cloudtogo4edge/kubelet:v${K8S_VERSIOIN}-cni"
docker buildx build --platform=${PLATFORM} \
  --build-arg CRI_TOOLS_BIN_PATH=${CRI_TOOLS_BIN_PATH} \
  --build-arg K8S_VERSIOIN=${K8S_VERSIOIN} \
  --build-arg CRICTL_VERSION=${CRICTL_VERSION} \
  --target with-cni \
  -t docker.io/cloudtogo4edge/kubelet:v${K8S_VERSIOIN}-cni \
  -f alpine-3.13.dockerfile --push .
echo "building image docker.io/cloudtogo4edge/kubelet:v${K8S_VERSIOIN}-kubeadm"
docker buildx build --platform=${PLATFORM} \
  --build-arg CRI_TOOLS_BIN_PATH=${CRI_TOOLS_BIN_PATH} \
  --build-arg K8S_VERSIOIN=${K8S_VERSIOIN} \
  --build-arg CRICTL_VERSION=${CRICTL_VERSION} \
  --target with-kubeadm \
  -t docker.io/cloudtogo4edge/kubelet:v${K8S_VERSIOIN}-kubeadm \
  -f alpine-3.13.dockerfile --push .
echo "building image docker.io/cloudtogo4edge/kubelet:v${K8S_VERSIOIN}-kubeadm-cni"
docker buildx build --platform=${PLATFORM} \
  --build-arg CRI_TOOLS_BIN_PATH=${CRI_TOOLS_BIN_PATH} \
  --build-arg K8S_VERSIOIN=${K8S_VERSIOIN} \
  --build-arg CRICTL_VERSION=${CRICTL_VERSION} \
  --target kubeadm-cni \
  -t docker.io/cloudtogo4edge/kubelet:v${K8S_VERSIOIN}-kubeadm-cni \
  -f alpine-3.13.dockerfile --push .

set +e
set +x
