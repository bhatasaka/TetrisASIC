// ============================
// This module will translate the high level representation of the
// Tetris grid in the tetris memory to the pixels that need to be drawn
// on the screen.
// 
// Author: Bryan Hatasaka
// 
// ============================
module Grid_To (
    input clk,
    input px_en,
    input reset,
	input [7:0] vga_data,
	input [7:0] grid_data,
    output [7:0] pixel_rgb,
    output reg [7:0] grid_addr,
    output reg [15:0] vga_addr
);
    reg px_addr_state;
    reg [3:0] status_reg;
    reg [4:0] state;
    reg [4:0] next_state;
    reg [7:0] data_reg;
    reg [7:0] shift_reg;

    parameter IDLE = 1'b0;
    parameter SET_PX_ADDR = 1'b0;

    parameter AIR =     16'b0;
    parameter I_PIECE = 16'd1;
    parameter O_PIECE = 16'd2;
    parameter T_PIECE = 16'd3;
    parameter S_PIECE = 16'd4;
    parameter Z_PIECE = 16'd5;
    parameter J_PIECE = 16'd6;
    parameter L_PIECE = 16'd7;
    parameter BORDER =  16'd8;

    parameter AIR_ADDR =    16'b0;
    parameter I_PIECE_ADDR =      16'd576;
    parameter O_PIECE_ADDR =      16'd1152;
    parameter T_PIECE_ADDR =      16'd1728;
    parameter S_PIECE_ADDR =      16'd2304;
    parameter Z_PIECE_ADDR =      16'd2880;
    parameter J_PIECE_ADDR =      16'd3456;
    parameter L_PIECE_ADDR =      16'd4032;
    parameter BORDER_ADDR = 16'd4608;

    reg px_clk;
    reg[4:0] col_offset_counter, row_offset_counter;
    reg[7:0] current_px_rgb, next_px_rgb;
    reg[9:0] current_row, current_column;


    assign pixel_rgb = vga_data;

    always @ (clk)
    begin
        if(reset)
        begin
            vga_addr <= 16'b0;
        end

        if(px_addr_state == SET_PX_ADDR) // start next block
        begin
            // Find the pixel in memory that we are looking for
            case (grid_data & 8'h0F) // Mask out the upper bits
                AIR:     vga_addr <= row_offset_counter * 24 + col_offset_counter + AIR_ADDR;
                I_PIECE: vga_addr <= row_offset_counter * 24 + col_offset_counter + I_PIECE_ADDR;
                O_PIECE: vga_addr <= row_offset_counter * 24 + col_offset_counter + O_PIECE_ADDR;
                T_PIECE: vga_addr <= row_offset_counter * 24 + col_offset_counter + T_PIECE_ADDR;
                S_PIECE: vga_addr <= row_offset_counter * 24 + col_offset_counter + S_PIECE_ADDR;
                Z_PIECE: vga_addr <= row_offset_counter * 24 + col_offset_counter + Z_PIECE_ADDR;
                J_PIECE: vga_addr <= row_offset_counter * 24 + col_offset_counter + J_PIECE_ADDR;
                L_PIECE: vga_addr <= row_offset_counter * 24 + col_offset_counter + L_PIECE_ADDR;
                BORDER:  vga_addr <= row_offset_counter * 24 + col_offset_counter + BORDER_ADDR;
                default: vga_addr <= grid_addr;
            endcase
        end
        else
        begin
            vga_addr <= vga_addr;
        end

    end

    always @ (px_clk, reset)
    begin
        if(reset)
        begin
            grid_addr <= 8'b0;
            col_offset_counter <= 5'b0;
            row_offset_counter <= 5'b0;
            current_column <= 10'b0;
            current_row <= 10'b0;
            px_addr_state <= 1'b0;
        end
        else if(px_en)
        begin
            // Testing that we are inside the actual tetris area
            if(current_column >= 177 && current_column <= 288)
            begin
                // If we have gone through all 24 pixels, reset the counter and increment to the next grid block
                if(col_offset_counter == 5'd23)
                begin
                    col_offset_counter <= 0;

                    // Test if we need to reset the grid_address or just increment it
                    if(grid_addr == 8'd239)
                        grid_addr <= 8'b0;
                    else
                        grid_addr <= grid_addr + 8'b1;

                    // Increment the row offset every time we reset the col_offset
                    if(row_offset_counter == 5'd23)
                        row_offset_counter <= 0;
                    else
                        row_offset_counter <= row_offset_counter + 5'b1;
                end
                // Otherwise just increment the col offset counter
                else
                begin
                    col_offset_counter <= col_offset_counter + 5'b1;
                end
            end
        end

        if(current_column == 10'd639)
            current_column <= 10'b0;
        else
            current_column <= current_column + 1;
        if(current_row == 10'd479)
            current_row <= 10'b0;
        else
            current_row <= current_row + 1;
        
        px_addr_state <= ~px_addr_state;
    end


    always @ (posedge clk)
    begin
        if(reset)
            px_clk <= 1'b0;
        else
            px_clk <= ~px_clk;
    end

endmodule