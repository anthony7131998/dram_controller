`timescale 1ns/100ps

module dram_ctrl_top_tb;

    localparam integer L2_REQ_WIDTH=22;
    localparam integer DATA_WIDTH=8;
    localparam integer NUM_OF_BANKS=8;
    localparam integer NUM_OF_ROWS=128;
    localparam integer NUM_OF_COLS=8;
    localparam integer CONCAT_ADDRESS = 20;

    reg clk;
    reg rst_b;
    reg l2_rw_req;
    reg cmd_ack;

    reg [DATA_WIDTH-1:0] l2_req_data;
    reg [L2_REQ_WIDTH-1:0] l2_req_instr;
    wire dram_data;

    reg cmd_req;
    reg [1:0] cmd;
    reg [NUM_OF_BANKS-1:0] bank_sel;
    reg [NUM_OF_ROWS-1:0] row_sel;
    reg [NUM_OF_COLS-1:0] col_sel;
    reg [DATA_WIDTH-1:0] l2_rsp_data;
    reg bank_rw;
    reg buf_rw;

    dram_ctrl #(
        .L2_REQ_WIDTH       (22),
        .DATA_WIDTH         (8),
        .NUM_OF_BANKS       (8),
        .NUM_OF_ROWS        (128),
        .NUM_OF_COLS        (8),
        .CONCAT_ADDRESS     (20)
    ) dut (.*);

    dram_bfm #(
        .NUM_OF_BANKS (8),
        .NUM_OF_ROWS (128),
        .NUM_OF_COLS (8),
        .DATA_WIDTH (1)
    ) bfm (
        .clk        (clk),
        .rst_b      (rst_b),
        .din        (dram_data),
        .bank_rw    (bank_rw),
        .bank_id    (dut.bank_id), //the sels will be encoded back to bank ids for the sake of dram bfm
        .rowid      (dut.row_id),
        .colid      (dut.col_id),
        .buffer_rw  (buf_rw),
        .dout       (dram_data)
    );

    initial begin : generate_clk
        while(1) #5 clk <= ~clk;
    end

    initial begin : drive_signals
        integer i;
        #10 rst_b <= 1'b0;
        #10 rst_b <= 1'b1;
        
    end
endmodule