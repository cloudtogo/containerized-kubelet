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

### About hostpath and local storage
If the `kubelet` image is desired to work in container-based Linux Distro, such as CoreOS or Flatcar Container Linux, 
hostpath volume should not be used because that nothing on host can be shared by containers. 
Instead, users should save them in remote storage or attached devices.

If you would like to use local storage, you need to manually mount those devices into the `kubelet` container.

### Join the cluster

### Start kubelet
