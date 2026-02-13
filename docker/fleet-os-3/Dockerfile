FROM debian:12.10

USER root
RUN echo root:1234 | chpasswd

ENV DEBIAN_FRONTEND=noninteractive

#
# Install Base dependencies into the docker container
#
RUN apt-get update && \
    apt-get install -y \
      build-essential xz-utils sed git libssl-dev openssh-server unzip python3 make patchelf wget locales perl file \
      findutils && \
    rm -rf /var/lib/apt/lists/*

# Java is needed for build of some tools.
# For example: Processing Aeron mapping files
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        default-jdk && \
    rm -rf /var/lib/apt/lists/*

# Generate the locale for en_US.UTF-8
RUN locale-gen en_US.UTF-8

# Set environment variables for locale
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Toolchain installs version 3.28 but aeron requires > 3.30
RUN wget "https://github.com/Kitware/CMake/releases/download/v3.31.8/cmake-3.31.8-linux-x86_64.sh" -O cmake.sh && \
    chmod +x cmake.sh && \
    ./cmake.sh --skip-license --prefix=/usr/local && \
    rm ./cmake.sh

RUN git clone https://github.com/cmakelib/cmakelib.git /cmakelib
RUN echo "export CMLIB_DIR=/cmakelib" >> /environment.sh

RUN sed -ri 's/#?PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN mkdir -p /run/sshd

#
# Install our BringAuto Fleet
#
COPY init_toolchain.sh /root/
COPY toolchain/oecore.sh /root/toolchain/oecore.sh
RUN chmod +x /root/init_toolchain.sh && \
    /root/init_toolchain.sh /root/toolchain /root/tools
COPY os-release /etc/os-release
COPY uname.txt /root/tools/

# Install Fleet Protocol's CMCONF system
COPY --from=package-context config/CMCONF_FLEET_PROTOCOLConfig.cmake /etc
ENV CMLIB_DIR=/cmakelib
RUN cmake -DCMCONF_INSTALL_AS_SYMLINK=ON -P /etc/CMCONF_FLEET_PROTOCOLConfig.cmake

RUN apt-get update && \
    apt-get purge -y \
      wget unzip && \
      rm -rf /var/lib/apt/lists/*

# Temporary until toolchain cmake is version > 3.30
RUN echo "alias cmake='/usr/local/bin/cmake'" >> /root/.bashrc

ENTRYPOINT ["/usr/sbin/sshd", "-D", "-o", "ListenAddress=0.0.0.0"]
