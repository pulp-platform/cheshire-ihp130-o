// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Jannis Schönleber <janniss@student.ethz.ch>

module tb_iguana;

  parameter time          HypPowerupTime = 600us;
  parameter int unsigned  HypPowerupItvs = 5;

  fixture_iguana fix();

  string      preload_elf;
  string      boot_hex;
  logic [1:0] boot_mode;
  logic [1:0] preload_mode;
  bit [31:0]  exit_code;

  initial begin
    // Fetch plusargs or use safe (fail-fast) defaults
    if (!$value$plusargs("BOOTMODE=%d", boot_mode))     boot_mode     = 0;
    if (!$value$plusargs("PRELMODE=%d", preload_mode))  preload_mode  = 0;
    if (!$value$plusargs("BINARY=%s",   preload_elf))   preload_elf   = "";
    if (!$value$plusargs("IMAGE=%s",    boot_hex))      boot_hex      = "";

    // Set boot mode and preload boot image if there is one
    fix.vip.set_boot_mode(boot_mode);
    fix.vip.i2c_eeprom_preload(boot_hex);
    fix.vip.spih_norflash_preload(boot_hex);

    // Wait for reset
    fix.vip.wait_for_reset();

    // Wait for Hyperbus to power up
    $timeformat(-6, 0, "", 5);
    $display("[TB] Waiting for HyperRAM powerup (%0t us)", HypPowerupTime);
    for (int i = 1; i <= HypPowerupItvs; ++i) begin
      automatic time delta = HypPowerupTime / HypPowerupItvs;
      #(delta) $display("[TB] - %0t/%0t us (%0d%%)", i*delta, HypPowerupTime, 100*i/HypPowerupItvs);
    end

    // Preload in idle mode or wait for completion in autonomous boot
    if (boot_mode == 0) begin
      // Idle boot: preload with the specified mode
      case (preload_mode)
        0: begin      // JTAG
          fix.vip.jtag_init();
          fix.vip.jtag_elf_run(preload_elf);
          fix.vip.jtag_wait_for_eoc(exit_code);
        end 1: begin  // Serial Link
          fix.vip.slink_elf_run(preload_elf);
          fix.vip.slink_wait_for_eoc(exit_code);
        end 2: begin  // UART
          fix.vip.uart_debug_elf_run_and_wait(preload_elf, exit_code);
        end default: begin
          $fatal(1, "Unsupported preload mode %d (reserved)!", boot_mode);
        end
      endcase
    end else if (boot_mode == 1) begin
      $fatal(1, "Unsupported boot mode %d (SD Card)!", boot_mode);
    end else begin
      // Autonomous boot: Only poll return code
      fix.vip.jtag_init();
      fix.vip.jtag_wait_for_eoc(exit_code);
    end

    $finish;
  end

endmodule
