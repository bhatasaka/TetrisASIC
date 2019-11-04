module Input_Controller (

    input clk, // 40Mhz clock
    //input reset,
    //input button_data,
    output reg latch,
    output reg pulse,

    output reg slow_clk;
);
    // 40Mhz clock to 60 hertz clock
    reg slow_clk_counter [18:0] = 19'd0;
    reg latch_clk_counter [18:0] = 19'd0;
    reg pulse_clk_counter [18:0] = 19'd0;
    slow_clk = 1'b0;
    reg pulse_active = 1'b0;
    latch = 1'b0;
    pulse = 1'b0;

    always@(posedge clk) // posedge every 25 ns
    begin
        slow_clk_counter <= slow_clk_counter + 1'b1;
        latch_clk_counter <= latch_clk_counter + 1'b1;
        pulse_clk_counter <= pulse_clk_counter + 1'b1;
        if(slow_clk_counter == 19'd333333) //25ns *666666 = 16.7ms then divide by 2 for when to flip from low to high, high to low. 
        begin
            slow_clk <= ~slow_clk;
            slow_clk_counter <= 19'd0;
        end
    end

    // always@(posedge slow_clk) // posedge every 16.7ms      *do if(slow_clk == 1) in first always block if this creates an error*
    // begin
    //     latch <= 1'b1;                  //posedge of latch pulse
    //     latch_clk_counter <= 19'd0                                //put this at end of always block? 
    //     if(latch_clk_counter == 19'd480) //25ns * 480 = 12us 
    //     begin
    //         latch <= 1'b0;              //negedge of latch pulse after 12us
    //     end
    //     if (latch_clk_counter == 19'd720) // send the pulse after 18us
    //     begin
    //         pulse_clk_counter <= 19'd0 
    //         if (pulse_active == 1) 
    //         begin
    //             pulse <= ~pulse;     // HERE MAKE PULSE SIGNAL
    //         end
    //         else
    //         begin
    //             pulse <= 1'b0;
    //         end
    //     end
    // end



endmodule