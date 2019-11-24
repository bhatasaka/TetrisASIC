module Piece_Placer(
    input en;
    input clk;
    input rst;
    output reg placed;
    output reg we;
    output reg [7:0] addr;
    output reg [7:0] data;
)


reg [7:0] block[11:0];
reg [3:0] box_number;

always @(clk)
begin
    if (rst)
    begin
        //Reset all registers
    end
    else
    begin
        if (en)
        begin
            case (box_number)
                0:
                begin
                    we <= 1'b1;
                    addr <= 8'd232;
                    data <= block[0];
                    box_number <= 4'd1;
                end
                1:
                begin
                    we <= 1'b1;
                    addr <= 8'd233;
                    data <= block[1];
                    box_number <= 4'd2;
                end
                2:
                begin
                    we <= 1'b1;
                    addr <= 8'd234;
                    data <= block[2];
                    box_number <= 4'd3;
                end
                3:
                begin
                    we <= 1'b1;
                    addr <= 8'd235;
                    data <= block[3];
                    box_number <= 4'd4;
                end
                4:
                begin
                    we <= 1'b1;
                    addr <= 8'd236;
                    data <= block[4];
                    box_number <= 4'd5;
                end
                5:
                begin
                    we <= 1'b1;
                    addr <= 8'd237;
                    data <= block[5];
                    box_number <= 4'd6;
                end
                6:
                begin
                    we <= 1'b1;
                    addr <= 8'd238;
                    data <= block[6];
                    box_number <= 4'd7;
                end
                7:
                begin
                    we <= 1'b1;
                    addr <= 8'd239;
                    data <= block[7];
                    box_number <= 4'd8;
                end
                8:
                begin
                    we <= 1'b1;
                    addr <= 8'd240;
                    data <= block[8];
                    box_number <= 4'd9;
                end
                9:
                begin
                    we <= 1'b1;
                    addr <= 8'd241;
                    data <= block[9];
                    box_number <= 4'd10;
                end
                10:
                begin
                    we <= 1'b1;
                    addr <= 8'd242;
                    data <= block[10];
                    box_number <= 4'd11;
                end
                0:
                begin
                    we <= 1'b1;
                    addr <= 8'd243;
                    data <= block[11];
                    box_number <= 4'd12;
                    placed <= 1'b1;
                end
        end
    end
end

endmodule