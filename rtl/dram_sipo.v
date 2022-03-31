module dram_sipo #(
	parameter WIDTH=8,
    parameter BKWD = 0)
	(
        input clk,
        input rst_b,
        input data_in,
        output [WIDTH-1:0] data_out
	);
	
    reg toggle;
    reg [WIDTH-1:0] temp;

    always @(posedge clk or negedge rst_b)
    begin
        if(!rst_b) begin
            temp <= '0;
            toggle <= '0;
        end
        else begin
            if (toggle) begin
                if (BKWD) begin
                    temp <= {data_in, temp[7:1]};
                end
                else begin
                    temp <= {temp[6:0], data_in};
                end
            end
        end
        toggle = toggle ^ 1;
    end

    assign data_out = temp;

endmodule
