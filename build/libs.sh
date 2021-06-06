#!/usr/bin/env bash

function lib::remote_image() {
  local imagePuller=${IMAGE_PULLER:-docker}
  if [[ "${PLATFORM}" == "" ]]; then
    eval ${imagePuller} pull $1 > /dev/null || echo "non-exist"
  else
    IFS=',' read -r -a platforms <<< "${PLATFORM}"
    for platform in "${platforms[@]}"
    do
      result=$(eval ${imagePuller} pull --platform=${platform} $1 > /dev/null || echo "non-exist")
      if [[ "${result}" == "non-exist" ]]; then
        echo "${result}"
        return
      fi
    done
  fi
}

function lib::image_name() {
  local name=$1
  local version=$2
  if [[ "${version}" == "v"* ]]; then
    echo "strip the leading 'v' from the image version"
    exit 1
  fi

  if [[ "${version}" != "" ]]; then
    echo "docker.io/cloudtogo4edge/${name}:v${version}-alpine${ALPINE_VERSION}"
  else
    echo "docker.io/cloudtogo4edge/${name}:alpine-${ALPINE_VERSION}"
  fi
}

function lib::build_image() {
  local name=$1
  local version=$2
  local image=$(lib::image_name $name $version)
  local dockerfile=${3:-Dockerfile}
  echo "checking ${image}"
  if [ "$(lib::remote_image ${image})" == "non-exist" ]; then
    lib::overwrite_image "$name" "$version" "$dockerfile"
  fi
}

function lib::overwrite_image() {
  local name=$1
  local version=$2
  local image=$(lib::image_name $name $version)
  local dockerfile=${3:-Dockerfile}
  local workdir=$(dirname ${dockerfile})
  local dockerfile=$(basename ${dockerfile})
  local imageBuilder=${IMAGE_BUILDER:-docker}
  local imageBuildCmd=${IMAGE_BUILD_CMD:-buildx}

  echo "building ${image}"
  (cd "${workdir}" && \
    eval ${imageBuilder} ${imageBuildCmd} build --platform=${PLATFORM} \
    --build-arg CRI_TOOLS_BIN_PATH=${CRI_TOOLS_BIN_PATH:-build/bin} \
    --build-arg K8S_VERSIOIN=${K8S_VERSIOIN} \
    --build-arg CRICTL_VERSION=${CRICTL_VERSION} \
    --build-arg ALPINE_VERSION=${ALPINE_VERSION} \
    --target=${TARGET} \
    -t ${image} \
    -f "${dockerfile}" --push .)
}
