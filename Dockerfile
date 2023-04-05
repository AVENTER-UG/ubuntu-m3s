FROM  ubuntu:22.04
LABEL maintainer="Andreas Peters <support@aventer.biz>"
LABEL org.opencontainers.image.title="ubuntu-m3s" 
LABEL org.opencontainers.image.description="Container image with preconfigured ubuntu for mesos m3s"
LABEL org.opencontainers.image.vendor="AVENTER UG (haftungsbeschränkt)"
LABEL org.opencontainers.image.source="https://github.com/AVENTER-UG/"

RUN apt-get update -y
RUN apt-get install -y wget jq containerd dnsmasq containernetworking-plugins tcpdump curl inetutils-ping iptables fuse-overlayfs procps bash iproute2 dnsutils net-tools systemctl socat
RUN apt-get upgrade -y
RUN update-alternatives --set iptables /usr/sbin/iptables-legacy

RUN curl -k -L https://github.com/Mirantis/cri-dockerd/releases/download/v0.2.0/cri-dockerd-v0.2.0-linux-amd64.tar.gz | tar -xvz -C /usr/bin/ 

RUN curl -k -L https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service > /etc/systemd/system/cri-docker.service && \
    curl -k -L https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket > /etc/systemd/system/cri-docker.socket 


# Prepare systemd environment.
ENV container docker

RUN ARCH=`uname -m` && \
    DOCKER_URL=https://download.docker.com/linux/static/stable/x86_64/docker-20.10.9.tgz && \
    mkdir -p /etc/docker && \
    curl -s $DOCKER_URL -o /docker.tgz && \
    tar -xzvf /docker.tgz -C /usr/local/bin --strip 1 && \
    rm -f /docker.tgz

RUN groupadd docker

COPY docker_daemon.json /etc/docker/daemon.json

# Prepare entrypoint.
COPY entrypoint.sh /

STOPSIGNAL SIGRTMIN+3

