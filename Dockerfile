# SPDX-FileCopyrightText: 2023 Rivos Inc.
#
# SPDX-License-Identifier: Apache-2.0

FROM debian:sid
ENV DEBIAN_FRONTEND=noninteractive

# Base packages to retrieve the other repositories/packages
RUN apt-get update && apt-get install --yes --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg

# Add additional packages here.
RUN apt-get update && apt-get install --yes --no-install-recommends \
    arch-test \
    autoconf \
    automake \
    autotools-dev \
    bash-completion \
    bc \
    binfmt-support \
    bison \
    bsdmainutils \
    build-essential \
    cpio \
    curl \
    diffstat \
    flex \
    gcc-arm-linux-gnueabihf \
    gawk \
    g++-arm-linux-gnueabihf \
    gdb \
    gettext \
    git \
    git-lfs \
    gperf \
    groff \
    less \
    libelf-dev \
    liburing-dev \
    lsb-release \
    mmdebstrap \
    ninja-build \
    patchutils \
    perl \
    pkg-config \
    psmisc \
    python-is-python3 \
    python3-venv \
    qemu-user-static \
    rsync \
    ruby \
    ssh \
    strace \
    texinfo \
    traceroute \
    unzip \
    vim \
    zlib1g-dev \
    lsb-release \
    wget \
    software-properties-common \
    gnupg \
    cmake \
    libdw-dev \
    libssl-dev \
    python3-docutils \
    kmod

RUN echo 'deb [arch=amd64] http://apt.llvm.org/unstable/ llvm-toolchain main' >> /etc/apt/sources.list.d/llvm.list

RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc

RUN apt update
RUN apt-get install --yes clang llvm

# Ick. BPF requires pahole "supernew" to work
RUN cd $(mktemp -d) && git clone https://git.kernel.org/pub/scm/devel/pahole/pahole.git && \
    cd pahole && mkdir build && cd build && cmake -D__LIB=lib .. && make install

RUN dpkg --add-architecture armhf

RUN apt-get update

RUN apt-get install --yes --no-install-recommends \
    libasound2-dev:armhf \
    libc6-dev:armhf \
    libcap-dev:armhf \
    libcap-ng-dev:armhf \
    libelf-dev:armhf \
    libfuse-dev:armhf \
    libhugetlbfs-dev:armhf \
    libmnl-dev:armhf \
    libnuma-dev:armhf \
    libpopt-dev:armhf \
    libssl-dev:armhf \
    liburing-dev:armhf

RUN mkdir /rootfs

RUN mmdebstrap --architectures=armhf --include="initramfs-tools-core,liburing2,libasound2,net-tools,socat,ethtool,iputils-ping,uuid-runtime,rsync,python3,libnuma1,libmnl0,libfuse2,libcap2,libcap-ng0,libhugetlbfs0,libssl3,jq,iptables,nftables,netsniff-ng,tcpdump,traceroute,tshark,fuse3,netcat-openbsd" sid /rootfs/ \
    --customize-hook='echo rv-selftester > "$1/etc/hostname"' \
    --customize-hook='echo 44f789c720e545ab8fb376b1526ba6ca > "$1/etc/machine-id"' \
    --customize-hook='mkdir -p "$1/etc/systemd/system/serial-getty@ttyAMA0.service.d"' \
    --customize-hook='printf "[Service]\nExecStart=\nExecStart=-/sbin/agetty -o \"-p -f -- \\\\\\\\u\" --keep-baud --autologin root 115200,57600,38400,9600 - \$TERM\n" > "$1/etc/systemd/system/serial-getty@ttyAMA0.service.d/autologin.conf"'

RUN ln -s /dev/null /rootfs/etc/systemd/network/99-default.link

COPY fstab /rootfs/etc/fstab
COPY interfaces /rootfs/etc/network/interfaces
COPY resolv.conf /rootfs/etc
COPY build-selftest /usr/local/bin

RUN apt-get clean && rm -rf /var/lib/apt/lists/

# The workspace volume is for bind-mounted source trees.
VOLUME /workspace
WORKDIR /workspace
