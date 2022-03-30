// dram_addr_decoder.v

// Changed mapping from bit-addressable to byte-addressable


module dram_addr_translator #(
    parameter integer ADDR_WIDTH=20,
    parameter integer NUM_OF_BANKS=8,
    parameter integer NUM_OF_ROWS=128,
    parameter integer NUM_OF_COLS=8
) (
    input [ADDR_WIDTH-1:0] l2_req_address,
    output [$clog2(NUM_OF_BANKS)-1:0] bank_id,
    output [$clog2(NUM_OF_ROWS)-1:0] row_id,
    output [$clog2(NUM_OF_COLS)-1:0] col_id,
    output [$clog2(NUM_OF_ROWS)-1:0] offset
);

    // Bank0: 0-7f      (0000 0000 0000 - 0000 0111 1111)
    // Bank1: 80-ff     (0000 1000 0000 - 0000 1111 1111)
    // Bank2: 100 - 17f (0001 0000 0000 - 0001 0111 1111)
    // Bank3: 180 - 1ff (0001 1000 0000 - 0001 1111 1111)
    // Bank4: 200 - 27f (0010 0000 0000 - 0010 0111 1111)
    // Bank5: 280 - 2ff (0010 1000 0000 - 0010 1111 1111)
    // Bank6: 300 - 37f (0011 0000 0000 - 0011 0111 1111)
    // Bank7: 380 - 3ff (0011 1000 0000 - 0011 1111 1111)

    // Overall DRAM Address Range: 0-3ff
    assign offset = l2_req_address[ADDR_WIDTH-1:ADDR_WIDTH-7];
    assign bank_id = l2_req_address[ADDR_WIDTH-8:ADDR_WIDTH-10];
    assign row_id  = l2_req_address[ADDR_WIDTH-11:ADDR_WIDTH-17];
    assign col_id  = 0; // Controller will adjust col_id by increments


endmodule
