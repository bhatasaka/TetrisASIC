module VGA_Controller(clock, reset, switch0, switch1, switch2,
switch3, switch4, hSync, vSync, RED, BLUE, GREEN, vga_blank,
vga_clock, switchMem);

input clock;
input reset;
input switch0;
input switch1;
input switch2;
input switch3;
input switch4;
input [15:0] switchMem;
output reg hSync = 1'b1;
output reg vSync = 1'b1;
output reg [7:0] RED;
output reg [7:0] BLUE;
output reg [7:0] GREEN;
output reg vga_blank = 1'b0;
output reg vga_clock;


reg q = 1'b0;
reg slow_clock;

integer x_count = 0;
integer y_count = 0;

integer x_max = 800;
integer y_max = 521;
integer on_switch = 0;

//50MHz -> 25MHz
always@(posedge clock)
    begin
        if(~reset)
            begin
                q <= 1'b0;
            end
        else
            begin
                q <= ~q;
                slow_clock <= q;
                vga_clock <= slow_clock;
            end
    end

always@(posedge slow_clock)
    begin
        if(x_count < x_max)
            begin
                x_count <= x_count + 1;
            end
        //once we've reached the horizontal end
        if(x_count == x_max)
            begin
                x_count <= 0;
            //if we're not at the vertical end, increment y
            if(y_count < y_max)
                begin
                    y_count <= y_count + 1;
                end
            else
            //if we are at the vertical end, reset y
                begin
                    y_count <= 0;
                end
            end

        //start displaying
        if((x_count > 130 && x_count < 784) && (y_count > 31 && y_count < 511))
            begin
                if(switchMem[4] == 1)
                begin
                    on_switch = 4;
                end
                else if(switchMem[3] == 1)
                begin
                    on_switch = 3;
                end
                else if(switchMem[2] == 1)
                begin
                    on_switch = 2;
                end
                else if(switchMem[1] == 1)
                begin
                    on_switch = 1;
                end
                else if(switchMem[0] == 1)
                begin
                    on_switch = 0;
                end
                else
                begin
                    on_switch = -1;
                end
            end

            if(x_count > 130 && x_count < 261)
                begin
                    if(on_switch == 4)
                    begin
                        GREEN <= 8'b1111_1111;
                        RED <= 8'b1111_1111;
                        BLUE <= 8'b1111_1111;
                    end
                    else
                    begin
                        GREEN <= 8'b0000_0000;
                        RED <= 8'b1111_1111; //red
                        BLUE <= 8'b0000_0000;
                    end
                    vga_blank <= 1'b1;
                end
            else if(x_count > 261 && x_count < 392)
                begin
                    if(on_switch == 3)
                    begin
                        GREEN <= 8'b1111_1111;
                        RED <= 8'b1111_1111;
                        BLUE <= 8'b1111_1111;
                    end
                    else
                    begin
                        GREEN <= 8'b1010_0101; // orange
                        RED <= 8'b1111_1111;
                        BLUE <= 8'b0000_0000;
                    end
                    vga_blank <= 1'b1;
                end
            else if(x_count > 392 && x_count < 523)
                begin
                    if(on_switch == 2)
                    begin
                        GREEN <= 8'b1111_1111;
                        RED <= 8'b1111_1111;
                        BLUE <= 8'b1111_1111;
                    end
                    else
                    begin
                        GREEN <= 8'b1111_1111; //yellow
                        RED <= 8'b1111_1111;
                        BLUE <= 8'b0000_0000;
                    end
                    vga_blank <= 1'b1;
                end
            else if(x_count > 523 && x_count < 653)
                begin
                    if(on_switch == 1)
                    begin
                        GREEN <= 8'b1111_1111;
                        RED <= 8'b1111_1111;
                        BLUE <= 8'b1111_1111;
                    end
                    else
                    begin
                        GREEN <= 8'b1111_1111; //green
                        RED <= 8'b0000_0000;
                        BLUE <= 8'b0000_0000;
                    end
                    vga_blank <= 1'b1;
                end
            else if(x_count > 653 && x_count < 784)
                begin
                    if(on_switch == 0)
                    begin
                        GREEN <= 8'b1111_1111;
                        RED <= 8'b1111_1111;
                        BLUE <= 8'b1111_1111;
                    end
                    else
                    begin
                        GREEN <= 8'b0000_0000; //blue
                        RED <= 8'b0000_0000;
                        BLUE <= 8'b1111_1111;
                    end
                    vga_blank <= 1'b1;
                end

        else
            begin
             vga_blank <= 1'b0;
            end
        //if we've reached the horizontal end, reset hSync
        if(x_count <= 96)
            begin
             hSync <= 1'b0;
            end
        else
            begin
             hSync <= 1'b1;
            end
        //if we've reached the horizontal end and the vertical end, reset vSync and hSync
        if(y_count <= 2)
            begin
             vSync <= 1'b0;
            end
        else
            begin
             vSync <= 1'b1;
            end
    end
endmodule