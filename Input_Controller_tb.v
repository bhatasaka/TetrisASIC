module Input_Controller_tb;

    reg clk, // 40Mhz clock
    //input reset,
    //reg button_data,
    wire latch,
    wire pulse,
    wire slow_clk;

    Input_Controller uut (
        .clk(clk),                
        //.button_data(button_data),
        .latch(latch),
        .pulse(pulse),
        .slow_clk(slow_clk)
    );

    initial begin

        clk = 0;
        #100

    end

    always @(*)
    begin
        #1 clk <= ~clk;
    end

endmodule