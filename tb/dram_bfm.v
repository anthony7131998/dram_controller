// dram_bfm.v


module dram_bfm #(
    parameter integer NUM_OF_BANKS=8,
    parameter integer NUM_OF_ROWS=128,
    parameter integer NUM_OF_COLS=8,
    parameter integer DATA_WIDTH=1
) (
    input clk,
    input rst_b,
    input bank_rw,
    input buffer_rw,
    input [$clog2(NUM_OF_BANKS)-1:0] bank_id,
    input [$clog2(NUM_OF_ROWS)-1:0] rowid,
    input [$clog2(NUM_OF_COLS)-1:0] colid,
    inout data
);

    integer i;
    integer j;

    reg [DATA_WIDTH-1:0] bank0 [NUM_OF_ROWS-1:0][NUM_OF_COLS-1:0];
    reg [DATA_WIDTH-1:0] bank1 [NUM_OF_ROWS-1:0][NUM_OF_COLS-1:0];
    reg [DATA_WIDTH-1:0] bank2 [NUM_OF_ROWS-1:0][NUM_OF_COLS-1:0];
    reg [DATA_WIDTH-1:0] bank3 [NUM_OF_ROWS-1:0][NUM_OF_COLS-1:0];
    reg [DATA_WIDTH-1:0] bank4 [NUM_OF_ROWS-1:0][NUM_OF_COLS-1:0];
    reg [DATA_WIDTH-1:0] bank5 [NUM_OF_ROWS-1:0][NUM_OF_COLS-1:0];
    reg [DATA_WIDTH-1:0] bank6 [NUM_OF_ROWS-1:0][NUM_OF_COLS-1:0];
    reg [DATA_WIDTH-1:0] bank7 [NUM_OF_ROWS-1:0][NUM_OF_COLS-1:0];

    reg tmp_data;

    reg [7:0] buffers [NUM_OF_BANKS-1:0];

    assign data = buffer_rw ? buffers : 'bz;

    always @(posedge clk or negedge rst_b) begin
        if(!rst_b) begin
            for (i=0; i<NUM_OF_ROWS; i=i+1) begin
                for (j=0; j<NUM_OF_COLS; j=j+1) begin
                    bank0[i][j] <= '0;
                    bank1[i][j] <= '0;
                    bank2[i][j] <= '0;
                    bank3[i][j] <= '0;
                    bank4[i][j] <= '0;
                    bank5[i][j] <= '0;
                    bank6[i][j] <= '0;
                    bank7[i][j] <= '0;

                    buffers[j] <= '0;
                end
            end
        end else begin
            if(bank_rw) begin
                case(bank_id)
                    3'b000: bank0[rowid][colid] <= tmp_data;
                    3'b001: bank1[rowid][colid] <= data;
                    3'b010: bank2[rowid][colid] <= data;
                    3'b011: bank3[rowid][colid] <= data;
                    3'b100: bank4[rowid][colid] <= data;
                    3'b101: bank5[rowid][colid] <= data;
                    3'b110: bank6[rowid][colid] <= data;
                    3'b111: bank7[rowid][colid] <= data;
                endcase
            end else if(buffer_rw) begin
                case(bank_id)
                    3'b000: buffers[0] <= bank0[rowid][colid];
                    3'b001: buffers[1] <= bank1[rowid][colid];
                    3'b010: buffers[2] <= bank2[rowid][colid];
                    3'b011: buffers[3] <= bank3[rowid][colid];
                    3'b100: buffers[4] <= bank4[rowid][colid];
                    3'b101: buffers[5] <= bank5[rowid][colid];
                    3'b110: buffers[6] <= bank6[rowid][colid];
                    3'b111: buffers[7] <= bank7[rowid][colid];
                endcase            
            end
        end
    end

    always @(posedge clk or negedge rst_b) begin
        if(!rst_b) begin
            data <= '0;
        end else begin
            if(!buffer_rw) begin
                case(bank_id)
                    3'b000: data <= buffers[0];
                    3'b001: data <= buffers[1];
                    3'b010: data <= buffers[2];
                    3'b011: data <= buffers[3];
                    3'b100: data <= buffers[4];
                    3'b101: data <= buffers[5];
                    3'b110: data <= buffers[6];
                    3'b111: data <= buffers[7];
                endcase
            end
        end
    end



endmodule
