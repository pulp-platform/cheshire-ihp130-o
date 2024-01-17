module tb_cheshire_bootrom;
    parameter int unsigned AW = 32;
    parameter int unsigned DW = 32;

    logic [AW-1:0] addr;
    logic [DW-1:0] data_orig, data_split;

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
        .req_i  ('0),
        .addr_i (addr),
        .data_o (data_split)
    );

    initial begin
        // in cheshire_soc it uses 16-bit AddrWidth
        for (int i = 0; i < 2**16; i++) begin
            addr = i;

            #1; // probably not necessary

            if (data_orig !== data_split) begin
            $display("Error at addr = %0d, orig = %h, split = %h", addr, data_orig, data_split);
            end

            #1; // probably not necessary
        end

        $stop;
    end

endmodule