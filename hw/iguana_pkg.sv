// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Thomas Benz  <tbenz@ethz.ch>

/// Iguana constants and Cheshire overwrites
package iguana_pkg;

    // the address iguana boots from
    localparam logic[63:0] iguana_boot_addr = 64'h0000_0000_0100_0000;

endpackage
