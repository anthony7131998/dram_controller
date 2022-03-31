module dram_buffer #(
	parameter WIDTH=8,
	parameter DEPTH=8)
	(
		input [WIDTH-1:0] datain,
		input clk,
		input rd_en,
		input wr_en,
		input rst_b,
		output reg [WIDTH-1:0] dataout,
		output full_flag,
		output empty_flag
	);
	
	integer i;
	reg [WIDTH-1:0] buff [DEPTH-1:0];
	reg [WIDTH-1:0] count;
	reg [WIDTH-1:0] rd_addr; // this will traverse along the width of the buffer
	reg [WIDTH-1:0] wr_addr; //

	assign empty_flag = (count == 0) ? 1'b1 : 1'b0;
	assign full_flag =  (count == DEPTH-1) ? 1'b1 : 1'b0;
	
	always @(posedge clk or negedge rst_b) begin
		if (!rst_b) begin
			rd_addr <= '0;
			wr_addr <= '0;
			dataout <= '0;
			count <= '0;
			for(i=0; i<DEPTH; i=i+1) begin
				buff[i] <= '0;
			end
		end
		else begin
			if (wr_en && !full_flag) begin
				buff[wr_addr] <= datain;
				wr_addr <= wr_addr + 1;
				count <= count + 1'b1;
			end else if (rd_en && !empty_flag) begin
				dataout <= buff[rd_addr];
				rd_addr <= rd_addr + 1;
				count <= count - 1'b1;
			end
			else;
		end
		
		if (rd_addr == DEPTH-1)
			rd_addr <= 0;
		else if (wr_addr == DEPTH-1)
			wr_addr <= '0;
		
		
	end
endmodule	
				
				
