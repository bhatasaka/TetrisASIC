module Piece_Placer(
    input en,
    input clk,
    input rst,
    output reg placed,
    output reg we,
    output reg [7:0] addr,
    output reg [7:0] data,
    output reg [7:0] reg_1_addr,
    output reg [7:0] reg_2_addr,
    output reg [7:0] reg_3_addr,
    output reg [7:0] reg_4_addr
);

parameter NEXT_PIECE_BASE_ADDR = 8'd240;
parameter [2:0] I = 3'd0, O = 3'd1, T = 3'd2, S = 3'd3, Z = 3'd4, J = 3'd5, L = 3'd6;

reg [7:0] block[11:0];
reg [3:0] lfsr;
reg [3:0] box_number;
reg piece_gen;

wire lf;

integer i;

// initial
// begin
// 	for (i = 0; i < 12; i = i + 1)
// 	begin
// 		block[i] = 4'b0;
// 	end
// 	lfsr = 3'b1;
// 	box_number = 4'b0;
// 	piece_gen = 1'b0;
// end

//LFSR Polynomial
assign lf = (lfsr[3] ^ lfsr[2] ^ lfsr[0]);

//LFSR, generates random number once module is disabled
//We never reset this reg to make piece generation appear
//more random (it will always be power on state or last piece
//state (potentially from previous game)
always @(posedge clk)
begin
	lfsr <= {lf, lfsr[3], lfsr[2], lfsr[1]};
end

//Write random block into local memory and indicate
//the corresponding grid memory addresses it will
//be found in once the piece is "placed"
always @(posedge clk)
begin
		if (~en || rst)
		begin
			reg_1_addr <= 8'b0;
			reg_2_addr <= 8'b0;
			reg_3_addr <= 8'b0;
			reg_4_addr <= 8'b0;
			piece_gen <= 1'b0;
		end
		else if (en && ~piece_gen)
		begin
			case (lfsr[2:0])
   	 	    I:
   	 	    begin
   	 	       block[0]  <= I + 1; 
   	 	       block[3]  <= I + 1; 
   	 	       block[6]  <= I + 1; 
   	 	       block[9]  <= I + 1; 
   	 	       reg_1_addr <= NEXT_PIECE_BASE_ADDR + 0;
   	 	       reg_2_addr <= NEXT_PIECE_BASE_ADDR + 3;
   	 	       reg_3_addr <= NEXT_PIECE_BASE_ADDR + 6;
   	 	       reg_4_addr <= NEXT_PIECE_BASE_ADDR + 9;
   	 	       piece_gen <= 1'b1;
   	 	    end
   	 	    O:
   	 	    begin
   	 	       block[6]  <= O + 1; 
   	 	       block[7]  <= O + 1; 
   	 	       block[9]  <= O + 1; 
   	 	       block[10] <= O + 1; 
   	 	       reg_1_addr <= NEXT_PIECE_BASE_ADDR + 6;
   	 	       reg_2_addr <= NEXT_PIECE_BASE_ADDR + 7;
   	 	       reg_3_addr <= NEXT_PIECE_BASE_ADDR + 9;
   	 	       reg_4_addr <= NEXT_PIECE_BASE_ADDR + 10;
   	 	       piece_gen <= 1'b1;
   	 	    end
   	 	    T:
   	 	    begin
   	 	       block[4]  <= T + 1; 
   	 	       block[6]  <= T + 1; 
   	 	       block[7]  <= T + 1; 
   	 	       block[10] <= T + 1; 
   	 	       reg_1_addr <= NEXT_PIECE_BASE_ADDR + 4;
   	 	       reg_2_addr <= NEXT_PIECE_BASE_ADDR + 6;
   	 	       reg_3_addr <= NEXT_PIECE_BASE_ADDR + 7;
   	 	       reg_4_addr <= NEXT_PIECE_BASE_ADDR + 10;
   	 	       piece_gen <= 1'b1;
   	 	    end
   	 	    S:
   	 	    begin
   	 	       block[7]  <= S + 1; 
   	 	       block[8]  <= S + 1; 
   	 	       block[9]  <= S + 1; 
   	 	       block[10] <= S + 1; 
   	 	       reg_1_addr <= NEXT_PIECE_BASE_ADDR + 7;
   	 	       reg_2_addr <= NEXT_PIECE_BASE_ADDR + 8;
   	 	       reg_3_addr <= NEXT_PIECE_BASE_ADDR + 9;
   	 	       reg_4_addr <= NEXT_PIECE_BASE_ADDR + 10;
   	 	       piece_gen <= 1'b1;
   	 	    end
   	 	    Z:
   	 	    begin
   	 	       block[6]  <= Z + 1; 
   	 	       block[7]  <= Z + 1; 
   	 	       block[10] <= Z + 1; 
   	 	       block[11] <= Z + 1; 
   	 	       reg_1_addr <= NEXT_PIECE_BASE_ADDR + 6;
   	 	       reg_2_addr <= NEXT_PIECE_BASE_ADDR + 7;
   	 	       reg_3_addr <= NEXT_PIECE_BASE_ADDR + 10;
   	 	       reg_4_addr <= NEXT_PIECE_BASE_ADDR + 11;
   	 	       piece_gen <= 1'b1;
   	 	    end
   	 	    J:
   	 	    begin
   	 	       block[4]  <= J + 1; 
   	 	       block[7]  <= J + 1; 
   	 	       block[9]  <= J + 1; 
   	 	       block[10] <= J + 1; 
   	 	       reg_1_addr <= NEXT_PIECE_BASE_ADDR + 4;
   	 	       reg_2_addr <= NEXT_PIECE_BASE_ADDR + 7;
   	 	       reg_3_addr <= NEXT_PIECE_BASE_ADDR + 9;
   	 	       reg_4_addr <= NEXT_PIECE_BASE_ADDR + 10;
   	 	       piece_gen <= 1'b1;
   	 	    end
   	 	    L:
   	 	    begin
   	 	       block[3]  <= L + 1; 
   	 	       block[6]  <= L + 1; 
   	 	       block[9]  <= L + 1; 
   	 	       block[10] <= L + 1; 
   	 	       reg_1_addr <= NEXT_PIECE_BASE_ADDR + 3;
   	 	       reg_2_addr <= NEXT_PIECE_BASE_ADDR + 6;
   	 	       reg_3_addr <= NEXT_PIECE_BASE_ADDR + 9;
   	 	       reg_4_addr <= NEXT_PIECE_BASE_ADDR + 10;
   	 	       piece_gen <= 1'b1;
   	 	    end
   	 	    default:    //THIS JUST PLACES AN AIR BLOCK
   	 	    begin
   	 	       piece_gen <= 1'b0;
   	 	    end
			endcase
		end
		else
			piece_gen <= 1'b1;
