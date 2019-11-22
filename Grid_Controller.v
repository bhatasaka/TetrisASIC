module Grid_Controller (
		
		input clock,
		input [3:0] controller_in,
        input [7:0] tetris_grid_in,
		output reset,
        output reg [7:0] grid_address
);
	reg reset = 1'b0;
	
	parameter [3:0] s_start = 4'b0000, s_reset = 4'b0001, s_address = 4'b0010, s_data = 4'b0011, s4 = 4'b0100, 
						  s5 = 4'b0101, s6 = 4'b0110, s7 = 4'b0111, s8 = 4'b1000, s9 = 4'b1001,
						  s10 = 4'b1010, s11 = 4'b1011, s12 = 4'b1100, s13 = 4'b1101;

	reg [3:0] state = s_start;

	// everyother clock we send address, everyother clock we read data
	always @(posedge clock)
	begin
		if (controller_in == 4'b4) //if start button is pressed, reset
		begin
			state <= s_reset;
			reset <= 1'b1;
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
					if(reset == 1'b0)
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