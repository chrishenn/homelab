FROM chrishenn/debian-systemd:latest

RUN apt update && export DEBIAN_FRONTEND=noninteractive \
    && apt --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages install -y \
    curl novnc swtpm wimtools p7zip-full genisoimage

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages install -y \
    vagrant qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils libguestfs-tools \
    ebtables dnsmasq-base iptables iproute2 ovmf \
    gcc-multilib ruby-libvirt libxml2-dev ruby-dev ruby-full libxslt-dev zlib1g zlib1g-dev \
    libelf-dev libbpf-dev elfutils

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages install -y \
    autoconf automake binutils git gcc make cmake pkg-config wget cpu-checker \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN vagrant plugin install vagrant-libvirt

ADD https://raw.githubusercontent.com/ElliotKillick/Mido/main/Mido.sh /run/mido.sh
ADD https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso /run/drivers.iso

COPY ./startup.sh /run/startup.sh

RUN chmod +x /run/*.sh

ENV VAGRANT_DEFAULT_PROVIDER=libvirt

RUN systemctl enable libvirtd

CMD ["/lib/systemd/systemd"]
