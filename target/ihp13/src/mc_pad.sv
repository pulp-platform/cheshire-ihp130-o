// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

module mc_pad_in (
  inout  logic pad_io,
  output logic d_o
);

  sg13g2_pad_in i_pad (.*);

endmodule

module mc_pad_io (
  inout  logic pad_io,
  input  logic d_i,
  output logic d_o,
  input  logic oe_i
);

  sg13g2_pad_io i_pad (.*);

endmodule

module mc_pad_io_pu (
  inout  logic pad_io,
  input  logic d_i,
  output logic d_o,
  input  logic oe_i
);

  sg13g2_pad_io_pu i_pad (.*);

endmodule

module mc_pad_io_pd (
  inout  logic pad_io,
  input  logic d_i,
  output logic d_o,
  input  logic oe_i
);

  sg13g2_pad_io_pd i_pad (.*);

endmodule

module mc_pad_vddco;

  sg13g2_pad_vddco i_pad ();

endmodule

module mc_pad_gndco;

  sg13g2_pad_gndco i_pad ();

endmodule

module mc_pad_vddio;

  sg13g2_pad_vddio i_pad ();

endmodule

module mc_pad_gndio;

  sg13g2_pad_gndio i_pad ();

endmodule
