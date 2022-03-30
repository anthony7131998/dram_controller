// dram_ctrl.v

// L2_REQ_WIDTH= 13 bits for address, 9 bits for offset
// Total l2_req_width = 22

// L2_REQ : <address, offset>

module dram_ctrl #(
    parameter integer L2_REQ_WIDTH=20,
    parameter integer DATA_WIDTH=8,
    parameter integer NUM_OF_BANKS=8,
    parameter integer NUM_OF_ROWS=128,
    parameter integer NUM_OF_COLS=8,
    parameter integer CONCAT_ADDRESS = 20
) (
    input clk,
    input rst_b,
    input l2_rw_req,
    input cmd_ack,

    input [DATA_WIDTH-1:0] l2_req_data,
    input [L2_REQ_WIDTH-1:0] l2_req_instr,
    inout dram_data,

    output cmd_req,
    output [1:0] cmd,
    output [NUM_OF_BANKS-1:0] bank_sel,
    output [NUM_OF_ROWS-1:0] row_sel,
    output [NUM_OF_COLS-1:0] col_sel,
    output [DATA_WIDTH-1:0] l2_rsp_data,
    output bank_rw,
    output buf_rw
);

// Internal Signal Declarations and Assignments
    wire nc_full_l2_buffer;
    wire nc_empty_l2_buffer;
    wire nc_empty_data_buffer;
    wire nc_full_data_buffer;
    wire nc_empty_rsp_buffer;
    wire nc_full_rsp_buffer;
    wire [L2_REQ_WIDTH-1:0] l2_buffer_out;
    wire [$clog2(NUM_OF_BANKS)-1:0] bank_id;
    wire [$clog2(NUM_OF_ROWS)-1:0] row_id;
    wire [$clog2(NUM_OF_COLS)-1:0] col_id;
    wire [$clog2(NUM_OF_ROWS)-1:0] offset;
    wire [$clog2(NUM_OF_ROWS)-1:0] row_offset;
    wire [DATA_WIDTH-1:0] data_buffer_out;
    wire [DATA_WIDTH-1:0] sipo_data_out;
    wire tmp_dram_bit_data;

    wire addr_val;
    wire addr_buff_en;
    wire row_en;
    wire col_en;
    wire bank_en;
    wire cnt_en;
    wire refresh_flag;
    wire row_inc;
    wire col_inc;

    reg [CONCAT_ADDRESS-1:0] address_trans_out;
    reg [CONCAT_ADDRESS-1:0] address_buff_out;
    reg [$clog2(NUM_OF_ROWS)-1:0] inc_row_id;
    reg [$clog2(NUM_OF_COLS)-1:0] inc_col_id;
    reg [$clog2(NUM_OF_ROWS)-1:0] address_buff_offset;
    reg [$clog2(NUM_OF_BANKS)-1:0] address_buff_bankid;
    reg [$clog2(NUM_OF_ROWS)-1:0] address_buff_rowid;
    reg [$clog2(NUM_OF_COLS)-1:0] address_buff_colid;

    always @(*) begin
        address_trans_out = {row_offset, bank_id, row_id, col_id};
        address_buff_offset = address_trans_out[CONCAT_ADDRESS-1:CONCAT_ADDRESS-7];
        address_buff_bankid = address_trans_out[CONCAT_ADDRESS-8:CONCAT_ADDRESS-10];
        address_buff_rowid = address_trans_out[CONCAT_ADDRESS-11:CONCAT_ADDRESS-17]; //this is input to incrementer
        address_buff_colid = address_trans_out[CONCAT_ADDRESS-18:CONCAT_ADDRESS-20]; //this is input to incrementer
        inc_col_id = col_inc ? address_buff_colid + 1'b1 : address_buff_colid;
        inc_row_id = row_inc ? address_buff_rowid + 1'b1 : address_buff_rowid; //move this in counter blocks,
    end

    //ToDo:insert counter blocks here


    assign dram_data = l2_rw_req ? tmp_dram_bit_data : 'bz;

    // Instantiations
    dram_buffer #(
        .WIDTH (20),
        .DEPTH (NUM_OF_ROWS)
    ) l2_req_buffer (
        .datain     (l2_req_instr),
        .clk        (clk),
        .rd_en      (addr_buff_en),
        .wr_en      (1'b1),
        .rst_b      (rst_b),
        .dataout    (l2_buffer_out),
        .full_flag  (addr_val),
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

    dram_piso #(
        .WIDTH (8)
    ) dram_piso (
        .clk        (clk),
        .rst_b      (rst_b),
        .load       (addr_buff_en),
        .data_in    (l2_req_data), 
        .data_out   (tmp_dram_bit_data)
    );

    dram_sipo #(
	    .WIDTH (8)
    ) dram_sipo(
        .clk      (clk), 
        .rst_b    (rst_b),
        .data_in  (dram_data),
        .data_out (sipo_data_out)
	);

    dram_buffer #(
        .WIDTH (8),
        .DEPTH (NUM_OF_ROWS)
    ) l2_rsp_buffer (
        .datain     (sipo_data_out),
        .clk        (clk),
        .rd_en      (1'b1),
        .wr_en      (1'b1),
        .rst_b      (rst_b),
        .dataout    (l2_rsp_data),
        .full_flag  (nc_full_rsp_buffer),
        .empty_flag (nc_empty_rsp_buffer)
    );

    dram_decoder3x8 bank_decoder(
        .din    (address_buff_bankid),
        .dout   (bank_sel)
    );

    dram_decoder3x8 col_decoder(
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
        .rst_b          (rst_b),
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
        .addr_val           (addr_val),
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
        .address_buff_en    (addr_buff_en),
        .bank_rw            (bank_rw),
        .buf_rw             (buf_rw),
        .cmd_ack            (cmd_ack)
    );

endmodule