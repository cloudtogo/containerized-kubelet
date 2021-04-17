FROM docker.io/arm64v8/golang:1.16 as crictl
WORKDIR /go/src/github.com/kubernetes-sigs/cri-tools
RUN git clone --depth 1 https://github.com/kubernetes-sigs/cri-tools.git .
RUN make crictl

FROM arm64v8/alpine:3

RUN apk update && apk add util-linux coreutils findutils ca-certificates conntrack-tools iptables && rm -rf /var/cache/apk/*

COPY kubelet kubeadm /usr/bin/
COPY --from=crictl /go/src/github.com/kubernetes-sigs/cri-tools/build/bin/crictl /usr/bin/
ADD cni-plugins-linux-arm64-v0.9.1.tgz /opt/cni/bin/

WORKDIR /root

ENV HOSTNAME=""
ENV NODE_IP=""

ENTRYPOINT kubelet --network-plugin=cni --hostname-override=${HOSTNAME} --node-ip=${NODE_IP} --config=/var/lib/kubelet/config.yaml