#!/bin/bash
source /usr/scratch/schneematt/janniss/Documents/openroad-iis-install/build.env
/usr/scratch/schneematt/janniss/Documents/openroad-iis-install/install/bin/openroad scripts/chip.tcl -log "openroad_$(date +"%Y_%m_%d_%I_%M_%p").log"