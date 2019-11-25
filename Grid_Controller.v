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
	parameter [3:0] s_place = 4'b0000, s_move_0 = 4'b0001, s_move_1 = 4'b0010, s_move_2 = 4'b0011, s_move_3 = 4'b0100, 
						  s_move_4 = 4'b0101, s_move_5 = 4'b0110, s_move_6 = 4'b0111, s8 = 4'b1000, s9 = 4'b1001,
						  s10 = 4'b1010, s11 = 4'b1011, s12 = 4'b1100, s13 = 4'b1101, s_input = 4'b1110;

	parameter [3:0] BTN_START 	= 4'b0100;
	parameter [7:0] BLOCK_AIR 	= 4'b0000,
					BLOCK_I 	= 4'b0001,
					BLOCK_O 	= 4'b0010,
					BLOCK_T 	= 4'b0011,
					BLOCK_S 	= 4'b0100,
					BLOCK_Z 	= 4'b0101,
					BLOCK_J 	= 4'b0110,
					BLOCK_L 	= 4'b0111,
				BLOCK_BORDER 	= 4'b1000;

	parameter [24:0] SECOND_CLK_INTERVAL = 26'd50000000;
	parameter THIS_MEM_OUT, PIECE_MEM_OUT;

	// Piece Placer Wires
	wire piece_placed, piece_we;
	wire[7:0] piece_addr, piece_grid_out;

	reg piece_placer_enable, this_we, blocks_will_collide;
	reg mem_out_ctl;
	reg [1:0] piece_pos_idx;
	reg [3:0] state = s_place;
	reg [7:0] this_addr, this_grid_out;

	//Array of four 8-bit Registers for tracking
	reg [7:0] piece_pos[3:0];
	reg [7:0] piece_next_pos[3:0];
	reg [7:0] active_block_data;
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
			this_grid_out <= 8'd0;
			grid_address <= 8'd0;
			state <= s_place;
			tick_interval_counter <= 25'b0;
			piece_pos_idx <= 2'b0;
		end
		else
		begin
			if (tick_interval_counter == SECOND_CLK_INTERVAL)
			begin
				tick_interval_counter <= 26'b0;
				state <= s_move_0;
			end
			else
			begin
				tick_interval_counter <= tick_interval_counter + 1'b1;
			end

			case(state)
				s_place:
				begin
					if(piece_placed == 1'b1)
					begin
						state <= s_move_0;
						piece_pos_idx <= 2'b0;
					end
					else
						state <= s_place;
				end
				s_move_0:
				begin
					state <= s_move_1;
				end
				s_move_1:
				begin
					// Go back and forth between states move_0 and move_1 4 times
					if(piece_pos_idx == 2'd3)
					begin
						if(blocks_will_collide)
							state <= s_place; // TODO: Maybe should go to clear line state and check for end of game also
						else
							state <= s_move_2;

						piece_pos_idx <= 2'b0;
					end
					else
					begin
						state <= s_move_0;
						piece_pos_idx <= piece_pos_idx + 2'b1;
					end
				end
				s_move_2: // Active block address
				begin
					state <= s_move_3;
				end
				s_move_3: // Set active block
				begin
					state <= s_move_4;
				end
				s_move_4: // Clear old grid_mem
				begin
					state <= s_move_5;
				end
				s_move_5: // Set new grid_mem
				begin
					if(piece_pos_idx == 2'd3)
					begin
						state <= s_move_6;
						piece_pos_idx = 2'b0;
					end
					else
					begin
						state <= s_move_4;
						piece_pos_idx = piece_pos_idx + 2'b1;
					end
				end
				s_move_6:
				begin
					state <= s_place; // TODO: Maybe should go to clear line state
				end
				default:
				begin
					state <= s_input;
				end
			endcase
		end
	end

	always @(state, reset)
	begin
		if(reset)
		begin
			mem_out_ctl = 1'b0;
			piece_placer_enable = 1'b0;
			blocks_will_collide = 1'b0;
		end
		else
		begin
			case (state)
				s_place:
				begin
					mem_out_ctl = PIECE_MEM_OUT;
					piece_placer_enable = 1'b1;
					blocks_will_collide = 1'b0;
				end
				s_move_0: // Find the next address that we need to read from
				begin
					mem_out_ctl = THIS_MEM_OUT;
					piece_placer_enable = 1'b0;
					if(piece_pos[piece_pos_idx] > 231) // Check if the block is in the starting area
					begin
						if(piece_pos[piece_pos_idx] == 8'd241)
							this_addr = 8'd4;
						else if(piece_pos[piece_pos_idx] == 8'd242)
							this_addr = 8'd5;
						else if(piece_pos[piece_pos_idx] == 8'd243)
							this_addr = 8'd6;
						else
						begin
							this_addr = piece_pos[piece_pos_idx] + 3;
						end

						// Blocking assignments so we can do this I think
						piece_next_pos[piece_pos_idx] = this_addr;
					end
					else
					begin
						this_addr = piece_pos[piece_pos_idx] + 12;
					end
				end

				s_move_1: // Read the next block position to see if it's available
				begin
					// Check if the block below isn't air and isn't active, the the block will collide
					if(tetris_grid_in[3:0] != BLOCK_AIR && tetris_grid_in[7] != 1'b1)  
						blocks_will_collide = 1'b1;
					else
						blocks_will_collide = blocks_will_collide;
				end

				s_move_2: // Set the address to get the block data of the active block
				begin
					this_addr = piece_pos[piece_pos_idx];
				end

				s_move_3: // Set the active block data and write enable
				begin
					active_block_data = tetris_grid_in;
					this_we = 1'b1;
				end
				s_move_4:
				begin // Set the data of the previous block to 0
					this_grid_out = 8'b0; 
					this_addr = piece_pos[piece_pos_idx];
				end
				s_move_5:
				begin // Set the data of the next block to the active block
					this_grid_out = active_block_data;
					this_addr = piece_next_pos[piece_pos_idx];
				end
				s_move_6:
				begin // After 
					this_we = 1'b0;
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
		else // Choose piece_placer to output to memory
		begin
			write_en = piece_we;
			grid_address = piece_addr;
			grid_data_out = piece_grid_out;
		end
	end
endmodule