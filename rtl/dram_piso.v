module dram_piso #(
	parameter WIDTH=8)
	(
        input clk,
        input rst_b,
        input load,
		input [WIDTH-1:0] data_in,
        output data_out
	);
	
    reg [WIDTH-1:0] loaded_value;

    always @(posedge clk or negedge rst_b)
    begin
        if(!rst_b) begin
            loaded_value <= '0;
        end
        else begin
            if (load) begin
                loaded_value <= data_in;
            end
            else begin
                loaded_value <= {1'b0, loaded_value[WIDTH-1:1]};
            end
        end
    end

    assign data_out = loaded_value[0];

endmodule
