# Copyright (c) 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@ethz.ch>

# Directories
# directory of the path to the last called Makefile (this one)
DOCKER_DIR 		:= $(realpath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

IMG_NAME = phsauter/pulp-iguana
IMG_TAG = dev

pull:
	docker pull $(IMG_NAME):$(IMG_TAG)

build: build-pickle build-yosys build-openroad
	cd $(DOCKER_DIR)/all && \
	docker build --build-arg PICKLE_IMG=pulp-iguana-pickle:$(IMG_TAG) \
				 --build-arg YOSYS_IMG=pulp-iguana-yosys:$(IMG_TAG) \
				 --build-arg OPENROAD_IMG=pulp-iguana-openroad:$(IMG_TAG) \
				 -t $(IMG_NAME):$(IMG_TAG) .


build-pickle:
	cd $(DOCKER_DIR)/pickle && \
	docker build -t pulp-iguana-pickle:$(IMG_TAG) .
	
build-yosys:
	cd $(DOCKER_DIR)/yosys && \
	docker build -t pulp-iguana-yosys:$(IMG_TAG) .
	
build-openroad:
	cd $(DOCKER_DIR)/openroad && \
	docker build -t pulp-iguana-openroad:$(IMG_TAG) .
	
.PHONY: pull build build-pickle build-yosys build-openroad
