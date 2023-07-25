// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

module ixc013_i16x (
  inout  logic PAD,
  output logic OUT
);

  buf (strong1, strong0) (OUT, PAD);

endmodule

module ixc013_b16m (
  inout  logic PAD,
  input  logic IN,
  output logic OUT,
  input  logic OEN
);

  buf (strong1, strong0) (OUT, PAD);
  bufif0 (strong1, strong0) (PAD, IN, OEN);

endmodule

module ixc013_b16mpup (
  inout  logic PAD,
  input  logic IN,
  output logic OUT,
  input  logic OEN
);

  buf (strong1, strong0) (OUT, PAD);
  bufif0 (strong1, strong0) (PAD, IN, OEN);
  pullup (PAD);

endmodule

module ixc013_b16mpdn (
  inout  logic PAD,
  input  logic IN,
  output logic OUT,
  input  logic OEN
);

  buf (strong1, strong0) (OUT, PAD);
  bufif0 (strong1, strong0) (PAD, IN, OEN);
  pulldown (PAD);

endmodule

module vddcore;

endmodule

module gndcore;

endmodule

module vddpad;

endmodule

module gndpad;

endmodule
