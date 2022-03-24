// dram_decoder.v


module dram_decoder #(
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

    // Bank0: 0-3ff     (0 0000 0000 0000 - 0 0011 1111 1111) 
    // Bank1: 400-7ff   (0 0100 0000 0000 - 0 0111 1111 1111)
    // Bank2: 800-Bff   (0 1000 0000 0000 - 0 1011 1111 1111)
    // Bank3: C00-fff   (0 1100 0000 0000 - 0 1111 1111 1111)
    // Bank4: 1000-13ff (1 0000 0000 0000 - 1 0011 1111 1111)
    // Bank5: 1400-17ff (1 0100 0000 0000 - 1 0111 1111 1111)
    // Bank6: 1800-1bff (1 1000 0000 0000 - 1 1000 0000 0000)
    // Bank7: 1c00-1fff (1 1100 0000 0000 - 1 1111 1111 1111)


    // Overall DRAM Address Range: 0-1fff
    assign bank_id = l2_req_address[ADDR_WIDTH-1:ADDR_WIDTH-3];
    assign row_id  = l2_req_address[ADDR_WIDTH-4:ADDR_WIDTH-10];
    assign col_id  = l2_req_address[2:0];

endmodule