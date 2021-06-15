# ARG is not supported in the --from parameter of COPY command.
# Multi-arch
ARG K8S_VERSIOIN
ARG ALPINE_VERSION
FROM docker.io/cloudtogo4edge/kube-node-binaries:v${K8S_VERSIOIN}-alpine${ALPINE_VERSION} as binaries

FROM docker.io/cloudtogo4edge/kube-node-base:alpine-${ALPINE_VERSION} as kubelet-only
WORKDIR /
COPY kubelet-config.yaml /var/lib/kubelet/config.yaml
ENTRYPOINT ["kubelet", "--config=/var/lib/kubelet/config.yaml", "--register-node", "--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf", "--kubeconfig=/etc/kubernetes/kubelet.conf"]
CMD []
COPY --from=binaries /kubelet /usr/bin/

FROM kubelet-only as with-cni
CMD ["--network-plugin=cni"]
COPY --from=binaries /cni-plugins /opt/cni/bin/

FROM kubelet-only as with-kubeadm
COPY --from=binaries /crictl /usr/bin/
COPY --from=binaries /kubeadm /usr/bin/

FROM with-kubeadm as kubeadm-cni
CMD ["--network-plugin=cni"]
COPY --from=binaries /cni-plugins /opt/cni/bin/

FROM kubelet-only as with-flannel
CMD ["--network-plugin=cni"]
COPY --from=binaries /cni-plugins/bridge /opt/cni/bin/
COPY --from=binaries /cni-plugins/flannel /opt/cni/bin/
COPY --from=binaries /cni-plugins/host-local /opt/cni/bin/
COPY --from=binaries /cni-plugins/portmap /opt/cni/bin/
COPY --from=binaries /cni-plugins/loopback /opt/cni/bin/