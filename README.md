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

#### v1.22.1

[`cloudtogo4edge/kubelet v1.22.1`](https://hub.docker.com/r/cloudtogo4edge/kubelet/tags?page=1&ordering=last_updated&name=v1.22.1)

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.22.1-alpine3.13`]()| `27.01MB / 92.56MB`|`25.08MB / 86.51MB`|`24.08MB / 69.14MB`|
|[`v1.22.1-flannel-alpine3.13`]()| `31.65MB / 97.30MB`|`29.31MB / 90.84MB`|`28.35MB / 73.51MB`|
|[`v1.22.1-cni-alpine3.13`]()| `44.91MB / 110.84MB`|`41.34MB / 103.22MB`|`40.52MB / 85.99MB`|
|[`v1.22.1-kubeadm-alpine3.13`]()| `46.36MB / 112.58MB`|`41.37MB / 103.50MB`|`39.47MB / 85.14MB`|
|[`v1.22.1-kubeadm-cni-alpine3.13`]()| `64.26MB / 130.86MB`|`57.63MB / 120.21MB`|`55.90MB / 101.99MB`|
#### v1.22.0

[`cloudtogo4edge/kubelet v1.22.0`](https://hub.docker.com/r/cloudtogo4edge/kubelet/tags?page=1&ordering=last_updated&name=v1.22.0)

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.22.0-alpine3.13`]()| `27.01MB / 92.55MB`|`25.08MB / 86.50MB`|`24.08MB / 69.13MB`|
|[`v1.22.0-flannel-alpine3.13`]()| `31.65MB / 97.28MB`|`29.31MB / 90.84MB`|`28.35MB / 73.51MB`|
|[`v1.22.0-cni-alpine3.13`]()| `44.91MB / 110.83MB`|`41.34MB / 103.21MB`|`40.51MB / 85.98MB`|
|[`v1.22.0-kubeadm-alpine3.13`]()| `46.36MB / 112.57MB`|`41.36MB / 103.49MB`|`39.46MB / 85.13MB`|
|[`v1.22.0-kubeadm-cni-alpine3.13`]()| `64.26MB / 130.85MB`|`57.62MB / 120.21MB`|`55.90MB / 101.99MB`|
#### v1.21.4

[`cloudtogo4edge/kubelet v1.21.4`](https://hub.docker.com/r/cloudtogo4edge/kubelet/tags?page=1&ordering=last_updated&name=v1.21.4)

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.21.4-alpine3.13`]()| `24.20MB / 76.50MB`|`22.24MB / 71.06MB`|`21.87MB / 60.90MB`|
|[`v1.21.4-flannel-alpine3.13`]()| `28.84MB / 81.24MB`|`26.47MB / 75.40MB`|`26.14MB / 65.28MB`|
|[`v1.21.4-cni-alpine3.13`]()| `42.10MB / 94.78MB`|`38.50MB / 87.77MB`|`38.30MB / 77.75MB`|
|[`v1.21.4-kubeadm-alpine3.13`]()| `43.25MB / 96.22MB`|`38.28MB / 87.80MB`|`37.04MB / 76.68MB`|
|[`v1.21.4-kubeadm-cni-alpine3.13`]()| `61.16MB / 114.50MB`|`54.54MB / 104.51MB`|`53.47MB / 93.53MB`|
#### v1.21.3

[`cloudtogo4edge/kubelet v1.21.3`](https://hub.docker.com/r/cloudtogo4edge/kubelet/tags?page=1&ordering=last_updated&name=v1.21.3)

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.21.3-alpine3.13`]()| `24.20MB / 76.49MB`|`22.24MB / 71.05MB`|`21.86MB / 60.90MB`|
|[`v1.21.3-flannel-alpine3.13`]()| `28.84MB / 81.23MB`|`26.47MB / 75.39MB`|`26.13MB / 65.27MB`|
|[`v1.21.3-cni-alpine3.13`]()| `42.10MB / 94.77MB`|`38.50MB / 87.76MB`|`38.30MB / 77.75MB`|
|[`v1.21.3-kubeadm-alpine3.13`]()| `43.25MB / 96.21MB`|`38.28MB / 87.79MB`|`37.03MB / 76.68MB`|
|[`v1.21.3-kubeadm-cni-alpine3.13`]()| `61.15MB / 114.49MB`|`54.54MB / 104.51MB`|`53.47MB / 93.53MB`|
#### v1.21.2

