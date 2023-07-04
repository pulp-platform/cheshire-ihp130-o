// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

module sg13g2_pad_in (
  inout  logic pad_io,
  output logic d_o
);

  buf (strong1, strong0) (d_o, pad_io);

endmodule

module sg13g2_pad_io (
  inout  logic pad_io,
  input  logic d_i,
  output logic d_o,
  input  logic oe_i
);

  buf (strong1, strong0) (d_o, pad_io);
  bufif1 (strong1, strong0) (pad_io, d_i, oe_i);

endmodule

module sg13g2_pad_io_pu (
  inout  logic pad_io,
  input  logic d_i,
  output logic d_o,
  input  logic oe_i
);

  buf (strong1, strong0) (d_o, pad_io);
  bufif1 (strong1, strong0) (pad_io, d_i, oe_i);
  pullup (pad_io);

endmodule

module sg13g2_pad_io_pd (
  inout  logic pad_io,
  input  logic d_i,
  output logic d_o,
  input  logic oe_i
);

  buf (strong1, strong0) (d_o, pad_io);
  bufif1 (strong1, strong0) (pad_io, d_i, oe_i);
  pulldown (pad_io);

endmodule

module sg13g2_pad_vddco;

endmodule

module sg13g2_pad_gndco;

endmodule

module sg13g2_pad_vddio;

endmodule

module sg13g2_pad_gndio;

endmodule
