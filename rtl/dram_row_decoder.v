// dram_row_decoder.v

module dram_row_decoder (
    input en,
    input [6:0] din,
    output reg [127:0] dout
);

    reg [127:0] tmp_dout;

    assign dout = tmp_dout;

    always @(*) begin
        tmp_dout <= 128'h0;
        if(en) begin
            tmp_dout <= 128'h1;
            tmp_dout <= tmp_dout << din;
        end
    end

endmodule