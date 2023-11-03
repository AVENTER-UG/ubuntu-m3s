FROM  ubuntu:22.04
LABEL maintainer="Andreas Peters <support@aventer.biz>"
LABEL org.opencontainers.image.title="ubuntu-m3s" 
LABEL org.opencontainers.image.description="Container image with preconfigured ubuntu for mesos m3s"
LABEL org.opencontainers.image.vendor="AVENTER UG (haftungsbeschränkt)"
LABEL org.opencontainers.image.source="https://github.com/AVENTER-UG/"

RUN apt-get update -y
RUN apt-get install -y wget jq containerd dnsmasq tcpdump curl inetutils-ping iptables fuse-overlayfs procps bash iproute2 dnsutils net-tools systemctl socat conntrack tzdata
RUN apt-get upgrade -y
RUN update-alternatives --set iptables /usr/sbin/iptables-legacy

# Prepare systemd environment.
ENV container docker

RUN ARCH=`uname -m` && \
    curl -k -L https://download.docker.com/linux/static/stable/${ARCH}/docker-24.0.6.tgz | tar -xvz -C /usr/local/bin --strip 1 && \
    mkdir -p /etc/docker 

RUN mkdir /usr/lib/cni/
RUN ARCH=`dpkg --print-architecture` && \
    curl -k -L https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.4/cri-dockerd-0.3.4.${ARCH}.tgz | tar -xvz -C /tmp && \
    curl -k -L https://github.com/flannel-io/cni-plugin/releases/download/v1.1.2/cni-plugin-flannel-linux-${ARCH}-v1.1.2.tgz | tar -xvz -C /usr/lib/cni/ && \
    curl -k -L https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-${ARCH}-v1.1.1.tgz | tar -xvz -C /usr/lib/cni/

RUN ARCH=`dpkg --print-architecture` && \
    mv /usr/lib/cni/flannel-${ARCH} /usr/lib/cni/flannel
RUN mv /tmp/cri-dockerd/cri-dockerd /usr/bin/
RUN rm -rf /tmp/cri-dockerd

RUN curl -k -L https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service > /etc/systemd/system/cri-docker.service && \
    curl -k -L https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket > /etc/systemd/system/cri-docker.socket 


RUN groupadd docker

COPY docker_daemon.json /etc/docker/daemon.json

# Prepare entrypoint.
COPY entrypoint.sh /

STOPSIGNAL SIGRTMIN+3

