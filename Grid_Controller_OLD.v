module Grid_Controller (
		
		input clock,
		input reset,
		input [3:0] controllerIn,
        input [7:0] tetrisGridIn,
        output reg [7:0] tetrisGridOut
);
	
	parameter [3:0] s0 = 4'b0000, s1 = 4'b0001, s2 = 4'b0010, s3 = 4'b0011, s4 = 4'b0100, 
						  s5 = 4'b0101, s6 = 4'b0110, s7 = 4'b0111, s8 = 4'b1000, s9 = 4'b1001,
						  s10 = 4'b1010, s11 = 4'b1011, s12 = 4'b1100, s13 = 4'b1101, SpecialState = 4'b1111;
	reg [3:0] state = s0;
		
	assign fsmState = state;


	// Define the next state combinational circuit
	always @(posedge clock)
	 begin
		if(reset == 1'b0)
		 begin
			state <= s0;
		 end
		else
		 begin
			case(state) 							
				s0: begin
						if(reset == 1'b0)
							state <= s0;
						else
							state <= s1;
					 end
				s1: begin
						if(reset == 1'b0)
						begin
							state <= s0;
						end
						else
							begin
								if (dataIn[15:12] == 4'b0001) //Load	
										state <= s3;
								else if(dataIn[15:12] == 4'b1111)	//Special instruction
								begin
										state <= SpecialState;
										i <= i + 1;
								end
								else if (dataIn[15:12] == 4'b0010) //Store 
										state <= s5;
								else if (dataIn[15:12] == 4'b0011) //Jump 
										state <= s7;
								else if (dataIn[15:12] == 4'b0100) //stop
										state <= s9;
								else if (dataIn[15:12] == 4'b1000) 
											//noOP  Just like pressing reset button, but in an instruction also, non used opcode as noOp
										state <= s0; 
								else if (dataIn[15:12] == 4'b1100) //jal
										state <= s12;
								else if(dataIn[15:12] == 4'b0000)
										state <= s2;	//Non-immediate R
								else                              
										state <= s10;      //Immediate R.
							end
					 end
			   SpecialState: state <= s6;
				s2: state <= s11;
				s3: state <= s4;
				s4: state <= s1;
				s5: state <= s6;
				s6: state <= s1;
				s7: state <= s8;
				s8: state <= s1;
				s9: state <= s9;
				s10: state <= s11;
				s11: state <= s1;
				s12: state <= s13;
				s13: state <= s1;
				default: state <= state;
			endcase
		 end
	 end
	
	always @(state)
	 begin
		case(state)
		
			SpecialState: begin

					end
			s0: begin // reset state

					end
			s1: begin // start/setup state


				 end
			s2: begin // move block down

				 end
			s3: begin // move block right

				 end
			s4: begin // move block left

				 end
			s5: begin // rotate block clockwise

				 end
			s6: begin // check for full row

				 end
			s7: begin // clear row(s)

				 end
			s8: begin // check for game over

				 end
	
			s9: begin // generate new block

				 end
			s10: begin 

				 end
			s11: begin

				 end
			s12: begin

				 end
			s13: begin 

				 end	
			default: begin 

				 end
		endcase
	 end
endmodule 