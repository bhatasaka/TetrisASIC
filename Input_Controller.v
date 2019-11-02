module Input_Controller (

    input clk, // 40Mhz clock
    input reset,

    input button_data,
    output latch,
    output pulse;
);
    // 40Mhz clock to 60 hertz clock
    reg clock_counter [18:0] = 19'd0;
    reg slow_clock = 1'b0;

    always@(clk)
    begin
        clock_counter <= clock_counter + 1'b1
        if(clock_counter == 19'd333333)
        begin
            slow_clock = ~slow_clock;
            clock_counter = 19'd0;
        end
    end



endmodule