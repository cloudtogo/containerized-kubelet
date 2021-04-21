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
RUN make crictl

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

FROM alpine:3.13
RUN apk update && apk add util-linux coreutils findutils ca-certificates conntrack-tools iptables && rm -rf /var/cache/apk/*
ARG CRI_TOOLS_BIN_PATH="build/bin"
COPY --from=k8s /go/src/k8s.io/kubernetes/_output/bin/kube* /usr/bin/
COPY --from=crictl /go/src/github.com/kubernetes-sigs/cri-tools/${CRI_TOOLS_BIN_PATH}/crictl /usr/bin/
COPY --from=cni-plugins /go/src/github.com/containernetworking/plugins/bin /opt/cni/bin/

WORKDIR /

ENV HOSTNAME=""
ENV NODE_IP=""

COPY kubelet-config.yaml /var/lib/kubelet/config.yaml
ENTRYPOINT kubelet --network-plugin=cni --hostname-override=${HOSTNAME} --node-ip=${NODE_IP} --config=/var/lib/kubelet/config.yaml