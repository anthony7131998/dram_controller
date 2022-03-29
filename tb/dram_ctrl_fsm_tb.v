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
    reg cmd_ack = 1'b0;
    reg [$clog2(NUMBER_OF_BANKS)-1:0] bank_id = '0;
    reg [$clog2(NUMBER_OF_ROWS)-1:0] row_id = '0;
    reg [$clog2(NUMBER_OF_COLS)-1:0] col_id = '0;
    reg [9:0] offset = '0;

    reg count_en;
    reg row_inc;
    reg col_inc;
    reg [1:0] cmd;
    reg row_en;
    reg col_en;
    reg bank_en;
    reg address_buff_en;
    reg cmd_req;
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
            if(dut.present_state != dut.IDLE_STATE) begin
                $display("Error! should be in Idle State    ADDR_VAL %0b", addr_val);
                total_errors = total_errors + 1;
            end
        end

        #8 addr_val <= 1'b1;
        bank_id <= $urandom % 8;
        row_id <= $urandom % 128;
        col_id <= 0;
        offset <= $urandom % (128-row_id);
        #24;

        @(dut.access_count == offset);
        #320;

        #8 refresh_flag <= 1'b1;

        @(dut.present_state == dut.REFRESH_STATE);

        #8 refresh_flag <= 1'b0;

        @(address_buff_en);

        for(i=0; i<2000; i=i+1) begin
            #16;
        end

        disable generate_clk;
    end

    always @(posedge clk) begin : models_colid_incr
        if(col_inc) begin
            col_id <= col_id + 1;
        end

        if (col_id == 3'b111) begin
            col_id <= 3'b0;
        end
    end

    always @(posedge clk) begin : models_rowid_incr
        if(row_inc) begin
            row_id <= row_id + 1;
        end

        if (dut.access_count==0) begin
            row_id <= '0;
        end
    end

    always @(cmd_req) begin : models_handshake
        if(cmd_req) begin
            #8 cmd_ack <= 1'b1;
        end else begin
            #8 cmd_ack <= 1'b0;
        end
    end

endmodule