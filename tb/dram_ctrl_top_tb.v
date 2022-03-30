`timescale 1ns/100ps

module dram_ctrl_top_tb;

    integer total_errors = 0;
    localparam integer NUM_OF_TESTS = 128;
    localparam integer L2_REQ_WIDTH=20;
    localparam integer DATA_WIDTH=8;
    localparam integer NUM_OF_BANKS=8;
    localparam integer NUM_OF_ROWS=128;
    localparam integer NUM_OF_COLS=8;
    localparam integer CONCAT_ADDRESS = 20;

    reg clk = 1'b0;
    reg rst_b = '0;
    reg l2_rw_req = '0;
    reg cmd_ack = '0;

    reg [DATA_WIDTH-1:0] l2_req_data = '0;
    reg [L2_REQ_WIDTH-1:0] l2_req_instr = '0;

    //bidir
    wire dram_data;

    reg cmd_req;
    reg [1:0] cmd;
    reg [NUM_OF_BANKS-1:0] bank_sel;
    reg [NUM_OF_ROWS-1:0] row_sel;
    reg [NUM_OF_COLS-1:0] col_sel;
    reg [DATA_WIDTH-1:0] l2_rsp_data;
    reg bank_rw;
    reg buf_rw;

    // assign dram_data = (buf_rw) ? data_reg : 1'bz;

    dram_ctrl #(
        .L2_REQ_WIDTH       (20),
        .DATA_WIDTH         (8),
        .NUM_OF_BANKS       (8),
        .NUM_OF_ROWS        (128),
        .NUM_OF_COLS        (8),
        .CONCAT_ADDRESS     (20)
    ) dut (.*);

    dram_bfm #(
        .NUM_OF_BANKS (8),
        .NUM_OF_ROWS (128),
        .NUM_OF_COLS (8),
        .DATA_WIDTH (1)
    ) bfm (
        .clk        (clk),
        .rst_b      (rst_b),
        .bank_rw    (bank_rw),
        .bank_id    (dut.bank_id), //the sels will be encoded back to bank ids for the sake of dram bfm
        .rowid      (dut.row_id),
        .colid      (dut.col_id),
        .buffer_rw  (buf_rw),
        .data       (dram_data)
    );

    initial begin : generate_clk
        while(1) #5 clk <= ~clk;
    end

    initial begin : drive_signals
        integer i;
        integer j;
        #10 rst_b <= 1'b0;
        #10 rst_b <= 1'b1;

        #10 l2_rw_req <= 1'b1; // write to DRAM
        l2_req_instr[L2_REQ_WIDTH-8:L2_REQ_WIDTH-10] <= $urandom; //bankid
        l2_req_instr[L2_REQ_WIDTH-11:L2_REQ_WIDTH-17] <= $urandom; //rowid
        l2_req_instr[L2_REQ_WIDTH-1:L2_REQ_WIDTH-7] <= $urandom - l2_req_instr[L2_REQ_WIDTH-11:L2_REQ_WIDTH-17]; // offset
        #10;

        // Send write instruction and data

        // Fills up buffer
        for(i=0; i<128; i=i+1) begin
            #5 l2_req_instr <= l2_req_instr + 1'b1;
        end

        // Completes all commands in buffer
        for(i=0; i<128*8; i=i+1) begin
            #5 l2_req_data <= $urandom;
            @(dut.dram_fsm.access_count == 0);
        end

        // ToDo: Read deassert
        #10 l2_rw_req <= 1'b0; // read from DRAM
        for(i=0; i<128; i=i+1) begin
            #5 l2_req_instr <= l2_req_instr - 1'b1;
            #5;
        end

        // waits for refresh
        @(dut.refresh_flag);

        #100;

        disable generate_clk;
    end

    initial begin : monitor_buffers
        $monitor("[$monitor] time=%0t rd_en=%0h, wr_en=%0h, addr_buffer_in=%0h, addr_buffer_out=%0h", 
                    $time, dut.l2_req_buffer.rd_en, dut.l2_req_buffer.wr_en, dut.l2_req_instr, dut.l2_buffer_out);
    end

    // initial begin : monitor_FSM
    //     @(dut.dram_fsm.present_state)
    //     $monitor("[$monitor] time=%0t present_state=%0b next_state=%0b", $time, dut.dram_fsm.present_state, dut.dram_fsm.next_state);
    // end

    initial begin : address_translator
        @(dut.address_translate.l2_req_address)
         $monitor("[$monitor] time=%0t l2_req_address=%0h bankid=%0d rowid=%0d colid=%0d offset=%0d", $time, dut.address_translate.l2_req_address, 
                    dut.address_translate.bank_id, dut.address_translate.row_id, dut.address_translate.col_id, dut.address_translate.offset);
    end

    initial begin : monitor_bfm
        @(bfm.data)
            $monitor("[$monitor] time=%0t bank_rw=%d bank_id=%d rowid=%d colid=%d buffer_rw=%0b, data= %0h", $time, bfm.bank_rw,
                    bfm.bank_id, bfm.rowid, bfm.colid, bfm.buffer_rw, bfm.data);
    end

    always @(cmd_req) begin : models_handshake
        if(cmd_req) begin
            #8 cmd_ack <= 1'b1;
        end else begin
            #8 cmd_ack <= 1'b0;
        end
    end

endmodule