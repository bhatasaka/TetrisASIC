`timescale 10ns/1ns

module Input_Controller_tb;

    reg clk; // 50Mhz clock
    reg button_data_in;
    //input reset;
    //reg button_data;
    //wire pulse;
    wire slow_clk_tb;
    wire latch_tb;
    wire pulse_tb;
    //wire [18:0] slow_clk_counter_tb;
    wire [3:0] button_data_out_tb;
    reg [3:0] pulse_counter = 4'b0;

    Input_Controller uut (
        .clk(clk),                
        .button_data_in(button_data_in),
        .latch_tb(latch_tb),
        //.pulse(pulse),
        .slow_clk_tb(slow_clk_tb),
        .pulse_tb(pulse_tb),
        .button_data_out_tb(button_data_out_tb)
        //.slow_clk_counter_tb(slow_clk_counter_tb)
    );

    initial begin
        clk = 1'b0;
        button_data_in = 1'b1;
        #836300
        button_data_in = 1'b0;
        #1100
        button_data_in = 1'b1;

        // To send a button for only one slow clock cycle, use # and do it for the
        // exact amount of time needed. Method below acts as if holding down a button
    end

    always @(negedge slow_clk_tb) //keep button data high (no button pressed)
    begin
        button_data_in = 1'b1;
    end

    // // *** Set button_data_in <= 1'b0 for button you want to send ***

    // always @(posedge latch_tb)
    // begin
    //     button_data_in = 1'b1; // send A button (1)
    // end

    // always @(posedge pulse_tb)
    // begin
    //     pulse_counter <= pulse_counter + 1'b1;
    //     case (pulse_counter)  
    //         4'd0: 
    //         begin
    //             button_data_in <= 1'b1; //send B button (2)
    //         end
    //         4'd1: 
    //         begin
    //             button_data_in <= 1'b0; //send Select button (3)
    //         end
    //         4'd2: 
    //         begin
    //             button_data_in <= 1'b1; //send Start button (4)
    //         end
    //         4'd3: 
    //         begin
    //             button_data_in <= 1'b1; //send Up button (5)
    //         end
    //         4'd4: 
    //         begin
    //             button_data_in <= 1'b1; //send Down button (6)
    //         end
    //         4'd5: 
    //         begin
    //             button_data_in <= 1'b1; //send Left button (7)
    //         end
    //         4'd6: 
    //         begin
    //             button_data_in <= 1'b1; //send Right button (8)
    //         end
    //         4'd7: 
    //         begin
    //             button_data_in <= 1'b1; //reset data line to 1
    //             pulse_counter <= 4'd0;
    //         end 
    //         4'd8: 
    //         begin
    //             button_data_in <= 1'b1;
    //         end
    //     endcase
        
    // end


    always @(*)
    begin
        #1 clk <= ~clk;
    end

endmodule
