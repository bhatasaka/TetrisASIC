`timescale 1ns / 1ps
// This testbench is set up so the Grid_Controller has a tick time of 25 clock cycles
// (instead of 50 million for 1 second)

module Grid_Controller_tb;
	reg clock, reset, test_write_mem;
    reg [3:0] controller_in;
    reg grid_we;
	reg [7:0] grid_addr_b,grid_addr_a, grid_data_in;
    reg [7:0] test_grid_addr, test_grid_data, test_grid_we;
    wire gc_we;
    wire [7:0] grid_out_a, grid_out_b, gc_addr_a, gc_grid_data;

	parameter FULL_CLK = 20;
	parameter HALF_CLK = 10;
	parameter [3:0] BTN_START 	= 4'b0100,
					BTN_LEFT	= 4'b0111,
					BTN_RIGHT	= 4'b1000;
	integer i = 0;

	Grid_Controller grid_controller_test (
		.clk(clock),
		.reset(reset),
		.controller_in(controller_in),
        .tetris_grid_in(grid_out_a),
        .grid_address(gc_addr_a),
		.grid_data_out(gc_grid_data),
		.write_en(gc_we)
	);

    Grid_Mem grid_mem_test (
        .data_a(grid_data_in),
		.addr_a(grid_addr_a),
		.addr_b(grid_addr_b),
		.we_a(grid_we),
		.clk(clock),
        .reset(1'b0),
		.q_a(grid_out_a),
		.q_b(grid_out_b)
    );
	initial begin
        clock = 1'b0;
        reset = 1'b1;
        controller_in = 4'b0;
        grid_addr_b = 8'b0;
        test_write_mem = 1'b1;
        test_grid_addr = 8'b0;
        test_grid_data = 8'b0;
        test_grid_we = 1'b0;

	    #FULL_CLK;
        reset = 1'b0;
        test_grid_we = 1'b1;
        // test_grid_addr = 8'd65; // Put a block at address 65 to collide when moving down in the grid memory
        test_grid_addr = 8'd54; // Put a block at address 52 to collide when moving left in the grid memory
        // test_grid_addr = 8'd255; // Put a block at address 255 to collide with nothing
        test_grid_data = 8'b0000_0001;

        #FULL_CLK;
        test_grid_we = 1'b0;
        test_write_mem = 1'b0;
        reset = 1'b1;

        #FULL_CLK;
        reset = 1'b0;
        #FULL_CLK;
        #(260 * FULL_CLK); // Wait 130 clock cycles before input is added so that the piece is in the game area
        controller_in = BTN_RIGHT;
        #(100 *FULL_CLK); // Wait 35 clock cycles to push the button again
        controller_in = 4'b0;

        #2000;


	    $display("Done.");
	end
	
	always@(*)
	begin
		#HALF_CLK clock <= ~clock;
	end

    always @(test_write_mem, test_grid_addr, test_grid_data, test_grid_we, gc_addr_a, gc_grid_data, gc_we)
    begin
        if(test_write_mem == 1'b1)
        begin
            grid_addr_a = test_grid_addr;
            grid_data_in = test_grid_data;
            grid_we = test_grid_we;
        end
        else
        begin
            grid_addr_a = gc_addr_a;
            grid_data_in = gc_grid_data;
            grid_we = gc_we;
        end

    end
	
endmodule