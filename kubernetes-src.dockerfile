FROM docker.io/cloudtogo4edge/curl-downloader:alpine-3 as builder
ARG K8S_VERSIOIN
WORKDIR /go/src/k8s.io/
RUN curl -skL https://github.com/kubernetes/kubernetes/archive/refs/tags/v${K8S_VERSIOIN}.tar.gz | tar zxpf - \
    && mv kubernetes-${K8S_VERSIOIN} kubernetes

ARG CRICTL_VERSION
WORKDIR /go/src/github.com/kubernetes-sigs/
RUN curl -skL https://github.com/kubernetes-sigs/cri-tools/archive/refs/tags/v${CRICTL_VERSION}.tar.gz | tar zxpf - \
    && mv cri-tools-${CRICTL_VERSION} cri-tools

ARG CNI_PLUGINS_VERSION=0.9.1
WORKDIR /go/src/github.com/containernetworking/
RUN curl -skL https://github.com/containernetworking/plugins/archive/refs/tags/v${CNI_PLUGINS_VERSION}.tar.gz | tar zxpf - \
    && mv plugins-${CNI_PLUGINS_VERSION} plugins

FROM scratch
WORKDIR /
COPY --from=builder /go/src/k8s.io/kubernetes /go/src/k8s.io/kubernetes/
COPY --from=builder /go/src/github.com/kubernetes-sigs /go/src/github.com/kubernetes-sigs/
COPY --from=builder /go/src/github.com/containernetworking /go/src/github.com/containernetworking/