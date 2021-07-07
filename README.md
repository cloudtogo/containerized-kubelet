# Containerized Kubelet

This project aims to build multi-arch `kubelet` images and help get rid of dependencies to the local filesystem,
especially for custom or embedded Linux distros. 

It also tries to optimize on image size to work on devices that have limited storage capacity.
Unlike k3s, it doesn't compress dependencies into binaries and extract them after installing.
It tries to identify necessary components in different scenarios and provide just the required binaries.
Users can pull images that just match their requirements.
It also compresses non-daemon binaries via upx, such as cni-plugins, crictl, and kubeadm,
those binaries will be only extracted in executing. 

All images are based on alpine:3.13 with CGO enabled. 
They are available on [cloudtogo4edge/kubelet](https://hub.docker.com/r/cloudtogo4edge/kubelet).

We also provide a multi-arch kube-proxy image based on alpine3.13. Its size is less than half of the size of the official one.
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
* `v1.xx.yy-alpine3.13` : kubelet and its dependent system commands. (smallest)
* `v1.xx.yy-flannel-alpine3.13`: kubelet and CNI plugins required by flannel.
* `v1.xx.yy-cni-alpine3.13` : kubelet and CNI plugins.
* `v1.xx.yy-kubeadm-alpine3.13` : kubelet and kubeadm, without CNI plugins.
* `v1.xx.yy-kubeadm-cni-alpine3.13` : kubelet, kubeadm, and CNI plugins. (largest)

### `Compressed / Extracted` Size Matrix

#### v1.21.1

[`cloudtogo4edge/kubelet v1.21.1`](https://hub.docker.com/r/cloudtogo4edge/kubelet/tags?page=1&ordering=last_updated&name=v1.21.1)

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.21.1-alpine3.13`]()| `24.17MB / 80.16MB`|`22.21MB / 74.46MB`|`21.84MB / 63.82MB`|
|[`v1.21.1-flannel-alpine3.13`]()| `28.82MB / 85.13MB`|`26.44MB / 79.01MB`|`26.12MB / 68.41MB`|
|[`v1.21.1-cni-alpine3.13`]()| `42.08MB / 99.34MB`|`38.48MB / 91.99MB`|`38.29MB / 81.5MB`|
|[`v1.21.1-kubeadm-alpine3.13`]()| `43.23MB / 100.8MB`|`38.25MB / 92.01MB`|` 37.02MB / 80.37MB`|
|[`v1.21.1-kubeadm-cni-alpine3.13`]()| `61.14MB / 120MB`|`54.51MB / 109.5MB`|`53.46MB / 98.05MB`|

### v1.20.7

[`cloudtogo4edge/kubelet v1.20.7`](https://hub.docker.com/r/cloudtogo4edge/kubelet/tags?page=1&ordering=last_updated&name=v1.20.7)

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.20.7-alpine3.13`]()| `24.11MB / 79.6MB`|`22.19MB / 74.13MB`|`21.83MB / 63.05MB`|
|[`v1.20.7-flannel-alpine3.13`]()| `28.75MB / 84.58MB`|`26.41MB / 78.68MB`|`26.11MB / 67.64MB`|
|[`v1.20.7-cni-alpine3.13`]()| `40.02MB / 98.79MB`|`38.45MB / 91.66MB`|`38.28MB / 80.73MB`|
|[`v1.20.7-kubeadm-alpine3.13`]()| `41.69MB / 98.68MB`|`36.94MB / 90.28MB`|`35.85MB / 78.34MB`|
|[`v1.20.7-kubeadm-cni-alpine3.13`]()| `59.6MB / 117.9MB`|`53.21MB / 107.8MB`|`52.3MB / 96.02MB`|

### v1.19.11

[`cloudtogo4edge/kubelet v1.19.11`](https://hub.docker.com/r/cloudtogo4edge/kubelet/tags?page=1&ordering=last_updated&name=v1.19.11)

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.19.11-alpine3.13`]()| `23.63MB / 77.57MB`|`21.76MB / 72.06MB`|`21.41MB / 61.41MB`|
|[`v1.19.11-flannel-alpine3.13`]()| `28.28MB / 82.54MB`|`25.99MB / 76.62MB`|`25.68MB / 66MB`|
|[`v1.19.11-cni-alpine3.13`]()| `41.54MB / 96.75MB`|`38.03MB / 89.6MB`|`37.86MB / 79.09MB`|
|[`v1.19.11-kubeadm-alpine3.13`]()| `39.48MB / 94.72MB`|`35.1MB / 86.62MB`|`34.25MB / 75.37MB`|
|[`v1.19.11-kubeadm-cni-alpine3.13`]()| `57.39MB / 113.9MB`|`51.37MB / 104.2MB`|`50.7MB / 93.05MB`|

### v1.18.19

[`cloudtogo4edge/kubelet v1.18.19`](https://hub.docker.com/r/cloudtogo4edge/kubelet/tags?page=1&ordering=last_updated&name=v1.18.19)

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.18.19-alpine3.13`]()| `23.01MB / 75.13MB`|`21.19MB / 69.79MB`|`20.83MB / 59.38MB`|
|[`v1.18.19-flannel-alpine3.13`]()| `27.65MB / 80.1MB`|`25.42MB / 74.34MB`|`25.1MB / 63.97MB`|
|[`v1.18.19-cni-alpine3.13`]()| `40.92MB / 94.31MB`|`37.46MB / 87.32MB`|`37.28MB / 77.06MB`|
|[`v1.18.19-kubeadm-alpine3.13`]()| `37.76MB / 91.09MB`|`33.61MB / 83.33MB`|`32.76MB / 72.35MB`|
|[`v1.18.19-kubeadm-cni-alpine3.13`]()| `55.67MB / 110.3MB`|`49.88MB / 100.9MB`|`49.2MB / 90.03MB`|

### Alpine 3.13 based kube-proxy image

[`cloudtogo4edge/kube-proxy`](https://hub.docker.com/r/cloudtogo4edge/kube-proxy)

* [`v1.21.1-alpine3.13`]()
* [`v1.20.7-alpine3.13`]()
* [`v1.19.11-alpine3.13`]()
* [`v1.18.19-alpine3.13`]()

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
  cloudtogo4edge/kubelet:v1.20.7-kubeadm-alpine3.13 \
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
  docker.io/cloudtogo4edge/kubelet:v1.20.7-kubeadm-alpine3.13 kubeadm0 \
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
    cloudtogo4edge/kubelet:v1.20.7-cni-alpine3.13
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
  docker.io/cloudtogo4edge/kubelet:v1.20.7-cni-alpine3.13 kubeletd \
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