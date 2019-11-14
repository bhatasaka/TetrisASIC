`timescale 100ps/100ps

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
    end

    always @(posedge latch_tb)
    begin
        button_data_in = 1'b1; // send A button
    end
    always @(negedge slow_clk_tb)
    begin
        button_data_in = 1'b1;
    end
    always @(posedge pulse_tb)
    begin
        pulse_counter <= pulse_counter + 1'b1;
        case (pulse_counter)
            4'd0: 
            begin
                //button_data_in <= 1'b0; //send B button
            end
            4'd1: 
            begin
                //button_data_in <= 1'b0; //send Select button
            end
            4'd2: 
            begin
                //button_data_in <= 1'b0; //send Start button
            end
            4'd3: 
            begin
                //button_data_in <= 1'b0; //send Up button
            end
            4'd4: 
            begin
                //button_data_in <= 1'b0; //send Down button
            end
            4'd5: 
            begin
                //button_data_in <= 1'b0; //send Left button
            end
            4'd6: 
            begin
                //button_data_in <= 1'b0; //send Right button
            end
            4'd7: 
            begin
                button_data_in <= 1'b1; //reset data line to 1
                pulse_counter <= 4'd0;
            end 
            4'd8: 
            begin

            end
        endcase
        button_data_in <= 1'b1;
    end


    always @(*)
    begin
        #100 clk <= ~clk;
    end

endmodule
