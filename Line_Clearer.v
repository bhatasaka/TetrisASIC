module Line_Clearer(
    input en,
    input clk,
    input rst,
    input [7:0] data_in,
    output reg cleared,
    output reg we,
    output reg [7:0] addr,
    output reg [7:0] data_out
);

	parameter [7:0] LINE_1 = 8'd1;
	parameter [7:0] LINE_OFFSET = 8'd12;
	parameter [7:0] LINE_WIDTH = 4'd10;
	
	reg [4:0] line_iterator;
	reg [7:0] current_line;
	reg [7:0] current_shift_line;
	reg [3:0] check_block_number;
	reg [3:0] block_count;
	reg [5:0] clear_state;
	reg [7:0] check_addr;
	reg [7:0] shift_addr;
	reg [7:0] data;
	
	reg clear_line, check_line;
	reg line_cleared, advance_line;
	
	//mux the address that goes out to the grid memory
	always @(clear_line, check_line, check_addr, shift_addr)
	begin
		//Line checker is reading memory
		if (check_line && !clear_line)
		begin
			addr <= check_addr;
		end
		//Line Shifter is reading/writing memory
		else if (clear_line)
		begin
			addr <= shift_addr;
		end
		//Nothing is happening to memory
		else
		begin
			addr <= 8'b0;
		end
	end
	
	//Line Shifting/Clearing State machine
	always @(posedge clk)
	begin
		//Clear all used signals when not clearing/shifting lines
		if (~clear_line || rst)
		begin
			we <= 1'b0;
			line_cleared <= 1'b0;
			current_shift_line <= 4'b0;
			clear_state <= 6'b0;
			shift_addr <= 8'b0;
			data <= 8'b0;
			data_out <= 8'b0;
		end
		else
		begin
			case (clear_state)
				//Init State
				0:
				begin
					current_shift_line <= current_line;
					clear_state <= clear_state + 1'b1;
					line_cleared <= 1'b0;
				end
				
				//Read Grid Mem
				1, 4, 7, 10, 13, 16, 19, 22, 25, 28:
				begin
					//Ignore reading line above if we are at the top line
					if (current_shift_line == LINE_1)
					begin
						shift_addr <= 8'b0;
					end
					else
					begin
						shift_addr <= (current_shift_line - LINE_OFFSET);
					end
	
					clear_state <= clear_state + 1'b1;
				end
				
				//Save value
				2, 5, 8, 11, 14, 17, 20, 23, 26, 29:
				begin
					//Overwrite with air if we are at the top line
					if (current_shift_line == LINE_1)
					begin
						data <= 8'b0;
					end
					else
					begin
						data <= data_in;
					end
	
					shift_addr <= current_shift_line;
					we <= 1'b1;
					clear_state <= clear_state + 1'b1;
				end
	
				//Write Grid Mem
				3, 6, 9, 12, 15, 18, 21, 24, 27, 30:
				begin
					data_out <= data;
					we <= 1'b0;
					clear_state <= clear_state + 1'b1;
				end
	
				//Tidy up or go to the next line to shift
				31:
				begin
					//Next line up
					if (current_shift_line != LINE_1)
					begin
						current_shift_line <= current_shift_line - LINE_OFFSET;
						clear_state <= 6'b1;
					end
					//Finished shifting all lines
					else
					begin
						line_cleared <= 1'b1;
						//Will hit default state to clear everything
						clear_state <= clear_state + 1'b1;
					end
				end

				default:
				begin
					we <= 1'b0;
					line_cleared <= 1'b0;
					current_shift_line <= 4'b0;
					clear_state <= 6'b0;
					shift_addr <= 8'b0;
					data <= 8'b0;
					data_out <= 8'b0;
				end
			endcase
		end
	end
	
	//Line checking statemachine
	always @(posedge clk)
	begin
		//clear all signals used when line checker is not active
		if (~check_line || rst)
		begin
			block_count <= 4'b0;
			check_addr <= 8'b0;
			check_block_number <= 4'b0;
			clear_line <= 1'b0;
			advance_line <= 1'b0;
		end
		else
		begin
			case(check_block_number)
				//Init State
				0:
				begin
					block_count <= 4'b0;
					check_addr <= current_line;
					check_block_number <= check_block_number + 1'b1;
				end
				//read memory for each block, see if it is air or not
				1, 2, 3, 4, 5, 6, 7, 8, 9, 10:
				begin
					//If not an air block, increment counter
					if (data_in != 8'b0)
					begin
						block_count <= block_count + 8'b1;
					end
					else
					begin
						block_count <= block_count;
					end
	
					check_addr <= check_addr + 8'b1;
					check_block_number <= check_block_number + 1'b1;
				end
				//Hold state while we wait for the line to clear (if needed)
				11:
				begin
					//If we found a line with no air blocks, it needs cleared
					if (block_count == LINE_WIDTH)
					begin
						clear_line <= 1'b1;
						advance_line <= 1'b0;
					end
					//Otherwise go to the next line
					else
					begin
						clear_line <= 1'b0;
						advance_line <= 1'b1;
					end
	
					//If a line has been or does not need to be cleared, go to the next line to check
					if ((line_cleared == 1'b1) || (advance_line == 1'b1))
					begin
						//This will hit the default state which will clear everything including advance line pulse
						check_block_number <= check_block_number + 1'b1;
						clear_line <= 1'b0;
						advance_line <= 1'b1;
					end
					//Otherwise stay put
					else
					begin
						check_block_number <= check_block_number;
			//			clear_line <= clear_line;
			//			advance_line <= 1'b0;
					end
				end
				//If we end up in a wonky state, go back to the init state
				default:
				begin
					block_count <= 4'b0;
					check_addr <= current_line;
					check_block_number <= 4'd0;
					clear_line <= 1'b0;
					advance_line <= 1'b0;
				end
			endcase
		end
	end
	
	// Line iteration state machine
	always @(posedge clk)
	begin
		//Clear all signals when line iterator is not active
		if (~en || rst)
		begin
			cleared <= 1'b0;
			check_line <= 1'b0;
			line_iterator <= 5'b0;
			current_line <= 8'b0;
		end
		else
		begin
			case (line_iterator)
				//Init State
				0:
				begin
					current_line	<= LINE_1;
					line_iterator	<= line_iterator + 5'b1;
				end
				//Iterate over each line
				1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20:
				begin
					if (advance_line == 1'b1)
					begin
						check_line <= 1'b0;
						current_line	<= current_line + LINE_OFFSET;
						line_iterator <= line_iterator + 5'b1;
					end
					else
					begin
						check_line <= 1'b1;
						current_line <= current_line;
						line_iterator <= line_iterator;
					end
				end
				21:
				begin
					cleared <= 1'b1;
				end
				default:
				begin
					current_line	<= 8'b0;
					line_iterator <= 5'b0;
				end
			endcase
		end
	end
endmodule
