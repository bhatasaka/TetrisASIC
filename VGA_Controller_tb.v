`timescale 100ps/100ps

module VGA_Controller_tb;

    reg clk; // 50Mhz clock
		reg  [7:0] rgb_8;
		wire [7:0] r_out;
		wire [7:0] g_out;
		wire [7:0] b_out;
		wire h_sync;
		wire v_sync;
		wire pixel_en;

    parameter FULL_CLK = 20;
    parameter HALF_CLK = 10;

		VGA_Controller uut(.clk(clk), .rgb_8(rgb_8), .r_out(r_out), .g_out(g_out), .b_out(b_out), .h_sync(h_sync), .v_sync(v_sync), .pixel_en(pixel_en));

    initial 
    begin
        clk = 1'b0;
				rgb_8 = 8'b0;
				
				$display("Testing RGB Conversion");

				#1;
				
				$display("RED EXPECTED: %d\tACTUAL: %d", 8'b0, r_out);
				$display("GREEN EXPECTED: %d\tACTUAL: %d", 8'b0, g_out);
				$display("BLUE EXPECTED: %d\tACTUAL: %d", 8'b0, b_out);

				rgb_8 = 8'b11111111;
				
				#1;

				$display("RED EXPECTED: %d\tACTUAL: %d", 8'b11100000, r_out);
				$display("GREEN EXPECTED: %d\tACTUAL: %d", 8'b11100000, g_out);
				$display("BLUE EXPECTED: %d\tACTUAL: %d", 8'b11000000, b_out);

				rgb_8 = 8'b10101010;

				#1;
				
				$display("RED EXPECTED: %d\tACTUAL: %d", 8'b10100000, r_out);
				$display("GREEN EXPECTED: %d\tACTUAL: %d", 8'b01000000, g_out);
				$display("BLUE EXPECTED: %d\tACTUAL: %d", 8'b10000000, b_out);

				rgb_8 = 8'b01010101;
				
				#1;

				$display("RED EXPECTED: %d\tACTUAL: %d", 8'b01000000, r_out);
				$display("GREEN EXPECTED: %d\tACTUAL: %d", 8'b10100000, g_out);
				$display("BLUE EXPECTED: %d\tACTUAL: %d", 8'b01000000, b_out);
    end

    always @(*)
    begin
        #HALF_CLK
        clk <= ~clk;
    end
endmodule
