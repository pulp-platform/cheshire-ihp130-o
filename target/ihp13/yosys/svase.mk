# Directories
BUILD		?= build

# Tools
SVASE 	?= svase	# https://github.com/paulsc96/svase/tree/iguana
SLANG		?= slang	# https://github.com/MikePopoloski/slang

# Project variables
TOP_DESIGN	?= iguana_padframe_fixture
PICKLE_FILE ?= $(BUILD)/$(TOP_DESIGN).pickle.sv
SVASE_FILE	?= $(BUILD)/$(TOP_DESIGN).svase.sv
UNIQUE_TOP	 = $(shell sed -n 's|module \($(TOP_DESIGN)[[:alnum:]_]*\)\s.*$$|\1|p' $(SVASE_FILE) | tail -1)

run-svase: $(SVASE) $(SVASE_FILE)
$(SVASE_FILE): $(PICKLE_FILE)
	$(SVASE) $(TOP_DESIGN) $@ $< | tee svase.log
	sed "s|RegOut.num_out|6'h0d|g" $@ > $@.tmp # Todo: fix this, is this even correct? (svase pass?) +1 due to regbus
	sed "s|localparam int unsigned SlinkMaxClkDiv  =|//// localparam int unsigned SlinkMaxClkDiv  =|g" $@.tmp > $@
	rm $@.tmp

run-slang: $(PICKLE_FILE) $(SLANG)
	sed -n 's|module \($(TOP_DESIGN)[[:alnum:]_]*\)\s.*$$|\1|p' $<
	$(SLANG) $< -Wrange-oob --allow-use-before-declare -Wrange-width-oob -error-limit=4419 -top $(UNIQUE_TOP)

svase:
	@if ! which svase > /dev/null 2>&1; then \
        echo "Not yet integrated, you will have to build it yourself."; \
		echo "git clone --recursive https://github.com/paulsc96/svase.git; cd svase; git checkout iguana;"; \
    fi

slang: svase

.PHONY: run-svase run-slang svase slang
