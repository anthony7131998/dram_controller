// dram_ctrl.v

// L2_REQ_WIDTH= 13 bits for address, 9 bits for offset
// Total l2_req_width = 22

// L2_REQ : <address, offset>

module dram_ctrl #(
    parameter integer L2_REQ_WIDTH=22,
    parameter integer DATA_WIDTH=1,
    parameter integer NUM_OF_BANKS=8,
    parameter integer NUM_OF_ROWS=128,
    parameter integer NUM_OF_COLS=8
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
    
    input l2_rw_req0,
    input l2_rw_req1,
    input l2_rw_req2,
    input l2_rw_req3,
    input l2_rw_req4,
    input l2_rw_req5,
    input l2_rw_req6,
    input l2_rw_req7,

    output [1:0] cmd,
    output [DATA_WIDTH-1:0] l2_rsp_data0,
    output [DATA_WIDTH-1:0] l2_rsp_data1,
    output [DATA_WIDTH-1:0] l2_rsp_data2,
    output [DATA_WIDTH-1:0] l2_rsp_data3,
    output [DATA_WIDTH-1:0] l2_rsp_data4,
    output [DATA_WIDTH-1:0] l2_rsp_data5,
    output [DATA_WIDTH-1:0] l2_rsp_data6,
    output [DATA_WIDTH-1:0] l2_rsp_data7,

    output [$clog2(NUM_OF_BANKS)-1:0] bank_rw,
    output [$clog2(NUM_OF_BANKS)-1:0] buf_rw,
    output [$clog2(NUM_OF_BANKS)-1:0] cs
);

// Internal Signal Declarations and Assignments

    reg refresh_flag;

    reg [L2_REQ_WIDTH-1:0] l2_addr_reqs [NUM_OF_BANKS];
    reg [L2_REQ_WIDTH-1:0] l2_rw_reqs [NUM_OF_BANKS];

    reg [$clog2(NUM_OF_BANKS)-1:0] l2_bank_id_reqs [NUM_OF_BANKS];
    reg [$clog2(NUM_OF_ROWS)-1:0] l2_row_id_reqs [NUM_OF_BANKS];
    reg [$clog2(NUM_OF_COLS)-1:0] l2_col_id_reqs [NUM_OF_BANKS];
    
    assign l2_addr_reqs = { l2_addr_req0, l2_addr_req1, l2_addr_req2, l2_addr_req3,
                            l2_addr_req4, l2_addr_req5, l2_addr_req6, l2_addr_req7};

    assign l2_rw_reqs = { l2_rw_req0, l2_rw_req1, l2_rw_req2, l2_rw_req3,
                            l2_rw_req4, l2_rw_req5, l2_rw_req6, l2_rw_req7};

// Instantiations
    genvar i;

    generate
        for (i=0; i<NUM_OF_BANKS; i=i+1) begin

            //ToDo: Instantiate L2 request buffers
            
            dram_addr_translator #(
                .ADDR_WIDTH     (L2_REQ_WIDTH),
                .NUM_OF_BANKS   (NUM_OF_BANKS),
                .NUM_OF_ROWS    (128),
                .NUM_OF_COLS    (8)
            ) addr_trans (
                .l2_req_address (l2_addr_reqs[i]),
                .bank_id        (l2_bank_id_reqs[i]),
                .row_id         (l2_row_id_reqs[i]),
                .col_id         (l2_col_id_reqs[i])
            );
        end
    endgenerate

    dram_decoder3x8 bank_decoder(
        .en     (),
        .din    (),
        .dout   ()
    );

    dram_decoder3x8 col_decoder(
        .en     (),
        .din    (),
        .dout   ()
    );

    dram_row_decoder row_decoder (
        .en     (),
        .din    (),
        .dout   ()
    );

    counter #(
        .width (36)
    ) refresh_counter (
        .clk            (clk),
        .rst            (rst_b),
        .en             (),
        .refresh_flag   (refresh_flag),
    );


endmodule