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

# The yocto toolchain Perl (5.38.2) is stripped and missing standard modules needed by
# msquic's bundled quictls (OpenSSL fork). Replace the toolchain's perl wrapper with a
# thin shell that invokes the system Perl (/usr/bin/perl), which has all standard modules.
# The toolchain perl binary is only used for build-time scripts (not for the target binary),
# so using system Perl here is safe.
RUN printf '#!/bin/sh\nexec /usr/bin/perl "$@"\n' \
      > /root/toolchain/sysroots/x86_64-oesdk-linux/usr/bin/perl && \
    chmod +x /root/toolchain/sysroots/x86_64-oesdk-linux/usr/bin/perl
# CROSS_COMPILE is set by the OE SDK toolchain for Makefile-based projects (Linux kernel,
# U-Boot). CMake projects use CMAKE_TOOLCHAIN_FILE for cross-compilation instead.
# When CROSS_COMPILE is set, quictls (OpenSSL fork used by msquic) incorrectly prepends
# it to the already-absolute CC path, producing a non-existent compiler path.
# This line is appended AFTER init_toolchain.sh so it overrides the SDK's export.
RUN echo "unset CROSS_COMPILE" >> /environment.sh

# msquic's cmake checks CMAKE_TARGET_ARCHITECTURE to select the quictls build path.
# Without it, msquic falls back to ./config which auto-detects the x86_64 host and
# passes -m64 to the aarch64 cross-compiler. Setting arm64 makes msquic call
# quictls/Configure linux-aarch64 directly, which uses CC from the environment.
RUN echo "set(CMAKE_TARGET_ARCHITECTURE arm64)" >> \
    /root/toolchain/sysroots/x86_64-oesdk-linux/usr/share/cmake/OEToolchainConfig.cmake

ENTRYPOINT ["/usr/sbin/sshd", "-D", "-o", "ListenAddress=0.0.0.0"]
