`timescale 1ns/1ns

module Tetris_tb;

	reg clk;
	reg rst;
	reg nes_in;
	wire [7:0] r;
	wire [7:0] g;
	wire [7:0] b;
	wire hs;
	wire vs;

  parameter FULL_CLK = 20;
  parameter HALF_CLK = 10;

  Tetris uut(
  	.clk(clk),
  	.hard_reset(rst),
  	.nes_in(nes_in),
  	.r_out(r),
  	.g_out(g),
  	.b_out(b),
  	.h_sync(hs),
  	.v_sync(vs)
  );

  initial
  begin
  	clk = 1'b0;
  	rst = 1'b0;
  	nes_in = 1'b0;

  	#FULL_CLK;

  	rst = 1'b1;

  	#FULL_CLK;

  	rst = 1'b0;

  	#FULL_CLK;
  end

    
  always @(*)
  begin
    #HALF_CLK
  	clk <= ~clk;
	end

endmodule
