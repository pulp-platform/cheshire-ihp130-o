// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Paul Scheffler <paulsc@iis.ee.ethz.ch>

module mc_pad_in (
  inout  logic pad_io,
  output logic d_o
);
  (* keep *)(* dont_touch = "true" *)
  ixc013_i16x i_pad (
    .PAD  ( pad_io ),
    .DOUT ( d_o )
  );

endmodule

module mc_pad_io (
  inout  logic pad_io,
  input  logic d_i,
  output logic d_o,
  input  logic oe_i
);
  (* keep *)(* dont_touch = "true" *)
  ixc013_b16m i_pad (
    .PAD  ( pad_io ),
    .DIN  ( d_i ),
    .DOUT ( d_o ),
    .OEN  ( ~oe_i )
  );

endmodule

module mc_pad_io_pu (
  inout  logic pad_io,
  input  logic d_i,
  output logic d_o,
  input  logic oe_i
);
  (* keep *)(* dont_touch = "true" *)
  ixc013_b16mpup i_pad (
    .PAD  ( pad_io ),
    .DIN  ( d_i ),
    .DOUT ( d_o ),
    .OEN  ( ~oe_i )
  );

endmodule

module mc_pad_io_pd (
  inout  logic pad_io,
  input  logic d_i,
  output logic d_o,
  input  logic oe_i
);
  (* keep *)(* dont_touch = "true" *)
  ixc013_b16mpdn i_pad (
    .PAD  ( pad_io ),
    .DIN  ( d_i ),
    .DOUT ( d_o ),
    .OEN  ( ~oe_i )
  );

endmodule

module mc_pad_vddco;
  (* keep *)(* dont_touch = "true" *)
  vddcore i_pad ();

endmodule

module mc_pad_gndco;
  (* keep *)(* dont_touch = "true" *)
  gndcore i_pad ();

endmodule

module mc_pad_vddio;
  (* keep *)(* dont_touch = "true" *)
  vddpad i_pad ();

endmodule

module mc_pad_gndio;
  (* keep *)(* dont_touch = "true" *)
  gndpad i_pad ();

endmodule
