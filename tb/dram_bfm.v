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
    reg data_out;

    reg [7:0] buffers [NUM_OF_BANKS-1:0];
    reg [7:0] buffer_tmp0;
    reg [7:0] buffer_tmp1;
    reg [7:0] buffer_tmp2;
    reg [7:0] buffer_tmp3;
    reg [7:0] buffer_tmp4;
    reg [7:0] buffer_tmp5;
    reg [7:0] buffer_tmp6;
    reg [7:0] buffer_tmp7;

    assign data = (!bank_rw) ? data_out : 1'bz;

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
                    buffer_tmp0 <= '0;
                    buffer_tmp1 <= '0;
                    buffer_tmp2 <= '0;
                    buffer_tmp3 <= '0;
                    buffer_tmp4 <= '0;
                    buffer_tmp5 <= '0;
                    buffer_tmp6 <= '0;
                    buffer_tmp7 <= '0;

                end
            end
        end else begin
            if(bank_rw) begin
                case(bank_id)
                    3'b000: bank0[rowid][colid] <= data;
                    3'b001: bank1[rowid][colid] <= data;
                    3'b010: bank2[rowid][colid] <= data;
                    3'b011: bank3[rowid][colid] <= data;
                    3'b100: bank4[rowid][colid] <= data;
                    3'b101: bank5[rowid][colid] <= data;
                    3'b110: bank6[rowid][colid] <= data;
                    3'b111: bank7[rowid][colid] <= data;
                endcase
            end else if(buffer_rw) begin
                for(i=0; i<NUM_OF_COLS ; i=i+1) begin
                    buffer_tmp0[i] <= bank0[rowid][i];
                    buffer_tmp1[i] <= bank1[rowid][i];
                    buffer_tmp2[i] <= bank2[rowid][i];
                    buffer_tmp3[i] <= bank3[rowid][i];
                    buffer_tmp4[i] <= bank4[rowid][i];
                    buffer_tmp5[i] <= bank5[rowid][i];
                    buffer_tmp6[i] <= bank6[rowid][i];
                    buffer_tmp7[i] <= bank7[rowid][i];
                end
                case(bank_id)
                        3'b000: buffers[0] <= buffer_tmp0;
                        3'b001: buffers[1] <= buffer_tmp1;
                        3'b010: buffers[2] <= buffer_tmp2;
                        3'b011: buffers[3] <= buffer_tmp3;
                        3'b100: buffers[4] <= buffer_tmp4;
                        3'b101: buffers[5] <= buffer_tmp5;
                        3'b110: buffers[6] <= buffer_tmp6;
                        3'b111: buffers[7] <= buffer_tmp7;
                endcase            
            end
        end
    end

    always @(posedge clk or negedge rst_b) begin
        if(!rst_b) begin
            data_out <= '0;
        end else begin
            if(!buffer_rw) begin
                case(bank_id)
                    3'b000: data_out <= buffers[0][colid];
                    3'b001: data_out <= buffers[1][colid];
                    3'b010: data_out <= buffers[2][colid];
                    3'b011: data_out <= buffers[3][colid];
                    3'b100: data_out <= buffers[4][colid];
                    3'b101: data_out <= buffers[5][colid];
                    3'b110: data_out <= buffers[6][colid];
                    3'b111: data_out <= buffers[7][colid];
                endcase
            end
        end
    end



endmodule
