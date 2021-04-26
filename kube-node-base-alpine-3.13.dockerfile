FROM alpine:3.13
RUN apk update && \
    apk add util-linux coreutils findutils ca-certificates conntrack-tools iptables && \
    rm -rf /var/cache/apk/*