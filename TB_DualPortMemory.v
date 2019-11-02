`timescale 1ns / 1ps

module dualPortMemoryTest;

	reg [15:0] data_a;
	reg [15:0] data_b;

	reg [9:0] addr_a;
	reg [9:0] addr_b;

	reg we_a;
	reg we_b;
	
	reg clock;
	
	wire [15:0] out_a;
	wire [15:0] out_b;
	
	DualPortMemory uut (
		.data_a(data_a),
		.data_b(data_b),	
		.address_a(addr_a),
		.address_b(addr_b),
		.wren_a(we_a),
		.wren_b(we_b),
		.clock(clock),
		.q_a(out_a),
		.q_b(out_b)
	);
	
	initial begin
	
		data_a = 0;
		data_b = 0;
		addr_a = 0;
		addr_b = 0;
		we_a = 0;
		we_b = 0;
		clock = 0;
	
	#20
	
	//1 - Write to A.
	data_a = 16'b0000_0000_0000_1111;
	addr_a = 10'b 00_0000_0000;
	we_a = 1'b1;
	
	#20
	
	$display("Writing only to A: ");
	$display(out_a); //Should display 15.
	
	//2 - Write to B
	we_a = 1'b0;
	data_b = 16'b0000_0000_0000_0111;
	addr_b = 10'b 00_0000_0001;
	
	we_b = 1'b1;
	
	#20
	
	$display("Writing only to B: ");
	$display(out_b); //Should display 7.

	//3 - Write to A and B separately.
	we_a = 1'b0;
	we_b = 1'b0;
	
	addr_a = 16'b 0000_0000_0000_0010;
	addr_b = 16'b 0000_0000_0000_0011;
	
	data_a = 10'b 00_0000_0101;
	data_b = 10'b 00_0000_0110;
	
	we_a = 1'b1;
	we_b = 1'b1;
	
	#20
	
	$display("Writing to A and B separately: ");
	$display(out_a);	//Display 5
	$display(out_b);	//Display 6
	
	//4 - Write to A and B, same address, show data_a is written.
	we_a = 1'b0;
	we_b = 1'b0;
	
	addr_a = 16'b 0000_0000_0000_0100;
	addr_b = 16'b 0000_0000_0000_0100;
	
	data_a = 10'b 00_0000_1000;
	data_b = 10'b 00_0000_1001;
	
	we_a = 1'b1;
	we_b = 1'b1;
	
	#20
	
	$display("Writing to A and B at same address: ");
	$display(out_a);	//Display 8
	$display(out_b);	//Display 8
	
	#300 $finish;
	
	end
	
	
	//----------------------OLD
	
	/*#20
	
	
	data = 16'b0000_0000_0000_0000;
	writeAddress = 10'b0000_0000_00;
	readAddress = 10'b0000_0000_00;
	writeEnable = 0;
	
	#10
	
	//Write 1 to the first memory address.
	data = 16'b0000_0000_0001_0000;
	writeAddress = 10'b0000_0000_01;
	readAddress = 10'b0000_0000_01;
	writeEnable = 1'b1;

	
	#10
	
	
	$display(out_a);
	
	data = 16'b0000_0000_0000_0010;
	writeAddress = 10'b0000_0001_00;
	readAddress = 10'b0000_0001_00;
	writeEnable = 1'b1;

	
	#10
	
	$display(out_a);
	
	end */
	
	always@(*)
	begin
		#1 clock <= ~clock;
	end 
	
	endmodule