// dram_ctrl_fsm.v

module dram_ctrl_fsm #(
    parameter int NUM_OF_BANKS=8,
    parameter int NUMBER_OF_ROWS=128,
    parameter int NUMBER_OF_COLS=8
) (
    input clk,
    input rst_b,
    input refresh_flag,
    input [$clog2(NUM_OF_BANKS)-1:0] bank_id,
    input [$clog2(NUMBER_OF_ROWS)-1:0] row_id,
    input [$clog2(NUMBER_OF_COLS)-1:0] col_id,

    output count_en,
    output [1:0] cmd,
    output [$clog2(NUM_OF_BANKS)-1:0] bank_rw,
    output [$clog2(NUM_OF_BANKS)-1:0] buf_rw
);

    // Signal Declarations



endmodule

