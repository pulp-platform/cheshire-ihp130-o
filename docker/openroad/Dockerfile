# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@ethz.ch>
#
# based on: https://docs.docker.com/build/building/multi-stage/
# syntax=docker/dockerfile:1
ARG DOCKER_BASE_IMG=almalinux:8.9

FROM ${DOCKER_BASE_IMG} AS builder
ARG OR_REPO=https://github.com/The-OpenROAD-Project/OpenROAD
ARG OR_COMMIT=589dee1c8b0d678bd2989dbb1150df86a0b5271f
# install packages
COPY packages.txt /packages.txt
RUN yum install -y $(cat /packages.txt)

# following dependencies from:
# https://github.com/The-OpenROAD-Project/OpenLane/blob/master/docker/openroad_app/Dockerfile
# with versions from: https://github.com/The-OpenROAD-Project/OpenROAD/blob/c02333b7cf98b74a78ac70715d8157535046957c/etc/DependencyInstaller.sh

# Build Boost
WORKDIR /boost
RUN curl -L https://sourceforge.net/projects/boost/files/boost/1.80.0/boost_1_80_0.tar.bz2/download | tar --strip-components=1 -xjC . && \
    ./bootstrap.sh && \
    ./b2 install --with-iostreams --with-test --with-serialization --with-system --with-thread -j $(nproc)

# Build Eigen
WORKDIR /eigen
RUN curl -L https://gitlab.com/libeigen/eigen/-/archive/3.4/eigen-3.4.tar.gz | tar --strip-components=1 -xzC . && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install

# Build Lemon
WORKDIR /lemon
RUN curl -L https://github.com/The-OpenROAD-Project/lemon-graph/archive/refs/tags/1.3.1.tar.gz | tar --strip-components=1 -xzC . && \
    cmake -B build . && \
    cmake --build build -j $(nproc) --target install

# Build Spdlog
WORKDIR /spdlog
RUN curl -L https://github.com/gabime/spdlog/archive/refs/tags/v1.8.1.tar.gz | tar --strip-components=1 -xzC . && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make install -j $(nproc)

# Build Swig
RUN yum remove -y swig3
WORKDIR /swig
RUN curl -L https://github.com/swig/swig/archive/refs/tags/v4.1.0.tar.gz | tar --strip-components=1 -xzC . && \
    ./autogen.sh && \
    ./configure --prefix=/usr && \
    make -j $(nproc) && \
    make install

# Build OR Tools
WORKDIR /ortools
RUN curl -L https://github.com/google/or-tools/archive/refs/tags/v9.5.tar.gz | tar --strip-components=1 -xzC . && \
    cmake -B build . -DBUILD_DEPS:BOOL=ON && \
    cmake --build build -j $(nproc) --target install

WORKDIR /openroad
RUN  yum config-manager --set-enabled powertools && yum update
RUN yum install -y doxygen

# ToDo: submodules lose their correct versions if done via archive -> OpenLane uses util.py, copy?
# pull and build
RUN git clone ${OR_REPO}.git . && git checkout ${OR_COMMIT} && \
    git submodule update --init --recursive
RUN mkdir build && mkdir -p /build/version && mkdir install
RUN cd build && cmake -DCMAKE_INSTALL_PREFIX=$(pwd)/install ..
RUN cd build && make -j$(nproc)
RUN cd build && make install
RUN cp -r build/install/bin /build/

# Add OR_Tools
RUN mkdir -p /build/lib
RUN cp /usr/local/lib64/libortools.so.9 /build/lib/libortools.so.9 
ENV PATH /build/bin:$PATH

# copy into runnner
FROM ${DOCKER_BASE_IMG} AS runner
COPY packages.txt /packages.txt
RUN yum install -y $(cat /packages.txt)
COPY --from=builder /build /build
ENV PATH /build/bin:$PATH
ENV LD_LIBRARY_PATH=/build/lib:$LD_LIBRARY_PATH
