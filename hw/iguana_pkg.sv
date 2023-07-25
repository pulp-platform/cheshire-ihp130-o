// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Thomas Benz <tbenz@iis.ee.ethz.ch>
// - Paul Scheffler <paulsc@iis.ee.ethz.ch>

package iguana_pkg;

  `include "cheshire/typedef.svh"

  import cheshire_pkg::*;

  // GPIO parameters
  localparam int unsigned GpioNumWired = 12;

  // Hyperbus parameters
  localparam int unsigned HypNumPhys      = 1;
  localparam int unsigned HypNumChips     = 2;
  localparam int unsigned HypRstChipBytes = 8*1024;   // S27KS0641 is 64 Mib (Mebibit)

  // Hyperbus configuration port
  localparam byte_bt RegOutHypCfgIdx  = 0;
  localparam doub_bt RegOutHypCfgBase = 'h4000_0000;
  localparam doub_bt RegOutHypCfgSize = doub_bt'(HypNumPhys * HypNumChips * 'h800_0000);
  localparam doub_bt RegOutHypCfgEnd  = RegOutHypCfgBase + RegOutHypCfgSize;

  // Cheshire configuration: default except for added Hyperbus config port
  function automatic cheshire_cfg_t gen_cheshire_cfg();
    cheshire_cfg_t ret = DefaultCfg;
    ret.RegExtNumSlv          = 1;
    ret.RegExtNumRules        = 1;
    ret.RegExtRegionIdx   [0] = RegOutHypCfgIdx;
    ret.RegExtRegionStart [0] = RegOutHypCfgBase;
    ret.RegExtRegionEnd   [0] = RegOutHypCfgEnd;
    return ret;
  endfunction

  localparam cheshire_cfg_t CheshireCfg = gen_cheshire_cfg();

  // Define used types
  `CHESHIRE_TYPEDEF_ALL(, CheshireCfg)

  // Hyperbus address rules
  typedef struct packed {
    int unsigned idx;
    logic [CheshireCfg.AddrWidth-1:0] start_addr;
    logic [CheshireCfg.AddrWidth-1:0] end_addr;
  } hyper_addr_rule_t;

endpackage
