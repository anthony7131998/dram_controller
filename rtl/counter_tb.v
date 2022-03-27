`timescale 1ns / 1ps

module counter_tb;

 parameter width = 1000;
  reg clk;
  reg rst;
  reg en;
  
  wire [(width)-1:0] count;
  
  counter counter_ut (.clk (clk), 
                      .rst(rst), 
					  .count(count),
					  .en(en));
  
  
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
	
	#100 $finish;
  end
  
  always #8 clk = ~clk;
  
endmodule