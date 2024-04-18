module tb_cheshire_bootrom;
    parameter int unsigned AW = 32;
    parameter int unsigned DW = 32;

    logic [AW-1:0] addr;
    logic [DW-1:0] data_orig, data_split;
    logic request;

    cheshire_bootrom #(
        .AddrWidth(AW), 
        .DataWidth(DW)
    ) i_cheshire_bootrom (
        .clk_i  ('0),
        .rst_ni ('0),
        .req_i  ('0),
        .addr_i (addr),
        .data_o (data_orig)
    );

    cheshire_bootrom_split #(
        .AddrWidth(AW), 
        .DataWidth(DW)
    ) i_cheshire_bootrom_split (
        .clk_i  ('0),
        .rst_ni ('0),
        .req_i  (request),
        .addr_i (addr),
        .data_o (data_split)
    );

    initial begin
        // in cheshire_soc it uses 16-bit AddrWidth
        for (int i = 0; i < 2**16; i++) begin
            addr = i;
            request = 1'b1;
            #10;

            if (data_orig !== data_split) begin
            $display("Error at addr = %0d, orig = %h, split = %h", addr, data_orig, data_split);
            end
            request = 1'b0;
            #10;
        end

        $stop;
    end

endmodule