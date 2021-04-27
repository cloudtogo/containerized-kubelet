FROM alpine:3.13

RUN apk update \
    && apk add iptables ip6tables ebtables \
    && apk add conntrack-tools ipset kmod alpine-baselayout dpkg \
    && rm -rf /var/cache/apk/*

# Install iptables wrapper scripts to detect the correct iptables mode
# the first time any of them is run
COPY iptables-wrapper /sbin/iptables-wrapper

RUN update-alternatives \
	--install /sbin/iptables iptables /sbin/iptables-wrapper 100 \
	--slave /sbin/iptables-restore iptables-restore /sbin/iptables-wrapper \
	--slave /sbin/iptables-save iptables-save /sbin/iptables-wrapper \
	&& update-alternatives --install /sbin/iptables iptables /sbin/iptables-legacy 10 \
	--slave /sbin/iptables-restore iptables-restore /sbin/iptables-legacy-restore \
    --slave /sbin/iptables-save iptables-save /sbin/iptables-legacy-save \
    && update-alternatives --install /sbin/iptables iptables /sbin/iptables-nft 20 \
    --slave /sbin/iptables-restore iptables-restore /sbin/iptables-nft-restore \
    --slave /sbin/iptables-save iptables-save /sbin/iptables-nft-save
RUN update-alternatives \
	--install /sbin/ip6tables ip6tables /sbin/iptables-wrapper 100 \
	--slave /sbin/ip6tables-restore ip6tables-restore /sbin/iptables-wrapper \
	--slave /sbin/ip6tables-save ip6tables-save /sbin/iptables-wrapper \
	&& update-alternatives --install /sbin/ip6tables ip6tables /sbin/ip6tables-legacy 10 \
	--slave /sbin/ip6tables-restore ip6tables-restore /sbin/ip6tables-legacy-restore \
    --slave /sbin/ip6tables-save ip6tables-save /sbin/ip6tables-legacy-save \
	&& update-alternatives --install /sbin/ip6tables ip6tables /sbin/ip6tables-nft 20 \
	--slave /sbin/ip6tables-restore ip6tables-restore /sbin/ip6tables-nft-restore \
    --slave /sbin/ip6tables-save ip6tables-save /sbin/ip6tables-nft-save