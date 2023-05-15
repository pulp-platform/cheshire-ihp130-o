# Directories
CDIR		:= $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
BUILD		?= build

# Tools
BENDER 	?= bender	# https://github.com/pulp-platform/bender
MORTY		?= morty	# https://github.com/pulp-platform/morty

# Project variables
TOP_DESIGN	?= iguana_padframe_fixture
PICKLE_FILE ?= $(BUILD)/$(TOP_DESIGN).pickle.sv


pickle: $(MORTY) $(PICKLE_FILE)
$(PICKLE_FILE): sources.json
	@mkdir -p $(@D)
	sed "s| << riscv::XLEN-2| << (riscv::XLEN-2)|g" $(shell $(BENDER) path cva6)/core/include/ariane_pkg.sv > ariane_pkg.tmp
	mv ariane_pkg.tmp $(shell $(BENDER) path cva6)/core/include/ariane_pkg.sv
	$(MORTY) -f $< -q -o $@ -D VERILATOR=1 --keep_defines --top $(TOP_DESIGN)
	# applying patches
	cat patches/reg_bus_interface_ugly_copy.sv >> $@  	# Todo: fix REGBUS copy in morty
	sed "s/\s*req_q <= (store_req_t'.*/      req_q <= (store_req_t'{mode: axi_llc_pkg::tag_mode_e'(2'b0), default: '0});/g" $@ > $@.tmp
	sed "s/module slib_mv_filter #(parameter WIDTH = 4, THRESHOLD = 10).*/module slib_mv_filter #(parameter WIDTH = 4, parameter THRESHOLD = 10) (/g" $@.tmp > $@
	patch -u $@ -i patches/serial_link_ddr_in_ff.patch # Todo: Change in source as per IEEE 1364.1 
	patch -u $@ -i patches/clic_implicit_conversion.patch # Todo: Make conversion explicit in RTL
	rm $@.tmp

# patch -u $@ -i patches/get_permutations.patch
morty: 
	@if ! which svase > /dev/null 2>&1; then \
        echo "Not yet integrated, you will have to go get it yourself."; \
		echo "https://github.com/pulp-platform/morty/releases"; \
    fi

.PHONY: pickle morty
