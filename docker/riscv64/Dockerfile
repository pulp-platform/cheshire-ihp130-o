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
ARG RISCV64_REPO=https://github.com/riscv-collab/riscv-gnu-toolchain
ARG RISCV64_COMMIT=23d031ef253bbdf1c551f86a3fbf3e24bc842f7d
# install packages
COPY packages.txt /packages.txt
RUN yum install -y yum-utils
RUN yum config-manager --set-enabled powertools && yum update -y
RUN yum install -y $(cat /packages.txt)

WORKDIR /riscv
# pull and build
RUN mkdir -p /build
RUN git clone --recursive ${RISCV64_REPO}.git && cd riscv-gnu-toolchain && git checkout ${RISCV64_COMMIT}
RUN cd riscv-gnu-toolchain && ./configure --prefix=/build && make -j

# copy into runnner
FROM ${DOCKER_BASE_IMG} AS runner
COPY --from=builder /build /build
ENV PATH /build/bin:$PATH