module fifo_dram #(
	parameter width = 8,
	parameter depth = 8 )
	(
		input [width-1:0] datain,
		input clk,
		input rd_en,
		input wr_en,
		input rst,
		output reg [width-1:0] dataout,
		output full_flag,
		output empty_flag
	);
	
	integer i;
	reg [width-1:0] buff [depth-1:0];
	reg [width-1:0] count;
	reg [width-1:0] rd_addr; // this will traverse along the width of the buffer
	reg [width-1:0] wr_addr; //

	assign empty_flag = (count == 0) ? 1'b1 : 1'b0;
	assign full_flag =  (count == width) ? 1'b1 : 1'b0;
	
	always@(posedge clk)
	begin
		if (rst) begin
			rd_addr <= '0;
			wr_addr <= '0;
			dataout <= '0;
			for(i=0; i<depth; i=i+1) begin
				buff[i] <= '0;
			end
		end
		else begin
			if (wr_en && !full_flag) begin
				buff[wr_addr] <= datain;
				wr_addr <= wr_addr + 1;
			end
			else if (rd_en && !empty_flag) begin
				dataout <= buff[rd_addr];
				rd_addr <= rd_addr +1;
			end
			else;
		end
		
		if (rd_addr == width)
			rd_addr <= '0;
		else if (wr_addr == width)
			wr_addr <= '0;
		
		count <= (wr_addr>rd_addr)? (wr_addr-rd_addr):(rd_addr-wr_addr);
		
	end
	endmodule			
				
				
