// dram_ctrl.v

// L2_REQ_WIDTH= 13 bits for address, 9 bits for offset
// Total l2_req_width = 22

// L2_REQ : <address, offset>

module dram_ctrl #(
    parameter integer L2_REQ_WIDTH=22,
    parameter integer INPUT_DATA_WIDTH=10,
    parameter integer OUTPUT_DATA_WIDTH=8,
    parameter integer NUM_OF_BANKS=8,
    parameter integer NUM_OF_ROWS=128,
    parameter integer NUM_OF_COLS=8,
    parameter integer CONCAT_ADDRESS = 20
) (
    input clk,
    input rst_b,
    input l2_rw_req,
    input cmd_ack,

    input [INPUT_DATA_WIDTH-1:0] l2_req_data,
    input [L2_REQ_WIDTH-1:0] l2_req_instr,
    inout [OUTPUT_DATA_WIDTH-1:0] dram_data,

    output cmd_req,
    output [1:0] cmd,
    output [NUM_OF_BANKS-1:0] bank_sel,
    output [NUM_OF_ROWS-1:0] row_sel,
    output [NUM_OF_COLS-1:0] col_sel,
    output [INPUT_DATA_WIDTH-1:0] l2_rsp_data,
    output [$clog2(NUM_OF_BANKS)-1:0] bank_rw,
    output [$clog2(NUM_OF_BANKS)-1:0] buf_rw
);

// Internal Signal Declarations and Assignments
    reg nc_full_l2_buffer;
    reg nc_empty_l2_buffer;
    reg nc_empty_data_buffer;
    reg nc_full_data_buffer;
    reg nc_empty_rsp_buffer;
    reg nc_full_rsp_buffer;

    reg [L2_REQ_WIDTH-1:0] l2_buffer_out;
    reg [CONCAT_ADDRESS-1:0] address_trans_out;
    reg [CONCAT_ADDRESS-1:0] address_buff_out;
    reg [INPUT_DATA_WIDTH-1:0] data_buffer_out;
    reg [OUTPUT_DATA_WIDTH-1:0] tmp_dram_data;
    reg [$clog2(NUM_OF_BANKS)-1:0] bank_id;
    reg [$clog2(NUM_OF_ROWS)-1:0] row_id;
    reg [$clog2(NUM_OF_COLS)-1:0] col_id;
    reg [$clog2(NUM_OF_ROWS)-1:0] offset;

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
    reg [$clog2(NUM_OF_ROWS)-1:0] address_buff_offset;
    reg [$clog2(NUM_OF_BANKS)-1:0] address_buff_bankid;
    reg [$clog2(NUM_OF_ROWS)-1:0] address_buff_rowid;
    reg [$clog2(NUM_OF_COLS)-1:0] address_buff_colid;

    always @(*) begin
        address_trans_out = {bank_id, row_id, col_id, offset};
        address_buff_offset = address_trans_out[CONCAT_ADDRESS-1:CONCAT_ADDRESS-7];
        address_buff_bankid = address_trans_out[CONCAT_ADDRESS-8:CONCAT_ADDRESS-10];
        address_buff_rowid = address_trans_out[CONCAT_ADDRESS-11:CONCAT_ADDRESS-17]; //this is input to incrementer
        address_buff_colid = address_trans_out[CONCAT_ADDRESS-18:CONCAT_ADDRESS-20]; //this is input to incrementer
        inc_col_id = col_inc ? address_buff_colid + 1'b1 : address_buff_colid;
        inc_row_id = row_inc ? address_buff_rowid + 1'b1 : address_buff_rowid;
    end

    assign dram_data = l2_rw_req ? tmp_dram_data : 'bz;

    // Instantiations
    dram_buffer #(
        .WIDTH (8),
        .DEPTH (1024)
    ) l2_req_buffer (
        .datain     (l2_req_instr),
        .clk        (clk),
        .rd_en      (address_buff_en),
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
        .WIDTH (14),
        .DEPTH (1024)
    ) data_buffer (
        .datain     (dram_data),
        .clk        (clk),
        .rd_en      (addr_buff_en),
        .wr_en      (1'b1),
        .rst        (rst_b),
        .dataout    (data_buffer_out),
        .full_flag  (nc_full_data_buffer),
        .empty_flag (nc_empty_data_buffer)
    );

    dram_piso #(
        .WIDTH (8)
    ) piso (
        .clk        (clk),
        .rst_b      (rst_b),
        .load       (addr_buff_en),
        .data_in    (data_buffer_out), 
        .data_out   (tmp_dram_data)
        );


    dram_buffer #(
        .WIDTH (14),
        .DEPTH (1024)
    ) l2_rsp_buffer (
        .datain     (dram_data),
        .clk        (clk),
        .rd_en      (1'b1),
        .wr_en      (1'b1),
        .rst        (rst_b),
        .dataout    (l2_rsp_data),
        .full_flag  (nc_full_rsp_buffer),
        .empty_flag (nc_empty_rsp_buffer)
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
        .width  (36)
    ) refresh_counter (
        .clk            (clk),
        .rst            (rst),
        .en             (cnt_en),
        .refresh_flag   (refresh_flag)
    );

    //ToDo: Connect ack/req
    dram_ctrl_fsm #(
        .NUMBER_OF_BANKS    (8),
        .NUMBER_OF_ROWS     (128),
        .NUMBER_OF_COLS     (8)
    ) dram_fsm (
        .clk                (clk),
        .rst_b              (rst_b),
        .addr_val           (address_en),
        .refresh_flag       (refresh_flag),
        .bank_id            (address_buff_bankid),
        .row_id             (address_buff_rowid),
        .col_id             (address_buff_colid),
        .offset             (address_buff_offset),
        .cmd_req            (cmd_req),
        .count_en           (cnt_en),
        .row_inc            (row_inc), // still needs to be used for incrementer
        .col_inc            (col_inc), // still needs to be used for incrementer
        .cmd                (cmd),
        .row_en             (row_en),
        .col_en             (col_en),
        .bank_en            (bank_en),
        .address_buff_en    (address_en),
        .bank_rw            (bank_rw),
        .buf_rw             (buf_rw),
        .cmd_ack            (cmd_ack)
    );

endmodule