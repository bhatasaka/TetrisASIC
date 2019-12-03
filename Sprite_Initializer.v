module Sprite_Initializer(
	input clk,
	input rst,
	output reg dis,
	output reg [12:0] addr,
	output reg [7:0] data,
	output reg we
);

	reg [12:0] addr_counter;
	reg [9:0] color_counter;
	reg [7:0] color;
	reg write;

	parameter [7:0] WHITE       = 8'b11111111,
	                GREEN       = 8'b00011100,
	                RED         = 8'b11100000,
	                BLUE        = 8'b00000011,
	                ORANGE      = 8'b11101100,
	                YELLOW      = 8'b11111100,
	                PURPLE      = 8'b11100011,
	                SKY_BLUE    = 8'b00011111,
	                BLACK       = 8'b00000000;

	always @(clk)
	begin
		if (rst)
		begin
			dis <= 1'b1;
			addr <= 13'b0;
			data <= WHITE;
			we <= 1'b0;

			write = 1'b0;
			addr_counter <= 13'b0;
			color_counter <= 10'b0;
			color <= WHITE;
		end
		else
		begin
			if (color_counter == 10'd576)
			begin
				case (color)
					WHITE:
					begin
						color_counter <= 10'd0;
						color <= GREEN;
					end
					GREEN:
					begin
						color_counter <= 10'd0;
						color <= RED;
					end
					RED:
					begin
						color_counter <= 10'd0;
						color <= BLUE;
					end
					BLUE:
					begin
						color_counter <= 10'd0;
						color <= ORANGE;
					end
					ORANGE:
					begin
						color_counter <= 10'd0;
						color <= YELLOW;
					end
					YELLOW:
					begin
						color_counter <= 10'd0;
						color <= PURPLE;
					end
					PURPLE:
					begin
						color_counter <= 10'd0;
						color <= SKY_BLUE;
					end
					SKY_BLUE:
					begin
						color_counter <= 10'd0;
						color <= BLACK;
					end
					BLACK:
					begin
						color_counter <= color_counter;
						we <= 1'b0;
						dis <= 1'b0;
						color <= color;
					end
					default:
						color <= BLACK;
				endcase
			end
			else
			begin
				if (write == 1'b0)
				begin
					we <= 1'b1;
					addr_counter <= addr_counter + 1'b1;
					color_counter <= color_counter + 1'b1;
					data <= color;
					write <= 1'b1;
				end
				else
				begin
					we <= 1'b0;
					addr <= addr_counter;
					write <= 1'b0;
				end
			end
		end
	end
endmodule
