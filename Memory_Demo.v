/*

Initialization values for addresses 0, 1, 2, 510, 511, 512, 513
come from the initialization.txt file, through readmemb.

	FSM States:
		0: Read the value 1 stored at address 0.
		1: Read the value 2 stored at address 1.
		2: Read the value 3 stored at address 2.
		3: Read the value 4 stored at address 510. 
		4: Read the value 5 stored at address 511.
		5: Read the value 6 stored at address 512.
		6: Read the value 7 stored at address 513.
		
		7: Add 15 to each of the above values.
		[repeat with new values]
 		
 */

module Memory_Demo (
		input clock,
		input continue,
		output reg [6:0] one,
		output reg [6:0] two,
		output reg [6:0] three,
		output reg [6:0] four
	);

	wire [15:0] out_a;
	wire [15:0] out_b;
	
	reg [15:0] display;
	
	reg [15:0] data_a;
	reg [15:0] data_b;
	reg [9:0] addr_a;
	reg [9:0] addr_b;
	reg we_a;
	reg we_b;
	
	reg [15:0] i = 0;
		
	wire [6:0] first, second, third, fourth;
	
	DualPortMemory mem (
		.data_a(data_a),
		.data_b(data_b),	
		.addr_a(addr_a),
		.addr_b(addr_b),
		.we_a(we_a),
		.we_b(we_b),
		.clk(clock),
		.q_a(out_a),
		.q_b(out_b)
	);
	
parameter [3:0] s0 = 4'b0000, s1 = 4'b0001, s2 = 4'b0010, s3 = 4'b0011, s4 = 4'b0100,
	s5 = 4'b0101, s6 = 4'b0110, s7 = 4'b0111, s8 = 4'b1000;
	
	reg [3:0] state = s0;
	
	// Define the next state combinational circuit
	always @(posedge continue)
		 begin
			case(state)
				s0: state <= s1;
				s1: state <= s2;
				s2: state <= s3;
				s3: state <= s4;
				s4: state <= s5;
				s5: state <= s6;
				s6: state <= s7;
				s7: state <= s8;
				s8: state <= s0;
				default: state <= state;
			endcase
		 
	 end

	always @(state)
	 begin
		case(state)
			//Read initial states.
			s0: begin 
					we_a = 1'b0;
					addr_a = 10'b 00_0000_0000; //Address 0
					display = out_a;
				 end  
			s1: begin 
					addr_a = 10'b 00_0000_0001; //Address 1
					display = out_a;

				 end			
			s2: begin 
 					addr_a = 10'b 00_0000_0010; //Address 2
					display = out_a;

				 end		
			s3: begin  
					addr_a = 10'b 01_1111_1110; //Address 510
					display = out_a;
				 end	
			s4: begin  
					addr_a = 10'b 01_1111_1111; //Address 511
					display = out_a;
				 end	
			s5: begin  
					addr_a = 10'b 10_0000_0000; //Address 512
					display = out_a;
				 end		
			s6: begin  
					addr_a = 10'b 10_0000_0001;	//Address 513
					display = out_a;
				 end	
			s7:
				//Split into two states, then should work!
				 begin
					display = 0;
				 	addr_a = 10'b 00_0000_0000; //Address 0
					i = out_a;
				 end
			s8:
				begin
					data_a = i + 1'b1;
				 	we_a = 1'b1;
				end
		

		endcase
end

always@(display) 
begin
	
	one = first;
	two = second;
	three = third;
	four = fourth;

end

	
hexTo7Seg firstDisplay(
		.hex_input(display[15:12]),
		.seven_seg_out(first)
	);
	
hexTo7Seg secondDisplay(
		.hex_input(display[11:8]),
		.seven_seg_out(second)
	);
	
hexTo7Seg thirdDisplay(
		.hex_input(display[7:4]),
		.seven_seg_out(third)
	);
	
hexTo7Seg fourthDisplay(
		.hex_input(display[3:0]),
		.seven_seg_out(fourth)
	);	

endmodule 