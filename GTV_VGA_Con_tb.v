`timescale 1ns / 1ps

module GTV_VGA_Conn_tb;
	reg clock, reset, grid_we, clock25;
	reg[7:0] grid_addr_a, grid_data_in;
	reg[15:0] vga_addr_b;
    wire px_en, v_sync, h_sync;
	wire [7:0] vga_out_a, grid_out_a, grid_addr_b, pixel_rgb;
	wire [7:0] vga_out_b, grid_out_b;
	wire [7:0] r_out, g_out, b_out;
    wire [15:0] vga_addr_a;
	// reg [7:0] data_a;
	// reg [15:0] addr_a;

	parameter FULL_CLK = 20;
	parameter HALF_CLK = 10;
	
	integer i = 0;
	integer dumpfile;

	VGA_Mem vga_mem_test (
		.data_a(8'b0),
		.addr_a(vga_addr_a),
		.addr_b(vga_addr_b),
		.we_a(1'b0),
		.clk(clock),
		.q_a(vga_out_a),
		.q_b(vga_out_b)
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

    Grid_To_Video grid_video_test (
        .clk(clock),
        .px_en(px_en),
        .reset(reset),
        .vga_data(vga_out_a),
        .grid_data(grid_out_b),
        .pixel_rgb(pixel_rgb),
        .grid_addr(grid_addr_b),
        .vga_addr(vga_addr_a)
    );

    VGA_Controller vga_test (
        .clk(clock),
		.rst(reset),
        .rgb_8(pixel_rgb),
        .r_out(r_out),
        .g_out(g_out),
        .b_out(b_out),
        .h_sync(v_sync),
        .v_sync(h_sync),
        .pixel_en(px_en)
    );

	initial begin
	
        // px_en = 1'b0;
        clock = 1'b0;
		clock25 = 1'b0;
        reset = 1'b1;
		grid_we = 1'b0;
		grid_data_in = 8'b0;
		grid_addr_a = 8'b0;
		vga_addr_b = 16'b0;
		i = 0;
		dumpfile = $fopen("/home/hatasaka/TetrisASIC/vga_dump.csv", "w");

	    #FULL_CLK

        reset = 1'b0;
        // Going to assume that the grid memory is loaded with some data right now
		// from a file (check Grid_Mem.v for the readmemb statement)

		
	    $display("Done.");
	end
	
	always@(posedge clock25)
	begin
		if(px_en == 1'b1)
		begin
			$fwrite(dumpfile, "%d,", pixel_rgb);
			if(i % 11 == 0)
			begin
				$fwrite(dumpfile, "\n");
				i = 0;
			end
			else
				i = i+1;
		end
	end

	always@(*)
	begin
		#HALF_CLK clock <= ~clock;
	end
	always@(*)
	begin
		#FULL_CLK clock25 <= ~clock25;
	end
	
endmodule