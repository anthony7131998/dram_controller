`timescale 1ns / 1ps

module counter_tb;

	parameter width = 36;
	
	reg clk;
    reg rst;
    reg en;
    reg refresh_flag;
    reg [width-1:0] count;

  
	counter counter_ut (.*);
  
	initial begin
		clk  = '0;
		rst  = 1'b1;
		en   = '0;
		#100;        // Wait 100 ns for global reset to finish
		
		rst  = 1'b0;
		en = 1'b1;
		#125 ;
		
		rst = 1'b1;
		en = '0;
		#125;
		
		rst = 1'b0;
		en = 1'b1;
		#125;
		
		@(refresh_flag);
		#125;
		@(refresh_flag);
		disable generate_clk;
	end
  
  initial begin : generate_clk
	  while(1) #8 clk = ~clk;
  end
  
endmodule