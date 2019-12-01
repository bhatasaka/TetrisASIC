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
	parameter [3:0] s_place_0 	= 4'd0,
					s_place_1 	= 4'd1,
					s_move_0 	= 4'd2, 
					s_move_1 	= 4'd3, 
					s_move_2 	= 4'd4, 
					s_move_3 	= 4'd5, 
					s_move_4 	= 4'd6, 
					s_move_5 	= 4'd7, 
					s_move_6 	= 4'd8, 
					s_move_7	= 4'd9, 
					s_move_8	= 4'd10,
					s_input 	= 4'd11, 
					s11 		= 4'd12, 
					s12 		= 4'd13, 
					s13 		= 4'd14, 
					s_14	 	= 4'd15;

	parameter [3:0] BTN_START 	= 4'b0100,
					BTN_LEFT	= 4'b0000,
					BTN_RIGHT	= 4'b0000;

	parameter [7:0] BLOCK_AIR 	= 4'b0000,
					BLOCK_I 	= 4'b0001,
					BLOCK_O 	= 4'b0010,
					BLOCK_T 	= 4'b0011,
					BLOCK_S 	= 4'b0100,
					BLOCK_Z 	= 4'b0101,
					BLOCK_J 	= 4'b0110,
					BLOCK_L 	= 4'b0111,
				BLOCK_BORDER 	= 4'b1000;

	// parameter [24:0] SECOND_CLK_INTERVAL = 26'd50000000;
	parameter [24:0] SECOND_CLK_INTERVAL = 26'd200;
	parameter 	THIS_MEM_OUT = 1'b0, 
				PIECE_MEM_OUT = 1'b1;

	// Piece Placer Wires
	wire piece_placed, piece_we;
	wire [7:0] reg_1_addr, reg_2_addr, reg_3_addr, reg_4_addr;
	wire [7:0] piece_addr, piece_grid_out;

	reg piece_placer_enable, this_we, piece_will_collide;
	reg mem_out_ctl, has_moved, need_to_move;
	reg [1:0] piece_pos_idx;
	reg [3:0] state = s_place_0;
	reg [7:0] this_addr, this_grid_out;

	//Array of four 8-bit Registers for tracking poisition
	reg [7:0] piece_pos[3:0];
	reg [7:0] piece_next_pos[3:0];
	reg [7:0] active_block_data;
	reg [24:0] tick_interval_counter;

	integer i;

	Piece_Placer piece_placer(
		.en(piece_placer_enable),
		.clk(clk),
		.rst(reset),
		
		.placed(piece_placed),
		.we(piece_we),
		.addr(piece_addr),
		.data(piece_grid_out),
		.reg_1_addr(reg_1_addr),
		.reg_2_addr(reg_2_addr),
		.reg_3_addr(reg_3_addr),
		.reg_4_addr(reg_4_addr)	
	);


	// every other clk we send address, everyother clk we read data
	always @(posedge clk)
	begin
		if (reset)
		begin
			this_grid_out <= 8'd0;
			grid_address <= 8'd0;
			state <= s_place_0;
			tick_interval_counter <= 25'b0;
			piece_pos_idx <= 2'b0;
			has_moved <= 1'b1; // Default true
		end
		else
		begin
			if (tick_interval_counter == SECOND_CLK_INTERVAL)
			begin
				tick_interval_counter <= 26'b0;
				 // If we are just sitting, waiting for input, then we are good to move the block down
				if(state == s_input)
					state <= s_move_0;
				// otherwise, don't increment the counter and we'll eventually move the block down when whatever we're doing finishes
			end
			else
			begin
				tick_interval_counter <= tick_interval_counter + 1'b1;
			end

			case(state)
				s_place_0:
				begin
					if(piece_placed == 1'b1)
					begin
						state <= s_place_1;
						piece_pos_idx <= 2'b0;
					end
					else
						state <= s_place_0;
				end
				s_place_1:
				begin
					state <= s_input;
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
						if(piece_will_collide)
							state <= s_place_0; // TODO: Maybe should go to clear line state and check for end of game also
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
					piece_pos_idx <= 2'd0;
				end
				s_move_4: // Clear old grid_mem
				begin
					state <= s_move_5;
					piece_pos_idx <= piece_pos_idx + 2'b1;
				end
				s_move_5: 
				begin
					if(piece_pos_idx == 2'd3)
					begin
						state <= s_move_6;
						piece_pos_idx <= 2'b0;
					end
					else
					begin
						state <= s_move_4;
						piece_pos_idx <= piece_pos_idx + 2'b1;
					end
				end
				s_move_6:// Set new grid_mem with 6 and 7
				begin
					state <= s_move_7;
					piece_pos_idx <= piece_pos_idx + 2'b1;
				end
				s_move_7:
				begin
					if(piece_pos_idx == 2'd3)
					begin
						state <= s_move_8;
						piece_pos_idx <= 2'b0;
					end
					else
					begin
						state <= s_move_6;
						piece_pos_idx <= piece_pos_idx + 2'b1;
					end
				end
				s_move_8:
				begin
					if(piece_will_collide)
						state <= s_place_0; // TODO: Maybe should go to clear line state
					else
						state <= s_input;// TODO: Maybe should go to clear line state and wait for input
				end

				s_input:
				begin
					if (need_to_move)
					begin
						has_moved <= false;
						//Move the piece
						// has_moved <= true;
					end
				end
				default:
				begin
					state <= s_input;
				end
			endcase
		end
	end

	// OUTPUT Logic always block
	always @(state, reset)
	begin
		if(reset)
		begin
			mem_out_ctl = 1'b0;
			piece_placer_enable = 1'b0;
			piece_will_collide = 1'b0;
			this_addr = 8'b0;
			active_block_data = 8'b0;
			this_grid_out = 8'b0;
			this_we = 1'b0;
			for (i = 0; i < 12; i = i + 1)
			begin
				piece_pos[i] = 4'b0;
				piece_next_pos[i] = 4'b0;
			end
		end
		else
		begin
			case (state)
				s_place_0:
				begin
					mem_out_ctl = PIECE_MEM_OUT;
					piece_placer_enable = 1'b1;
					piece_will_collide = 1'b0;
				end
				s_place_1: // Update all the addresses to the new ones
				begin
					mem_out_ctl = THIS_MEM_OUT;
					piece_placer_enable = 1'b0;
					piece_pos[0] = reg_1_addr;
					piece_pos[1] = reg_2_addr;
					piece_pos[2] = reg_3_addr;
					piece_pos[3] = reg_4_addr;
				end
				s_move_0: // Find the next address that we need to read from
				begin
					if(piece_pos[piece_pos_idx] > 231) // Check if the block is in the starting area
					begin
						if(piece_pos[piece_pos_idx] == 8'd241)
							this_addr = 8'd5;
						else if(piece_pos[piece_pos_idx] == 8'd242)
							this_addr = 8'd6;
						else if(piece_pos[piece_pos_idx] == 8'd243)
							this_addr = 8'd7;
						else // If it's in the starting area, but not on the bottom row
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
					// We are now reading the addresses directly below each block
					// And we need to check if we are able to move this block down
					// 
					// If a block is in the starting area, it will always be able to move down
					// If a block is in the game area, we have to test if the block below it is
					// not air and not itself. If so, then the block can't move down
					// Also, if the block is in the game area, we have to check if the address below it
					// is not in the game area (aka the block is at the bottom). If so, the block can't move down.
					// 
					// First, we have to check if the original address is in the starting area. If it is,
					// then we know that, for this block, don't modify piece collide
					// 
					// Otherwise, check if the new address is beyond the game area, if it is then the piece will collide
					// Otherwise, check if the new address is equal to another address, if it is, don't modify piece collision
					// Otherwise, check if the new block is not air, if it isn't air, then the piece will collide

					// Check that the block is in the game area
					if(piece_pos[piece_pos_idx] >= 8'd1 && piece_pos[piece_pos_idx] <= 8'd231)
					begin
						if( piece_next_pos[piece_pos_idx] != piece_pos[0] &&
						    piece_next_pos[piece_pos_idx] != piece_pos[1] &&
						    piece_next_pos[piece_pos_idx] != piece_pos[2] &&
						    piece_next_pos[piece_pos_idx] != piece_pos[3] )
						begin
							if(tetris_grid_in[3:0] != BLOCK_AIR)
								piece_will_collide = 1'b0;
							else
								piece_will_collide = piece_will_collide;
						end
					end
				end

				s_move_2: // Set the address to get the block data of the active block
				begin
					this_addr = piece_pos[0];
				end

				s_move_3: // Get the active block data
				begin
					active_block_data = tetris_grid_in;
				end
				s_move_4, s_move_5:
				begin // Set the data of the old block positions to air
					this_we = 1'b1;
					this_grid_out = 8'b0;
					this_addr = piece_pos[piece_pos_idx];
				end
				s_move_6, s_move_7:
				begin // Set the data of the next block to the active block and update the current address
					this_we = 1'b1;
					this_grid_out = active_block_data;
					this_addr = piece_next_pos[piece_pos_idx];
					piece_pos[piece_pos_idx] = piece_next_pos[piece_pos_idx];
				end
				s_move_8:
				begin // After clear write enable
					this_we = 1'b0;
				end

			endcase
		end
	end

	// Multiplexor to choose the write enable signal going to memory
	always @ (mem_out_ctl, this_we, this_addr, this_grid_out, piece_we, piece_addr, piece_grid_out)
	begin
		if(mem_out_ctl == THIS_MEM_OUT)
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

	always @(controller_in)
	begin
		if (!has_moved)
		begin
			need_to_move <= 1'b0;
		end
		else
		begin
			if (controller_in == BTN_LEFT || controller_in == BTN_RIGHT)
			begin
				need_to_move <= 1'b1;
			end
		end
	end
endmodule