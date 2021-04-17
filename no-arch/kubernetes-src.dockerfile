FROM curlimages/curl:7.76.1 as builder
ARG K8S_VERSIOIN
WORKDIR /go/src/k8s.io/
RUN curl -skL https://github.com/kubernetes/kubernetes/archive/refs/tags/v${K8S_VERSIOIN}.tar.gz | tar zxpf - \
    && mv kubernetes-${K8S_VERSIOIN} kubernetes

FROM scratch
WORKDIR /go/src/k8s.io/kubernetes
COPY --from=builder /go/src/k8s.io/kubernetes ./