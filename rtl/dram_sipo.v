module dram_sipo #(
	parameter WIDTH=8)
	(
        input clk,
        input rst_b,
        input load,
        input data_in,
        output [WIDTH-1:0] data_out
	);
	
    reg [WIDTH-1:0] temp;

    always @(posedge clk or negedge rst_b)
    begin
        if(!rst_b) begin
            temp <= '0;
        end
        else begin
            temp <= {temp[6:0], data_in};
        end
    end

    assign data_out = temp;

endmodule
