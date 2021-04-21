%:
	$(eval K8S_VERSIOIN = $@)
	$(eval K8S_VERSIOIN_PREFIX = $(subst $() $(),., $(wordlist 1, 2, $(subst ., ,$(K8S_VERSIOIN)))))
	$(eval CRICTL_VERSION = $(K8S_VERSIOIN_PREFIX:.%=%.0))
	docker buildx build --platform=linux/amd64,linux/arm64,linux/arm/v7 --build-arg K8S_VERSIOIN=$(K8S_VERSIOIN) --build-arg CRICTL_VERSION=$(CRICTL_VERSION) -t docker.io/cloudtogo4edge/kubernetes-source:v$(K8S_VERSIOIN) -f kubernetes-src.dockerfile --push .
	docker buildx build --platform=linux/amd64,linux/arm64,linux/arm/v7 --build-arg K8S_VERSIOIN=$(K8S_VERSIOIN) --build-arg CRICTL_VERSION=$(CRICTL_VERSION) -t docker.io/cloudtogo4edge/kubelet:v$(K8S_VERSIOIN) -f alpine-3.13.dockerfile --push .

.PHONY: lts
lts: 1.21.0 1.20.6 1.19.10 1.18.18
