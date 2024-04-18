#!/usr/bin/env python3
#
# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Philippe Sauter <phsauter@iis.ee.ethz.ch>

import re
import sys
import csv

def extract_delay_and_module(log_file):
    delays = {}
    current_module = None
    delay_matches = None
    post_buff_match = None
    with open(log_file, 'r') as file:
        for line in file:
            # delay match only counts if immediately followed by this line (we want pre-buff delay)
            # pre_buff_match = re.search(r'ABC: buffering for delay and fanout...', line)

            delay_matches = re.search(r'ABC: WireLoad .* Delay =\s*(\d+\.\d+) ps', line) 

            if post_buff_match and delay_matches:
                delay_value = float(delay_matches.group(1))
                if current_module not in delays or delays[current_module] < delay_value:
                    delays[current_module] = delay_value

            post_buff_match = re.search(r'ABC: Final timing: ', line)

            module_match = re.search(r"Extracting gate netlist of module `(.*)' to ", line)
            if module_match:
                module = re.sub(r'[^\w]', '', module_match.group(1))
                current_module = module

    return delays


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <log_file>")
        sys.exit(1)
    log_file = sys.argv[1]

    delays = extract_delay_and_module(log_file)

    writer = csv.writer(sys.stdout)
    writer.writerow(['Module', 'Delay (ps)'])
    for module, delay in delays.items():
        writer.writerow([module, delay])
