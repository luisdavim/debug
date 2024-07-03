FROM alpine:edge

RUN cat << EOF > /etc/apk/repositories
https://dl-cdn.alpinelinux.org/alpine/v$(cut -d'.' -f1,2 /etc/alpine-release)/main/
https://dl-cdn.alpinelinux.org/alpine/v$(cut -d'.' -f1,2 /etc/alpine-release)/community/
https://dl-cdn.alpinelinux.org/alpine/edge/testing/
EOF

RUN apk update && \
    apk add --no-cache \
    # base
    coreutils findutils \
    # build/code
    build-base git go bash bash-completion ncurses vim tmux jq \
    # network
    bind-tools iputils tcpdump curl nmap tcpflow iftop net-tools mtr netcat-openbsd bridge-utils iperf ngrep \
    # certificates
    ca-certificates openssl \
    # processes/io
    htop atop strace iotop sysstat ltrace ncdu logrotate hdparm pciutils psmisc tree pv \
    # kubernetes
    kubectl helm stern flux \
    # cloud
    govc

# Install clusterctl
RUN curl -L https://github.com/kubernetes-sigs/cluster-api/releases/latest/download/clusterctl-linux-$(uname -m) -o clusterctl && \
    mv clusterctl /usr/bin/clusterctl && \
    chmod +x /usr/bin/clusterctl

ENTRYPOINT bash
