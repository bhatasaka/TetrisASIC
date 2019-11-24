`timescale 100ps/100ps

module Piece_Placer_tb;

    reg clk; // 50Mhz clock
    reg rst;
    reg en;
    wire placed;
    wire we;
    wire [7:0] addr;
    wire [7:0] data;
    wire [7:0] reg_1_addr;
    wire [7:0] reg_2_addr;
    wire [7:0] reg_3_addr;
    wire [7:0] reg_4_addr;

    parameter FULL_CLK = 20;
    parameter HALF_CLK = 10;

    Piece_Placer uut(
            .en(en);
            .clk(clk);
            .rst(rst);
            .placed(placed);
            .we(we);
            .addr(addr);
            .data(data);
            .reg_1_addr(reg_1_addr);
            .reg_2_addr(reg_2_addr);
            .reg_3_addr(reg_3_addr);
            .reg_4_addr(reg_4_addr);
    );

    initial
    begin
        rst = 0;
        clk = 0;
        en = 0;

        #FULL_CLK;

        rst = 1;

        #FULL_CLK;

        en = 1;

        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;

        en = 0;

        #FULL_CLK;

        rst = 1;

        #FULL_CLK;

        rst = 0;

        #FULL_CLK;

        en = 1;

        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;

        en = 0;

        #FULL_CLK;

        rst = 1;

        #FULL_CLK;

        rst = 0;

        #FULL_CLK;

        en = 1;

        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;
        #FULL_CLK;

        en = 0;

        #FULL_CLK;

        rst = 1;

        #FULL_CLK;

        rst = 0;

        #FULL_CLK;
        
    end

    always @(*)
    begin
        #HALF_CLK
        clk <= ~clk;
    end

endmodule