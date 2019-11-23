module VGA_Controller (

	input clk,
	input  [7:0] rgb_8,
	output [7:0] r_out,
	output [7:0] g_out,
	output [7:0] b_out,
	output reg h_sync,
	output reg v_sync,
	//output reg pixel_clk,
	output pixel_en
	//output reg line_inc

);

	reg h_screen_on;
	reg v_screen_on;
	reg [14:0] h_sync_counter;
	reg [1:0] h_sync_mode;
	reg [1:0] v_sync_mode;
	reg [9:0] v_sync_counter;
	
	
	initial
	begin
		h_screen_on = 1'd0;
		v_screen_on = 1'd0;
		h_sync_counter = 14'd0;
		v_sync_counter = 10'd0;
		h_sync_mode = 2'd0;
		v_sync_mode = 2'd0;
	end
	
	//enable pixel input
	assign pixel_en = h_screen_on & v_screen_on;
	//Convert 8 bit RGB to 24 bit RGB
	//assign r_out = ((rgb_8[7:5] & 8'd255) >> 5) * 8'd255 / 8'd7;
	//assign g_out = ((rgb_8[4:2] & 8'd255) >> 2) * 8'd255 / 8'd7;
	//assign b_out = ((rgb_8[7:5] & 8'd255)) * 8'd255 / 8'd7;
	assign r_out = {rgb_8[7:5], 5'd0};
	assign g_out = {rgb_8[4:2], 5'd0};
	assign b_out = {rgb_8[1:0], 6'd0};
	
	always @(posedge clk)
	begin
		
		//pixel clock assumes 50MHz input
		//divides to 25MHz (close to 25.175)
	//	if (pixel_counter == 2'd2)
	//	begin
	//		pixel_clk <= ~pixel_clk;
	//		pixel_counter <= 2'd0;
	//	end
	//	else
	//	begin
	//		pixel_counter <= pixel_counter + 1'd1;
	//	end
	
		//Handle the horizontal sync signal
		case(h_sync_mode)
			//Wait for horizontal Sync, set hsync high
			2'b00:
			begin
				if (h_sync_counter == 14'd1900)
				begin
					h_sync <= 1'b1;
					h_sync_mode <= h_sync_mode + 1'd1;
					h_sync_counter <= 11'd0;
				end
				else
				begin
					h_sync_counter <= h_sync_counter + 1'd1;
				end
			end
	
			//Wait for the back porch until pixels are
			//clocked
			2'b01:
			begin
				if (h_sync_counter == 14'd950)
				begin
					h_screen_on <= 1'b1;
					h_sync_mode <= h_sync_mode + 1'd1;
					h_sync_counter <= 11'd0;
				end
				else
				begin
					h_sync_counter <= h_sync_counter + 1'd1;
				end
			end
	
			//Display is on, can clock pixels during this time
			2'b10:
			begin
				if (h_sync_counter == 14'd12700)
				begin
					h_sync_mode <= h_sync_mode + 1'd1;
					h_sync_counter <= 11'd0;
					//Stop clocking pixels after end of display interval
					h_screen_on <= 1'b0;
				end
				else
				begin
					h_sync_counter <= h_sync_counter + 1'd1;
				end
			end
			
			//Wait for back porch, set hsync low, track the number
			//of horizontal lines
			2'b11:
			begin
				if (h_sync_counter == 14'd300)
				begin
					h_sync <= 1'b0;
					h_sync_mode <= 2'b00;
					h_sync_counter <= 11'd0;
	
					if (v_sync_counter == 10'd525)
					begin
						v_sync_counter <= 10'd1;
					end
					else
					begin
						v_sync_counter <= v_sync_counter + 1'd1;
					end
				end
				else
				begin
					h_sync_counter <= h_sync_counter + 1'd1;
				end
			end
		endcase
	end
	
	//Vertical sync signal
	always @(posedge clk or v_sync_counter)
	begin
		
		case(v_sync_counter)
			//Wait Sync
			10'd2:
			begin
				v_sync <= 1'b1;
			end
			//Wait Front Porch
			10'd35:
			begin
				v_screen_on <= 1'b1;
			end
			//Wait Display Time
			10'd515:
			begin
				v_screen_on <= 1'b0;
			end
			//Wait Back Porch
			10'd525:
			begin
				v_sync <= 1'b0;
			end
			//maintain signal while lines are counting
			default:
			begin
				v_sync <= v_sync;
				v_screen_on <= v_screen_on;
			end
		endcase
	end
endmodule
