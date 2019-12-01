`timescale 100ps/100ps

module Grid_Mem_Piece_Placer_tb;

	reg clk;
	reg en;
	reg grid_rst;
	reg placer_rst;
	reg [7:0] read_addr;
	reg [7:0] read_piece_from_mem [11:0];

	wire we;
	wire placed;
	wire [7:0] write_addr;
	wire [7:0] data;
	wire [7:0] out_a;
	wire [7:0] out_b;
	wire [7:0] reg_1;
	wire [7:0] reg_2;
	wire [7:0] reg_3;
	wire [7:0] reg_4;

	integer i, j, k;

	wire lf;
	reg[3:0] tb_lfsr;

	parameter FULL_CLK = 20;
	parameter HALF_CLK = 10;
	parameter PIECE_BASE_ADDR = 240;
	parameter PIECE_MAX_ADDR = 251;

	Grid_Mem uut_grid (
		.data_a(data),
		.addr_a(write_addr),
		.addr_b(read_addr),
		.we_a(we),
		.reset(grid_rst),
		.clk(clk),
		.q_a(out_a),
		.q_b(out_b)
	);
    
	Piece_Placer uut(
		.en(en),
    .clk(clk),
    .rst(placer_rst),
    .placed(placed),
    .we(we),
    .addr(write_addr),
    .data(data),
    .reg_1_addr(reg_1),
    .reg_2_addr(reg_2),
    .reg_3_addr(reg_3),
    .reg_4_addr(reg_4)
	);

	initial
	begin
		i = 0;
		j = 0;
		k = 0;
		clk = 0;
		en = 0;
		grid_rst = 0;
		placer_rst = 0;
		read_addr = 8'b0;
		tb_lfsr = 4'b0001;

		#FULL_CLK;

		grid_rst = 1'b1;
		placer_rst = 1'b1;

		#FULL_CLK;

		grid_rst = 1'b0;
		placer_rst = 1'b0;

		#FULL_CLK;

		en = 1'b1;

		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK; //14 clk cycles

		en = 1'b0;

		#FULL_CLK;

		placer_rst = 1'b1;

		#FULL_CLK;

		placer_rst = 1'b0;
		
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;
		#FULL_CLK;


		for (j = 12; j < 100; j = j + 1)
		begin
			en = 1'b1;
			
			for (k = 0; k < 14; k = k + 1)
			begin
				#FULL_CLK;
			end

			en = 1'b0;

			#FULL_CLK;

			placer_rst = 1'b1;

			#FULL_CLK;

			placer_rst = 1'b0;
			
			for (k = {24'b0, tb_lfsr}; k < 30; k = k + 1)
			begin
				#FULL_CLK;
				#FULL_CLK;
				#FULL_CLK;
			end
		end
	end


	always @(posedge placed)
	begin
		//Piece min bound 232
		//Piece max bound 243 (12 total blocks)
		//Go one past piece max (mem max is 255, 244+ unused)
		//To ensure we aren't writing there.
		#FULL_CLK;
		for (i = PIECE_BASE_ADDR; i <= PIECE_MAX_ADDR; i = i + 1)
		begin
			read_addr = i[7:0];
			#FULL_CLK;
			read_piece_from_mem[i - PIECE_BASE_ADDR] = out_b;
			
		//	$display("Piece Mem @[%d]: [%d]", i, out_b);
		end

		$display("+-----------+\n|%d|%d|%d|\n|%d|%d|%d|\n|%d|%d|%d|\n|%d|%d|%d|\n+-----------+", 
				read_piece_from_mem[0], read_piece_from_mem[1], read_piece_from_mem[2], 
				read_piece_from_mem[3], read_piece_from_mem[4], read_piece_from_mem[5], 
				read_piece_from_mem[6], read_piece_from_mem[7], read_piece_from_mem[8], 
				read_piece_from_mem[9], read_piece_from_mem[10], read_piece_from_mem[11]
		);             

		$display("\n");
	end
	
	assign lf = (tb_lfsr[3] ^ tb_lfsr[2] ^ tb_lfsr[0]);

	always @(posedge placed)
	begin
		tb_lfsr <= {lf, tb_lfsr[3], tb_lfsr[2], tb_lfsr[1]};
	end

	always @(*)
	begin
		#HALF_CLK
		clk <= ~clk;
	end

endmodule
