module dram_sipo_tb;

    localparam WIDTH = 8;
    
    reg clk = 1'b0;
    reg rst_b = 1'b0;
    reg data_in;
    reg [WIDTH-1:0] data_out;


    dram_sipo #(
        .WIDTH (8)
    ) dut (.*);

    initial begin : generate_clk
        while(1) #5 clk <= ~clk;
    end


    initial begin : drive
        integer i;
        #10 rst_b <= 1'b0;
        #10 rst_b <= 1'b1;
        for(i=0; i<100; i=i+1) begin
            data_in <= $urandom;
            @(posedge clk);
        end
        disable generate_clk;
    end

endmodule