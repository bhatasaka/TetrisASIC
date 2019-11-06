module Input_Controller (

    input clk, // 40Mhz clock
    //input reset,
    input button_data_in,
    output latch_tb,
    output slow_clk_tb,
    output pulse_tb,
    output reg [3:0] button_data_out

    //output reg slow_clk

);
    // 40Mhz clock to 60 hertz clock
    reg [18:0] slow_clk_counter = 19'd0;
    reg [18:0] latch_clk_counter = 19'd0;
    reg [18:0] pulse_clk_counter = 19'd0;
    reg slow_clk = 1'b0;
    //reg pulse_active = 1'b0;
    reg latch = 1'b0;
    reg pulse = 1'b0;
    assign slow_clk_tb = slow_clk;
    assign latch_tb = latch;
    assign pulse_tb = pulse;
    
    always@(posedge clk) // posedge every 25 ns
    begin
        slow_clk_counter <= slow_clk_counter + 19'd1;
        case (slow_clk_counter)
            19'd480: begin
                latch <= 1'b0;
            end
            19'd720: 
            begin
                if (button_data_in == 1'b0) // A button pressed
                begin
                    
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd1200:
            begin
                if (button_data_in == 1'b0) // B button pressed
                begin
                    
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd1680:
            begin
                if (button_data_in == 1'b0) // Select button pressed
                begin
                    
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd2160:
            begin
                if (button_data_in == 1'b0) // Start button pressed
                begin
                    
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd2640:
            begin
                if (button_data_in == 1'b0) // Up button pressed
                begin
                    
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd3120:
            begin
                if (button_data_in == 1'b0) // Down button pressed
                begin
                    
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd3600:
            begin
                if (button_data_in == 1'b0) // Left button pressed
                begin
                    
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd4080:
            begin
                if (button_data_in == 1'b0) // Right button pressed
                begin
                    
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd960, 19'd1440, 19'd1920, 19'd2400, 19'd2880, 19'd3360, 19'd3840, 19'd4320: 
            begin
                pulse <= 1'b0;
            end
            19'd333333: // 60 Hz clock
            begin
                if (slow_clk == 1'b0) 
                begin
                    latch <= 1'b1;
                end
                slow_clk <= ~slow_clk;
                slow_clk_counter <= 19'd0;
            end
        endcase
    end
endmodule