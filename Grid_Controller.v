// ============================
// This module is the FSM for Tetris. It receives button data
// from the input controller, determines the action that needs to 
// take place, then updates the tetris grid data.
// 
// Author: Jamison Bauer
// 
// ============================

module Grid_Controller (
		
		input clk,
		input reset,
		input [3:0] controller_in,
        input [7:0] tetris_grid_in,
        output reg [7:0] grid_address,
		output reg [7:0] tetris_grid_out,
		output reg write_en
);
	parameter [3:0] s_start = 4'b0000, s_reset = 4'b0001, s_address = 4'b0010, s_data = 4'b0011, s4 = 4'b0100, 
						  s5 = 4'b0101, s6 = 4'b0110, s7 = 4'b0111, s8 = 4'b1000, s9 = 4'b1001,
						  s10 = 4'b1010, s11 = 4'b1011, s12 = 4'b1100, s13 = 4'b1101;

	reg [3:0] state = s_start;

	// everyother clk we send address, everyother clk we read data
	always @(posedge clk)
	begin
		if (reset)
		begin
			write_en <= 1'b0;
			grid_data <= 8'd0;
			grid_address <= 8'd0;
			state <= s_reset;
		end
		else
		begin
			case(state) 
				s_start:
				begin
					// wait for user to press start. 
				end							
				s_reset: 
				begin
					if(reset)
						state <= s_reset;
					else
						state <= s_address;
				end
				s_address:
				begin

					grid_address <= grid_address + 1'b1;
					
					state <= s_data;
				end
				s_data:
				begin

					state <= s_address
				end
		end
	end





endmodule