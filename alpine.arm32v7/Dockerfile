# Multi-arch
FROM docker.io/cloudtogo/curl-downloader:alpine-3 as crictl
WORKDIR /
ARG K8S_VERSIOIN
RUN curl -skL https://github.com/kubernetes-sigs/cri-tools/releases/download/v${K8S_VERSIOIN}/crictl-v${K8S_VERSIOIN}-linux-arm.tar.gz | tar -C /usr/bin/ -zxpf -

# Multi-arch
FROM docker.io/cloudtogo/curl-downloader:alpine-3 as cni-plugins
WORKDIR /
ARG CNI_PLUGINS_VERSION=0.9.1
RUN mkdir -p /opt/cni/bin && \
    curl -skL https://github.com/containernetworking/plugins/releases/download/v${CNI_PLUGINS_VERSION}/cni-plugins-linux-arm-v${CNI_PLUGINS_VERSION}.tgz | tar -C /opt/cni/bin/ -zxpf -

# ARG is not supported in the --from parameter of COPY command.
ARG K8S_VERSIOIN
FROM docker.io/cloudtogo/kubernetes-source:v${K8S_VERSIOIN} as k8s-src

FROM arm32v7/golang:1.16-alpine as k8s
RUN apk update && apk add make build-base bash rsync && rm -rf /var/cache/apk/*
WORKDIR /go/src/k8s.io/kubernetes
COPY --from=k8s-src /go/src/k8s.io/kubernetes ./
USER root
ENV CGO_ENABLED="1"
ENV KUBE_VERBOSE=5
ENV KUBE_BUILD_PLATFORMS=linux/amd64
RUN make WHAT=cmd/kubelet GOFLAGS=-v
RUN make WHAT=cmd/kubeadm GOFLAGS=-v

FROM arm32v7/alpine:3
RUN apk update && apk add util-linux coreutils findutils ca-certificates conntrack-tools iptables && rm -rf /var/cache/apk/*

COPY --from=k8s /go/src/k8s.io/kubernetes/_output/local/bin/linux/amd64/* /usr/bin/
COPY --from=crictl /usr/bin/crictl /usr/bin/
COPY --from=cni-plugins /opt/cni/bin /opt/cni/bin/

WORKDIR /

ENV HOSTNAME=""
ENV NODE_IP=""

COPY kubelet-config.yaml /var/lib/kubelet/config.yaml
ENTRYPOINT kubelet --network-plugin=cni --hostname-override=${HOSTNAME} --node-ip=${NODE_IP} --config=/var/lib/kubelet/config.yaml