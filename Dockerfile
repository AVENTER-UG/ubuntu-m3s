FROM  ubuntu:focal
LABEL maintainer="Andreas Peters <support@aventer.biz>"

ARG DOCKER_URL=https://download.docker.com/linux/static/stable/x86_64/docker-20.10.9.tgz

RUN apt-get update -y
RUN apt-get install -y jq containerd dnsmasq containernetworking-plugins tcpdump curl inetutils-ping iptables fuse-overlayfs procps bash iproute2 dnsutils net-tools systemctl
RUN update-alternatives --set iptables /usr/sbin/iptables-legacy

# Prepare systemd environment.
ENV container docker

RUN mkdir -p /etc/docker && \
    curl -s $DOCKER_URL -o /docker.tgz && \
    tar -xzvf /docker.tgz -C /usr/local/bin --strip 1 && \
    rm -f /docker.tgz

RUN groupadd docker

COPY docker_daemon.json /etc/docker/daemon.json

# Prepare entrypoint.
COPY entrypoint.sh /

STOPSIGNAL SIGRTMIN+3

