`timescale 100ps/100ps

module Line_Clearer_tb;

	reg en;
	reg clk;
	reg rst;
	reg [7:0] mem_out;

	wire cleared;
	wire we;
	wire [7:0] addr;
	wire [7:0] mem_in;

  parameter FULL_CLK = 20;
  parameter HALF_CLK = 10;
   
  integer i;

	Line_Clearer uut(
    .en(en),
    .clk(clk),
    .rst(rst),
    .data_in(mem_out),
    .cleared(cleared),
    .we(we),
    .addr(addr),
    .data_out(mem_in)
	);

	initial
	begin
		en = 0;
		clk = 0;
		rst = 0;
		mem_out = 8'b0;

		#FULL_CLK;

		rst = 1'b1;
		#FULL_CLK;
		rst = 1'b0;
		#FULL_CLK;

		mem_out = 8'd1;
		en = 1'b1;
		//Step through Line Iterator - should tranistion to checker
		#FULL_CLK;	//Line Iterator should be in state 0
		#FULL_CLK;	//Line Iterator should be in state 1

		//Step through Line Checker
		#FULL_CLK;	//Line Checker should be in state 0
		#FULL_CLK;	//Line Checker should be in state 1
		#FULL_CLK;	//Line Checker should be in state 2
		#FULL_CLK;	//Line Checker should be in state 3
		#FULL_CLK;	//Line Checker should be in state 4
		#FULL_CLK;	//Line Checker should be in state 5
		#FULL_CLK;	//Line Checker should be in state 6
		#FULL_CLK;	//Line Checker should be in state 7
		#FULL_CLK;	//Line Checker should be in state 8
		#FULL_CLK;	//Line Checker should be in state 9
		#FULL_CLK;	//Line Checker should be in state 10
		#FULL_CLK;	//Line Checker should be in state 11

		#FULL_CLK;	//Line Shifter should be in state 0
		#FULL_CLK;	//Line Shifter should be in state 1
		#FULL_CLK;	//Line Shifter should be in state 2
	end

  always @(*)
  begin
  	#HALF_CLK
    clk <= ~clk;
  end

endmodule
