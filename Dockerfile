FROM alpine:edge

RUN cat <<EOF > /etc/apk/repositories
http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
http://dl-cdn.alpinelinux.org/alpine/edge/testing
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

# Install krew
RUN set -x; \
  cd "$(mktemp -d)" && \
  OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
  KREW="krew-${OS}_${ARCH}" && \
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
  tar zxvf "${KREW}.tar.gz" && \
  ./"${KREW}" install krew && \
  echo 'export PATH=/root/.krew/bin:$PATH' >> ~/.bashrc && \
  rm -rf "${KREW}.tar.gz" ./"${KREW}"

# Set up PATH for krew
ENV PATH="${KREW_ROOT:-/root/.krew}/bin:$PATH"

# Install krew plugins
RUN kubectl krew update && \
  kubectl krew install tree

# Install helm plugins
RUN helm plugin install https://github.com/databus23/helm-diff && rm -rf /tmp/helm-* && \
  rm -rf ~/.cache/helm/plugins/https-github.com-databus23-helm-diff/.git

ENTRYPOINT bash
