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
ARG PICKLE_IMG
ARG YOSYS_IMG
ARG OPENROAD_IMG
FROM ${PICKLE_IMG} as pickle
FROM ${YOSYS_IMG} as yosys
FROM ${OPENROAD_IMG} as openroad

FROM ${DOCKER_BASE_IMG} AS runner
# install packages
COPY packages.txt /packages.txt
RUN yum install -y $(cat /packages.txt)
COPY requirements.txt /requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

# copy into runnner
COPY --from=pickle /build /build
COPY --from=yosys /build /build
COPY --from=openroad /build /build

# gui
RUN dbus-uuidgen --ensure

ENV PATH /build/bin:$PATH
ENV LD_LIBRARY_PATH=/build/lib:$LD_LIBRARY_PATH
CMD /bin/bash
