FROM ubuntu:20.04 AS base

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ="Europe/London"

ENV UNAME retro

######################################
FROM base AS sunshine-builder

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    # Packages needed to build sunshine
    build-essential fakeroot gcc-10 g++-10 cmake libssl-dev libavdevice-dev libboost-thread-dev libboost-filesystem-dev libboost-log-dev libpulse-dev libopus-dev libxtst-dev libx11-dev libxrandr-dev libxfixes-dev libevdev-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev \
    git ca-certificates apt-transport-https gnupg \
    && rm -rf /var/lib/apt/lists/*

# CUDA install steps adapted from:
# https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=20.04&target_type=deb_network

ADD https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600

# RUN wget --no-verbose --progress=bar:force:noscroll --show-progress \
#     https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin \
#     -O /etc/apt/preferences.d/cuda-repository-pin-600

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub

RUN echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /" | tee -a /etc/apt/sources.list

ARG CUDA_VER=11-4

RUN apt-get update \
 && apt-get install --no-install-recommends --yes \
    cuda-minimal-build-${CUDA_VER} \
 && rm -rf /var/lib/apt/lists/*

ENV PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
# ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# Pulling Sunshine v0.11.1
ARG SUNSHINE_SHA=e4c9c292e57d39136df2d46d1e9b66eba53f3bd3
ARG BUILD_TYPE=RELEASE

RUN git clone https://github.com/loki-47-6F-64/sunshine.git && \
    cd sunshine && \
    # Fix the SHA commit
    git checkout -qf $SUNSHINE_SHA && \
    # Just printing out git info so that I can double check on CI if the right version as been picked up
    git show && \
    # Recursively download submodules
    git submodule update --init --recursive && \
    # Normal compile
    mkdir build && cd build && \
    cmake -DCMAKE_C_COMPILER=gcc-10 -DCMAKE_CXX_COMPILER=g++-10 -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DSUNSHINE_EXECUTABLE_PATH=sunshine -DSUNSHINE_ASSETS_DIR=/etc/sunshine .. && \
    make -j${nproc} && \
    # Generate the debian install package
    ./gen-deb

######################################
FROM base AS sunshine

# Get compiled sunshine
COPY --from=sunshine-builder /sunshine/build/package-deb/sunshine.deb /sunshine.deb

# Install using the official .deb package
# This will take care of installing the required dependencies
RUN apt-get update -y && \
    apt-get install -y -f /sunshine.deb \
    && apt-get install -y --no-install-recommends \
    # Seems that libgbm1 and libgl is missing
    libgbm1 libgles2-mesa libegl1 libgl1-mesa-dri \
    # Intel GPU drivers
    i965-va-driver-shaders \
    intel-media-va-driver-non-free \
    libdrm-intel1 \
    libva-drm2 libva-x11-2 va-driver-all \
    # Install xdpyinfo so that we can wait for X11 on startup
    x11-utils \
    # sudo isn't installed by default
    sudo \
    && rm -rf /var/lib/apt/lists/*

ENV HOME /home/$UNAME

# Common scripts
COPY --chmod=777 common/* /bin/
# Set up the user
RUN setup-retro-user

# Utils for debugging
# RUN apt-get update -y && \
#     apt-get install -y --no-install-recommends gdb vainfo ffmpeg \
#     && apt-get remove -y software-properties-common \
#     && rm -rf /var/lib/apt/lists/*

WORKDIR $HOME
USER ${UNAME}

# Config files
COPY sunshine/configs/sunshine.conf /cfg/sunshine.conf
COPY sunshine/configs/apps.json /cfg/apps.json
COPY sunshine/scripts/startup.sh /startup.sh

# Port configuration taken from https://github.com/moonlight-stream/moonlight-docs/wiki/Setup-Guide#manual-port-forwarding-advanced
EXPOSE 47984-47990/tcp
EXPOSE 48010
EXPOSE 48010/udp 
EXPOSE 47998-48000/udp

CMD /bin/bash /startup.sh

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
