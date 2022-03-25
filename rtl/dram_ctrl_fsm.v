// dram_ctrl_fsm.v

module dram_ctrl_fsm #(
    parameter integer NUMBER_OF_BANKS=8,
    parameter integer NUMBER_OF_ROWS=128,
    parameter integer NUMBER_OF_COLS=8
) (
    input clk,
    input offset,
    input rst_b,
    input addr_val,
    input refresh_flag,
    input cmd_ack,
    input [$clog2(NUMBER_OF_BANKS)-1:0] bank_id,
    input [$clog2(NUMBER_OF_ROWS)-1:0] row_id,
    input [$clog2(NUMBER_OF_COLS)-1:0] col_id,

    output reg count_en,
    output reg row_inc,
    output reg col_inc,
    output reg [1:0] cmd,
    output reg row_en,
    output reg col_en,
    output reg bank_en,
    output reg address_buff_en,
    output reg cmd_req
    output reg [$clog2(NUMBER_OF_BANKS)-1:0] bank_rw,
    output reg [$clog2(NUMBER_OF_BANKS)-1:0] buf_rw
);

    // State Declarations
    localparam idle_state = 3'b000;
    localparam BnR_state = 3'b001;
    localparam col_state = 3'b010;
    localparam precharge_state = 3'b011;
    localparam refresh_state = 3'b100;

    reg [2:0] present_state, next_state, prev_state;
    reg [$clog2(NUMBER_OF_BANKS)-1:0]  prev_bank_id;
    reg [$clog2(NUMBER_OF_ROWS)-1:0]  prev_row_id;
    reg [3:0] col_counter, access_count, next_col_counter, next_access_count;

    wire cond1;

    assign cond1 = (prev_row_id != row_id) || (prev_bank_id != bank_id);

    always @(posedge clk, posedge rst_b) 
    begin 
        if (!rst_b) begin
            present_state <= BnR_state;
            col_counter <= '0;
            access_count <= '0;
        end
        else begin
            present_state <= next_state;
            prev_bank_id <= bank_id;
            prev_row_id <= row_id;
            col_counter <= next_col_counter;
            access_count <= next_access_count;
        end
    end

    always @ (*)
    begin
        
        count_en = 1'b1;
        buf_rw = 0;
        bank_rw = 0;
        count_en = 1'b0;
        cmd = 2'b10;
        bank_rw = '0;
        buf_rw = '0; 

        row_en = 1'b0;
        col_en = 1'b0;
        bank_en = 1'b0;

        prev_state = present_state;

        case(present_state)

            BnR_state:
            begin
                cmd_req = 1'b1;
                if (cmd_ack == 1'b1) 
                begin
                    cmd_req = 1'b0;
                    if (refresh_flag == 1'b1) 
                    begin
                        next_state = refresh_state;
                        prev_state = BnR_state;
                    end
                    else begin
                        if (access_count == offset)
                        begin
                            access_count = '0;
                            address_buffer_enable = 1'b1;
                        end
                        cmd = 2'b00;
                        buf_rw = 1'b1;
                        bank_en = 1'b1;
                        row_en = 1'b1;
                        next_state = col_state;
                    end
                end
                else begin
                    next_state = BnR_state;
                end
                
            end

            col_state:
                cmd_req = 1'b1;
                if (cmd_ack == 1'b1) 
                begin
                    cmd_req = 1'b0;
                    if (refresh_flag == 1'b1) 
                    begin
                        next_state = refresh_state;
                        prev_state = col_state;
                    end
                    else begin

                        if (col_counter == 3'b111)  //checking col count to make sure we havent read the row
                        begin
                            row_inc = 1'b1;
                            next_col_counter = '0;
                            next_access_count = next_access_count + 1'b1;
                        end
                        else begin
                            col_inc = 1'b1;
                            next_col_counter = next_col_counter + 1'b1;
                        end

                        cmd = 2'b01;
                        col_en = 1'b1;
                        if (cond1)
                        begin
                            next_state = precharge_state;
                        end else begin
                            next_state = col_state;
                        end
                    end
                end
                else begin
                    next_state = col_state;
                end
            end

            precharge_state:
                cmd_req = 1'b1;
                if (cmd_ack == 1'b1) 
                begin
                    cmd_req = 1'b0;
                    if (refresh_flag == 1'b1) 
                    begin
                        next_state = refresh_state;
                        prev_state = precharge_state;
                    end
                    else begin
                        cmd = 2'b11;
                        bank_rw = 1;
                        next_state = BnR_state;
                    end
                end
                else
                else begin
                    next_state = precharge_state;
                end
            end

            refresh_state:
                cmd_req = 1'b1;
                if (cmd_ack == 1'b1) 
                begin
                    cmd_req = 1'b0;
                    cmd = 2'b10;
                    count_en = 0'b0;
                    next_state = prev_state;
                end
                else begin
                    next_state = refresh_state;
                end
        endcase
    end

endmodule

