#!/usr/bin/env bash

set -x

PLATFORM=$1
K8S_VERSIOIN=$2

function ExistsImage() {
  local num=${2:-3}
  local manifests=$(docker manifest inspect $1 | jq '.manifests | length')
  [ "$manifests" == "$num" ] && echo "exist" || echo ""
}

echo "checking docker.io/cloudtogo4edge/alpine-iptables:v12.1.2"
if [ "$(ExistsImage docker.io/cloudtogo4edge/alpine-iptables:v12.1.2)" == "" ]; then
  echo "building image docker.io/cloudtogo4edge/alpine-iptables:v12.1.2"
  pushd alpine-iptables
  docker buildx build --push \
    --platform=${PLATFORM} \
    -t docker.io/cloudtogo4edge/alpine-iptables:v12.1.2 \
    -f 3.13.dockerfile .
  popd
fi

echo "building image docker.io/cloudtogo4edge/kube-proxy:v${K8S_VERSIOIN}"
docker buildx build --platform=${PLATFORM} --push \
  --build-arg K8S_VERSIOIN=${K8S_VERSIOIN} \
  -t docker.io/cloudtogo4edge/kube-proxy:v${K8S_VERSIOIN} \
  -f kube-proxy-alpine-3.13.dockerfile .

set +x