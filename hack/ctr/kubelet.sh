#!/usr/bin/env bash

# Should set rootfsPropagation to rshared for the container
./ctr -n k8s.io run --privileged --net-host --runtime=io.containerd.runtime.v1.linux --rm --with-ns="pid:/proc/1/ns/pid"\
	--log-uri=/tmp/kubelet.log \
	--env HOSTNAME=minikube-m02 \
	--env NODE_IP=192.168.64.29 \
  --mount type=bind,src=/etc/systemd,dst=/etc/systemd,options=rbind:rw \
  --mount type=bind,src=/lib/systemd,dst=/lib/systemd,options=rbind:rw \
  --mount type=bind,src=/etc/machine-id,dst=/etc/machine-id,options=bind:ro \
  --mount type=bind,src=/var/lib/dbus/machine-id,dst=/var/lib/dbus/machine-id,options=bind:ro \
  --mount type=bind,src=/mnt/vda1/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs,dst=/mnt/vda1/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs,options=rbind:rshared:rw \
	--mount type=bind,src=/var/lib/minikube/certs/ca.crt,dst=/var/lib/minikube/certs/ca.crt,options=bind:ro \
	--mount type=bind,src=/run/systemd/resolve/resolv.conf,dst=/run/systemd/resolve/resolv.conf,options=bind:ro \
	--mount type=bind,src=/run/containerd/containerd.sock,dst=/run/containerd/containerd.sock,options=bind:rw \
	--mount type=bind,src=/var/lib/kubelet,dst=/var/lib/kubelet,options=rbind:rshared:rw \
  --mount type=bind,src=/var/log/pods,dst=/var/log/pods,options=rbind:rw \
	--mount type=bind,src=/etc/kubernetes,dst=/etc/kubernetes,options=rbind:rw \
	--mount type=bind,src=/etc/cni/net.d,dst=/etc/cni/net.d,options=rbind:ro \
	--mount type=bind,src=/sys/fs/cgroup,dst=/sys/fs/cgroup,options=rbind:rw \
	docker.io/kitt0hsu/kubelet:v1.20.5 kubeletd \
	kubelet --register-node --network-plugin=cni --hostname-override=${HOSTNAME} --node-ip=${NODE_IP} \
	--config=/var/lib/kubelet/config.yaml --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf \
	--container-runtime=remote \
	--container-runtime-endpoint=unix:///run/containerd/containerd.sock \
	--image-service-endpoint=unix:///run/containerd/containerd.sock \
	--runtime-request-timeout=15m --v=5