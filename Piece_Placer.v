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
)

parameter NEXT_PIECE_BASE_ADDR = 8'd232;
parameter [2:0] A = 3'd0, I = 3'd1, O = 3'd2, T = 3'd3, S = 3'd4, Z = 3'd5, J = 3'd6, L = 3'd7;

reg [7:0] block[11:0];
reg [7:0] lfsr;
reg [3:0] box_number;
reg piece_gen;

//LFSR Polynomial
assign lfsr = !(out[7] ^ out[3]);

//Write random block into local memory and indicate
//the corresponding grid memory addresses it will
//be found in once the piece is "placed"
always @(posedge en)
begin
    case (lfsr[2:0])
        I:
        begin
           block[0]  <= I; 
           block[3]  <= I; 
           block[6]  <= I; 
           block[9]  <= I; 
           reg_1 <= NEXT_PIECE_BASE_ADDR + 0;
           reg_2 <= NEXT_PIECE_BASE_ADDR + 3;
           reg_3 <= NEXT_PIECE_BASE_ADDR + 6;
           reg_4 <= NEXT_PIECE_BASE_ADDR + 9;
           piece_gen <= 1'b1;
        end
        O:
        begin
           block[6]  <= O; 
           block[7]  <= O; 
           block[9]  <= O; 
           block[10] <= O; 
           reg_1 <= NEXT_PIECE_BASE_ADDR + 6;
           reg_2 <= NEXT_PIECE_BASE_ADDR + 7;
           reg_3 <= NEXT_PIECE_BASE_ADDR + 9;
           reg_4 <= NEXT_PIECE_BASE_ADDR + 10;
           piece_gen <= 1'b1;
        end
        T:
        begin
           block[4]  <= T; 
           block[6]  <= T; 
           block[7]  <= T; 
           block[10] <= T; 
           reg_1 <= NEXT_PIECE_BASE_ADDR + 4;
           reg_2 <= NEXT_PIECE_BASE_ADDR + 6;
           reg_3 <= NEXT_PIECE_BASE_ADDR + 7;
           reg_4 <= NEXT_PIECE_BASE_ADDR + 10;
           piece_gen <= 1'b1;
        end
        S:
        begin
           block[7]  <= S; 
           block[8]  <= S; 
           block[9]  <= S; 
           block[10] <= S; 
           reg_1 <= NEXT_PIECE_BASE_ADDR + 7;
           reg_2 <= NEXT_PIECE_BASE_ADDR + 8;
           reg_3 <= NEXT_PIECE_BASE_ADDR + 9;
           reg_4 <= NEXT_PIECE_BASE_ADDR + 10;
           piece_gen <= 1'b1;
        end
        Z:
        begin
           block[6]  <= Z; 
           block[7]  <= Z; 
           block[10] <= Z; 
           block[11] <= Z; 
           reg_1 <= NEXT_PIECE_BASE_ADDR + 6;
           reg_2 <= NEXT_PIECE_BASE_ADDR + 7;
           reg_3 <= NEXT_PIECE_BASE_ADDR + 10;
           reg_4 <= NEXT_PIECE_BASE_ADDR + 11;
           piece_gen <= 1'b1;
        end
        J:
        begin
           block[4]  <= J; 
           block[7]  <= J; 
           block[9]  <= J; 
           block[10] <= J; 
           reg_1 <= NEXT_PIECE_BASE_ADDR + 4;
           reg_2 <= NEXT_PIECE_BASE_ADDR + 7;
           reg_3 <= NEXT_PIECE_BASE_ADDR + 9;
           reg_4 <= NEXT_PIECE_BASE_ADDR + 10;
           piece_gen <= 1'b1;
        end
        L:
        begin
           block[3]  <= L; 
           block[6]  <= L; 
           block[9]  <= L; 
           block[10] <= L; 
           reg_1 <= NEXT_PIECE_BASE_ADDR + 3;
           reg_2 <= NEXT_PIECE_BASE_ADDR + 6;
           reg_3 <= NEXT_PIECE_BASE_ADDR + 9;
           reg_4 <= NEXT_PIECE_BASE_ADDR + 10;
           piece_gen <= 1'b1;
        end
        default:    //THIS JUST PLACES AN AIR BLOCK
        begin
           block[0]  <= A; 
           block[1]  <= A; 
           block[2]  <= A; 
           block[3]  <= A; 
           reg_1 <= NEXT_PIECE_BASE_ADDR + 0;
           reg_2 <= NEXT_PIECE_BASE_ADDR + 1;
           reg_3 <= NEXT_PIECE_BASE_ADDR + 2;
           reg_4 <= NEXT_PIECE_BASE_ADDR + 3;
           piece_gen <= 1'b1;
        end
    endcase
end

//LFSR, generates random number once module is disabled
//We never reset this reg to make piece generation appear
//more random (it will always be power on state or last piece
//state (potentially from previous game)
always @(negedge en)
begin
    lfsr <= {lfsr[6], lfsr[5], lfsr[4], lfsr[3], lfsr[2], lfsr[1], lfrsr[0], lf};
end

//Write the generated piece from local storage into 
//next piece grid memory storage.
always @(posedge clk)
begin
    if (rst)
    begin
        box_number = 4'b0;

        for (i = 0; i < 12; i = i + 1)
        begin
            block[i] = 4'b0;
        end
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
                end
                1:
                begin
                    we <= 1'b1;
                    data <= block[1];
                    box_number <= box_number + 1;
                end
                2:
                begin
                    we <= 1'b1;
                    data <= block[2];
                    box_number <= box_number + 1;
                end
                3:
                begin
                    we <= 1'b1;
                    data <= block[3];
                    box_number <= box_number + 1;
                end
                4:
                begin
                    we <= 1'b1;
                    data <= block[4];
                    box_number <= box_number + 1;
                end
                5:
                begin
                    we <= 1'b1;
                    data <= block[5];
                    box_number <= box_number + 1;
                end
                6:
                begin
                    we <= 1'b1;
                    data <= block[6];
                    box_number <= box_number + 1;
                end
                7:
                begin
                    we <= 1'b1;
                    data <= block[7];
                    box_number <= box_number + 1;
                end
                8:
                begin
                    we <= 1'b1;
                    data <= block[8];
                    box_number <= box_number + 1;
                end
                9:
                begin
                    we <= 1'b1;
                    data <= block[9];
                    box_number <= box_number + 1;
                end
                10:
                begin
                    we <= 1'b1;
                    data <= block[10];
                    box_number <= box_number + 1;
                end
                11:
                begin
                    we <= 1'b1;
                    data <= block[11];
                    box_number <= box_number + 1;
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
                end
            endcase
        end
    end
end

endmodule