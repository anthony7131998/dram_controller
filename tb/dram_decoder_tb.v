
`timescale 1ns/100ps

module dram_decoder_tb;

    localparam NUMBER_OF_TESTS = 8192;
    localparam ADDR_WIDTH = 13;
    localparam NUM_OF_BANKS = 8;
    localparam NUM_OF_ROWS = 128;
    localparam NUM_OF_COLS = 8;

    reg [ADDR_WIDTH-1:0] l2_req_address;
    reg [$clog2(NUM_OF_BANKS)-1:0] bank_id;
    reg [$clog2(NUM_OF_ROWS)-1:0] row_id;
    reg [$clog2(NUM_OF_COLS)-1:0] col_id;

    reg [$clog2(NUM_OF_BANKS)-1:0] correct_bank_id;
    reg [$clog2(NUM_OF_ROWS)-1:0] correct_row_id;
    reg [$clog2(NUM_OF_COLS)-1:0] correct_col_id;

    integer total_errors=0;

    dram_decoder #(
        .ADDR_WIDTH   (13),
        .NUM_OF_BANKS (8),
        .NUM_OF_ROWS  (128),
        .NUM_OF_COLS  (8)
    ) dut (.*);

    initial begin : drive_signals
        integer i;
        for(i=0; i<NUMBER_OF_TESTS; i=i+1) begin
            #10 l2_req_address <= i;
        end
        $display("Finished Simulation. Total Errors %0d", total_errors);
    end

    initial begin : check_signals
        integer i;
        for(i=0; i<NUMBER_OF_TESTS; i=i+1) begin
            correct_bank_id = i[12:10];
            correct_row_id = i[9:3];
            correct_col_id = i[2:0];

            if(correct_bank_id != bank_id) begin
                $display("Error (%0t) Incorrect BankID....... BankID %0h Correct %0h", $time, bank_id, correct_bank_id);
                total_errors = total_errors + 1;
            end

            if(correct_row_id != row_id) begin
                $display("Error (%0t) Incorrect RowID....... RowID %0h Correct %0h", $time, row_id, correct_row_id);
                total_errors = total_errors + 1;
            end

            if(correct_col_id != col_id) begin
                $display("Error (%0t) Incorrect ColID....... ColID %0h Correct %0h", $time, col_id, correct_col_id);
                total_errors = total_errors + 1;
            end
        end
    end

endmodule