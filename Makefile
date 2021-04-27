PLATFORM := linux/amd64,linux/arm64,linux/arm/v7

.PHONY: kube-proxy
kube-proxy:
	./build/kube-proxy.sh $(PLATFORM) 1.21.0
	./build/kube-proxy.sh $(PLATFORM) 1.20.6
	./build/kube-proxy.sh $(PLATFORM) 1.19.10
	./build/kube-proxy.sh $(PLATFORM) 1.18.18

%:
	$(eval K8S_VERSIOIN = $@)
	$(eval K8S_VERSIOIN_PREFIX = $(subst $() $(),., $(wordlist 1, 2, $(subst ., ,$(K8S_VERSIOIN)))))
	$(eval K8S_MIDDLE_VERSION = $(word 2, $(subst ., ,$(K8S_VERSIOIN))))
	$(eval CRICTL_VERSION = $(K8S_VERSIOIN_PREFIX:.%=%.0))
	$(eval CRI_TOOLS_BIN_PATH = $(shell [ ${K8S_MIDDLE_VERSION} -lt 21 ] && echo _output || echo build/bin))
	./build/image.sh $(PLATFORM) $(K8S_VERSIOIN) $(CRICTL_VERSION) $(CRI_TOOLS_BIN_PATH)

.PHONY: lts
lts: 1.21.0 1.20.6 1.19.10 1.18.18
