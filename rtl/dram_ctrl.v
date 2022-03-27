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
        .ADDR_WIDTH     (13),
        .NUM_OF_BANKS   (8),
        .NUM_OF_ROWS    (128),
        .NUM_OF_COLS    (8)
    ) address_translate (
        .l2_req_address (),
        .bank_id        (),
        .row_id         (),
        .col_id         ()
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

    counter #(
        .width(36)
    ) refresh_flag (
        .clk            (),
        .rst            (),
        .en             (),
        .refresh_flag   ()
    );


    dram_ctrl_fsm #(
        .NUMBER_OF_BANKS (8),
        .NUMBER_OF_ROWS (128),
        .NUMBER_OF_COLS (8)
    ) dram_fsm (
        .clk                (),
        .rst_b              (),
        .addr_val           (),
        .refresh_flag       (),
        .bank_id            (),
        .row_id             (),
        .col_id             (),
        .offset             (),
        .count_en           (),
        .row_inc            (),
        .col_inc            (),
        .cmd                (),
        .row_en             (),
        .col_en             (),
        .bank_en            (),
        .address_buff_en    (),
        .bank_rw            (),
        .buf_rw             ()
    );




endmodule