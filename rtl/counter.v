module counter #(parameter width = 18000000 )

	(input clk,
    input rst,
    input en,
    output reg [width-1:0] count);
	
    reg refresh_flag;
	reg reset_flag;
	
	assign refresh_flag = (count == 17857142)?1'b1:1'b0;    //assuming clock freq of 150MHz, time period of 7ns, 125 ms = 17857142 cycles
	assign reset_flag = (count == 17857142)?1'b1:1'b0;
			   
always @ (posedge clk) 
begin
            if (rst || reset_flag)
				count <= '0;
				
            else if (en) 
            count <= count+1;
			
            else;
end
endmodule