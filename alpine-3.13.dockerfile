# ARG is not supported in the --from parameter of COPY command.
# Multi-arch
ARG K8S_VERSIOIN
FROM docker.io/cloudtogo4edge/kube-node-binaries:v${K8S_VERSIOIN} as binaries

FROM docker.io/cloudtogo4edge/kube-node-base:alpine-3.13 as kubelet-only
WORKDIR /
COPY kubelet-config.yaml /var/lib/kubelet/config.yaml
ENTRYPOINT ["kubelet", "--config=/var/lib/kubelet/config.yaml"]
CMD []
COPY --from=binaries /crictl /usr/bin/
COPY --from=binaries /kubelet /usr/bin/

FROM kubelet-only as with-cni
CMD ["--network-plugin=cni"]
COPY --from=binaries /cni-plugins /opt/cni/bin/

FROM kubelet-only as with-kubeadm
COPY --from=binaries /kubeadm /usr/bin/

FROM with-cni as kubeadm-cni
COPY --from=binaries /kubeadm /usr/bin/