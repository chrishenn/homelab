FROM ubuntu:24.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt install -y \
    qemu-kvm \
    build-essential \
    libvirt-daemon-system \
    libvirt-dev \
    openssh-server \
    curl \
    net-tools \
    gettext-base \
    jq \
    && apt autoremove -y && apt clean

ADD https://releases.hashicorp.com/vagrant/2.4.0/vagrant_2.4.0-1_amd64.deb /vagrant_2.4.0-1_amd64.deb
RUN apt install ./vagrant_2.4.0-1_amd64.deb \
    && rm -rf ./vagrant_2.4.0-1_amd64.deb
RUN vagrant plugin install vagrant-libvirt
ENV VAGRANT_DEFAULT_PROVIDER=libvirt

COPY Vagrantfile /Vagrantfile.ini
COPY provision.ps1 /provision.ps1

COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

CMD ["/startup.sh"]
