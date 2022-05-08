# Containerized Kubelet

This project aims to build multi-arch `kubelet` images and help get rid of dependencies to the local filesystem,
especially for custom or embedded Linux distros. 

It also tries to optimize on image size to work on devices that have limited storage capacity.
Unlike k3s, it doesn't compress dependencies into binaries and extract them after installing.
It tries to identify necessary components in different scenarios and provide just the required binaries.
Users can pull images that just match their requirements.
It also compresses non-daemon binaries via upx, such as cni-plugins, crictl, and kubeadm,
those binaries will be only extracted in executing. 

All images are based on alpine:3.15 with CGO enabled.
They are available on [cloudtogo4edge/kubelet](https://hub.docker.com/r/cloudtogo4edge/kubelet).

We also provide a multi-arch kube-proxy image based on alpine3.15. Its size is less than half of the size of the official one.
It is available on [cloudtogo4edge/kube-proxy](https://hub.docker.com/r/cloudtogo4edge/kube-proxy).

- [Tags](#tags)
    * [kubelet](#tag-style)
    * [kube-proxy](#alpine-313-based-kube-proxy-image)
- [Usage](#usage)
    * [Join the cluster](#join-the-cluster)
        - [Docker](#docker)
        - [Containerd](#containerd)
    * [Start kubelet](#start-kubelet)
        - [Docker](#docker-1)
        - [Containerd](#containerd-1)
    * [About hostpath and local storage](#about-hostpath-and-local-storage)
- [Test](#test)
    * [Setup a multi-node cluster](#setup-a-multi-node-cluster)
    * [e2e test](#e2e-test)

## Tags

### Tag style
* `v1.xx.yy-alpine3.15` : kubelet and its dependent system commands. (smallest)
* `v1.xx.yy-flannel-alpine3.15`: kubelet and CNI plugins required by flannel.
* `v1.xx.yy-cni-alpine3.15` : kubelet and CNI plugins.
* `v1.xx.yy-kubeadm-alpine3.15` : kubelet and kubeadm, without CNI plugins.
* `v1.xx.yy-kubeadm-cni-alpine3.15` : kubelet, kubeadm, and CNI plugins. (largest)

### `Compressed / Extracted` Size Matrix

#### v1.24.0

[`cloudtogo4edge/kubelet v1.24.0`](https://hub.docker.com/r/cloudtogo4edge/kubelet/tags?page=1&ordering=last_updated&name=v1.24.0)

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.24.0-alpine3.15`]()| `24.75MB / 75.46MB`|`23.28MB / 73.35MB`|`22.79MB / 66.54MB`|
|[`v1.24.0-flannel-alpine3.15`]()| `29.27MB / 80.07MB`|`27.42MB / 77.60MB`|`27.04MB / 70.90MB`|
|[`v1.24.0-cni-alpine3.15`]()| `42.38MB / 93.47MB`|`39.45MB / 89.95MB`|`39.29MB / 83.47MB`|
|[`v1.24.0-kubeadm-alpine3.15`]()| `42.94MB / 94.24MB`|`38.89MB / 89.58MB`|`37.67MB / 81.99MB`|
|[`v1.24.0-kubeadm-cni-alpine3.15`]()| `60.57MB / 112.24MB`|`55.06MB / 106.17MB`|`54.17MB / 98.92MB`|
#### v1.23.6

[`cloudtogo4edge/kubelet v1.23.6`](https://hub.docker.com/r/cloudtogo4edge/kubelet/tags?page=1&ordering=last_updated&name=v1.23.6)

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.23.6-alpine3.15`]()| `24.94MB / 80.19MB`|`23.49MB / 78.74MB`|`22.76MB / 66.81MB`|
|[`v1.23.6-flannel-alpine3.15`]()| `29.35MB / 84.70MB`|`27.57MB / 82.93MB`|`26.87MB / 71.03MB`|
|[`v1.23.6-cni-alpine3.15`]()| `42.08MB / 97.71MB`|`39.29MB / 94.98MB`|`38.63MB / 83.10MB`|
|[`v1.23.6-kubeadm-alpine3.15`]()| `43.84MB / 99.77MB`|`39.65MB / 95.61MB`|`37.81MB / 82.49MB`|
|[`v1.23.6-kubeadm-cni-alpine3.15`]()| `60.98MB / 117.29MB`|`55.45MB / 111.85MB`|`53.69MB / 98.78MB`|
#### v1.22.9

[`cloudtogo4edge/kubelet v1.22.9`](https://hub.docker.com/r/cloudtogo4edge/kubelet/tags?page=1&ordering=last_updated&name=v1.22.9)

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.22.9-alpine3.15`]()| `24.21MB / 77.00MB`|`22.85MB / 75.43MB`|`22.05MB / 63.70MB`|
|[`v1.22.9-flannel-alpine3.15`]()| `28.62MB / 81.51MB`|`26.92MB / 79.62MB`|`26.17MB / 67.92MB`|
|[`v1.22.9-cni-alpine3.15`]()| `41.35MB / 94.52MB`|`38.64MB / 91.67MB`|`37.93MB / 79.99MB`|
|[`v1.22.9-kubeadm-alpine3.15`]()| `42.87MB / 96.34MB`|`38.80MB / 92.09MB`|`36.95MB / 79.21MB`|
|[`v1.22.9-kubeadm-cni-alpine3.15`]()| `60.01MB / 113.86MB`|`54.60MB / 108.33MB`|`52.82MB / 95.50MB`|
#### Alpine 3.13 based kube-proxy image

[`cloudtogo4edge/kube-proxy`](https://hub.docker.com/r/cloudtogo4edge/kube-proxy)

* [`v1.24.0-alpine3.15`]()
* [`v1.23.6-alpine3.15`]()
* [`v1.22.9-alpine3.15`]()

## Usage

### Join the cluster

Users can join nodes into a cluster via images with tags contain `kubeadm`.
Before joining, users should create a bootstrap token via a authenticated kubeadm by running the command below.

```shell script
$ kubeadm token create --print-join-command
kubeadm join control-plane.minikube.internal:8443 --token putlik.1dgfo3518jdyix3a     --discovery-token-ca-cert-hash sha256:33c6538ef24069827dbcac46e7b43079d2c4d471dc040fc330425bdd25c591c3
```

Then, two directories are required by kubelet on each node, which are `/etc/kubernetes` and `/var/lib/kubelet`.

```shell script
mkdir -p /etc/kubernetes /var/lib/kubelet
```

#### Docker

Users also need to start kubelet on nodes before executing `kubeadm join ...`. See [Start kubelet](#docker-1)

For docker, run the following command to join nodes.

```shell script
docker run --rm --network=host --pid=host --uts=host \
  -v /etc/kubernetes:/etc/kubernetes \
  -v /var/lib/kubelet:/var/lib/kubelet \
  --entrypoint kubeadm \
  cloudtogo4edge/kubelet:v1.23.2-kubeadm-alpine3.15 \
  join control-plane.minikube.internal:8443 --token putlik.1dgfo3518jdyix3a     --discovery-token-ca-cert-hash sha256:33c6538ef24069827dbcac46e7b43079d2c4d471dc040fc330425bdd25c591c3
```

Note that, the script above,
1. Needs two host paths `/etc/kubernetes` and `/var/lib/kubelet` to be mounted,
2. Replaces the original entrypoint with `kubeadm` through `--entrypoint`,
3. Runs the command `kubeadm token create` generated before.

#### Containerd

Since the containerd client `ctr` doesn't support creating containers that can be restarted on failure,
users should start kubelet after kubeadm created configuration.

Run the following command to start kubeadm and check the output.
```shell script
ctr -n k8s.io run -t --privileged --net-host --runtime=io.containerd.runtime.v1.linux --rm \
  --with-ns="pid:/proc/1/ns/pid" --with-ns="uts:/proc/1/ns/uts" \
  --mount type=bind,src=/var/lib/kubelet,dst=/var/lib/kubelet,options=rbind:rw \
  --mount type=bind,src=/etc/kubernetes,dst=/etc/kubernetes,options=rbind:rw \
  --rootfs-propagation=rshared \
  docker.io/cloudtogo4edge/kubelet:v1.23.2-kubeadm-alpine3.15 kubeadm0 \
  kubeadm join control-plane.minikube.internal:8443 --token putlik.1dgfo3518jdyix3a     --discovery-token-ca-cert-hash sha256:33c6538ef24069827dbcac46e7b43079d2c4d471dc040fc330425bdd25c591c3
```

If seeing the output below, all configuration are well-created. You can press `ctrl+c` to stop kubeadm, then [start kubelet](#containerd-1).
```shell script
...
[kubelet-start] Starting the kubelet
[kubelet-start] no supported init system detected, won't make sure the kubelet is running properly.
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...
```

### Start kubelet

The default entrypoint of the kubelet image is `kubelet --config=/var/lib/kubelet/config.yaml --register-node --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf`.
If you use an image has a tag contains cni, a command line flag `--network-plugin=cni` is append automatically.
The command line flags can be changed by passing custom arguments whiling creating the kubelet container as well as specifying `--entrypoint=kubelet`.

#### Host Path Mounts

The following host paths should be mounted to the kubelet container.

| Source/Target | Propagation | Required | Description |
| --- | --- | --- | --- |
| `/etc/machine-id` `/var/lib/dbus/machine-id` | default | no | - |
| `/sys/fs/cgroup` | default | yes | cgroups |
| `/var/lib/kubelet` | **rshared** | yes | kubelet root |
| `/var/log/pods` | default | yes | pod logs |
| `/etc/kubernetes` | default | yes | kubelet configuration |
| `/etc/cni/net.d` | default | if cni is enabled | CNI configuration |
| `/run/flannel` | default | if flannel is used | run root of flannel |
| Paths in the file `/var/lib/kubelet/config.yaml` | default | yes | kubelet configuration |

#### Docker

| Source/Target | Propagation | Required | Description |
| --- | --- | --- | --- |
| `/var/run/docker.sock` | default | yes | docker endpoint |
| `/var/lib/docker/overlay2` | **rshared** | yes | docker storage root, will vary depends on the docker storage driver. |
| `/var/lib/docker/image/overlay2` | **rshared** | yes | docker image root, will vary depends on the docker storage driver |
| `/var/lib/docker/containers` | **rshared** | yes | docker container root |

Host paths above should also be mounted. Run the following command to start the kubelet container.
```shell script
mkdir -p /var/lib/kubelet /var/log/pods /etc/kubernetes
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
    cloudtogo4edge/kubelet:v1.23.2-cni-alpine3.15
```

#### Containerd

| Source/Target | Propagation | Required | Description |
| --- | --- | --- | --- |
| `/run/containerd/containerd.sock` | default | yes | containerd endpoint |
| `/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs` | **rshared** | yes | containerd storage root |

Host paths above should also be mounted. 

The current official `ctr`(v1.5.0) doesn't support setting propagation of container rootfs.
We built a new version of `ctr` which supports command line flags `--rootfs-propagation`.
Users can download it from [our release page](https://github.com/cloudtogo/containerd/releases/tag/v1.5.0-propagation).

```shell script
touch /tmp/kubelet.log
ctr -n k8s.io run -d --privileged --net-host --runtime=io.containerd.runtime.v1.linux \
  --with-ns="pid:/proc/1/ns/pid" --with-ns="uts:/proc/1/ns/uts" \
  --log-uri=/tmp/kubelet.log \
  --mount type=bind,src=/etc/machine-id,dst=/etc/machine-id,options=bind:ro --mount type=bind,src=/var/lib/dbus/machine-id,dst=/var/lib/dbus/machine-id,options=bind:ro \
  --mount type=bind,src=/sys/fs/cgroup,dst=/sys/fs/cgroup,options=rbind:rw \
  --mount type=bind,src=/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs,dst=/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs,options=rbind:rshared:rw \
  --mount type=bind,src=/run/containerd/containerd.sock,dst=/run/containerd/containerd.sock,options=bind:rw \
  --mount type=bind,src=/var/lib/kubelet,dst=/var/lib/kubelet,options=rbind:rshared:rw \
  --mount type=bind,src=/var/log/pods,dst=/var/log/pods,options=rbind:rw \
  --mount type=bind,src=/etc/kubernetes,dst=/etc/kubernetes,options=rbind:rw --mount type=bind,src=/etc/cni/net.d,dst=/etc/cni/net.d,options=rbind:ro \
  --rootfs-propagation=rshared \
  docker.io/cloudtogo4edge/kubelet:v1.23.2-cni-alpine3.15 kubeletd \
  kubelet --config=/var/lib/kubelet/config.yaml --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf \
  --register-node --network-plugin=cni --container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock
```

### About hostpath and local storage
If the `kubelet` image is desired to work in container-based Linux Distro, such as CoreOS or Flatcar Container Linux, 
hostpath volume should not be used because that nothing on host can be shared by containers. 
Instead, users should save them in remote storage or attached devices.

If you would like to use local storage, you need to manually mount those devices into the `kubelet` container.

## Test

### Setup a multi-node cluster

The `Vagrantfile` and its dependent scripts in [`test/k8s-e2e`](https://github.com/cloudtogo/containerized-kubelet/tree/master/test/k8s-e2e) can create a 2-node cluster using the current project.
If you use vagrant and **VirtualBox** as the virtual machine driver,
you can easily install project [vagrant-lan](https://github.com/warm-metal/vagrant-lan) then run `vagrant up` in the directory `test/k8s-e2e` to start a new cluster.

You can also modify the variable `K8S_VERSION` in the Vagrantfile to change the version of kubernetes. 

### e2e test