[`cloudtogo4edge/kubelet v1.21.2`](https://hub.docker.com/r/cloudtogo4edge/kubelet/tags?page=1&ordering=last_updated&name=v1.21.2)

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.21.2-alpine3.13`]()| `24.20MB / 76.49MB`|`22.24MB / 71.05MB`|`21.86MB / 60.90MB`|
|[`v1.21.2-flannel-alpine3.13`]()| `28.84MB / 81.23MB`|`26.47MB / 75.39MB`|`26.14MB / 65.28MB`|
|[`v1.21.2-cni-alpine3.13`]()| `42.11MB / 94.78MB`|`38.51MB / 87.77MB`|`38.31MB / 77.76MB`|
|[`v1.21.2-kubeadm-alpine3.13`]()| `43.25MB / 96.21MB`|`38.27MB / 87.79MB`|`37.03MB / 76.68MB`|
|[`v1.21.2-kubeadm-cni-alpine3.13`]()| `61.16MB / 114.50MB`|`54.54MB / 104.51MB`|`53.48MB / 93.54MB`|
#### v1.20.9

[`cloudtogo4edge/kubelet v1.20.9`](https://hub.docker.com/r/cloudtogo4edge/kubelet/tags?page=1&ordering=last_updated&name=v1.20.9)

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.20.9-alpine3.13`]()| `24.10MB / 75.90MB`|`22.18MB / 70.67MB`|`21.83MB / 60.11MB`|
|[`v1.20.9-flannel-alpine3.13`]()| `28.75MB / 80.64MB`|`26.41MB / 75.01MB`|`26.10MB / 64.48MB`|
|[`v1.20.9-cni-alpine3.13`]()| `42.01MB / 94.18MB`|`38.44MB / 87.39MB`|`38.27MB / 76.96MB`|
|[`v1.20.9-kubeadm-alpine3.13`]()| `41.69MB / 94.09MB`|`36.93MB / 86.07MB`|`35.85MB / 74.69MB`|
|[`v1.20.9-kubeadm-cni-alpine3.13`]()| `59.59MB / 112.38MB`|`53.19MB / 102.78MB`|`52.29MB / 91.54MB`|
#### v1.20.8

[`cloudtogo4edge/kubelet v1.20.8`](https://hub.docker.com/r/cloudtogo4edge/kubelet/tags?page=1&ordering=last_updated&name=v1.20.8)

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.20.8-alpine3.13`]()| `24.10MB / 75.90MB`|`22.18MB / 70.67MB`|`21.84MB / 60.11MB`|
|[`v1.20.8-flannel-alpine3.13`]()| `28.75MB / 80.64MB`|`26.41MB / 75.02MB`|`26.11MB / 64.48MB`|
|[`v1.20.8-cni-alpine3.13`]()| `42.01MB / 94.19MB`|`38.45MB / 87.39MB`|`38.28MB / 76.97MB`|
|[`v1.20.8-kubeadm-alpine3.13`]()| `41.69MB / 94.09MB`|`36.94MB / 86.07MB`|`35.85MB / 74.68MB`|
|[`v1.20.8-kubeadm-cni-alpine3.13`]()| `59.60MB / 112.38MB`|`53.20MB / 102.79MB`|`52.30MB / 91.55MB`|
#### v1.19.14

[`cloudtogo4edge/kubelet v1.19.14`](https://hub.docker.com/r/cloudtogo4edge/kubelet/tags?page=1&ordering=last_updated&name=v1.19.14)

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.19.14-alpine3.13`]()| `23.64MB / 73.96MB`|`21.76MB / 68.71MB`|`21.41MB / 58.54MB`|
|[`v1.19.14-flannel-alpine3.13`]()| `28.28MB / 78.70MB`|`25.99MB / 73.05MB`|`25.68MB / 62.92MB`|
|[`v1.19.14-cni-alpine3.13`]()| `41.54MB / 92.24MB`|`38.02MB / 85.42MB`|`37.85MB / 75.40MB`|
|[`v1.19.14-kubeadm-alpine3.13`]()| `39.48MB / 90.32MB`|`35.10MB / 82.60MB`|`34.25MB / 71.86MB`|
|[`v1.19.14-kubeadm-cni-alpine3.13`]()| `57.39MB / 108.60MB`|`51.36MB / 99.31MB`|`50.69MB / 88.71MB`|
#### v1.19.13

