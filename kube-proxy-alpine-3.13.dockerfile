# ARG is not supported in the --from parameter of COPY command.
# Multi-arch
ARG K8S_VERSIOIN
FROM docker.io/cloudtogo4edge/kubernetes-source:v${K8S_VERSIOIN} as src

FROM golang:1.16-alpine3.13 as builder-base
RUN apk update && apk add make build-base bash rsync linux-headers && rm -rf /var/cache/apk/*

FROM builder-base as k8s
WORKDIR /go/src/k8s.io/kubernetes
COPY --from=src /go/src/k8s.io/kubernetes ./
USER root
ENV CGO_ENABLED="1"
RUN make WHAT=cmd/kube-proxy

FROM docker.io/cloudtogo4edge/alpine-iptables:v12.1.2
COPY --from=k8s /go/src/k8s.io/kubernetes/_output/bin/kube-proxy /usr/local/bin/