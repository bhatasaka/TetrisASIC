`timescale 100ps/100ps

module Grid_Mem_Line_Clearer_tb;

	reg clk;
	reg en;
	reg grid_rst;
	reg lc_rst;

	wire cleared;
	wire lc_we;
	wire [7:0] lc_addr;
	wire [7:0] lc_data;
	wire [7:0] data_out;
	wire [7:0] dummy_out;

	reg mux_sel;
	reg we;
	reg tb_we;
	reg [7:0] data;
	reg [7:0] addr;
	reg [7:0] tb_data;
	reg [7:0] tb_addr;
	reg [7:0] dummy_addr;

	parameter FULL_CLK = 20;
	parameter HALF_CLK = 10;
	parameter MAX_ADDR = 239;

	integer i, dumpfile, fulldump;

	Grid_Mem uut_grid (
		.data_a(data),
		.addr_a(addr),
		.addr_b(dummy_addr),
		.we_a(we),
		.reset(grid_rst),
		.clk(clk),
		.q_a(data_out),
		.q_b(dummy_out)
	);
    
	Line_Clearer uut_lc(
    .en(en),
    .clk(clk),
    .rst(lc_rst),
    .data_in(data_out),
    .cleared(cleared),
    .we(lc_we),
    .addr(lc_addr),
    .data_out(lc_data)
	);

	initial
	begin
		dumpfile = $fopen("/home/eastland/ece6710/prjkt/TetrisASIC/dump_file.hex", "w");
		fulldump = $fopen("/home/eastland/ece6710/prjkt/TetrisASIC/full_dump.hex", "w");

		clk = 1'b0;
		grid_rst = 1'b0;
		lc_rst = 1'b0;
		en = 1'b0;
		mux_sel = 1'b0;
		tb_addr = 8'b0;
		tb_data = 8'b0;
		we = 1'b0;
		tb_we = 1'b0;

		#FULL_CLK;

		grid_rst = 1'b1;
		lc_rst = 1'b1;

		#FULL_CLK;

		grid_rst = 1'b0;
		lc_rst = 1'b0;

		#FULL_CLK;

		tb_we = 1'b1;

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
			tb_data = i - 204;
			#FULL_CLK;
		end

		tb_addr = 8'd224;
		tb_data = 8'd4;
		#FULL_CLK;

		tb_addr = 8'd220;
		tb_data = 8'd3;
		#FULL_CLK;

		tb_we = 1'b0;
		#FULL_CLK;

		//dump ram to file
		$fwrite(dumpfile, "Init Mem for Line Clear Test: Basic\n");

		for (i = 0; i < 240; i = i + 1)
		begin
			tb_addr = i[7:0];
			case(i)
				11, 23, 35, 47, 59, 71, 83, 95, 107, 119, 131, 143, 155, 167, 179, 191, 203, 215, 227, 239:
				begin
					$fwrite(dumpfile, "%h\n", uut_grid.ram[i]);
				end
				default:
				begin
					$fwrite(dumpfile, "%h\t", uut_grid.ram[i]);
				end
			endcase
		end

		$fwrite(dumpfile, "\n\n");

		#FULL_CLK;
		mux_sel = 1'b1;
		en = 1'b1;
		
		//Wait enough time for the grid to clear
		#50000;

		en = 1'b0;
		mux_sel = 1'b0;
		#FULL_CLK;

		//dump ram to file
		$fwrite(dumpfile, "Mem After Line Clear Test: Basic\n");

		for (i = 0; i < 240; i = i + 1)
		begin
			tb_addr = i[7:0];
			case(i)
				11, 23, 35, 47, 59, 71, 83, 95, 107, 119, 131, 143, 155, 167, 179, 191, 203, 215, 227, 239:
				begin
					$fwrite(dumpfile, "%h\n", uut_grid.ram[i]);
				end
				default:
				begin
					$fwrite(dumpfile, "%h\t", uut_grid.ram[i]);
				end
			endcase
		end

		$fwrite(dumpfile, "\n\n");

		tb_we = 1'b1;

		for (i = 0; i < MAX_ADDR; i = i + 1)
		begin
			tb_addr = i;

			case (i)
				0, 12, 24, 36, 48, 60, 72, 84, 96, 108, 120, 132, 144, 156, 168, 180, 192, 204, 216, 228, 11, 23, 35, 47, 59, 71, 83, 95, 107, 119, 131, 143, 155, 167, 179, 191, 203, 215, 227, 239:
					tb_data = 8'd8;
				97, 114, 27, 69, 202, 190:
					tb_data = 8'd0;
				default:
					tb_data = 8'd6;
			endcase

			#FULL_CLK;
		end
		
		tb_we = 1'b0;

		dumpfile = $fopen("/home/eastland/ece6710/prjkt/TetrisASIC/dump_file_2.hex", "w");

		//dump ram to file
		$fwrite(dumpfile, "Init Mem for Line Clear Test: 97 percent Full\n");

		for (i = 0; i < 240; i = i + 1)
		begin
			tb_addr = i[7:0];
			case(i)
				11, 23, 35, 47, 59, 71, 83, 95, 107, 119, 131, 143, 155, 167, 179, 191, 203, 215, 227, 239:
				begin
					$fwrite(dumpfile, "%h\n", uut_grid.ram[i]);
				end
				default:
				begin
					$fwrite(dumpfile, "%h\t", uut_grid.ram[i]);
				end
			endcase
		end

		$fwrite(dumpfile, "\n\n");

		#FULL_CLK;
		mux_sel = 1'b1;
		en = 1'b1;
		
		//Wait enough time for the grid to clear
		#500000;

		en = 1'b0;
		mux_sel = 1'b0;
		#FULL_CLK;

		//dump ram to file
		$fwrite(dumpfile, "Mem After Line Clear Test: 97 Percent Full\n");

		for (i = 0; i < 240; i = i + 1)
		begin
			tb_addr = i[7:0];
			case(i)
				11, 23, 35, 47, 59, 71, 83, 95, 107, 119, 131, 143, 155, 167, 179, 191, 203, 215, 227, 239:
				begin
					$fwrite(dumpfile, "%h\n", uut_grid.ram[i]);
				end
				default:
				begin
					$fwrite(dumpfile, "%h\t", uut_grid.ram[i]);
				end
			endcase
		end

		$fwrite(dumpfile, "\n\n");

		#FULL_CLK;

	end

	always @(posedge uut_lc.advance_line)
	begin
		//dump ram to file
		$fwrite(fulldump, "Mem After Line Clear\n");

		for (i = 0; i < 240; i = i + 1)
		begin
			tb_addr = i[7:0];
			case(i)
				11, 23, 35, 47, 59, 71, 83, 95, 107, 119, 131, 143, 155, 167, 179, 191, 203, 215, 227, 239:
				begin
					$fwrite(fulldump, "%h\n", uut_grid.ram[i]);
				end
				default:
				begin
					$fwrite(fulldump, "%h\t", uut_grid.ram[i]);
				end
			endcase
		end

		$fwrite(fulldump, "\n\n");
	end

	always @(*)
	begin
		if (mux_sel == 1'b0)
		begin
			addr = tb_addr;
			data = tb_data;
			we = tb_we;
		end
		else
		begin
			addr = lc_addr;
			data = lc_data;
			we = lc_we;
		end
	end

  always @(*)
  begin
  	#HALF_CLK
    clk <= ~clk;
  end

endmodule
