%:
	@echo "Building source code image for kubernetes v$@"
	kubectl dev build -t docker.io/cloudtogo/curl-downloader:alpine-3 -f downloader.dockerfile no-arch
	kubectl dev build --build-arg K8S_VERSIOIN=$@ -t docker.io/cloudtogo/kubernetes-source:v$@ -f kubernetes-src.dockerfile no-arch
	kubectl dev build --build-arg K8S_VERSIOIN=$@ -t docker.io/cloudtogo/kubelet:v$@-amd64 alpine.amd64

