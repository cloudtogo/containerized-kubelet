FROM docker.io/cloudtogo4edge/github-src-downloader:http-v0.0.1 as downloader
ARG K8S_VERSIOIN
WORKDIR /go/src/k8s.io/
RUN github kubernetes/kubernetes ${K8S_VERSIOIN}

ARG CRICTL_VERSION
WORKDIR /go/src/github.com/kubernetes-sigs/
RUN github kubernetes-sigs/cri-tools ${CRICTL_VERSION}

ARG CNI_PLUGINS_VERSION=0.9.1
WORKDIR /go/src/github.com/containernetworking/
RUN github containernetworking/plugins ${CNI_PLUGINS_VERSION}

FROM scratch
WORKDIR /
COPY --from=downloader /go/src/k8s.io/kubernetes /go/src/k8s.io/kubernetes/
COPY --from=downloader /go/src/github.com/kubernetes-sigs /go/src/github.com/kubernetes-sigs/
COPY --from=downloader /go/src/github.com/containernetworking /go/src/github.com/containernetworking/