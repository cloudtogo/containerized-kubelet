ARG ALPINE_VERSION
FROM alpine:${ALPINE_VERSION}
RUN apk update && \
    apk add util-linux coreutils findutils ca-certificates conntrack-tools iptables && \
    rm -rf /var/cache/apk/*