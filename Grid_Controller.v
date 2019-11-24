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
	
	parameter [3:0] BTN_START = 4'b0100;
	parameter [24:0] SECOND_CLK_INTERVAL = 25'd25000000;

	reg [3:0] state = s_address;

	reg [24:0] tick_interval_counter;

	reg piece_ticker;

	//Registers for tracking 
	reg [7:0] piece_pos_blk_0, piece_pos_blk_1, piece_pos_blk_2, piece_pos_blk_3;

	//Clock divider so we can make teris pieces move down every second
	always @(posedge clk)
	begin
		if (reset)
		begin
			tick_interval_counter <= 25'b0;
			piece_ticker <= 1'b0;
		end
		else 
		begin
			if (tick_interval_counter == SECOND_CLK_INTERVAL)
			begin
				tick_interval_counter <= 25'b0;
				piece_ticker <= ~piece_ticker;
			end
			else
			begin
				tick_interval_counter <= tick_interval_counter + 1'b1;
			end
		end
	end

	// every other clk we send address, everyother clk we read data
	always @(posedge clk)
	begin
		if (reset)
		begin
			write_en <= 1'b0;
			grid_data <= 8'd0;
			grid_address <= 8'd0;
			state <= s_address;
		end
		else
		begin
			case(state)
				s_address:
				begin

					grid_address <= grid_address + 1'b1;
					
					state <= s_data;
				end
				s_data:
				begin

					state <= s_address
				end
				default:
				begin
					state <= s_address;
				end
		end
	end





endmodule