`timescale 100ps/10ps

module Input_Controller_tb;

    reg clk; // 40Mhz clock
    //input reset;
    //reg button_data;
    wire pulse;
    wire slow_clk_tb;
    wire latch_tb;
    //wire [18:0] slow_clk_counter_tb;

    Input_Controller uut (
        .clk(clk),                
        //.button_data(button_data),
        .latch_tb(latch_tb),
        .pulse(pulse),
        .slow_clk_tb(slow_clk_tb)
        //.slow_clk_counter_tb(slow_clk_counter_tb)
    );

    initial begin
        clk = 1'b0;
    end

    always @(*)
    begin
        #125 clk <= ~clk;
    end

endmodule