# ARG is not supported in the --from parameter of COPY command.
# Multi-arch
ARG K8S_VERSIOIN
ARG ALPINE_VERSION
FROM docker.io/cloudtogo4edge/kube-node-binaries:v${K8S_VERSIOIN}-alpine${ALPINE_VERSION} as binaries

FROM docker.io/cloudtogo4edge/alpine-iptables:v12.1.2-alpine${ALPINE_VERSION}
COPY --from=binaries /kube-proxy /usr/local/bin/