module CPU_FSM (
		
		input clock,
		input reset,
		input [15:0] dataIn,
		output reg Mux_Imm_Cntrl,
		output reg Mux_PC_Cntrl,
		output reg Mux_LD_Cntrl,
		output reg Mux_J_Cntrl,
		output reg Mux_RegEn_Cntrl,
		output reg Mux_Switches_Cntrl,
		output reg Flag_En,
		output reg PC_En,
		output reg regOn,	
		output reg [1:0] WR_En,
		output [3:0] fsmState,
		output reg [15:0] i
);
	
	parameter [3:0] s0 = 4'b0000, s1 = 4'b0001, s2 = 4'b0010, s3 = 4'b0011, s4 = 4'b0100, 
						  s5 = 4'b0101, s6 = 4'b0110, s7 = 4'b0111, s8 = 4'b1000, s9 = 4'b1001,
						  s10 = 4'b1010, s11 = 4'b1011, s12 = 4'b1100, s13 = 4'b1101, SpecialState = 4'b1111;
	reg [3:0] state = s0;
		
	assign fsmState = state;
	reg[3:0] dout1;
	
	
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
					Mux_Imm_Cntrl = 1'b0; 
					Mux_PC_Cntrl = 1'b0;
					Mux_LD_Cntrl = 1'b0;
					Mux_J_Cntrl = 1'b0;
					Flag_En = 1'b0;
					//PC_En = 1'b0;
					PC_En = 1'b1;
					WR_En = 2'b10; /// maybe next step?
					regOn = 1'b0;
					Mux_RegEn_Cntrl = 1'b0;
					Mux_Switches_Cntrl = 1'b0;
					end
			s0: begin // reset state
					Mux_Imm_Cntrl = 1'b0;
					Mux_PC_Cntrl = 1'b0;
					Mux_LD_Cntrl = 1'b0;
					Mux_J_Cntrl = 1'b0;
					Flag_En = 1'b0;
					PC_En = 1'b0;
					WR_En = 2'b00;
					regOn = 1'b0;
					Mux_RegEn_Cntrl = 1'b0;
					Mux_Switches_Cntrl = 1'b1;
					end
			s1: begin // initial state
					Mux_Imm_Cntrl = 1'b0;
					Mux_PC_Cntrl = 1'b1;
					Mux_LD_Cntrl = 1'b0;
					Mux_J_Cntrl = 1'b0;
					Flag_En = 1'b0;
					PC_En = 1'b0; // should this be 1?
					WR_En = 2'b00;
					regOn = 1'b0;
					Mux_RegEn_Cntrl = 1'b0;
					Mux_Switches_Cntrl = 1'b1;

				 end
			s2: begin // Rtype non immediate
					Mux_Imm_Cntrl = 1'b0;
					Mux_PC_Cntrl = 1'b1;
					Mux_LD_Cntrl = 1'b0;
					Mux_J_Cntrl = 1'b0;
					Flag_En = 1'b1;
					PC_En = 1'b1;
					WR_En = 2'b00;
					regOn = 1'b1;
					Mux_RegEn_Cntrl = 1'b0;
					Mux_Switches_Cntrl = 1'b1;
				 end	
			s10: begin // Rtype immediate
					Mux_Imm_Cntrl = 1'b1;
					Mux_PC_Cntrl = 1'b1;
					Mux_LD_Cntrl = 1'b0;
					Mux_J_Cntrl = 1'b0;
					Flag_En = 1'b1;
					PC_En = 1'b1;
					//PC_En = 1'b0;
					WR_En = 2'b00;
					regOn = 1'b1;
					Mux_RegEn_Cntrl = 1'b0;
					Mux_Switches_Cntrl = 1'b1;
				 end	
			s11: begin // Rtype immediate
					Mux_Imm_Cntrl = 1'b0;
					Mux_PC_Cntrl = 1'b1;
					Mux_LD_Cntrl = 1'b0;
					Mux_J_Cntrl = 1'b0;
					Flag_En = 1'b0;
					//PC_En = 1'b1;
					PC_En = 1'b0;
					WR_En = 2'b00;
					regOn = 1'b0;
					Mux_RegEn_Cntrl = 1'b0;
					Mux_Switches_Cntrl = 1'b1;
				 end		 	 
			s3: begin //Load
					Mux_Imm_Cntrl = 1'b0; //don't care
					Mux_PC_Cntrl = 1'b0;
					Mux_LD_Cntrl = 1'b1;
					Mux_J_Cntrl = 1'b0;
					Flag_En = 1'b0;
					//PC_En = 1'b0;
					PC_En = 1'b1;
					WR_En = 2'b00;
					regOn = 1'b0;
					Mux_RegEn_Cntrl = 1'b0;
					Mux_Switches_Cntrl = 1'b1;
				 end		
			s4: begin // Load
					Mux_Imm_Cntrl = 1'b0; //don't care
					Mux_PC_Cntrl = 1'b1;
					Mux_LD_Cntrl = 1'b1;
					Mux_J_Cntrl = 1'b0;
					Flag_En = 1'b0;
					PC_En = 1'b0;
					//PC_En = 1'b1;
					WR_En = 2'b00;
					regOn = 1'b1;
					Mux_RegEn_Cntrl = 1'b1;
					Mux_Switches_Cntrl = 1'b1;
				 end	
			s5: begin // store 
					Mux_Imm_Cntrl = 1'b0; 
					Mux_PC_Cntrl = 1'b0;
					Mux_LD_Cntrl = 1'b0;
					Mux_J_Cntrl = 1'b0;
					Flag_En = 1'b0;
					//PC_En = 1'b0;
					PC_En = 1'b1;
					WR_En = 2'b10; /// maybe next step?
					regOn = 1'b0;
					Mux_RegEn_Cntrl = 1'b0;
					Mux_Switches_Cntrl = 1'b1;
				 end	
			s6: begin //store
					Mux_Imm_Cntrl = 1'b0; 
					Mux_PC_Cntrl = 1'b1;
					Mux_LD_Cntrl = 1'b0;
					Mux_J_Cntrl = 1'b0;
					Flag_En = 1'b0;
					//PC_En = 1'b1;
					PC_En = 1'b0;
					WR_En = 2'b00;
					regOn = 1'b0;
					Mux_RegEn_Cntrl = 1'b0;
					Mux_Switches_Cntrl = 1'b1;
				 end	
	
			s7: begin //jump
					Mux_Imm_Cntrl = 1'b0; //don't care
					Mux_PC_Cntrl = 1'b1;
					Mux_LD_Cntrl = 1'b0;
					Mux_J_Cntrl = 1'b1;
					Flag_En = 1'b0;
					PC_En = 1'b1; 
					WR_En = 2'b00;
					regOn = 1'b0;
					Mux_RegEn_Cntrl = 1'b0;
					Mux_Switches_Cntrl = 1'b1;
				 end	
			s8: begin //jump
					Mux_Imm_Cntrl = 1'b0; //don't care
					Mux_PC_Cntrl = 1'b1;
					Mux_LD_Cntrl = 1'b0;
					Mux_J_Cntrl = 1'b0; 
					Flag_En = 1'b0;
					PC_En = 1'b0;
					WR_En = 2'b00;
					regOn = 1'b0;
					Mux_RegEn_Cntrl = 1'b0;
					Mux_Switches_Cntrl = 1'b1;
				 end	
			s12: begin //jal - store pc in r15
					Mux_Imm_Cntrl = 1'b0; 
					Mux_PC_Cntrl = 1'b1;
					Mux_LD_Cntrl = 1'b0;
					Mux_J_Cntrl = 1'b1;
					Flag_En = 1'b0;
					PC_En = 1'b1; 
					WR_En = 2'b00;
					regOn = 1'b1;
					Mux_RegEn_Cntrl = 1'b0;
					Mux_Switches_Cntrl = 1'b1;
				 end	
			s13: begin //jal
					Mux_Imm_Cntrl = 1'b0;
					Mux_PC_Cntrl = 1'b1; 
					Mux_LD_Cntrl = 1'b0; 
					Mux_J_Cntrl = 1'b0;
					Flag_En = 1'b0;
					PC_En = 1'b0;
					WR_En = 2'b00;
					regOn = 1'b0;
					Mux_RegEn_Cntrl = 1'b0;
					Mux_Switches_Cntrl = 1'b1;
				 end	
			s9: begin //stop
					Mux_Imm_Cntrl = 1'b0; //don't care
					Mux_PC_Cntrl = 1'b1;
					Mux_LD_Cntrl = 1'b0;
					Mux_J_Cntrl = 1'b0;
					Flag_En = 1'b0;
					PC_En = 1'b0;
					WR_En = 2'b00;
					regOn = 1'b0;
					Mux_RegEn_Cntrl = 1'b0;
					Mux_Switches_Cntrl = 1'b1;
				 end	
			default: begin 
					Mux_Imm_Cntrl = 1'b0; //don't care
					Mux_PC_Cntrl = 1'b0;
					Mux_LD_Cntrl = 1'b0;
					Mux_J_Cntrl = 1'b0;
					Flag_En = 1'b0;
					PC_En = 1'b0;
					WR_En = 2'b00;
					regOn = 1'b0;
					Mux_RegEn_Cntrl = 1'b0;
					Mux_Switches_Cntrl = 1'b1;
				 end
		endcase
	 end
endmodule 