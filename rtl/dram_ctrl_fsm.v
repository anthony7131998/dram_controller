// dram_ctrl_fsm.v

module dram_ctrl_fsm #(
    parameter integer NUMBER_OF_BANKS=8,
    parameter integer NUMBER_OF_ROWS=128,
    parameter integer NUMBER_OF_COLS=8
) (
    input clk,
    input rst_b,
    input addr_val,
    input refresh_flag,
    input cmd_ack,
    input [$clog2(NUMBER_OF_BANKS)-1:0] bank_id,
    input [$clog2(NUMBER_OF_ROWS)-1:0] row_id,
    input [$clog2(NUMBER_OF_COLS)-1:0] col_id,
    input [$clog2(NUMBER_OF_ROWS)-1:0] offset,

    output reg count_en,
    output reg row_inc,
    output reg col_inc,
    output reg cmd_req,
    output reg [1:0] cmd,
    output reg row_en,
    output reg col_en,
    output reg bank_en,
    output reg address_buff_en,
    output reg bank_rw,
    output reg buf_rw
);

    // State Declarations
    localparam IDLE_STATE = 3'b000;
    localparam BNR_STATE = 3'b001;
    localparam COL_STATE = 3'b010;
    localparam PRECHARGE_STATE = 3'b011;
    localparam REFRESH_STATE = 3'b100;

    reg [2:0] present_state, next_state, prev_state;
    reg [$clog2(NUMBER_OF_BANKS)-1:0]  prev_bank_id;
    reg [$clog2(NUMBER_OF_ROWS)-1:0]  prev_row_id;
    reg [3:0] col_counter, next_col_counter;
    reg [9:0] access_count, next_access_count;

    always @(posedge clk, posedge rst_b) 
    begin 
        if (!rst_b) begin
            present_state <= IDLE_STATE;
            col_counter <= '0;
            access_count <= offset;
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
        cmd = 2'b00;
        bank_rw = '0;
        buf_rw = '0; 
        row_en = 1'b0;
        col_en = 1'b0;
        bank_en = 1'b0;
        row_inc = 1'b0;
        col_inc = 1'b0;
        address_buff_en = 1'b0;

        next_state = present_state;
        next_access_count = access_count;
        next_col_counter = col_counter;

        case(present_state)
            IDLE_STATE: begin
                next_state = IDLE_STATE;
                if(addr_val) begin
                    next_state = BNR_STATE;
                end
            end

            BNR_STATE: begin
                if (access_count == 0) begin
                    next_access_count = offset;
                    address_buff_en = 1'b1;
                end else begin
                    next_access_count = access_count - 1'b1;
                    cmd = 2'b00;
                    buf_rw = 1'b1;
                    bank_en = 1'b1;
                    row_en = 1'b1;
                    row_inc = 1'b1;
                end

                if(refresh_flag) begin
                    next_state = REFRESH_STATE;
                end else if(cmd_ack) begin
                    next_state = COL_STATE;
                end

            end

            COL_STATE: begin
                if (col_counter == 3'b111)  //checking col count to make sure we havent read the row
                begin
                    row_inc = 1'b1;
                    next_col_counter = '0;
                    if(refresh_flag) begin
                        next_state = REFRESH_STATE;
                    end else if (cmd_ack) begin
                        next_state = PRECHARGE_STATE;
                    end
                end
                else begin
                    col_inc = 1'b1;
                    next_col_counter = next_col_counter + 1'b1;
                end
            end

            PRECHARGE_STATE: begin
                if(refresh_flag) begin
                    next_state = REFRESH_STATE;
                end else if(cmd_ack) begin
                    next_state = BNR_STATE;
                end

                cmd = 2'b11;
                bank_rw = 1;
            end

            REFRESH_STATE: begin
                cmd = 2'b10;
                count_en = 1'b0;
                if(cmd_ack) begin
                    next_state = prev_state;
                end
            end

        endcase
    end

    always @(*) begin
        if(refresh_flag) begin
            case(present_state)
                BNR_STATE: begin
                    prev_state = BNR_STATE;
                end
                COL_STATE: begin
                    prev_state = COL_STATE;
                end
                PRECHARGE_STATE: begin
                    prev_state = PRECHARGE_STATE;
                end
            endcase
        end
    end

    always @(posedge clk or posedge rst_b) begin
        if(!rst_b) begin
            cmd_req <= 1'b0;
        end else if(present_state != IDLE_STATE) begin
            if(cmd_ack) begin
                cmd_req <= 1'b0;
            end else begin
                cmd_req <= 1'b1;
            end
        end
    end



endmodule

