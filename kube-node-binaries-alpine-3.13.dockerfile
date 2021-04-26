# ARG is not supported in the --from parameter of COPY command.
# Multi-arch
ARG K8S_VERSIOIN
FROM docker.io/cloudtogo4edge/kubernetes-source:v${K8S_VERSIOIN} as src

FROM golang:1.16-alpine3.13 as builder-base
RUN apk update && apk add make build-base bash rsync linux-headers && rm -rf /var/cache/apk/*

FROM builder-base as crictl
WORKDIR /go/src/github.com/kubernetes-sigs/cri-tools
COPY --from=src /go/src/github.com/kubernetes-sigs/cri-tools ./
ENV CGO_ENABLED="1"
ARG CRICTL_VERSION
RUN make crictl VERSION=${CRICTL_VERSION}

FROM builder-base as cni-plugins
WORKDIR /go/src/github.com/containernetworking/plugins
COPY --from=src /go/src/github.com/containernetworking/plugins ./
ENV CGO_ENABLED="1"
RUN ./build_linux.sh

FROM builder-base as k8s
WORKDIR /go/src/k8s.io/kubernetes
COPY --from=src /go/src/k8s.io/kubernetes ./
USER root
ENV CGO_ENABLED="1"
RUN make WHAT=cmd/kubelet
RUN make WHAT=cmd/kubeadm

FROM scratch
ARG CRI_TOOLS_BIN_PATH="build/bin"
COPY --from=crictl /go/src/github.com/kubernetes-sigs/cri-tools/${CRI_TOOLS_BIN_PATH}/crictl /crictl/
COPY --from=k8s /go/src/k8s.io/kubernetes/_output/bin/kubelet /kubelet/
COPY --from=k8s /go/src/k8s.io/kubernetes/_output/bin/kubeadm /kubeadm/
COPY --from=cni-plugins /go/src/github.com/containernetworking/plugins/bin /cni-plugins/
