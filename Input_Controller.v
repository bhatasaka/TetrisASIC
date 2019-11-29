// ============================
// This module implements the NES controller communication protocol.
// At a frequency of 60 Hz, a latch signal is set high for 12us, 
// followed by a 6us delay, followed by 8 12us 50% duty cycle pulses.
// The button data is received from the NES controller and sent to the
// Grid_Controller module to perform the appropriate actions.
// 
// Author: Jamison Bauer
// 
// ============================

module Input_Controller (

    input clk, // 50Mhz clock
    input reset,
    input button_data_in,
    output reg nes_reset,
    output reg [3:0] button_data_out

    // output latch_tb,
    // output slow_clk_tb,
    // output pulse_tb,
    // output [3:0] button_data_out_tb
    
);
    // 50Mhz clock to 60 hertz clock
    reg [18:0] slow_clk_counter = 19'd0;
    reg button_lock = 1'b1;

    reg slow_clk = 1'b0;
    reg latch = 1'b0;
    reg pulse = 1'b0;
    //reg [3:0] button_data_out = 4'b0;

    // assign slow_clk_tb = slow_clk;
    // assign latch_tb = latch;
    // assign pulse_tb = pulse;
    // assign button_data_out_tb = button_data_out;
    parameter [3:0] A_BUTTON = 4'b0001, B_BUTTON = 4'b0010, SELECT_BUTTON = 4'b0011, START_BUTTON = 4'b0100,
                    UP_BUTTON = 4'b0101, DOWN_BUTTON = 4'b0110, LEFT_BUTTON = 4'b0111, RIGHT_BUTTON = 4'b1000;
    
    always@(posedge clk) // posedge every 20 ns
    begin
        if (reset)
        begin
            slow_clk_counter <= 19'd0;
            button_lock <= 1'b1;
            nes_reset <= 1'b0;
            slow_clk <= 1'b0;
            latch <= 1'b0;
            pulse <= 1'b0;
            button_data_out <= 4'b0;
        end
        slow_clk_counter <= slow_clk_counter + 19'd1;
        
        case (slow_clk_counter)
            19'd600: // //negedge of latch
            begin
                latch <= 1'b0;
            end
            19'd900: //posedge of pulse1
            begin
                if (~button_data_in && ~button_lock) // A button pressed = 1
                begin
                    button_data_out <= A_BUTTON;
                    button_lock <= 1'b1;
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd1500: // posedge pulse2
            begin
                if (~button_data_in && ~button_lock) // B button pressed = 2
                begin
                    button_data_out <= B_BUTTON;
                    button_lock <= 1'b1;
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd2100: //posedge pulse3
            begin
                if (~button_data_in && ~button_lock) // Select button pressed = 3
                begin
                    button_data_out <= SELECT_BUTTON;
                    button_lock <= 1'b1;
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd2700: //posedge pulse4
            begin
                if (~button_data_in && ~button_lock) // Start button pressed = 4
                begin
                    button_data_out <= START_BUTTON;
                    button_lock <= 1'b1;
                    nes_reset <= 1'b1;
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd3300: //posedge pulse5
            begin
                if (~button_data_in && ~button_lock) // Up button pressed = 5
                begin
                    button_data_out <= UP_BUTTON;
                    button_lock <= 1'b1;
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd3900: //posedge pulse6
            begin
                if (~button_data_in && ~button_lock) // Down button pressed = 6
                begin
                    button_data_out <= DOWN_BUTTON;
                    button_lock <= 1'b1;
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd4500: //posedge pulse7
            begin
                if (~button_data_in && ~button_lock) // Left button pressed = 7
                begin
                    button_data_out <= LEFT_BUTTON;
                    button_lock <= 1'b1;
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd5100: //posedge pulse8
            begin
                if (~button_data_in && ~button_lock) // Right button pressed = 8
                begin
                    button_data_out <= RIGHT_BUTTON;
                    button_lock <= 1'b1;
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd1200, 19'd1800, 19'd2400, 19'd3000, 19'd3600, 19'd4200, 19'd4800, 19'd5400: //negedge of pusles 
            begin
                pulse <= 1'b0;
            end
            19'd416667: // 60 Hz clock
            begin
                if (~slow_clk) // if on rising edge of slow clock send latch signal
                begin
                    latch <= 1'b1;
                    button_data_out <= 1'd0; 
                end
                slow_clk <= ~slow_clk;
                slow_clk_counter <= 19'd0;
                button_lock <= 1'b0;
            end
        endcase
    end
endmodule