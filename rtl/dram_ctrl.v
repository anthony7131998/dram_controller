// dram_ctrl.v

module dram_ctrl #(
    parameter int L2_REQ_WIDTH=13,
    parameter int DATA_WIDTH=1,
    parameter int NUMBER_OF_BANKS=8
) (
    input clk,
    input rst_b,
    input [DATA_WIDTH-1:0] dram_data_in,
    input [L2_REQ_WIDTH-1:0] l2_addr_req0,
    input [L2_REQ_WIDTH-1:0] l2_addr_req1,
    input [L2_REQ_WIDTH-1:0] l2_addr_req2,
    input [L2_REQ_WIDTH-1:0] l2_addr_req3,
    input [L2_REQ_WIDTH-1:0] l2_addr_req4,
    input [L2_REQ_WIDTH-1:0] l2_addr_req5,
    input [L2_REQ_WIDTH-1:0] l2_addr_req6,
    input [L2_REQ_WIDTH-1:0] l2_addr_req7,
    
    input [L2_REQ_WIDTH-1:0] l2_rw_req0,
    input [L2_REQ_WIDTH-1:0] l2_rw_req1,
    input [L2_REQ_WIDTH-1:0] l2_rw_req2,
    input [L2_REQ_WIDTH-1:0] l2_rw_req3,
    input [L2_REQ_WIDTH-1:0] l2_rw_req4,
    input [L2_REQ_WIDTH-1:0] l2_rw_req5,
    input [L2_REQ_WIDTH-1:0] l2_rw_req6,
    input [L2_REQ_WIDTH-1:0] l2_rw_req7,

    output [1:0] cmd,
    output [DATA_WIDTH-1:0] l2_rsp_data0,
    output [DATA_WIDTH-1:0] l2_rsp_data1,
    output [DATA_WIDTH-1:0] l2_rsp_data2,
    output [DATA_WIDTH-1:0] l2_rsp_data3,
    output [DATA_WIDTH-1:0] l2_rsp_data4,
    output [DATA_WIDTH-1:0] l2_rsp_data5,
    output [DATA_WIDTH-1:0] l2_rsp_data6,
    output [DATA_WIDTH-1:0] l2_rsp_data7,

    output [$clog2(NUMBER_OF_BANKS)-1:0] bank_rw,
    output [$clog2(NUMBER_OF_BANKS)-1:0] buf_rw,
    output [$clog2(NUMBER_OF_BANKS)-1:0] cs
);


// Internal Signal Declarations and Assignments

// 7 banks => 3 bits
// 128 rows => 7 bits
// 8 columns => 3 bits
// Total Address width => 13 bits


// Instantiations




endmodule