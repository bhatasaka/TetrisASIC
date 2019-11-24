// ============================
// This module is the FSM for Tetris. It receives button data
// from the input controller, determines the action that needs to 
// take place, then updates the tetris grid data.
// 
// Author: Jamison Bauer, Sean Eastland, Brian Hatasaka
// 
// ============================

module Grid_Controller (
		
		input clk,
		input reset,
		input [3:0] controller_in,
        input [7:0] tetris_grid_in,
        output reg [7:0] grid_address,
		output reg [7:0] grid_data_out,
		output reg write_en
);
	parameter [3:0] s_place = 4'b0000, s_data = 4'b0001, s_move = 4'b0010, s_3 = 4'b0011, s4 = 4'b0100, 
						  s5 = 4'b0101, s6 = 4'b0110, s7 = 4'b0111, s8 = 4'b1000, s9 = 4'b1001,
						  s10 = 4'b1010, s11 = 4'b1011, s12 = 4'b1100, s13 = 4'b1101;
	
	parameter [3:0] BTN_START = 4'b0100;
	parameter [24:0] SECOND_CLK_INTERVAL = 26'd50000000;

	// Piece Placer Wires
	wire piece_placed, piece_we;
	wire[7:0] piece_addr, piece_grid_out;

	reg piece_ticker, piece_placer_enable, this_we;
	reg mem_out_ctl;
	reg [3:0] state = s_place;
	reg [7:0] this_addr, this_grid_out;


	//Registers for tracking 
	reg [7:0] piece_pos_blk_0, piece_pos_blk_1, piece_pos_blk_2, piece_pos_blk_3;
	reg [24:0] tick_interval_counter;


	Piece_Placer piece_placer(
		.en(piece_placer_enable),
		.clk(clk),
		.rst(reset),
		
		.placed(piece_placed),
		.we(piece_we),
		.addr(piece_addr),
		.data(),
		.reg_1_addr(),
		.reg_2_addr(),
		.reg_3_addr(),
		.reg_4_addr()	
	);


	// every other clk we send address, everyother clk we read data
	always @(posedge clk)
	begin
		if (reset)
		begin
			grid_data <= 8'd0;
			grid_address <= 8'd0;
			state <= s_place;
			tick_interval_counter <= 25'b0;
			piece_ticker <= 1'b0;
		end
		else
		begin
			if (tick_interval_counter == SECOND_CLK_INTERVAL)
			begin
				tick_interval_counter <= 26'b0;
				state <= s_move;
			end
			else
			begin
				tick_interval_counter <= tick_interval_counter + 1'b1;
			end

			case(state)
				s_place:
				begin
					if()
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

	always @(state, reset)
	begin
		if(reset)
		begin
			mem_out_ctl = 1'b0;
			piece_placer_enable = 1'b0;
		end
		else
		begin
			case (state)
				s_place:
				begin
					piece_placer_enable = 1'b1;
				end
			endcase
		end
	end

	// Multiplexor to choose the write enable signal going to memory
	always @ (mem_out_ctl, this_we, this_addr, this_grid_out, piece_we, piece_addr, piece_grid_out)
	begin
		if(mem_out_ctl)
		begin
			write_en = this_we;
			grid_address = this_addr;
			grid_data_out = this_grid_out;
		end
		else
		begin
			write_en = piece_we;
			grid_address = piece_addr;
			grid_data_out = piece_grid_out;
		end
	end
endmodule