[`cloudtogo4edge/kubelet v1.19.13`](https://hub.docker.com/r/cloudtogo4edge/kubelet/tags?page=1&ordering=last_updated&name=v1.19.13)

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.19.13-alpine3.13`]()| `23.63MB / 73.95MB`|`21.76MB / 68.70MB`|`21.41MB / 58.54MB`|
|[`v1.19.13-flannel-alpine3.13`]()| `28.28MB / 78.69MB`|`25.98MB / 73.04MB`|`25.68MB / 62.92MB`|
|[`v1.19.13-cni-alpine3.13`]()| `41.54MB / 92.24MB`|`38.01MB / 85.42MB`|`37.84MB / 75.39MB`|
|[`v1.19.13-kubeadm-alpine3.13`]()| `39.48MB / 90.31MB`|`35.09MB / 82.59MB`|`34.25MB / 71.85MB`|
|[`v1.19.13-kubeadm-cni-alpine3.13`]()| `57.38MB / 108.59MB`|`51.35MB / 99.30MB`|`50.69MB / 88.70MB`|
#### v1.19.12

[`cloudtogo4edge/kubelet v1.19.12`](https://hub.docker.com/r/cloudtogo4edge/kubelet/tags?page=1&ordering=last_updated&name=v1.19.12)

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.19.12-alpine3.13`]()| `23.63MB / 73.95MB`|`21.76MB / 68.70MB`|`21.41MB / 58.54MB`|
|[`v1.19.12-flannel-alpine3.13`]()| `28.28MB / 78.69MB`|`25.99MB / 73.04MB`|`25.68MB / 62.92MB`|
|[`v1.19.12-cni-alpine3.13`]()| `41.54MB / 92.24MB`|`38.03MB / 85.42MB`|`37.85MB / 75.40MB`|
|[`v1.19.12-kubeadm-alpine3.13`]()| `39.48MB / 90.31MB`|`35.10MB / 82.59MB`|`34.25MB / 71.85MB`|
|[`v1.19.12-kubeadm-cni-alpine3.13`]()| `57.39MB / 108.60MB`|`51.37MB / 99.31MB`|`50.69MB / 88.71MB`|
#### v1.18.20

[`cloudtogo4edge/kubelet v1.18.20`](https://hub.docker.com/r/cloudtogo4edge/kubelet/tags?page=1&ordering=last_updated&name=v1.18.20)

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.18.20-alpine3.13`]()| `23.01MB / 71.63MB`|`21.20MB / 66.53MB`|`20.83MB / 56.60MB`|
|[`v1.18.20-flannel-alpine3.13`]()| `27.65MB / 76.37MB`|`25.42MB / 70.87MB`|`25.10MB / 60.98MB`|
|[`v1.18.20-cni-alpine3.13`]()| `40.92MB / 89.92MB`|`37.46MB / 83.25MB`|`37.27MB / 73.47MB`|
|[`v1.18.20-kubeadm-alpine3.13`]()| `37.76MB / 86.85MB`|`33.61MB / 79.45MB`|`32.76MB / 68.97MB`|
|[`v1.18.20-kubeadm-cni-alpine3.13`]()| `55.67MB / 105.14MB`|`49.88MB / 96.17MB`|`49.20MB / 85.83MB`|
#### Alpine 3.13 based kube-proxy image

[`cloudtogo4edge/kube-proxy`](https://hub.docker.com/r/cloudtogo4edge/kube-proxy)

* [`v1.22.1-alpine3.13`]()
* [`v1.22.0-alpine3.13`]()
* [`v1.21.4-alpine3.13`]()
* [`v1.21.3-alpine3.13`]()
* [`v1.21.2-alpine3.13`]()
* [`v1.20.9-alpine3.13`]()
* [`v1.20.8-alpine3.13`]()
* [`v1.19.14-alpine3.13`]()
* [`v1.19.13-alpine3.13`]()
* [`v1.19.12-alpine3.13`]()
* [`v1.18.20-alpine3.13`]()

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