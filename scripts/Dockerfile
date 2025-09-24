# Use the official Ubuntu base image
FROM --platform=linux/amd64 ubuntu:22.04

# Set environment variables to prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y

# Check and install ca-certificates earlier if Rosetta gets broken
RUN apt-get install ca-certificates -y

# Install x11-apps and other necessary packages
RUN apt-get update && \
    apt-get install -y x11-apps

# install dependencies for Vivado
RUN apt-get install -y --no-install-recommends \
    expect sudo libxtst6 libgdk-pixbuf2.0-0 libgtk2.0-0 libgtk-3-0 libglib2.0-0\
    python3-pip python3-dev build-essential git gcc-multilib g++ \
    ocl-icd-opencl-dev libjpeg62-dev libc6-dev-i386 graphviz make \
    unzip libtinfo5 xvfb libncursesw5 locales libswt-gtk-4-jni \
    fonts-dejavu fonts-dejavu-core fonts-dejavu-extra fonts-liberation \
    fontconfig x11-xserver-utils xfonts-base xfonts-75dpi xfonts-100dpi \
    libxrender1 libxrandr2 libxss1 libxcursor1 libxcomposite1 libxdamage1 \
    libxfixes3 libxi6 libxinerama1 libgl1-mesa-glx libglu1-mesa \
    gtk2-engines-murrine gtk2-engines-pixbuf libcanberra-gtk-module \
    libcanberra-gtk3-module dbus-x11 at-spi2-core


RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8


RUN useradd -m -s /bin/bash -G sudo user && \
    echo "user:password" | chpasswd && \
    chown -R user:user /home/user

USER user
WORKDIR /home/user


ENV LD_PRELOAD="/lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libselinux.so.1 /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/libgdk-x11-2.0.so.0"