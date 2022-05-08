# ARG is not supported in the --from parameter of COPY command.
# Multi-arch
ARG ALPINE_VERSION
ARG K8S_VERSIOIN
FROM docker.io/cloudtogo4edge/kubernetes-source:v${K8S_VERSIOIN}-alpine${ALPINE_VERSION} as src

FROM golang:1.18.1-alpine${ALPINE_VERSION} as builder-base
RUN apk add --no-cache make build-base bash rsync linux-headers

FROM builder-base as crictl
WORKDIR /go/src/github.com/kubernetes-sigs/cri-tools
COPY --from=src /go/src/github.com/kubernetes-sigs/cri-tools ./
ENV CGO_ENABLED="1"
ARG CRICTL_VERSION
RUN make crictl VERSION=${CRICTL_VERSION} GO_LDFLAGS="-X github.com/kubernetes-sigs/cri-tools/pkg/version.Version=${CRICTL_VERSION} -s -w"

FROM builder-base as cni-plugins
WORKDIR /go/src/github.com/containernetworking/plugins
COPY --from=src /go/src/github.com/containernetworking/plugins ./
ENV CGO_ENABLED="1"
RUN ./build_linux.sh -ldflags "-s -w"

FROM builder-base as k8s
WORKDIR /go/src/k8s.io/kubernetes
COPY --from=src /go/src/k8s.io/kubernetes ./
USER root
ENV CGO_ENABLED="1"
ENV GOFLAGS="-tags=providerless"
RUN make WHAT=cmd/kubelet
RUN make WHAT=cmd/kubeadm
RUN make WHAT=cmd/kube-proxy

FROM docker.io/cloudtogo4edge/upx:3.96 as compressor
ARG CRI_TOOLS_BIN_PATH="build/bin"
COPY --from=crictl /go/src/github.com/kubernetes-sigs/cri-tools/${CRI_TOOLS_BIN_PATH}/crictl /crictl/
RUN for bin in /crictl/*; do upx --best $bin; done
COPY --from=k8s /go/src/k8s.io/kubernetes/_output/bin/kubeadm /kubeadm/
RUN for bin in /kubeadm/*; do upx --best $bin; done
COPY --from=cni-plugins /go/src/github.com/containernetworking/plugins/bin /cni-plugins/
RUN for bin in /cni-plugins/*; do upx --best $bin; done

FROM scratch
ARG CRI_TOOLS_BIN_PATH="build/bin"
COPY --from=compressor /crictl /crictl/
COPY --from=k8s /go/src/k8s.io/kubernetes/_output/bin/kubelet /kubelet/
COPY --from=compressor /kubeadm /kubeadm/
COPY --from=k8s /go/src/k8s.io/kubernetes/_output/bin/kube-proxy /kube-proxy/
COPY --from=compressor /cni-plugins /cni-plugins/