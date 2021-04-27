# Containerized Kubelet

This project aims to build multi-arch `kubelet` images and help get rid of dependencies to the local filesystem,
especially for custom or embedded Linux distros. 

It also tries to optimize on image size to work on devices that have limited storage capacity.

All images are based on alpine:3.13 with CGO enabled. 
They are available on [cloudtogo4edge/kubelet](https://hub.docker.com/r/cloudtogo4edge/kubelet).

## Tags

### Tag style
* `v1.xx.yy` : kubelet and its dependent system commands. (smallest)
* `v1.xx.yy-cni` : kubelet and CNI plugins.
* `v1.xx.yy-kubeadm` : kubelet and kubeadm, without CNI plugins.
* `v1.xx.yy-kubeadm-cni` : kubelet, kubeadm, and CNI plugins. (largest)

### v1.21.0

`Compressed / Extracted` Size Matrix

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.21.0`](https://hub.docker.com/layers/cloudtogo4edge/kubelet/v1.21.0/images/sha256-a4c25ac5eff6874d2e455b74d0e0537689b4d4b5b5ead9da4bdf8ae23890dd45?context=explore)| `52 MB / 181 MB`|`48 MB / 168 MB`|`47 MB / 147 MB`|
|[`v1.21.0-cni`](https://hub.docker.com/layers/cloudtogo4edge/kubelet/v1.21.0-cni/images/sha256-f75863a27cb816a303bf563070a3f82285b16c91c32873722721dfcf79dce050?context=explore)| `88 MB / 251 MB`|`82 MB / 236 MB`|`82 MB / 210 MB`|
|[`v1.21.0-kubeadm`](https://hub.docker.com/layers/cloudtogo4edge/kubelet/v1.21.0-kubeadm/images/sha256-6db0d153f779cba7bf399ac7730beeed595d3b55041fc6433299ec0fd50dde69?context=explore)| `64 MB / 227 MB`|`59 MB / 211 MB`|` 59 MB / 185 MB`|
|[`v1.21.0-kubeadm-cni`](https://hub.docker.com/layers/cloudtogo4edge/kubelet/v1.21.0-kubeadm-cni/images/sha256-937fd41dce829c40b73608cf16fcd2420aea2abc3aba254082c631fadf3af1c8?context=explore)| `101 MB / 297 MB`|`93 MB / 279 MB`|`93 MB / 249 MB`|

### v1.20.6

Compressed/Extracted Size Matrix

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.20.6`](https://hub.docker.com/layers/cloudtogo4edge/kubelet/v1.20.6/images/sha256-ea9aaa325037cde19b1ba76bdcba25e5fca6825d9a590a51a527f16dd72fff05?context=explore)| `50 MB / 175 MB`|`47 MB / 163 MB`|`46 MB / 142 MB`|
|[`v1.20.6-cni`](https://hub.docker.com/layers/cloudtogo4edge/kubelet/v1.20.6-cni/images/sha256-a30a81d19fa39912a8a039c52d311e0865fc423c3707a5b377a191256dc7dc8d?context=explore)| `87 MB / 246 MB`|`81 MB / 231 MB`|`80 MB / 206 MB`|
|[`v1.20.6-kubeadm`](https://hub.docker.com/layers/cloudtogo4edge/kubelet/v1.20.6-kubeadm/images/sha256-d05f274c51cd7505d2979ac0a54683a03d30e98ac249cecf365e50e7ad5379b3?context=explore)| `61 MB / 215 MB`|`56 MB / 200 MB`|`56 MB / 175 MB`|
|[`v1.20.6-kubeadm-cni`](https://hub.docker.com/layers/cloudtogo4edge/kubelet/v1.20.6-kubeadm-cni/images/sha256-23922e7cd76f8b30cb90853ac6395fc80f13e55a71711874f0adec35955af191?context=explore)| `98 MB / 285 MB`|`90 MB / 268 MB`|`90 MB / 238 MB`|

### v1.19.10

Compressed/Extracted Size Matrix

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.19.10`](https://hub.docker.com/layers/cloudtogo4edge/kubelet/v1.19.10/images/sha256-ed29b3f97851acbf5345937a8e63ef35d9fd30b46eb7df53cefcad7fd7d75a17?context=explore)| `45 MB / 157 MB`|`41 MB / 146 MB`|`41 MB / 126 MB`|
|[`v1.19.10-cni`](https://hub.docker.com/layers/cloudtogo4edge/kubelet/v1.19.10-cni/images/sha256-034f452ba4bfb9c1cf92ff3f15688990ffefa5bdc2b86d1ccafc517dbbbab21d?context=explore)| `81 MB / 227 MB`|`75 MB / 214 MB`|`75 MB / 190 MB`|
|[`v1.19.10-kubeadm`](https://hub.docker.com/layers/cloudtogo4edge/kubelet/v1.19.10-kubeadm/images/sha256-5959d7c9751346bcc009df494b2f7efd8b77a845792a84ff5f9d3bb6f7210bc4?context=explore)| `55 MB / 196 MB`|`51 MB / 182 MB`|`50 MB / 159 MB`|
|[`v1.19.10-kubeadm-cni`](https://hub.docker.com/layers/cloudtogo4edge/kubelet/v1.19.10-kubeadm-cni/images/sha256-4a5d2fe1f6c6ff429d067f8f2d3b7e2233f864080bd10592434d455cb3a3da85?context=explore)| `92 MB / 266 MB`|`85 MB / 250 MB`|`85 MB / 223 MB`|

### v1.18.18

Compressed/Extracted Size Matrix

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[`v1.18.18`](https://hub.docker.com/layers/cloudtogo4edge/kubelet/v1.18.18/images/sha256-7cbdca791c6d9c2e0e5e95197754fa904174de7f3fc7dcec5445f5370c6ff967?context=explore)| `42 MB / 148 MB`|`39 MB / 137 MB`|`38 MB / 119 MB`|
|[`v1.18.18-cni`](https://hub.docker.com/layers/cloudtogo4edge/kubelet/v1.18.18-cni/images/sha256-dd69f5b4e6da9aa380dc0f2efbe11b4dd6773ab76fc7a1aebe61d283a1c2b3b3?context=explore)| `78 MB / 218 MB`|`73 MB / 205 MB`|`73 MB / 182 MB`|
|[`v1.18.18-kubeadm`](https://hub.docker.com/layers/cloudtogo4edge/kubelet/v1.18.18-kubeadm/images/sha256-3694400e7f1cd6dd55a9270b5a73e6f6d6478665e2a6ca61b40e692dcc59d4ad?context=explore)| `52 MB / 185 MB`|`48 MB / 172 MB`|`48 MB / 150 MB`|
|[`v1.18.18-kubeadm-cni`](https://hub.docker.com/layers/cloudtogo4edge/kubelet/v1.18.18-kubeadm-cni/images/sha256-d5e61b8685fd65c1c33350c565643a1fead0615deb4efd1ae0550c4035c71bd2?context=explore)| `89 MB / 255 MB`|`82 MB / 239 MB`|`82 MB / 213 MB`|

## About hostpath and local storage
If the `kubelet` image is desired to work in container-based Linux Distro, such as CoreOS or Flatcar Container Linux, 
hostpath volume should not be used because that nothing on host can be shared by containers. 
Instead, users should save them in remote storage or attached devices.

If you would like to use local storage, you need to manually mount those devices into the `kubelet` container.
