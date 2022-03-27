`timescale 1ns / 1ps

module fifo_tb;
	reg clk; //inputs
	reg [7:0] datain; //inputs
	reg rd_en;
	reg wr_en;
	reg rst;
 
	wire [7:0] dataout; // output
	wire empty_flag; //output
	wire full_flag; //output

 // Instantiate the Unit Under Test (UUT)

 fifo_dram uut (

                  .clk(clk), 
                  .datain(datain), 
                  .rd_en(rd_en), 
                  .wr_en(wr_en), 
                  .dataout(dataout), 
                  .rst(rst), 
                  .empty_flag(empty_flag), 
                  .full_flag(full_flag)
                  );

 initial begin

  clk  = 1'b0;
  datain  =8'h0;
  rd_en  = 1'b1;
  wr_en  = 1'b0;
  rst  = 1'b1;
  
  #100;        // Wait 100 ns for global reset to finish 

 
  rst  = 1'b1;
  #30;
  rst  = 1'b0;
  wr_en  = 1'b1;
  datain  = 8'h0;
  #30;
  datain  = 8'h1;
  #30;
  datain  = 8'h2;
  #30;
  datain  = 8'h3;
  #30;
  datain  = 8'h4;
  #30;
  wr_en = 1'b0;
  rd_en = 1'b1;  

 end 

   always #15 clk = ~clk;    

endmodule