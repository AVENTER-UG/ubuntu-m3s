FROM  ubuntu:22.04
LABEL maintainer="Andreas Peters <support@aventer.biz>"
LABEL org.opencontainers.image.title="ubuntu-m3s" 
LABEL org.opencontainers.image.description="Container image with preconfigured ubuntu for mesos m3s"
LABEL org.opencontainers.image.vendor="AVENTER UG (haftungsbeschränkt)"
LABEL org.opencontainers.image.source="https://github.com/AVENTER-UG/"

RUN apt-get update -y
RUN apt-get install -y wget jq containerd dnsmasq tcpdump curl inetutils-ping iptables fuse-overlayfs procps bash iproute2 dnsutils net-tools systemctl socat conntrack
RUN apt-get upgrade -y
RUN update-alternatives --set iptables /usr/sbin/iptables-legacy

RUN mkdir /usr/lib/cni/
RUN curl -k -L https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.4/cri-dockerd-0.3.4.amd64.tgz | tar -xvz -C /usr/bin/
RUN curl -k -L https://github.com/flannel-io/cni-plugin/releases/download/v1.1.2/cni-plugin-flannel-linux-amd64-v1.1.2.tgz | tar -xvz -C /usr/lib/cni/
RUN curl -k -L https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz | tar -xvz -C /usr/lib/cni/
RUN mv /usr/lib/cni/flannel-amd64 /usr/lib/cni/flannel

RUN curl -k -L https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service > /etc/systemd/system/cri-docker.service && \
    curl -k -L https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket > /etc/systemd/system/cri-docker.socket 


# Prepare systemd environment.
ENV container docker

RUN ARCH=`uname -m` && \
    DOCKER_URL=https://download.docker.com/linux/static/stable/x86_64/docker-24.0.6.tgz && \
    mkdir -p /etc/docker && \
    curl -s $DOCKER_URL -o /docker.tgz && \
    tar -xzvf /docker.tgz -C /usr/local/bin --strip 1 && \
    rm -f /docker.tgz

RUN groupadd docker

COPY docker_daemon.json /etc/docker/daemon.json

# Prepare entrypoint.
COPY entrypoint.sh /

STOPSIGNAL SIGRTMIN+3

