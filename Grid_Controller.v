// ============================
// This module is the FSM for Tetris. It receives button data
// from the input controller, determines the action that needs to 
// take place, then updates the tetris grid data.
// 
// Author: Jamison Bauer, Sean Eastland, Bryan Hatasaka
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
	parameter [4:0] s_place_0 	= 5'd0,
					s_place_1 	= 5'd1,
					s_move_0 	= 5'd2, 
					s_move_1 	= 5'd3, 
					s_move_2 	= 5'd4, 
					s_move_3 	= 5'd5, 
					s_move_4 	= 5'd6, 
					s_move_5 	= 5'd7, 
					s_move_6 	= 5'd8, 
					s_move_7	= 5'd9, 
					s_move_8	= 5'd10,
					s_input_0 	= 5'd11, 
					s_input_1	= 5'd12, 
					s_input_2	= 5'd13, 
					s_input_3	= 5'd14, 
					s_input_4 	= 5'd15,
					s_input_5 	= 5'd16,
					s_clear_0 	= 5'd17,
					s_clear_1 	= 5'd18,
					s_move_05 	= 5'd19,
					s_move_55 	= 5'd20,
					s_move_22	= 5'd21,
					s_input_45  = 5'd22,
					s_input_6	= 5'd23;

	parameter [3:0] BTN_START 	= 4'b0100,
					BTN_LEFT	= 4'b0111,
					BTN_RIGHT	= 4'b1000;

	parameter [7:0] BLOCK_AIR 	= 4'b0000,
					BLOCK_I 	= 4'b0001,
					BLOCK_O 	= 4'b0010,
					BLOCK_T 	= 4'b0011,
					BLOCK_S 	= 4'b0100,
					BLOCK_Z 	= 4'b0101,
					BLOCK_J 	= 4'b0110,
					BLOCK_L 	= 4'b0111,
				BLOCK_BORDER 	= 4'b1000;

	parameter [7:0] GRID_START_ADDR = 0,
					GRID_END_ADDR = 239,
					PLACE_AREA_START_ADDR = 240,
					PLACE_AREA_END_ADDR = 251;

	parameter [24:0] SECOND_CLK_INTERVAL = 26'd50000000;
	// parameter [24:0] SECOND_CLK_INTERVAL = 26'd50; // Testing purposes
	parameter[1:0] 	THIS_MEM_OUT 	= 2'd0, 
					PIECE_MEM_OUT 	= 2'd1,
					LINE_MEM_OUT 	= 2'd2;

	// Piece Placer Wires
	wire piece_placed, piece_we;
	wire [7:0] reg_1_addr, reg_2_addr, reg_3_addr, reg_4_addr;
	wire [7:0] piece_addr, piece_grid_out;

	// Line Clearer Wires
	wire line_cleared, line_clear_we;
	wire [7:0] line_clear_addr, line_clear_grid_out;

	reg piece_placer_enable, line_clearer_enable, this_we, piece_will_collide;
	reg has_moved, has_lifted, move_right, move_left, has_ticked;
	reg [1:0] piece_pos_idx, mem_out_ctl;
	reg [4:0] state, next_state;
	reg [7:0] this_addr, this_grid_out;

	//Array of four 8-bit Registers for tracking poisition
	reg [7:0] piece_pos[3:0];
	reg [7:0] piece_next_pos[3:0];
	reg [7:0] active_block_data;
	reg [24:0] tick_interval_counter;

	integer unsigned i;

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

	Line_Clearer line_clearer(
		.en(line_clearer_enable),
		.clk(clk),
		.rst(reset),
		.data_in(tetris_grid_in),
		.cleared(line_cleared),
		.we(line_clear_we),
		.addr(line_clear_addr),
		.data_out(line_clear_grid_out)
	);


	always @(state, reset, piece_placed, line_cleared, has_ticked, move_left, move_right, piece_pos_idx, piece_will_collide)
	begin
		if (reset)
		begin
			next_state = s_place_0;
			has_moved = 1'b1; // Default true
		end
		else
		begin
			case(state)
				s_place_0:
				begin
					if(piece_placed == 1'b1)
					begin
						next_state = s_place_1;
					end
					else
						next_state = s_place_0;
					has_moved = 1'b1;
				end
				s_place_1:
				begin
					next_state = s_input_0;
					has_moved = 1'b1;
				end
				
				s_move_0:
				begin
					next_state = s_move_05;
					has_moved = 1'b1;
				end
				s_move_05:
				begin
					next_state = s_move_1;
					has_moved = 1'b1;
				end
				s_move_1:
				begin
					// Go back and forth between states move_0 and move_1 4 times
					if(piece_pos_idx == 2'd3)
					begin
						next_state = s_move_2;
					end
					else
					begin
						next_state = s_move_0;
					end
					has_moved = 1'b1;
				end
				s_move_2: // Active block address
				begin
					if(piece_will_collide) // If a previous step detected a collision
						next_state = s_clear_0;
					else
						next_state = s_move_22;
					has_moved = 1'b1;
				end
				s_move_22:
				begin
					next_state = s_move_3;
					has_moved = 1'b1;
				end
				s_move_3: // Set active block
				begin
					next_state = s_move_4;
					has_moved = 1'b1;
				end
				s_move_4: // Clear old grid_mem
				begin
					next_state = s_move_5;
					has_moved = 1'b1;
				end
				s_move_5: 
				begin
					if(piece_pos_idx == 2'd3)
					begin
						next_state = s_move_55;
					end
					else
					begin
						next_state = s_move_4;
					end
					has_moved = 1'b1;
				end
				s_move_55:
				begin
					next_state = s_move_6;
					has_moved = 1'b1;
				end
				s_move_6:// Set new grid_mem with 6 and 7
				begin
					next_state = s_move_7;
					has_moved = 1'b1;
				end
				s_move_7:
				begin
					if(piece_pos_idx == 2'd3)
					begin
						next_state = s_move_8;
					end
					else
					begin
						next_state = s_move_6;
					end
					has_moved = 1'b1;
				end
				s_move_8:
				begin
					next_state = s_input_0; 
					has_moved = 1'b1;
				end

				s_input_0:
				begin
					if (has_ticked)
					begin
						next_state = s_move_0;
						has_moved = 1'b1;
					end
					else if ((move_right || move_left))
					begin
						has_moved = 1'b0;
						
						if(move_right == 1'b1)
							next_state = s_input_1;
						else
							next_state = s_input_2;

					end
					else
					begin
						next_state = s_input_0;
						has_moved = 1'b1;
					end
				end
				s_input_1: // Set next addresses to move right
				begin
					next_state = s_input_3;
					has_moved = 1'b0;
				end
				s_input_2: // Set next addresses to move left
				begin
					next_state = s_input_3;
					has_moved = 1'b0;
				end
				s_input_3:
				begin
					if(piece_will_collide)
					begin
						next_state = s_input_0;
						has_moved = 1'b1;
					end
					else
					begin
						next_state = s_input_4;
						has_moved = 1'b0;
					end
				end
				s_input_4: // Go through each new address and set the grid address to it
				begin
					next_state = s_input_45;
					has_moved = 1'b0;
				end
				s_input_45:
				begin
					next_state = s_input_5;
					has_moved = 1'b0;
				end
				s_input_5: //look at the address and data and determine if a collision will occur
				begin
					// Go back and forth between states s_input_4 and s_input_5 4 times
					if(piece_pos_idx == 2'd3)
					begin
						next_state = s_input_6;
					end
					else
					begin
						next_state = s_input_4;
					end
					has_moved = 1'b0;
				end
				s_input_6:
				begin
					if(piece_will_collide)
					begin
						next_state = s_input_0; // Just go back to input
						has_moved = 1'b1;
					end
					else
					begin
						next_state = s_move_2;
						has_moved = 1'b0;
					end
				end
				s_clear_0:
				begin
					if(line_cleared == 1'b1)
						next_state = s_clear_1;
					else
						next_state = s_clear_0;
					has_moved = 1'b1;
				end
				s_clear_1:
				begin
					next_state = s_place_0;
					has_moved = 1'b1;
				end

				default:
				begin
					next_state = s_input_0;
					has_moved = 1'b1; // Default true
				end
			endcase
		end
	end

	always @ (posedge clk)
	begin
		if(reset)
		begin
			tick_interval_counter = 25'b0;
			state <= s_place_0;
		end
		else
		begin
			state <= next_state;
			if(tick_interval_counter == SECOND_CLK_INTERVAL)
			begin
				if(next_state == s_move_0)
				begin
					has_ticked = 1'b0;
					tick_interval_counter = 25'b0;
				end
				else
					has_ticked = 1'b1;
			end
			else
			begin
				tick_interval_counter = tick_interval_counter + 1'b1;
				has_ticked = 1'b0;
			end
		end
	end

	always @(posedge clk)
	begin
		if(reset)
		begin
			mem_out_ctl <= THIS_MEM_OUT;
			piece_placer_enable <= 1'b0;
			line_clearer_enable <= 1'b0;
			piece_will_collide <= 1'b0;
			this_addr <= 8'b0;
			active_block_data <= 8'b0;
			this_grid_out <= 8'b0;
			this_we <= 1'b0;
			for (i = 0; i < 12; i = i + 1)
			begin
				piece_pos[i] <= 4'b0;
				piece_next_pos[i] <= 4'b0;
			end
			piece_pos_idx <= 2'b0;

		end
		else
		begin
			// this_grid_out <= 8'b0;
			// this_we <= 1'b0;
			// this_addr <= 8'b0;
			// piece_placer_enable <= 1'b0;
			// line_clearer_enable <= 1'b0;

			// for (i = 0; i < 12; i = i + 1)
			// begin
			// 	piece_pos[i] <= piece_pos[i];
			// 	piece_next_pos[i] <= piece_next_pos[i];
			// end
			// active_block_data <= active_block_data;
			// piece_will_collide <= piece_will_collide;
			// mem_out_ctl <= THIS_MEM_OUT;

			case (state)
				s_place_0:
				begin
					mem_out_ctl <= PIECE_MEM_OUT;
					piece_placer_enable <= 1'b1;
					piece_will_collide <= 1'b0;
				end
				s_place_1: // Update all the addresses to the new ones
				begin
					mem_out_ctl <= THIS_MEM_OUT;
					piece_placer_enable <= 1'b0;
					piece_pos[0] <= reg_1_addr;
					piece_pos[1] <= reg_2_addr;
					piece_pos[2] <= reg_3_addr;
					piece_pos[3] <= reg_4_addr;
					piece_pos_idx <= 2'b0;
				end

				s_move_0: // Find the next address that we need to read from
				begin
					if(piece_pos[piece_pos_idx] >= PLACE_AREA_START_ADDR) // Check if the block is in the starting area
					begin
						if(piece_pos[piece_pos_idx] == 8'd249)
						begin
							this_addr <= 8'd5;
							piece_next_pos[piece_pos_idx] <= 8'd5;
						end
						else if(piece_pos[piece_pos_idx] == 8'd250)
						begin
							piece_next_pos[piece_pos_idx] <= 8'd6;
							this_addr <= 8'd6;
						end
						else if(piece_pos[piece_pos_idx] == 8'd251)
						begin
							piece_next_pos[piece_pos_idx] <= 8'd7;
							this_addr <= 8'd7;
						end
						else // If it's in the starting area, but not on the bottom row
						begin
							piece_next_pos[piece_pos_idx] <= piece_pos[piece_pos_idx] + 3;
							this_addr <= piece_pos[piece_pos_idx] + 3;
						end

					end
					else
					begin
						piece_next_pos[piece_pos_idx] <= piece_pos[piece_pos_idx] + 12;
						this_addr <= piece_pos[piece_pos_idx] + 12;
					end
				end

				s_move_05: // Read the next block position to see if it's available
				begin
				end
				s_move_1:
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
					// First, we have to check if the original address is in the starting area. If it is not,
					// then we know that, for this block, don't modify piece collide
					// 
					// Otherwise, check if the new address is beyond the game area, if it is then the piece will collide
					// Otherwise, check if the new address is equal to another address, if it is, don't modify piece collision
					// Otherwise, check if the new block is not air, if it isn't air, then the piece will collide

					// Check that the block is in the game area
					if(piece_pos[piece_pos_idx] >= GRID_START_ADDR && piece_pos[piece_pos_idx] <= GRID_END_ADDR)
					begin
						if(piece_next_pos[piece_pos_idx] > GRID_END_ADDR)
						begin
							piece_will_collide <= 1'b1;
						end
						// Checking for overlap, it's fine if the new address is an old address
						else if( piece_next_pos[piece_pos_idx] != piece_pos[0] &&
						    piece_next_pos[piece_pos_idx] != piece_pos[1] &&
						    piece_next_pos[piece_pos_idx] != piece_pos[2] &&
						    piece_next_pos[piece_pos_idx] != piece_pos[3] )
						begin
							if(tetris_grid_in[3:0] != BLOCK_AIR)
								piece_will_collide <= 1'b1;
						end
					end
					piece_pos_idx <= piece_pos_idx + 2'b1;
				end

				s_move_2: // Set the address to get the block data of the active block
				begin
					this_addr <= piece_pos[0];
					piece_will_collide <= 1'b0; // Can reset this here
				end

				s_move_22:
				begin
					piece_pos_idx <= 2'b0;
				end

				s_move_3: // Get the active block data
				begin
					active_block_data <= tetris_grid_in;
				end
				s_move_4:
				begin
					this_we <= 1'b1;
					this_grid_out <= 8'b0;
					this_addr <= piece_pos[piece_pos_idx];
				end
				s_move_5:
				begin // Set the data of the old block positions to air
					this_we <= 1'b1;
					this_grid_out <= 8'b0;
					this_addr <= piece_pos[piece_pos_idx];
					piece_pos_idx <= piece_pos_idx + 2'b1;
				end
				s_move_55:
				begin
					piece_pos_idx <= 2'b0;
				end
				s_move_6:
				begin
					this_we <= 1'b1;
					this_grid_out <= active_block_data;
					this_addr <= piece_next_pos[piece_pos_idx];
					piece_pos[piece_pos_idx] <= piece_next_pos[piece_pos_idx];
				end
				s_move_7:
				begin // Set the data of the next block to the active block and update the current address
					this_we <= 1'b1;
					this_grid_out <= active_block_data;
					this_addr <= piece_next_pos[piece_pos_idx];
					piece_pos[piece_pos_idx] <= piece_next_pos[piece_pos_idx];
					piece_pos_idx <= piece_pos_idx + 2'b1;
				end
				s_move_8:
				begin // After clear write enable
					this_we <= 1'b0;
				end

				s_input_0:
				begin
					piece_will_collide <= 1'b0;
					piece_pos_idx <= 2'b0;
				end
				s_input_1: // Move right, get next addresses, don't worry about overflow, or edges yet
				begin
					piece_next_pos[0] <= piece_pos[0] + 1;
					piece_next_pos[1] <= piece_pos[1] + 1;
					piece_next_pos[2] <= piece_pos[2] + 1;
					piece_next_pos[3] <= piece_pos[3] + 1;
				end
				s_input_2: // Move right, get next addresses, don't worry about overflow, or edges yet
				begin
					piece_next_pos[0] <= piece_pos[0] - 8'd1;
					piece_next_pos[1] <= piece_pos[1] - 8'd1;
					piece_next_pos[2] <= piece_pos[2] - 8'd1;
					piece_next_pos[3] <= piece_pos[3] - 8'd1;
				end
				s_input_3:
				begin
					for(i = 0; i < GRID_END_ADDR; i = i + 12)
					begin
						// Check if moving the piece will result in a bad area
						if(piece_next_pos[0] == i[7:0] || piece_next_pos[0] == i[7:0]+11
						|| piece_next_pos[1] == i[7:0] || piece_next_pos[1] == i[7:0]+11
						|| piece_next_pos[2] == i[7:0] || piece_next_pos[2] == i[7:0]+11
						|| piece_next_pos[3] == i[7:0] || piece_next_pos[3] == i[7:0]+11)
						begin
							piece_will_collide <= 1'b1;
						end
					end
					piece_pos_idx <= 2'b0;
					this_addr <= piece_next_pos[piece_pos_idx];
				end
				s_input_4:
				begin
					this_addr <= piece_next_pos[piece_pos_idx];
				end
				s_input_45:
				begin
				end
				s_input_5:
				begin
					// If the piece is in the starting area, we're not going to move it
					if(piece_pos[piece_pos_idx] >= PLACE_AREA_START_ADDR)
					begin
						piece_will_collide <= 1'b1;
					end
					else // At this point, we should have valid addresses
					begin
						// Check if the next block is air or itself
						if( piece_next_pos[piece_pos_idx] != piece_pos[0] &&
						    piece_next_pos[piece_pos_idx] != piece_pos[1] &&
						    piece_next_pos[piece_pos_idx] != piece_pos[2] &&
						    piece_next_pos[piece_pos_idx] != piece_pos[3] )
						begin
							if(tetris_grid_in[3:0] != BLOCK_AIR)
								piece_will_collide <= 1'b1;
						end
					end
					piece_pos_idx <= piece_pos_idx + 2'b1;
				end
				s_input_6:
				begin
					piece_pos_idx <= 2'b0;
				end
				s_clear_0:
				begin
					mem_out_ctl <= LINE_MEM_OUT;
					line_clearer_enable <= 1'b1;
				end
				s_clear_1:
				begin
					mem_out_ctl <= THIS_MEM_OUT;
					line_clearer_enable <= 1'b0;
				end

				default:
				begin
				end
			endcase
		end
	end

	// Multiplexor to choose the write enable signal going to memory
	always @ (mem_out_ctl, this_we, this_addr, this_grid_out, piece_we, piece_addr, piece_grid_out, line_clear_we, line_clear_addr, line_clear_grid_out)
	begin
		if(mem_out_ctl == PIECE_MEM_OUT) // Choose piece_placer to output to memory
		begin
			write_en = piece_we;
			grid_address = piece_addr;
			grid_data_out = piece_grid_out;
		end
		else if(mem_out_ctl == LINE_MEM_OUT)
		begin
			write_en = line_clear_we;
			grid_address = line_clear_addr;
			grid_data_out = line_clear_grid_out;
		end
		else
		begin
			write_en = this_we;
			grid_address = this_addr;
			grid_data_out = this_grid_out;
		end
	end

	// Triggers on changing input
	always @(controller_in, has_moved)
	begin
		if (!has_moved)
		begin
			move_right = 1'b0;
			move_left = 1'b0;
			has_lifted = 1'b0;
		end
		else
		begin
			if (controller_in == BTN_RIGHT)
			begin
				if(has_lifted == 1'b1)
				begin
					move_right = 1'b1;
					move_left = 1'b0;
					has_lifted = 1'b0;
				end
				else
				begin
					move_right = 1'b0;
					move_left = 1'b0;
					has_lifted = 1'b0;
				end
			end
			else if(controller_in == BTN_LEFT)
			begin
				if(has_lifted == 1'b1)
				begin
					move_right = 1'b0;
					move_left = 1'b1;
					has_lifted = 1'b0;
				end
				else
				begin
					move_right = 1'b0;
					move_left = 1'b0;
					has_lifted = 1'b0;
				end
			end
			else
			begin
				move_right = 1'b0;
				move_left = 1'b0;
				has_lifted = 1'b1;
			end
		end
	end
endmodule