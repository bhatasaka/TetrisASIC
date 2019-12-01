`timescale 100ps/100ps

module Grid_Mem_Piece_Placer_tb;

	reg clk;
	reg en;
	reg grid_rst;
	reg lc_rst;
	reg [7:0] tb_addr;

	wire cleared;
	wire we;
	wire [7:0] lc_addr;
	wire [7:0] mem_in;
	wire [7:0] mem_out;
	wire [7:0] tb_out;

	reg mux_sel
	reg [7:0] data;
	reg [7:0] tb_data;

	parameter FULL_CLK = 20;
	parameter HALF_CLK = 10;

	integer i;

	Grid_Mem uut_grid (
		.data_a(data),
		.addr_a(lc_addr),
		.addr_b(tb_addr),
		.we_a(we),
		.reset(grid_rst),
		.clk(clk),
		.q_a(mem_out),
		.q_b(tb_out)
	);
    
	Line_Clearer uut(
    .en(en),
    .clk(clk),
    .rst(lc_rst),
    .data_in(mem_out),
    .cleared(cleared),
    .we(we),
    .addr(lc_addr),
    .data_out(mem_in)
	);

	initial
	begin
		clk = 1'b1;
		grid_rst = 1'b0;
		lc_rst = 1'b0;
		en = 1'b0;
		mux_sel = 1'b0;
		tb_addr = 8'b0;

		#FULL_CLK;

		grid_rst = 1'b1;
		lc_rst = 1'b1;

		#FULL_CLK;

		grid_rst = 1'b0;
		lc_rst = 1'b0;

		#FULL_CLK;

		for (i = 238; i > 228; i = i - 1)
		begin
			tb_addr = i;
			tb_data = 8'd6;
			#FULL_CLK;
		end

		for (i = 226; i > 216; i = i - 1)
		begin
			tb_addr = i;
			tb_data = 8'd0;
			#FULL_CLK;
		end

		for (i = 214; i > 204; i = i - 1)
		begin
			tb_addr = i;
			tb_data = 8'd1;
			#FULL_CLK;
		end

		tb_addr = 8'd224;
		tb_data = 8'd4;
		#FULL_CLK;

		tb_addr = 8'd220;
		tb_data = 8'd3;
		#FULL_CLK;
			
	end

	always @(mux_sel)
	begin
		if (mux_sel == 1'b0)
		begin
			data = tb_data;
		end
		else
		begin
			data = mem_in;
		end
	end

  always @(*)
  begin
  	#HALF_CLK
    clk <= ~clk;
  end
		/*
		$display("+-----------+\n|%d|%d|%d|\n|%d|%d|%d|\n|%d|%d|%d|\n|%d|%d|%d|\n+-----------+", 
				read_piece_from_mem[0], read_piece_from_mem[1], read_piece_from_mem[2], 
				read_piece_from_mem[3], read_piece_from_mem[4], read_piece_from_mem[5], 
				read_piece_from_mem[6], read_piece_from_mem[7], read_piece_from_mem[8], 
				read_piece_from_mem[9], read_piece_from_mem[10], read_piece_from_mem[11]
		);             

		$display("\n");
		*/

endmodule
