`timescale 1ns/100ps

module dram_ctrl_top_tb;

    localparam integer L2_REQ_WIDTH=22;
    localparam integer DATA_WIDTH=1;
    localparam integer NUM_OF_BANKS=8;
    localparam integer NUM_OF_ROWS=128;
    localparam integer NUM_OF_COLS=8;
    localparam integer CONCAT_ADDRESS = 20;

    reg clk;
    reg rst_b;
    reg [DATA_WIDTH-1:0] dram_data_in;
    reg [L2_REQ_WIDTH-1:0] l2_req_instr;
    reg [1:0] cmd;
    reg [$clog2(NUM_OF_BANKS)-1:0] bank_rw;
    reg [$clog2(NUM_OF_BANKS)-1:0] buf_rw;
    reg [NUM_OF_BANKS-1:0] bank_sel;
    reg [NUM_OF_ROWS-1:0] row_sel;
    reg [NUM_OF_COLS-1:0] col_sel;

    dram_ctrl #(
        .L2_REQ_WIDTH (22),
        .DATA_WIDTH (8),
        .NUM_OF_BANKS (8),
        .NUM_OF_ROWS (128),
        .NUM_OF_COLS (8),
        .CONCAT_ADDRESS (20)
    ) dut (.*);

    initial begin : generate_clk
        while(1) #5 clk <= ~clk;
    end

    initial begin : drive_signals
        integer i;
        #10 rst_b <= 1'b0;
        #10 rst_b <= 1'b1;
    end
endmodule