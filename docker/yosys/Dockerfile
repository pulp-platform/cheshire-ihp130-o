# based on: https://docs.docker.com/build/building/multi-stage/
# syntax=docker/dockerfile:1
ARG DOCKER_BASE_IMG=almalinux:8.9

FROM ${DOCKER_BASE_IMG} AS builder
ARG YOSYS_REPO=https://github.com/YosysHQ/yosys
ARG YOSYS_COMMIT=yosys-0.36
# install packages
COPY packages.txt /packages.txt
RUN yum install -y $(cat /packages.txt)

WORKDIR /yosys
# pull and build
RUN curl -L ${YOSYS_REPO}/archive/${YOSYS_COMMIT}.tar.gz | tar -xzC . --strip-components=1 && \
    make config-clang && \
    make -j && \
    make PREFIX=/build install

# copy into runnner
FROM ${DOCKER_BASE_IMG} AS runner
COPY --from=builder /build /build
ENV PATH /build/bin:$PATH