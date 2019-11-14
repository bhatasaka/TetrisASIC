module Input_Controller (

    input clk, // 50Mhz clock
    //input reset,
    input button_data_in,
    output latch_tb,
    output slow_clk_tb,
    output pulse_tb,
    output [3:0] button_data_out_tb

    //output reg slow_clk

);
    // 50Mhz clock to 60 hertz clock
    reg [18:0] slow_clk_counter = 19'd0;
    reg [18:0] latch_clk_counter = 19'd0;
    reg [18:0] pulse_clk_counter = 19'd0;
    reg button_lock = 1'b1;

    reg slow_clk = 1'b0;
    reg latch = 1'b0;
    reg pulse = 1'b0;
    reg [3:0] button_data_out = 4'b0;

    assign slow_clk_tb = slow_clk;
    assign latch_tb = latch;
    assign pulse_tb = pulse;
    assign button_data_out_tb = button_data_out;
    
    always@(posedge clk) // posedge every 20 ns
    begin
        slow_clk_counter <= slow_clk_counter + 19'd1;
        
        case (slow_clk_counter)
            19'd600: begin
                latch <= 1'b0;
            end
            19'd900: 
            begin
                if (button_data_in == 1'b0 && button_lock == 1'b0) // A button pressed = 1
                begin
                    button_data_out <= 4'b0001;
                    button_lock <= 1'b1;
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd1500:
            begin
                if (button_data_in == 1'b0 && button_lock == 1'b0) // B button pressed = 2
                begin
                    button_data_out <= 4'b0010;
                    button_lock <= 1'b1;
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd2100:
            begin
                if (button_data_in == 1'b0 && button_lock == 1'b0) // Select button pressed = 3
                begin
                    button_data_out <= 4'b0011;
                    button_lock <= 1'b1;
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd2700:
            begin
                if (button_data_in == 1'b0 && button_lock == 1'b0) // Start button pressed = 4
                begin
                    button_data_out <= 4'b0100;
                    button_lock <= 1'b1;
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd3300:
            begin
                if (button_data_in == 1'b0 && button_lock == 1'b0) // Up button pressed = 5
                begin
                    button_data_out <= 4'b0101;
                    button_lock <= 1'b1;
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd3900:
            begin
                if (button_data_in == 1'b0 && button_lock == 1'b0) // Down button pressed = 6
                begin
                    button_data_out <= 4'b0110;
                    button_lock <= 1'b1;
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd4500:
            begin
                if (button_data_in == 1'b0 && button_lock == 1'b0) // Left button pressed = 7
                begin
                    button_data_out <= 4'b0111;
                    button_lock <= 1'b1;
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd5100:
            begin
                if (button_data_in == 1'b0 && button_lock == 1'b0) // Right button pressed = 8
                begin
                    button_data_out <= 4'b1000;
                    button_lock <= 1'b1;
                end
                if (slow_clk == 1'b1) 
                begin
                    pulse <= 1'b1;
                end
            end
            19'd1200, 19'd1800, 19'd2400, 19'd3000, 19'd3600, 19'd4200, 19'd4800, 19'd5400: 
            begin
                pulse <= 1'b0;
            end
            19'd416667: // 60 Hz clock
            begin
                if (slow_clk == 1'b0) 
                begin
                    latch <= 1'b1;
                end
                slow_clk <= ~slow_clk;
                slow_clk_counter <= 19'd0;
                button_lock <= 1'b0;
            end
        endcase
    end
    
    always@(posedge slow_clk)
    begin
        button_data_out <= 1'd0;
    end
endmodule