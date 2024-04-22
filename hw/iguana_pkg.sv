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
  //                         and activated CLIC
  function automatic cheshire_cfg_t gen_cheshire_cfg();
    cheshire_cfg_t ret = DefaultCfg;
    // Last-Level-Cache: 4-way 256-sets @ 8x64b
    ret.LlcSetAssoc  = 4;
    ret.LlcNumLines  = 256;
    ret.LlcNumBlocks = 8;

    // Tame atomic filters
    ret.RegMaxReadTxns      = 2;
    ret.RegMaxWriteTxns     = 2;
    ret.RegAmoNumCuts       = 0;
    ret.DbgMaxReqs          = 2;
    ret.DbgMaxReadTxns      = 2;
    ret.DbgMaxWriteTxns     = 2;
    ret.DbgAmoNumCuts       = 0;
    ret.LlcAmoNumCuts       = 0;
    ret.LlcAmoPostCut       = 1;
    ret.LlcMaxReadTxns      = 16;
    ret.LlcMaxWriteTxns     = 16;
    ret.DmaConfMaxReadTxns  = 1;
    ret.DmaConfMaxWriteTxns = 1;
    ret.DmaConfAmoNumCuts   = 0;

    // reduce axi-xbar a smidge
    ret.AxiMaxMstTrans      = 16;
    ret.AxiMaxSlvTrans      = 16;

    ret.DmaNumAxInFlight    = 8;

    // 16 bit for Linux compatibility, only MSB bits are connected to pins
    ret.VgaRedWidth   = 5;
    ret.VgaGreenWidth = 6;
    ret.VgaBlueWidth  = 5;

    // if you change this you may have to change the number of regbus coming out of
    // cheshire (RegOut.num_out) in the patch at target/ihp13/picle/patch/svase/svase.sed
    ret.BusErr = 0; // too large

    // Hyberbus configuration port
    ret.RegExtNumSlv          = 1;
    ret.RegExtNumRules        = 1;
    ret.RegExtRegionIdx   [0] = RegOutHypCfgIdx;
    ret.RegExtRegionStart [0] = RegOutHypCfgBase;
    ret.RegExtRegionEnd   [0] = RegOutHypCfgEnd;
    return ret;
  endfunction

  localparam cheshire_cfg_t CheshireCfg = gen_cheshire_cfg();

  localparam int unsigned VgaOutRedWidth   = 3;
  localparam int unsigned VgaOutGreenWidth = 3;
  localparam int unsigned VgaOutBlueWidth  = 2;

  // Define used types
  `CHESHIRE_TYPEDEF_ALL(, CheshireCfg)

  // Hyperbus address rules
  typedef struct packed {
    int unsigned idx;
    logic [CheshireCfg.AddrWidth-1:0] start_addr;
    logic [CheshireCfg.AddrWidth-1:0] end_addr;
  } hyper_addr_rule_t;

endpackage
