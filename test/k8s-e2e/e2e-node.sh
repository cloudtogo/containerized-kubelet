#!/usr/bin/env bash

set -e

[ ${K8S_VERSION} == "" ] && echo "K8S_VERSION not defined" && exit 1

IMAGE=${IMAGE:-cloudtogo4edge/kubelet:${K8S_VERSION}-kubeadm-cni-alpine3.13}

docker pull ${IMAGE}

mkdir -p /etc/kubernetes /etc/cni/net.d /var/lib/kubelet /var/log/pods

echo "starting kubelet"
docker run -d --restart=always --name=kubeletd --network=host --pid=host --uts=host --privileged \
    -v /etc/machine-id:/etc/machine-id -v /var/lib/dbus/machine-id:/var/lib/dbus/machine-id \
    -v /sys/fs/cgroup:/sys/fs/cgroup \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --mount type=bind,src=/var/lib/docker/`docker info -f '{{.Driver}}'`,dst=/var/lib/docker/`docker info -f '{{.Driver}}'`,bind-propagation=rshared \
    --mount type=bind,src=/var/lib/docker/image/`docker info -f '{{.Driver}}'`,dst=/var/lib/docker/image/`docker info -f '{{.Driver}}'`,bind-propagation=rshared \
    --mount type=bind,src=/var/lib/docker/containers,dst=/var/lib/docker/containers,bind-propagation=rshared \
    --mount type=bind,src=/var/lib/kubelet,dst=/var/lib/kubelet,bind-propagation=rshared \
    -v /var/log/pods:/var/log/pods \
    -v /etc/kubernetes:/etc/kubernetes -v /etc/cni/net.d:/etc/cni/net.d \
    ${IMAGE}

echo "joining the cluster"
docker run --rm --network=host --pid=host --uts=host \
  -v /etc/kubernetes:/etc/kubernetes \
  -v /var/lib/kubelet:/var/lib/kubelet \
  --entrypoint kubeadm \
  ${IMAGE} \
  join 10.38.1.3:6443 --token e2etok.en0containerized --discovery-token-unsafe-skip-ca-verification --ignore-preflight-errors=all

set +e