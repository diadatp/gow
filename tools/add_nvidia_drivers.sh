#!/usr/bin/env bash
set -euxo pipefail

# based on https://github.com/tianon/docker-bin/blob/master/nvidiize

# gameonwhales/xorg
# gameonwhales/steam

DOCKER_BUILDKIT=1 docker build - --tag ${1}-nvidia --build-arg FROM=$1 << 'EOF'
ARG FROM
FROM ${FROM}

USER root

ARG NVIDIA_DRIVER_VERSION=465.19.01

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get upgrade --yes && \
    apt-get install --no-install-recommends --yes \
        libegl1 \
        libegl1:i386 \
        libgl1 \
        libgl1:i386 \
        libgles2 \
        libgles2:i386 \
        libglvnd0 \
        libglvnd0:i386 \
        libglx0 \
        libglx0:i386 \
        libopengl0 \
        libopengl0:i386 && \
    apt-get install --no-install-recommends --yes \
        ca-certificates \
        kmod \
        pkg-config \
        wget && \
    wget --no-verbose --progress=bar:force:noscroll --show-progress \
        http://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_DRIVER_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run && \
    sh NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run \
        --install-compat32-libs \
        --install-libglvnd \
        --no-backup \
        --no-check-for-alternate-installs \
        --no-kernel-module \
        --no-kernel-module-source \
        --no-nouveau-check \
        --no-nvidia-modprobe \
        --no-questions \
        --ui=none && \
    rm NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run && \
    rm -rf /var/lib/apt/lists/*

USER ${UNAME}
EOF
