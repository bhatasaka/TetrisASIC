// ============================
// This module will translate the high level representation of the
// Tetris grid in the tetris memory to the pixels that need to be drawn
// on the screen.
// 
// Author: Bryan Hatasaka
// 
// ============================
module Grid_To_Video (
    input clk,
    input px_en,
    input reset,
	input [7:0] grid_data,
    output [7:0] grid_addr,
    output reg [7:0] pixel_rgb
);

    reg px_clk;
    reg[4:0] col_offset_counter, row_offset_counter, grid_col, grid_row;
    reg[9:0] current_row, current_column;

    parameter IDLE = 1'b0;
    parameter SET_PX_ADDR = 1'b1;

    parameter AIR =     4'b0;
    parameter I_PIECE = 4'd1;
    parameter O_PIECE = 4'd2;
    parameter T_PIECE = 4'd3;
    parameter S_PIECE = 4'd4;
    parameter Z_PIECE = 4'd5;
    parameter J_PIECE = 4'd6;
    parameter L_PIECE = 4'd7;
    parameter BORDER =  4'd8;

    parameter AIR_ADDR =    13'b0;
    parameter I_PIECE_ADDR =      13'd576;
    parameter O_PIECE_ADDR =      13'd1152;
    parameter T_PIECE_ADDR =      13'd1728;
    parameter S_PIECE_ADDR =      13'd2304;
    parameter Z_PIECE_ADDR =      13'd2880;
    parameter J_PIECE_ADDR =      13'd3456;
    parameter L_PIECE_ADDR =      13'd4032;
    parameter BORDER_ADDR = 13'd4608;

	parameter [7:0] WHITE       = 8'b11111111,
	                GREEN       = 8'b00011100,
	                RED         = 8'b11100000,
	                BLUE        = 8'b00000011,
	                ORANGE      = 8'b11101100,
	                YELLOW      = 8'b11111100,
	                PURPLE      = 8'b11100011,
	                SKY_BLUE    = 8'b00011111,
	                BLACK       = 8'b00000000;

    assign grid_addr = 12 * grid_row + grid_col;

    // Combinational logic to determine the vga_address
    always @ (grid_data)
    begin
        case (grid_data[3:0]) // Mask out the upper bits
            AIR:     pixel_rgb = WHITE;
            I_PIECE: pixel_rgb = GREEN;
            O_PIECE: pixel_rgb = RED;
            T_PIECE: pixel_rgb = BLUE;
            S_PIECE: pixel_rgb = ORANGE;
            Z_PIECE: pixel_rgb = YELLOW;
            J_PIECE: pixel_rgb = PURPLE;
            L_PIECE: pixel_rgb = SKY_BLUE;
            BORDER:  pixel_rgb = BLACK;
            default: pixel_rgb = 16'b0;
        endcase
    end

    always @ (posedge px_clk, posedge reset)
    begin
        if(reset)
        begin
            col_offset_counter <= 5'b0;
            current_column <= 10'b0;
            grid_col <= 5'b0;
        end
        else if(px_en)
        begin
            // Testing that we are inside the actual tetris area
            if(current_column >= 176 && current_column <= 463)
            begin
                // If we have gone through all 24 pixels, reset the counter and increment to the next grid block
                if(col_offset_counter == 5'd23)
                begin
                    col_offset_counter <= 0;
                    // If we have counted 24 pixels, we must increment the grid column
                    // only if we are less than 11 (block 12) this will get reset at a different point
                    if(grid_col < 5'd11)
                        grid_col <= grid_col + 5'd1;
                    else
                        grid_col <= grid_col;

                end
                // Otherwise just increment the col offset counter
                else
                begin
                    col_offset_counter <= col_offset_counter + 5'b1;
                end
            end

            // Increment the count for our current column
            if(current_column == 10'd639)
            begin
                current_column <= 10'b0;
            end
            else
            begin
                current_column <= current_column + 10'b1;
            end
        end
        else if(px_en == 1'b0)
        begin
            // If px_en isn't high, then we will just reset the current column to 0
            current_column <= 10'b0;
            grid_col <= 5'b0;
            col_offset_counter <= 5'b0;
        end
    end

    always @ (negedge px_en, posedge reset)
    begin
        if(reset)
        begin
            current_row <= 10'b0;
            row_offset_counter <= 5'b0;
            grid_row <= 5'b0;
        end
        else
        begin
            // On the negative edge of the px_en, the row can be incremented
            if(current_row == 10'd479) // Reset back to screen 0,0
            begin
                current_row <= 10'b0;
                row_offset_counter <= 5'b0;
                grid_row <= 5'b0;
            end
            else
            begin
                current_row <= current_row + 10'b1;

                if(row_offset_counter == 5'd23)
                begin
                    row_offset_counter <= 5'b0;

                    // If we have moved 24 pixels down, we need to increment the grid row
                    // Only if we are less than 19, otherwise, stay at 19 (block 20)
                    if(grid_row < 5'd19)
                        grid_row <= grid_row + 5'd1;
                    else
                        grid_row <= grid_row;
                end
                else
                begin
                    row_offset_counter <= row_offset_counter + 5'b1;
                end
            end
        end
    end


    always @ (posedge clk)
    begin
        if(reset)
            px_clk <= 1'b0;
        else
            px_clk <= ~px_clk;
    end

endmodule