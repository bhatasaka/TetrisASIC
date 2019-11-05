module Input_Controller (

    input clk, // 40Mhz clock
    //input reset,
    //input button_data,
    output latch_tb,
    output slow_clk_tb,
    output reg pulse

    //output reg slow_clk

);
    // 40Mhz clock to 60 hertz clock
    reg [18:0] slow_clk_counter = 19'd0;
    reg [18:0] latch_clk_counter = 19'd0;
    //reg [18:0] pulse_clk_counter = 19'd0;
    reg slow_clk = 1'b0;
    //reg pulse_active = 1'b0;
    reg latch = 1'b0;
    //pulse = 1'b0;
    assign slow_clk_tb = slow_clk;
    assign latch_tb = latch;
    
    always@(posedge clk) // posedge every 25 ns
    begin
        slow_clk_counter <= slow_clk_counter + 19'd1;
        //latch_clk_counter <= latch_clk_counter + 1'b1;
        //pulse_clk_counter <= pulse_clk_counter + 1'b1;
        if(slow_clk_counter == 19'd333333) //25ns *666666 = 16.7ms then divide by 2 for when to flip from low to high, high to low. 
        begin
            if (slow_clk == 1'b0) begin
                latch <= 1'b1;
            end
            //latch_clk_counter <= 19'd0;
            slow_clk <= ~slow_clk;
            slow_clk_counter <= 19'd0;
        end
        if (slow_clk_counter == 19'd480) 
        begin
            latch <= 1'b0;    
        end
    end



        // MAKE A 6us BASED CLOCK FOR PULSE and LATCH?


    // always@(negedge slow_clk) // posedge every 16.7ms      *do if(slow_clk == 1) in first always block if this creates an error*
    // begin
          
    //     latch <= 1'b0;                  //posedge of latch pulse
                                      //put this at end of always block? 
        // if(latch_clk_counter == 19'd480) //25ns * 480 = 12us 
        // begin
        //     latch <= 1'b0;              //negedge of latch pulse after 12us
        // end
        // if (latch_clk_counter == 19'd720) // send the pulse after 18us
        // begin
        //     pulse_clk_counter <= 19'd0 
        //     if (pulse_active == 1) 
        //     begin
        //         pulse <= ~pulse;     // HERE MAKE PULSE SIGNAL
        //     end
        //     else
        //     begin
        //         pulse <= 1'b0;
        //     end
        // end
    //end
endmodule