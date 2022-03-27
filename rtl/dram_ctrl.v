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
    parameter integer CONCAT_ADDRESS = 20;
) (
    input clk,
    input rst_b,
    input [DATA_WIDTH-1:0] dram_data_in,
    input [L2_REQ_WIDTH-1:0] l2_req_instr;

    output [1:0] cmd,
    output [$clog2(NUM_OF_BANKS)-1:0] bank_rw,
    output [$clog2(NUM_OF_BANKS)-1:0] buf_rw,

    output [NUM_OF_BANKS-1:0] bank_sel;
    output [NUM_OF_ROWS-1:0] row_sel;
    output [NUM_OF_COLS-1:0] col_sel;

);

// Internal Signal Declarations and Assignments

   

    reg [L2_REQ_WIDTH-1:0] l2_buffer_out;
    reg nc_full_l2_buffer;
    reg nc_empty_l2_buffer;

    reg nc_empty_addr_buffer;
    reg nc_full_addr_buffer;

    reg [$clog2(NUM_OF_BANKS)-1:0] bank_id;
    reg [$clog2(NUM_OF_ROWS)-1:0] row_id;
    reg [$clog2(NUM_OF_COLS)-1:0] col_id;

    reg [CONCAT_ADDRESS-1:0] address_trans_out;
    reg [CONCAT_ADDRESS-1:0] address_buff_out;



    reg [NUM_OF_ROWS-1:0] row_offset;

    reg address_en;
    reg row_en;
    reg col_en;
    reg bank_en;
    reg cnt_en;
    reg refresh_flag;

    reg row_inc;
    reg col_inc;
    
    reg [$clog2(NUM_OF_ROWS)-1:0] inc_row_id;
    reg [$clog2(NUM_OF_COLS)-1:0] inc_col_id;


    //output from address buffer:
    // assign offset = l2_req_address[ADDR_WIDTH-1:ADDR_WIDTH-7]
    // assign bank_id = l2_req_address[ADDR_WIDTH-8:ADDR_WIDTH-10];
    // assign row_id  = l2_req_address[ADDR_WIDTH-11:ADDR_WIDTH-17];
    // assign col_id  = l2_req_address[ADDR_WIDTH-18:ADDR_WIDTH-20];
    reg [$clog2(NUM_OF_ROWS)-1:0] address_buff_offset;
    reg [$clog2(NUM_OF_BANKS)-1:0] address_buff_bankid;
    reg [$clog2(NUM_OF_ROWS)-1:0] address_buff_rowid;
    reg [$clog2(NUM_OF_COLS)-1:0] address_buff_colid;

    //need to seperate sections of the address buffer
    assign address_trans_out = {bank_id, row_id, col_id, offset};

    assign address_buff_offset = address_trans_out[CONCAT_ADDRESS-1:CONCAT_ADDRESS-7];
    assign address_buff_bankid = address_trans_out[CONCAT_ADDRESS-8:CONCAT_ADDRESS-10];
    assign address_buff_rowid = address_trans_out[CONCAT_ADDRESS-11:CONCAT_ADDRESS-17]; //this is input to incrementer
    assign address_buff_colid = address_trans_out[CONCAT_ADDRESS-18:CONCAT_ADDRESS-20]; //this is input to incrementer




   

    assign address_buff_offset;



// Instantiations
    dram_buffer #(
        .width (8),
        .depth (1024)
    ) l2_req_buffer (
        .datain     (l2_req_instr),
        .clk        (clk),
        .rd_en      (1'b1),
        .wr_en      (1'b1),
        .rst        (rst_b),
        .dataout    (l2_buffer_out),
        .full_flag  (nc_full_l2_buffer),
        .empty_flag (nc_empty_l2_buffer)
    );

    dram_addr_translator #(
        .ADDR_WIDTH     (20),
        .NUM_OF_BANKS   (8),
        .NUM_OF_ROWS    (128),
        .NUM_OF_COLS    (8)
    ) address_translate (
        .l2_req_address (l2_buffer_out),
        .bank_id        (bank_id),
        .row_id         (row_id),
        .col_id         (col_id),
        .offset         (row_offset)
    );

    dram_buffer #(
        .width (20),
        .depth (1024)
    ) addr_buffer (
        .datain     (address_trans_out),
        .clk        (clk),
        .rd_en      (1'b1),
        .wr_en      (address_en),
        .rst        (rst_b),
        .dataout    (address_buff_out),
        .full_flag  (nc_full_addr_buffer),
        .empty_flag (nc_empty_addr_buffer)
    );

    dram_decoder3x8 bank_decoder(
        .en     (bank_en),
        .din    (address_buff_bankid),
        .dout   (bank_sel)
    );

    dram_decoder3x8 col_decoder(
        .en     (col_en),
        .din    (inc_col_id),  //need to make module to drive this
        .dout   (col_sel)
    );

    dram_row_decoder row_decoder (
        .en     (row_en),
        .din    (inc_row_id),  //need to make module to drive this
        .dout   (row_sel)
    );

    counter #(
        .width(36)
    ) refresh_flag (
        .clk            (clk),
        .rst            (rst),
        .en             (cnt_en),
        .refresh_flag   (refresh_flag)
    );


    dram_ctrl_fsm #(
        .NUMBER_OF_BANKS (8),
        .NUMBER_OF_ROWS (128),
        .NUMBER_OF_COLS (8)
    ) dram_fsm (
        .clk                (clk),
        .rst_b              (rst_b),
        .addr_val           (address_en),
        .refresh_flag       (refresh_flag),
        .bank_id            (address_buff_bankid),
        .row_id             (address_buff_rowid),
        .col_id             (address_buff_colid),
        .offset             (address_buff_offset),
        .count_en           (cnt_en),
        .row_inc            (row_inc), // still needs to be used for incrementer
        .col_inc            (col_inc), // still needs to be used for incrementer
        .cmd                (cmd),
        .row_en             (row_en),
        .col_en             (col_en),
        .bank_en            (bank_en),
        .address_buff_en    (address_en),
        .bank_rw            (bank_rw),
        .buf_rw             (buf_rw)
    );




endmodule