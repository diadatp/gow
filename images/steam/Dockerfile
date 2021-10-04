FROM ubuntu:20.04 AS base

ARG DEBIAN_FRONTEND=noninteractive

ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV NVIDIA_VISIBLE_DEVICES=all

RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get upgrade --yes \
 && apt-get install --no-install-recommends --yes \
        libegl1 \
        libegl1:i386 \
        libgl1 \
        libgl1:i386 \
        libgles1 \
        libgles1:i386 \
        libgles2 \
        libgles2:i386 \
        libglvnd0 \
        libglvnd0:i386 \
        libglx0 \
        libglx0:i386 \
        libopengl0 \
        libopengl0:i386 \
        libpulse0 \
        libpulse0:i386 \
        mesa-vulkan-drivers \
        mesa-vulkan-drivers:i386 \
        x11-utils \
 && rm -rf /var/lib/apt/lists/*

ENV TZ="Europe/London"

ENV UNAME retro
ENV HOME /home/$UNAME

# RUN apt-get update -y && \
#     apt-get install -y --no-install-recommends software-properties-common sudo && \
#     # \
#     # Install steam (Steam is 32-bit only) \
#     dpkg --add-architecture i386 && \
#     add-apt-repository multiverse && \
#     apt-get update -y && \
#     apt-get install -y --no-install-recommends steam \
#     # Adding Vulkan
#     libvulkan1 libvulkan1:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386 \
#     # Add libdbus to fix webui black screen (https://github.com/ValveSoftware/steam-for-linux/issues/7058)
#     libdbus-1-3 \
#     # Libraries needed to play games
#     libgtk-3-0 libegl1 libsdl2-2.0-0 \
#     # Install xdpyinfo so that we can wait for X11 on startup
#     x11-utils \
#     && \
#     # \
#     # Cleanup \
#     apt-get remove -y software-properties-common && \
#     apt-get autoremove -y && \
#     rm -rf /var/lib/apt/lists/*

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get upgrade --yes && \
    apt-get install --no-install-recommends --yes \
        ca-certificates \
        wget && \
    wget --no-verbose --progress=bar:force:noscroll --show-progress \
        https://cdn.cloudflare.steamstatic.com/client/installer/steam.deb && \
    apt-get autoremove --purge --yes \
        ca-certificates \
        wget && \
    apt-get install --no-install-recommends --yes \
        ./steam.deb \
        mesa-vulkan-drivers \
        mesa-vulkan-drivers:i386 \
        xdg-desktop-portal \
        xdg-desktop-portal-gtk && \
    rm steam.deb && \
    apt-get update && \
    apt-get install --no-install-recommends --yes \
        steam-libs-amd64 \
        steam-libs-i386:i386 && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update \
 && apt-get install --no-install-recommends --yes \
        locales \
        mesa-utils \
        pulseaudio-utils \
        sudo \
        vulkan-utils \
 && rm -rf /var/lib/apt/lists/*

# Common scripts
COPY --chmod=777 common/* /bin/
# Seems that nvidia-docker is taking care of passing:
# /usr/lib/x86_64-linux-gnu/libnvidia-glvkspirv.so.460.80
# /usr/lib/i386-linux-gnu/libnvidia-glvkspirv.so.460.80
# But it's missing the following json file

COPY steam/configs/nvidia_icd.json /usr/share/vulkan/icd.d/nvidia_icd.json

# Set up the user
RUN setup-retro-user

# TODO remove this
RUN echo "$UNAME ALL = NOPASSWD: ALL" >> /etc/sudoers.d/$UNAME

# steam installer bootstrap
# ARG BOOTSTRAP_STEAM=true
RUN if [ -n "${BOOTSTRAP_STEAM}" ] ; then \
        apt-get update && \
        apt-get install --no-install-recommends --yes \
            xvfb && \
        sudo -E -u ${UNAME} /bin/bash -c "awk '/steamwebhelper/{exit}1' < <(xvfb-run -e /dev/stdout steam)" && \
        apt-get autoremove --purge --yes \
            xvfb && \
        rm -rf /var/lib/apt/lists/* \
    ; fi

# # proton bootstrap
# RUN if [ -n "${BOOTSTRAP_PROTON}" ] ; then \
#         TODO steamcmd
#     ; fi

WORKDIR $HOME
USER ${UNAME}

COPY steam/scripts/startup.sh /startup.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

CMD /bin/bash /startup.sh

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
