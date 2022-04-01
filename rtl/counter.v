// counter.v

module counter #(
    parameter width=36
) ( input clk,
    input rst_b,
    input en,
    output reg refresh_flag
);

	reg [width-1:0] count;

    always @ (posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            count <= '0;
            refresh_flag <= 1'b0;

        end else begin
            if (en) begin
                count <= count+1;
                refresh_flag <= 1'b0;
            end
            if(count == 12500000) begin
                refresh_flag <= 1'b1;    //assuming clock freq of 150MHz, time period of 7ns, 125 ms = 17857142 cycles
                count <= '0;
            end
        end
    end


endmodule