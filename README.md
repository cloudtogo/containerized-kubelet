# K8s Node Container

This project aims to build a containerized `kubelet` and to help get rid of dependencies to local filesystems and binaries,
especially for custom and embedded Linux distros.

If the containerized `kubelet` is designed to work in container-based Linux Distro, such as CoreOS, 
hostpath volume should not be used because that nothing on host can be shared by containers. 
Instead, users should save them in remote storage or attached devices.

If you would like to use local storage, you need to manually mount those devices into the `kubelet` container.


```
docker run -d --restart=always --name=kubelet --network=host --pid=host --privileged \
	--env HOSTNAME=hytera --env NODE_IP=10.10.10.200 \
	-v `pwd`/kubelet-config.yaml:/var/lib/kubelet/config.yaml \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v /var/lib/kubelet:/var/lib/kubelet -v /opt/kubernetes:/etc/kubernetes -v /opt/cni/net.d:/etc/cni/net.d \
	test.local/cloudtogo/kubelet:v0.1.0

ctr -n k8s.io run -d --privileged --net-host \
	--log-uri=/tmp/kubelet.log \
	--env HOSTNAME=minikube-m02 \
	--env NODE_IP=192.168.64.29 \
    --mount type=bind,src=/etc/systemd,dst=/etc/systemd,options=rbind \
    --mount type=bind,src=/lib/systemd,dst=/lib/systemd,options=rbind \
    --mount type=bind,src=/mnt/vda1/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs,dst=/mnt/vda1/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs,options=rbind:rshared \
	--mount type=bind,src=/var/lib/minikube/certs/ca.crt,dst=/var/lib/minikube/certs/ca.crt,options=rbind:ro \
	--mount type=bind,src=/run/systemd/resolve/resolv.conf,dst=/run/systemd/resolve/resolv.conf,options=rbind:ro \
	--mount type=bind,src=/run/containerd/containerd.sock,dst=/run/containerd/containerd.sock,options=rbind \
	--mount type=bind,src=/var/lib/kubelet,dst=/var/lib/kubelet,options=rbind:rshared \
    --mount type=bind,src=/var/log/pods,dst=/var/log/pods,options=rbind \
	--mount type=bind,src=/etc/kubernetes,dst=/etc/kubernetes,options=rbind \
	--mount type=bind,src=/etc/cni/net.d,dst=/etc/cni/net.d,options=rbind \
	--mount type=bind,src=/sys/fs/cgroup,dst=/sys/fs/cgroup,options=rbind \
	docker.io/kitt0hsu/kubelet:v1.20.5 kubelet \
	kubelet --register-node --network-plugin=cni --hostname-override=${HOSTNAME} --node-ip=${NODE_IP} \
	--config=/var/lib/kubelet/config.yaml --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf \
	--container-runtime=remote \
	--container-runtime-endpoint=unix:///run/containerd/containerd.sock \
	--image-service-endpoint=unix:///run/containerd/containerd.sock \
	--runtime-request-timeout=15m --v=5

ctr -n k8s.io run --rm --privileged --net-host \
	--log-uri=/tmp/kubelet.log \
	--env HOSTNAME=minikube-m02 \
	--env NODE_IP=192.168.64.29 \
    --mount type=bind,src=/lib/modules,dst=/lib/modules,options=rbind \
	--mount type=bind,src=/run/containerd/containerd.sock,dst=/run/containerd/containerd.sock,options=rbind \
	--mount type=bind,src=/var/lib/kubelet,dst=/var/lib/kubelet,options=rbind \
    --mount type=bind,src=/var/log/pods,dst=/var/log/pods,options=rbind \
	--mount type=bind,src=/etc/kubernetes,dst=/etc/kubernetes,options=rbind \
	--mount type=bind,src=/etc/cni/net.d,dst=/etc/cni/net.d,options=rbind \
	docker.io/kitt0hsu/kubelet:v1.20.5 kubeadm \
	kubeadm join 192.168.64.26:8443 --token id2p6d.h6w0wbntqp8wajj5     --discovery-token-ca-cert-hash sha256:33c6538ef24069827dbcac46e7b43079d2c4d471dc040fc330425bdd25c591c3

ctr -n k8s.io run --rm --privileged --net-host \
	--log-uri=/tmp/kubelet.log \
	--env HOSTNAME=minikube-m02 \
	--env NODE_IP=192.168.64.29 \
    --mount type=bind,src=/lib/modules,dst=/lib/modules,options=rbind \
	--mount type=bind,src=/run/containerd/containerd.sock,dst=/run/containerd/containerd.sock,options=rbind \
	--mount type=bind,src=/var/lib/kubelet,dst=/var/lib/kubelet,options=rbind \
    --mount type=bind,src=/var/log/pods,dst=/var/log/pods,options=rbind \
	--mount type=bind,src=/etc/kubernetes,dst=/etc/kubernetes,options=rbind \
	--mount type=bind,src=/etc/cni/net.d,dst=/etc/cni/net.d,options=rbind \
	docker.io/kitt0hsu/kubelet:v1.20.5 kubeadm \
	kubeadm reset

docker run -d --restart=always --name=kubelet --network=host --pid=host --privileged \
	--env HOSTNAME=n1.ws.env.lab.io \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v /sys/fs/cgroup:/sys/fs/cgroup \
	-v /var/lib/docker:/var/lib/docker \
	-v /var/lib/kubelet:/var/lib/kubelet \
	--mount type=bind,src=/var/lib/kubelet/kubelet-config.yaml,dst=/var/lib/kubelet/config.yaml \
	-v /etc/kubernetes:/etc/kubernetes -v /etc/cni/net.d:/etc/cni/net.d \
	docker.io/kitt0hsu/kubelet:v1.20.5 kubelet --hostname-override=${HOSTNAME} --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf \
	--register-node --network-plugin=cni --config=/var/lib/kubelet/config.yaml

docker run -ti --rm --network=host --pid=host --privileged \
	--env HOSTNAME=10.38.1.41 \
	-v /boot:/boot \
	-v /lib/modules:/lib/modules \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v /var/lib/kubelet:/var/lib/kubelet \
	-v /etc/kubernetes:/etc/kubernetes -v /etc/cni/net.d:/etc/cni/net.d \
	docker.io/kitt0hsu/kubelet:v1.20.5 kubeadm join 192.168.64.26:8443 --token haylue.goqjy3om7yf31zts     --discovery-token-ca-cert-hash sha256:33c6538ef24069827dbcac46e7b43079d2c4d471dc040fc330425bdd25c591c3
```

mount /boot and /lib/modules for kubeadm

/var/lib/minikube/binaries/v1.20.2/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --config=/var/lib/kubelet/config.yaml --container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock --hostname-override=minikube-m02 --image-service-endpoint=unix:///run/containerd/containerd.sock --kubeconfig=/etc/kubernetes/kubelet.conf --network-plugin=cni --node-ip=192.168.64.29 --runtime-request-timeout=15m


























