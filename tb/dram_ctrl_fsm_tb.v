// dram_ctrl_fsm_tb.v


module dram_ctrl_fsm_tb;

    localparam NUMBER_OF_BANKS = 8;
    localparam NUMBER_OF_ROWS = 128;
    localparam NUMBER_OF_COLS = 8;
    localparam NUMBER_OF_TESTS = 1000;

    integer total_errors=0;
    reg clk = 1'b0;
    reg rst_b = 1'b0;
    reg addr_val = 1'b0;
    reg refresh_flag = 1'b0;
    reg [$clog2(NUMBER_OF_BANKS)-1:0] bank_id = '0;
    reg [$clog2(NUMBER_OF_ROWS)-1:0] row_id = '0;
    reg [$clog2(NUMBER_OF_COLS)-1:0] col_id = '0;

    reg count_en;
    reg [1:0] cmd;
    reg row_en;
    reg col_en;
    reg bank_en;
    reg [$clog2(NUMBER_OF_BANKS)-1:0] bank_rw;
    reg [$clog2(NUMBER_OF_BANKS)-1:0] buf_rw;

    dram_ctrl_fsm #(
        .NUMBER_OF_BANKS (8),
        .NUMBER_OF_ROWS  (128),
        .NUMBER_OF_COLS  (8)
    ) dut (.*);


    initial begin : generate_clk
        while(1) #8 clk <= ~clk;
    end

    initial begin : drive_signals
        integer i;
        #10 rst_b <= 1'b0;
        #10 rst_b <= 1'b1;

        for(i=0; i<10; i=i+1) begin
            #8;
            if(dut.present_state != dut.idle_state) begin
                $display("Error! should be in Idle State    ADDR_VAL %0b", addr_val);
                total_errors = total_errors + 1;
            end
        end

        #8 addr_val <= 1'b1;
        #8 bank_id <= $urandom % 8;
        #8 row_id <= $urandom % 128;
        #8 col_id <= $urandom % 8;

        if(dut.present_state != dut.BnR_state) begin
            $display("Error! should be in BnR state  curr_state %0h", dut.present_state);
            total_errors = total_errors + 1;
        end

        #8;
        
        if(dut.present_state != dut.col_state) begin
            $display("Error! should be in Col state  curr_state %0h", dut.present_state);
            total_errors = total_errors + 1;
        end
        #8;

        for(i=0; i<NUMBER_OF_TESTS/2; i=i+1) begin
            addr_val <= 1'b1;
            bank_id <= $urandom % 8;
            row_id <= $urandom % 128;
            col_id <= $urandom % 8;
            #16;
        end

        for(i=0; i<NUMBER_OF_TESTS/2; i=i+1) begin
            addr_val <= 1'b1;
            col_id <= $urandom % 8;
            #8;
            if(dut.present_state != dut.col_state) begin
                $display("Error! should be in Col state  Time %0t  curr_state %0h", $time, dut.present_state);
                total_errors = total_errors + 1;
            end       
            #16;
        end

        disable generate_clk;

    end


endmodule