end

//Write the generated piece from local storage into 
//next piece grid memory storage.
always @(posedge clk)
begin
    if (rst)
    begin
        box_number <= 4'b0;

        for (i = 0; i < 12; i = i + 1)
        begin
            block[i] = 4'b0;
        end
    		
    		placed <= 1'b0;
    		we <= 1'b0;
    		addr <= 8'b0;
    		data <= 8'b0;
    end
    else
    begin
        if (en && piece_gen)
        begin
            addr <= (NEXT_PIECE_BASE_ADDR + box_number);

            case (box_number)
                0:
                begin
                    we <= 1'b1;
                    data <= block[0];
                    box_number <= box_number + 1;
                    placed <= 1'b0;
                end
                1:
                begin
                    we <= 1'b1;
                    data <= block[1];
                    box_number <= box_number + 1;
                    placed <= 1'b0;
                end
                2:
                begin
                    we <= 1'b1;
                    data <= block[2];
                    box_number <= box_number + 1;
                    placed <= 1'b0;
                end
                3:
                begin
                    we <= 1'b1;
                    data <= block[3];
                    box_number <= box_number + 1;
                    placed <= 1'b0;
                end
                4:
                begin
                    we <= 1'b1;
                    data <= block[4];
                    box_number <= box_number + 1;
                    placed <= 1'b0;
                end
                5:
                begin
                    we <= 1'b1;
                    data <= block[5];
                    box_number <= box_number + 1;
                    placed <= 1'b0;
                end
                6:
                begin
                    we <= 1'b1;
                    data <= block[6];
                    box_number <= box_number + 1;
                    placed <= 1'b0;
                end
                7:
                begin
                    we <= 1'b1;
                    data <= block[7];
                    box_number <= box_number + 1;
                    placed <= 1'b0;
                end
                8:
                begin
                    we <= 1'b1;
                    data <= block[8];
                    box_number <= box_number + 1;
                    placed <= 1'b0;
                end
                9:
                begin
                    we <= 1'b1;
                    data <= block[9];
                    box_number <= box_number + 1;
                    placed <= 1'b0;
                end
                10:
                begin
                    we <= 1'b1;
                    data <= block[10];
                    box_number <= box_number + 1;
                    placed <= 1'b0;
                end
                11:
                begin
                    we <= 1'b1;
                    data <= block[11];
                    box_number <= box_number + 1;
                    placed <= 1'b0;
                end
                12: //Not an actual box, just a dummy state to reset signals and the state machine
                begin
                    we <= 1'b0; 
                    box_number <= 4'd0;
                    placed <= 1'b1;
                end
                default:
                begin
                    we <= 1'b0; 
                    box_number <= 4'd0;
                    placed <= 1'b0;
                end
            endcase
        end
    end
end

endmodule
