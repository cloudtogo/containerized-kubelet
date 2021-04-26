# Containerized Kubelet

This project aims to build a containerized `kubelet` and to help get rid of dependencies to the local filesystem and binaries,
especially for custom or embedded Linux distros.

## Tags

* 1.21.0-alpine-3.13
* 1.21.0-cni-alpine-3.13
* 1.21.0-kubeadm-alpine-3.13
* 1.21.0-kubeadm-cni-alpine-3.13

## About hostpath and local storage
If the containerized `kubelet` is designed to work in container-based Linux Distro, such as CoreOS and Flatcar Container Linux, 
hostpath volume should not be used because that nothing on host can be shared by containers. 
Instead, users should save them in remote storage or attached devices.

If you would like to use local storage, you need to manually mount those devices into the `kubelet` container.
