module counter #(
    parameter width=36
) ( input clk,
    input rst,
    input en,
    output reg refresh_flag,
    output reg [width-1:0] count
);
	
				   
    always @ (posedge clk) begin
        if (rst) begin
            count <= '0;
            refresh_flag <= 1'b0;
            
        end else begin
            if (en) begin
                count <= count+1;
                refresh_flag <= 1'b0;
            end
            if(count == 7812479) begin
                refresh_flag <= 1'b1;    //assuming clock freq of 150MHz, time period of 7ns, 125 ms = 17857142 cycles
                count <= '0;
            end
        end
    end

endmodule