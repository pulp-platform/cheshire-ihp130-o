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
ARG BENDER_TAR=https://github.com/pulp-platform/bender/releases/download/v0.27.4/bender-0.27.4-x86_64-linux-gnu-almalinux8.8.tar.gz
ARG MORTY_REPO=https://github.com/pulp-platform/morty
ARG MORTY_COMMIT=v0.9.0
ARG SVASE_REPO=https://github.com/pulp-platform/svase
ARG SVASE_COMMIT=f5f5290d57ff6f6ffbc06bcb5099b9d76a67f454
ARG SV2V_REPO=https://github.com/zachjs/sv2v
ARG SV2V_COMMIT=v0.0.11

# install packages
COPY packages.txt /packages.txt
RUN yum install -y $(cat /packages.txt)
# install rust cargo (morty)
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"
# install haskell stack (sv2v)
RUN curl -sSL https://get.haskellstack.org/ | bash


WORKDIR /build/bin
RUN curl -L ${BENDER_TAR} | tar -xzC .

WORKDIR /morty
RUN curl -L ${MORTY_REPO}/archive/${MORTY_COMMIT}.tar.gz | tar -xzC . --strip-components=1 && \
    cargo build --release && \
    cp target/release/morty /build/bin/morty

# ToDo: submodules lose their correct versions if done via archive -> fix in svase?
WORKDIR /svase
RUN git clone ${SVASE_REPO}.git . && git checkout ${SVASE_COMMIT} && \
    git submodule update --init --recursive && \
    export CXX=clang++-16 && \
    make -j && \
    cp build/svase /build/bin/svase

WORKDIR /sv2v
RUN curl -L ${SV2V_REPO}/archive/${SV2V_COMMIT}.tar.gz | tar -xzC . --strip-components=1 && \
    make -j && \
    cp bin/sv2v /build/bin/sv2v

# copy into runnner
FROM ${DOCKER_BASE_IMG} AS runner
COPY --from=builder /build /build
ENV PATH /build/bin:$PATH
