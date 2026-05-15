FROM fedora:44

USER root
RUN echo root:1234 | chpasswd

RUN dnf -y update && \
    dnf -y install  \
    automake autoconf automake binutils gcc gcc-c++ git kernel-devel libtool lsb-release make openssh-server openssl-devel patchelf perl-FindBin perl-IPC-Cmd wget \
    && dnf clean all

# Java is needed for build of some tools.
# For example: Processing Aeron mapping files
RUN dnf -y update && \
    dnf -y install java-latest-openjdk java-latest-openjdk-devel \
    && dnf clean all


ARG CMAKE_VERSION=4.3.0
ARG CMAKE_SHA256=c59f5915c76b7881160238ccb16b4991ac76bf8e7872e7b3d40bb1d502c86a6b
RUN wget "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh" -O cmake.sh && \
    echo "${CMAKE_SHA256}  cmake.sh" | sha256sum -c - && \
     chmod +x cmake.sh && \
     ./cmake.sh --skip-license --prefix=/usr/local && \
     rm ./cmake.sh

ARG CMLIB_VERSION=1.3.5
RUN git clone --branch v${CMLIB_VERSION} --depth 1 https://github.com/cmakelib/cmakelib.git /cmakelib
RUN echo "export CMLIB_DIR=/cmakelib" >> /root/.bashrc

# Install Fleet Protocol's CMCONF system
COPY --from=package-context config/CMCONF_FLEET_PROTOCOLConfig.cmake /etc
ENV CMLIB_DIR=/cmakelib
RUN cmake -DCMCONF_INSTALL_AS_SYMLINK=ON -P /etc/CMCONF_FLEET_PROTOCOLConfig.cmake

RUN sed -ri 's/#?PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN mkdir -p /run/sshd

RUN ssh-keygen -A

ENTRYPOINT ["/usr/sbin/sshd", "-D", "-o", "ListenAddress=0.0.0.0"]
