module Piece_Mover (

    input clk,
    input reset,
    input [3:0] controller,
    output write_en,
    output reg [7:0] block_data,
    output reg [7:0] address
    // piece placer signal. piece placer inside piece mover? or both in grid controller side by side.

);
	reg [24:0] tick_interval_counter;
	reg piece_ticker;



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



endmodule