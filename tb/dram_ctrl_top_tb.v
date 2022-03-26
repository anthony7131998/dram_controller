`timescale 1ns/100ps

module dram_ctrl_top_tb;

    localparam L2_REQ_WIDTH=13,
    localparam DATA_WIDTH=1,
    localparam NUMBER_OF_BANKS = 8;
    localparam NUMBER_OF_ROWS = 128;
    localparam NUMBER_OF_COLS = 8;
    localparam NUMBER_OF_TESTS = 1000;

    integer total_errors=0;

    reg clk,
    reg rst_b,
    reg [DATA_WIDTH-1:0] dram_data_in,
    reg [L2_REQ_WIDTH-1:0] l2_addr_req0,
    reg [L2_REQ_WIDTH-1:0] l2_addr_req1,
    reg [L2_REQ_WIDTH-1:0] l2_addr_req2,
    reg [L2_REQ_WIDTH-1:0] l2_addr_req3,
    reg [L2_REQ_WIDTH-1:0] l2_addr_req4,
    reg [L2_REQ_WIDTH-1:0] l2_addr_req5,
    reg [L2_REQ_WIDTH-1:0] l2_addr_req6,
    reg [L2_REQ_WIDTH-1:0] l2_addr_req7,
    
    reg [L2_REQ_WIDTH-1:0] l2_rw_req0,
    reg [L2_REQ_WIDTH-1:0] l2_rw_req1,
    reg [L2_REQ_WIDTH-1:0] l2_rw_req2,
    reg [L2_REQ_WIDTH-1:0] l2_rw_req3,
    reg [L2_REQ_WIDTH-1:0] l2_rw_req4,
    reg [L2_REQ_WIDTH-1:0] l2_rw_req5,
    reg [L2_REQ_WIDTH-1:0] l2_rw_req6,
    reg [L2_REQ_WIDTH-1:0] l2_rw_req7,

    reg [1:0] cmd,
    reg [DATA_WIDTH-1:0] l2_rsp_data0,
    reg [DATA_WIDTH-1:0] l2_rsp_data1,
    reg [DATA_WIDTH-1:0] l2_rsp_data2,
    reg [DATA_WIDTH-1:0] l2_rsp_data3,
    reg [DATA_WIDTH-1:0] l2_rsp_data4,
    reg [DATA_WIDTH-1:0] l2_rsp_data5,
    reg [DATA_WIDTH-1:0] l2_rsp_data6,
    reg [DATA_WIDTH-1:0] l2_rsp_data7,

    reg [$clog2(NUM_OF_BANKS)-1:0] bank_rw,
    reg [$clog2(NUM_OF_BANKS)-1:0] buf_rw,
    reg [$clog2(NUM_OF_BANKS)-1:0] cs

    dram_ctrl #(
        .NUMBER_OF_BANKS (8),
        .NUMBER_OF_ROWS  (128),
        .NUMBER_OF_COLS  (8),
        .L2_REQ_WIDTH    (13),
        .DATA_WIDTH      (1)
    ) dut (.*);


     initial begin : generate_clk
        while(1) #5 clk <= ~clk;
    end

    initial begin : drive_signals
        integer i;
        #10 rst_b <= 1'b0;
        #10 rst_b <= 1'b1;