# TODO change once we have correct tools installed with DZ
OPENROAD_ROOT := /usr/scratch/schneematt/janniss/Documents/openroad-build/install
# sourcing yosys and sv2v
export PATH := $(OPENROAD_ROOT)/bin:$(PATH)
# hacky svase pathiing
export PATH := $(PATH):/usr/scratch/schneematt/janniss/Documents/tmp/svase/build
# sourcing svase and morty
export PATH := $(PATH):/usr/scratch/pisoc11/sem23f30/tools/bin
