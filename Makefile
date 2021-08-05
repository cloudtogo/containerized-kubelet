PLATFORM := linux/amd64,linux/arm64,linux/arm/v7
ALPINE_VERSION := 3.13

.PHONY: 1.16.15
1.16.15:
	$(eval K8S_VERSIOIN = 1.16.15)
	$(eval K8S_VERSIOIN_PREFIX = $(subst $() $(),., $(wordlist 1, 2, $(subst ., ,$(K8S_VERSIOIN)))))
	$(eval K8S_MIDDLE_VERSION = $(word 2, $(subst ., ,$(K8S_VERSIOIN))))
	$(eval CRICTL_VERSION = $(K8S_VERSIOIN_PREFIX:.%=%.0))
	$(eval CRI_TOOLS_BIN_PATH = $(shell [ ${K8S_MIDDLE_VERSION} -lt 21 ] && echo _output || echo build/bin))
	./build/image.sh $(PLATFORM) 1.16.15 $(CRICTL_VERSION) $(CRI_TOOLS_BIN_PATH) $(ALPINE_VERSION)

.PHONY: lts
lts: 1.21.2 1.20.8 1.19.12 1.18.20

%:
	$(eval K8S_VERSIOIN = $@)
	$(eval K8S_VERSIOIN_PREFIX = $(subst $() $(),., $(wordlist 1, 2, $(subst ., ,$(K8S_VERSIOIN)))))
	$(eval K8S_MIDDLE_VERSION = $(word 2, $(subst ., ,$(K8S_VERSIOIN))))
	$(eval CRICTL_VERSION = $(K8S_VERSIOIN_PREFIX:.%=%.0))
	$(eval CRI_TOOLS_BIN_PATH = $(shell [ ${K8S_MIDDLE_VERSION} -lt 21 ] && echo _output || echo build/bin))
	./build/image.sh $(PLATFORM) $(K8S_VERSIOIN) $(CRICTL_VERSION) $(CRI_TOOLS_BIN_PATH) $(ALPINE_VERSION)
