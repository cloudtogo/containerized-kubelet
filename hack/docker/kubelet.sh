#!/usr/bin/env bash

docker run -d --restart=always --name=kubeletd --network=host --pid=host --privileged \
	--env HOSTNAME=Hytera \
	--env NODE_IP=10.10.10.200 \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v /etc/resolv.conf:/etc/resolv.conf \
	-v /sys/fs/cgroup:/sys/fs/cgroup \
	--mount type=bind,src=/opt/docker-root/overlay2,dst=/opt/docker-root/overlay2,bind-propagation=rshared \
	--mount type=bind,src=/opt/docker-root/image/overlay2,dst=/opt/docker-root/image/overlay2,bind-propagation=rshared \
	--mount type=bind,src=/opt/docker-root/containers,dst=/opt/docker-root/containers,bind-propagation=rshared \
	--mount type=bind,src=/var/lib/kubelet,dst=/var/lib/kubelet,bind-propagation=rshared \
	-v /var/log/pods:/var/log/pods \
	-v /opt/kubernetes:/etc/kubernetes -v /opt/cni/net.d:/etc/cni/net.d \
	--entrypoint kubelet \
	docker.io/kitt0hsu/kubelet:v1.20.5 --hostname-override=Hytera --node-ip=10.10.10.200 \
	--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf \
	--register-node --network-plugin=cni --config=/var/lib/kubelet/config.yaml --v=5



docker run -d --restart=always --name=kubeletd --network=host --pid=host --privileged \
	--env HOSTNAME=Hytera \
	--env NODE_IP=10.10.10.200 \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v /etc/resolv.conf:/etc/resolv.conf \
	-v /sys/fs/cgroup:/sys/fs/cgroup \
	--mount type=bind,src=/opt/docker-root/overlay2,dst=/opt/docker-root/overlay2,bind-propagation=rshared \
	--mount type=bind,src=/opt/docker-root/image/overlay2,dst=/opt/docker-root/image/overlay2,bind-propagation=rshared \
	--mount type=bind,src=/opt/docker-root/containers,dst=/opt/docker-root/containers,bind-propagation=rshared \
	--mount type=bind,src=/var/lib/kubelet,dst=/var/lib/kubelet,bind-propagation=rshared \
	-v /var/log/pods:/var/log/pods \
	-v /opt/kubernetes:/etc/kubernetes -v /opt/cni/net.d:/etc/cni/net.d \
	--entrypoint kubelet \
	docker.io/kitt0hsu/kubelet:v1.16.9 --hostname-override=Hytera --node-ip=10.10.10.200 \
	--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf \
	--register-node --network-plugin=cni --config=/var/lib/kubelet/config.yaml --v=5