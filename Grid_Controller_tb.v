`timescale 1ns / 1ps

module Grid_To_Video_tb;
	reg clock, reset;
    reg [3:0] controller_in;
    wire grid_we;
	wire [7:0] vga_out_a, grid_out_a, grid_addr_b, grid_out_b, grid_addr_a, grid_data_in;
	// reg[15:0] vga_addr_b;
    // wire px_en, v_sync, h_sync;
	// wire [7:0] vga_out_b, pixel_rgb;
	// wire [7:0] r_out, g_out, b_out;
    // wire [15:0] vga_addr_a;
	// reg [7:0] data_a;
	// reg [15:0] addr_a;

	parameter FULL_CLK = 20;
	parameter HALF_CLK = 10;
	
	integer i = 0;

	Grid_Controller grid_controller_test (
		.clk(clock),
		.reset(reset),
		.controller_in(controller_in),
        .tetris_grid_in(grid_out_a),
        .grid_address(grid_addr_a),
		.grid_data_out(grid_data_in),
		.write_en(grid_we)
	);

    Grid_Mem grid_mem_test (
        .data_a(grid_data_in),
		.addr_a(grid_addr_a),
		.addr_b(grid_addr_b),
		.we_a(grid_we),
		.clk(clock),
        .reset(reset),
		.q_a(grid_out_a),
		.q_b(grid_out_b)
    );
	initial begin
        clock = 1'b0;
        reset = 1'b1;
        controller_in = 4'b0;

	    #FULL_CLK;

        reset = 1'b0;

        #FULL_CLK;
        #4200; // Wait quite a few clock cycles for the game ticker clock to trigger

	    $display("Done.");
	end
	
	always@(*)
	begin
		#HALF_CLK clock <= ~clock;
	end
	
endmodule