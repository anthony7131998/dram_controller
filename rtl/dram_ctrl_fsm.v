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
    output reg load_data,
    output reg bank_en,
    output reg address_buff_en,
    output reg read_data_en
);

    // State Declarations
    localparam IDLE_STATE = 3'b000;
    localparam BNR_STATE = 3'b001;
    localparam COL_STATE = 3'b010;
    localparam PRECHARGE_STATE = 3'b011;
    localparam REFRESH_STATE = 3'b100;
    localparam WAIT_ACK = 3'b101;

    reg [2:0] present_state, next_state, prev_state;
    reg [$clog2(NUMBER_OF_BANKS)-1:0]  prev_bank_id;
    reg [$clog2(NUMBER_OF_ROWS)-1:0]  prev_row_id;
    reg [3:0] col_counter, next_col_counter;
    reg [9:0] access_count, next_access_count;
    reg [1:0] read_count, next_read_count;

    always @(posedge clk, posedge rst_b) 
    begin 
        if (!rst_b) begin
            present_state <= IDLE_STATE;
            col_counter <= '0;
            read_count <= 2'b10;
            access_count <= offset;
        end
        else begin
            present_state <= next_state;
            prev_bank_id <= bank_id;
            prev_row_id <= row_id;
            col_counter <= next_col_counter;
            access_count <= next_access_count;
            read_count <= next_read_count;
        end
    end

    always @ (*) begin

        count_en = 1'b1;
        cmd = 2'b00;
        row_en = 1'b0;
        col_en = 1'b0;
        bank_en = 1'b0;
        row_inc = 1'b0;
        col_inc = 1'b0;
        load_data = 1'b0;
        address_buff_en = 1'b0;

        next_state = present_state;
        next_access_count = access_count;
        next_col_counter = col_counter;

        case(present_state)
            IDLE_STATE: begin
                next_state = IDLE_STATE;
                if(addr_val) begin
                    next_state = BNR_STATE;
                    address_buff_en = 1'b1;
                end
            end

            BNR_STATE: begin
                if(refresh_flag) begin
                    next_state = REFRESH_STATE;
                end else if(!cmd_ack) begin
                    load_data = 1'b1;
                    if (access_count == 0) begin
                        next_access_count = offset;
                        address_buff_en = 1'b1;
                    end
                    cmd = 2'b00;
                    next_state = WAIT_ACK;
                end
                read_data_en = '0;
            end

            COL_STATE: begin
                if(refresh_flag) begin
                    next_state = REFRESH_STATE;
                end else if (!cmd_ack) begin
                    cmd = 2'b01;
                    if (col_counter == 3'b111)  begin
                        row_inc = 1'b1;
                        next_col_counter = '0;
                        next_state = WAIT_ACK;
                        col_en = 1;
                    end else begin
                        col_inc = 1'b1;
                        next_col_counter = next_col_counter + 1'b1;
                    end
                end
            end

            PRECHARGE_STATE: begin
                if(refresh_flag) begin
                    next_state = REFRESH_STATE;
                end else if(!cmd_ack) begin
                    if (access_count == 0) begin
                        next_access_count = offset;
                        address_buff_en = 1'b1;
                        row_en = 1;
                    end else begin
                        cmd = 2'b11;
                        next_access_count = access_count - 1'b1;
                        next_state = WAIT_ACK;
                    end
                    read_data_en = '1;
                end

            end

            WAIT_ACK: begin
                if(refresh_flag) begin
                    next_state = REFRESH_STATE;
                end else if (cmd_ack) begin
                    case(prev_state)
                        BNR_STATE: next_state = COL_STATE;
                        COL_STATE: next_state = PRECHARGE_STATE;
                        PRECHARGE_STATE: next_state = BNR_STATE;
                    endcase
                end
                read_data_en = '0;
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
        // prev_state = present_state;
        if(refresh_flag || next_state==WAIT_ACK) begin
            case(present_state)
                BNR_STATE: prev_state = BNR_STATE;
                COL_STATE: prev_state = COL_STATE;
                PRECHARGE_STATE: prev_state = PRECHARGE_STATE;
                // WAIT_ACK: prev_state = WAIT_ACK;
            endcase
        end
    end

    always @(posedge clk or negedge rst_b) begin
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

