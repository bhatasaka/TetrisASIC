module Tetris (

    input clock,
    input hard_reset,
    input nes_reset,
    output reset,
    output clock

);

always @(posedge clock)
begin
    if (hard_reset == 1'b1 || nes_reset == 1'b1)
    begin
        reset <= 1'b1;
    end
    else
    begin
        reset <= 1'b0;
    end
end





endmodule