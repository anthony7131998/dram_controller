// dram_row_decoder.v

module dram_row_decoder (
    input [6:0] din,
    output reg [127:0] dout
);

    reg [127:0] tmp_dout;

    always @(*) begin
        tmp_dout = 128'h1;
        dout = tmp_dout << din;
    end

endmodule