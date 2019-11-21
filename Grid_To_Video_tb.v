`timescale 1ns / 1ps

module Grid_To_Video_tb;
	reg clock, px_en, reset;
	wire [7:0] vga_out_a, grid_out_a, grid_addr_a, pixel_rgb;
	wire [7:0] vga_out_b, grid_out_b, grid_addr_b;
    wire [15:0] vga_addr_a, vga_addr_b;
	// reg [7:0] data_a;
	// reg [15:0] addr_a;

	parameter FULL_CLK = 20;
	parameter HALF_CLK = 10;
	
	VGA_Mem vga_mem_test (
		.data_a(0),
		.addr_a(vga_addr_a),
		.addr_b(vga_addr_b),
		.we_a(0),
		.clk(clock),
		.q_a(vga_out_a),
		.q_b(vga_out_b)
	);
	
    Grid_Mem grid_mem_test (
        .data_a(0),
		.addr_a(grid_addr_a),
		.addr_b(grid_addr_b),
		.we_a(0),
		.clk(clock),
		.q_a(grid_out_a),
		.q_b(grid_out_b)
    );

    Grid_To_Video grid_video_test (
        .clk(clock),
        .px_en(px_en),
        .reset(reset),
        .vga_data(vga_out_a),
        .grid_data(grid_out_a),
        .pixel_rgb(pixel_rgb),
        .grid_addr(grid_addr_a),
        .vga_addr(vga_addr_a)
    );


	integer i;

	initial begin
	
        px_en = 1'b0;
        clock = 1'b0;
        reset = 1'b1;
	    #FULL_CLK

        reset = 1'b0;
        px_en = 1'b1;
	
	    $display("Done.");
	end
	
	always@(*)
	begin
		#HALF_CLK clock <= ~clock;
	end
	
endmodule