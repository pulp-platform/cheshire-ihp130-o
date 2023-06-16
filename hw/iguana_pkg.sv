// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Thomas Benz  <tbenz@ethz.ch>

/// Iguana constants and Cheshire overwrites
package iguana_pkg;
  `include "cheshire/typedef.svh"
  import cheshire_pkg::*;

  localparam int unsigned HyperBusNumPhys = 1;
  localparam int unsigned HyperBusNumChips = 2;
  // the address iguana boots from
  localparam logic[63:0] iguana_boot_addr = 64'h0000_0000_0100_0000;

  // Cheshire regbus out
  typedef enum byte_bt {
    RegOutHyperBusIdx = 'd0
  } cheshire_reg_out_e;

  typedef enum doub_bt {
    RegOutHyperBusBase = 'h0000_0001_0000_0000
  } reg_start_t;

  localparam doub_bt RegOutHyperBusSize = doub_bt'(HyperBusNumPhys * HyperBusNumChips * 'h800_0000);

  typedef enum doub_bt {
    RegOutHyperBusEnd = RegOutHyperBusBase + RegOutHyperBusSize
  } reg_end_t;


  localparam cheshire_cfg_t IguanaCfg = '{
    // CHANGED
    // External reg slaves (at most 8 ports and rules)
    RegExtNumSlv      : 1,
    RegExtNumRules    : 1,
    RegExtRegionIdx   : { 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, 8'b0, byte_bt'(RegOutHyperBusIdx)  },
    RegExtRegionStart : { 64'b0, 64'b0, 64'b0, 64'b0, 64'b0, 64'b0, 64'b0, doub_bt'(RegOutHyperBusBase) },
    RegExtRegionEnd   : { 64'b0, 64'b0, 64'b0, 64'b0, 64'b0, 64'b0, 64'b0, doub_bt'(RegOutHyperBusEnd)  },

    LlcSetAssoc       : 4, // 8 default
    LlcMaxReadTxns    : 4,
    LlcMaxWriteTxns   : 4,

    // DEFAULTS copied from default below here
    // CVA6 parameters
    Cva6RASDepth      : shrt_bt'(ariane_pkg::ArianeDefaultConfig.RASDepth),
    Cva6BTBEntries    : shrt_bt'(ariane_pkg::ArianeDefaultConfig.BTBEntries),
    Cva6BHTEntries    : shrt_bt'(ariane_pkg::ArianeDefaultConfig.BHTEntries),
    Cva6NrPMPEntries  : 0,
    Cva6ExtCieLength  : 'h2000_0000,
    // Harts
    DualCore          : 0,  // Only one core, but rest of config allows for two
    CoreMaxTxns       : 8,
    CoreMaxTxnsPerId  : 4,
    // Interconnect
    AddrWidth         : 48,
    AxiDataWidth      : 64,
    AxiUserWidth      : 2,  // Convention: bit 0 for core(s), bit 1 for serial link
    AxiMstIdWidth     : 2,
    AxiMaxMstTrans    : 8,
    AxiMaxSlvTrans    : 8,
    AxiUserAmoMsb     : 1,
    AxiUserAmoLsb     : 0,
    RegMaxReadTxns    : 8,
    RegMaxWriteTxns   : 8,
    RegAmoNumCuts     : 1,
    RegAmoPostCut     : 1,
    // RTC
    RtcFreq           : 32768,
    // Features
    Bootrom           : 1,
    Uart              : 1,
    I2c               : 1,
    SpiHost           : 1,
    Gpio              : 1,
    Dma               : 1,
    SerialLink        : 1,
    Vga               : 1,
    // Debug
    DbgIdCode         : CheshireIdCode,
    DbgMaxReqs        : 4,
    DbgMaxReadTxns    : 4,
    DbgMaxWriteTxns   : 4,
    DbgAmoNumCuts     : 1,
    DbgAmoPostCut     : 1,
    // LLC: 128 KiB, up to 2 GiB DRAM
    LlcNotBypass      : 1,
    LlcNumLines       : 256,
    LlcNumBlocks      : 8,
    LlcAmoNumCuts     : 1,
    LlcAmoPostCut     : 1,
    LlcOutConnect     : 1,
    LlcOutRegionStart : 'h8000_0000,
    LlcOutRegionEnd   : doub_bt'('h1_0000_0000),
    // VGA: RGB332
    VgaRedWidth       : 3,
    VgaGreenWidth     : 3,
    VgaBlueWidth      : 2,
    VgaHCountWidth    : 24, // TODO: Default is 32; is this needed?
    VgaVCountWidth    : 24, // TODO: See above
    // Serial Link: map other chip's lower 32bit to 'h1_000_0000
    SlinkMaxTxnsPerId : 4,
    SlinkMaxUniqIds   : 4,
    SlinkMaxClkDiv    : 1024,
    SlinkRegionStart  : doub_bt'('h2_0000_0000),
    SlinkRegionEnd    : doub_bt'('h3_0000_0000),
    SlinkTxAddrMask   : 'hFFFF_FFFF,
    SlinkTxAddrDomain : 'h0000_0000,
    SlinkUserAmoBit   : 1,  // Upper atomics bit for serial link
    // DMA config
    DmaConfMaxReadTxns  : 4,
    DmaConfMaxWriteTxns : 4,
    DmaConfAmoNumCuts   : 1,
    DmaConfAmoPostCut   : 1,
    // GPIOs
    GpioInputSyncs    : 1,
    // All non-set values should be zero
    // AXI RT
    AxiRtNumPending   : 16,
    AxiRtWBufferDepth : 16,
    default: '0
  };
  `CHESHIRE_TYPEDEF_ALL(, IguanaCfg)

endpackage
