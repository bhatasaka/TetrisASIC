module Grid_Mem
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=8)
(
	input [(DATA_WIDTH-1):0] data_a,
	input [(ADDR_WIDTH-1):0] addr_a, addr_b,
	input we_a, clk, reset,
	output reg [(DATA_WIDTH-1):0] q_a, q_b
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];
	integer i;
	
	initial begin
	for(i = 0; i < 256; i = i+1)	//Just initialize all with zeros
		ram[i] = 8'b0;
	$readmemb("/home/hatasaka/TetrisASIC/grid_mem.txt", ram);
	end

	// Port A 
	always @ (posedge clk)
	begin
		if(reset)
		begin
			for(i = 0; i < 256; i = i+1)	//Just initialize all with zeros
				ram[i] <= 8'b0;
		end
		else
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
	end

	// Port B 
	always @ (posedge clk)
	begin
		if(reset == 1'b0)
		begin
			if(addr_b == addr_a && we_a)
				q_b <= data_a;
			else
				q_b <= ram[addr_b];
		end
	end

endmodule