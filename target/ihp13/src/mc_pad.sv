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

  ixc013_i16x i_pad (
    .PAD ( pad_io ),
    .OUT ( d_o )
  );

endmodule

module mc_pad_io (
  inout  logic pad_io,
  input  logic d_i,
  output logic d_o,
  input  logic oe_i
);

  ixc013_b16m i_pad (
    .PAD ( pad_io ),
    .IN  ( d_i ),
    .OUT ( d_o ),
    .OEN ( ~oe_i )
  );

endmodule

module mc_pad_io_pu (
  inout  logic pad_io,
  input  logic d_i,
  output logic d_o,
  input  logic oe_i
);

  ixc013_b16m i_pad (
    .PAD ( pad_io ),
    .IN  ( d_i ),
    .OUT ( d_o ),
    .OEN ( ~oe_i )
  );

endmodule

module mc_pad_io_pd (
  inout  logic pad_io,
  input  logic d_i,
  output logic d_o,
  input  logic oe_i
);

  ixc013_b16m i_pad (
    .PAD ( pad_io ),
    .IN  ( d_i ),
    .OUT ( d_o ),
    .OEN ( ~oe_i )
  );

endmodule

module mc_pad_vddco;

  vddcore i_pad ();

endmodule

module mc_pad_gndco;

  gndcore i_pad ();

endmodule

module mc_pad_vddio;

  vddpad i_pad ();

endmodule

module mc_pad_gndio;

  gndpad i_pad ();

endmodule
