module VGA_Mem
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=13)
(
	input [(DATA_WIDTH-1):0] data_a,
	input [(ADDR_WIDTH-1):0] addr_a,
	input we_a, clk,
	output reg [(DATA_WIDTH-1):0] q_a
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];
	integer i;
	
	// initial begin
	// for(i = 0; i < 65536; i = i+1)	//Just initialize all with zeros
	// 	ram[i] = 8'b0;
	// $readmemb("/home/hatasaka/TetrisASIC/VGA_data.txt", ram);
	// end


	// Port A 
	always @ (posedge clk)
	begin
		if (we_a) 
		begin
			ram[addr_a] <= data_a;
			q_a <= data_a;
		end
		else 
		begin
			q_a <= ram[addr_a];
		end
	end
endmodule