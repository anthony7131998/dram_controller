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

    output [1:0] cmd,

    output [$clog2(NUM_OF_BANKS)-1:0] bank_rw,
    output [$clog2(NUM_OF_BANKS)-1:0] buf_rw,
    output [$clog2(NUM_OF_BANKS)-1:0] cs
);

// Internal Signal Declarations and Assignments


// Instantiations
    dram_buffer #(
        .width (8),
        .depth (1024)
    ) l2_req_buffer (
        .datain     (),
        .clk        (clk),
        .rd_en      (),
        .wr_en      (),
        .rst        (rst_b),
        .dataout    (),
        .full_flag  (),
        .empty_flag ()
    );

dram_addr_translator #(
    parameter integer ADDR_WIDTH=13,
    parameter integer NUM_OF_BANKS=8,
    parameter integer NUM_OF_ROWS=128,
    parameter integer NUM_OF_COLS=8
) (
    input [ADDR_WIDTH-1:0] l2_req_address,
    output [$clog2(NUM_OF_BANKS)-1:0] bank_id,
    output [$clog2(NUM_OF_ROWS)-1:0] row_id,
    output [$clog2(NUM_OF_COLS)-1:0] col_id
);


    dram_buffer #(
        .width (8),
        .depth (1024)
    ) addr_buffer (
        .datain     (),
        .clk        (clk),
        .rd_en      (),
        .wr_en      (),
        .rst        (rst_b),
        .dataout    (),
        .full_flag  (),
        .empty_flag ()
    );

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




endmodule