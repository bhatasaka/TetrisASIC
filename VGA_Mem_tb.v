`timescale 1ns / 1ps

module VGA_Mem_tb;
	reg [15:0] addr_a;
	reg [15:0] addr_b;

	reg [7:0] data_a;
	reg we_a;
	
	reg clock;
	
	wire [7:0] out_a;
	wire [7:0] out_b;

	parameter FULL_CLK = 24;
	parameter HALF_CLK = 12;
	
	VGA_Mem grid_mem_test (
		.data_a(data_a),
		.addr_a(addr_a),
		.addr_b(addr_b),
		.we_a(we_a),
		.clk(clock),
		.q_a(out_a),
		.q_b(out_b)
	);
	
	integer i;

	initial begin
	
		data_a = 8'b0;
		addr_a = 8'b0;
		addr_b = 8'b0;
		we_a = 1'b0;
		clock = 1'b0;
	
	#FULL_CLK

	//1 - Write to A.
	$display("Writing only to A: ");
	data_a = 8'd200;
	addr_a = 8'b0000_0000;
	we_a = 1'b1;
	#FULL_CLK
	we_a = 1'b0;
	$display(out_a); //Should display 200.
	
	$display("Reading from B: ");
	addr_b = 8'b0;
	#FULL_CLK
	$display(out_b); //Should display 200
	
	//2 - Read from both
	$display("Read different addresses from both: ");
	addr_a = 8'd23;
	addr_b = 8'd24;
	data_a = 8'd37;
	
	#FULL_CLK
	$display(out_a);	// Should display 37
	$display(out_b);	// Should display 

	//3 - Write to A and read from both
	$display("Writing to A and reading the same addr from A and B: ");
	addr_a = 8'b0000_0001;
	addr_b = 8'b0000_0001;
	data_a = 8'd37;
	we_a = 1'b1;
	
	#FULL_CLK
	we_a = 1'b0;
	$display(out_a);	// Should display 37
	$display(out_b);	// Should display 

	//4 - Write and read every 8-bit number to A and B
	$display("Writing and reading every number up to 12-bits: ");
    for (i = 0; i < 2096; i = i+1)
    begin
		addr_a = i[7:0];
		addr_b = i[7:0];
		data_a = i[7:0];
		we_a = 1'b1;
		#FULL_CLK
		we_a = 1'b0;
		if(out_a != i[7:0])
			$display("Read from a EXPECTED: %d\tACTUAL: %d", i[7:0], out_a);
		if(out_b != i[7:0])
			$display("Read from b EXPECTED: %d\tACTUAL: %d", i[7:0], out_b);
		#FULL_CLK;
	end
	
	$display("Done.");
	end
	
	always@(*)
	begin
		#HALF_CLK clock <= ~clock;
	end
	
endmodule