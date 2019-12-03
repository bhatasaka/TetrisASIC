`include "/research/ece/lnis-teaching/5710_6710/Lab_files/HDL/padlib_tsmc180_innovus.v"

`include "/home/jamisonb/ECE5710_F19/verilog/Project/TetrisASIC/Tetris_mapped.v"

module Tetris_Top (
    input clk,
    input hard_reset,
    input nes_in,
    output wire [7:0] r_out,
	output wire [7:0] g_out,
	output wire [7:0] b_out,
	output wire h_sync,
	output wire v_sync
);

    // input pads
    pad_in pad_in_clk (.pad(clk), .DataIn(clk_pad));
    pad_in pad_in_reset (.pad(hard_reset), .DataIn(hard_reset_pad));
    pad_in pad_in_nes (.pad(nes_in), .DataIn(nes_in_pad));

    // output pads

    // r_out
    pad_out_buffered pad_out_r0 (.pad(r_out[0]), .out(r_out_pad[0]));
    pad_out_buffered pad_out_r1 (.pad(r_out[1]), .out(r_out_pad[1]));
    pad_out_buffered pad_out_r2 (.pad(r_out[2]), .out(r_out_pad[2]));
    pad_out_buffered pad_out_r3 (.pad(r_out[3]), .out(r_out_pad[3]));
    pad_out_buffered pad_out_r4 (.pad(r_out[4]), .out(r_out_pad[4]));
    pad_out_buffered pad_out_r5 (.pad(r_out[5]), .out(r_out_pad[5]));
    pad_out_buffered pad_out_r6 (.pad(r_out[6]), .out(r_out_pad[6]));
    pad_out_buffered pad_out_r7 (.pad(r_out[7]), .out(r_out_pad[7]));

    // g_out
    pad_out_buffered pad_out_g0 (.pad(g_out[0]), .out(g_out_pad[0]));
    pad_out_buffered pad_out_g1 (.pad(g_out[1]), .out(g_out_pad[1]));
    pad_out_buffered pad_out_g2 (.pad(g_out[2]), .out(g_out_pad[2]));
    pad_out_buffered pad_out_g3 (.pad(g_out[3]), .out(g_out_pad[3]));
    pad_out_buffered pad_out_g4 (.pad(g_out[4]), .out(g_out_pad[4]));
    pad_out_buffered pad_out_g5 (.pad(g_out[5]), .out(g_out_pad[5]));
    pad_out_buffered pad_out_g6 (.pad(g_out[6]), .out(g_out_pad[6]));
    pad_out_buffered pad_out_g7 (.pad(g_out[7]), .out(g_out_pad[7]));

    // b_out
    pad_out_buffered pad_out_b0 (.pad(b_out[0]), .out(b_out_pad[0]));
    pad_out_buffered pad_out_b1 (.pad(b_out[1]), .out(b_out_pad[1]));
    pad_out_buffered pad_out_b2 (.pad(b_out[2]), .out(b_out_pad[2]));
    pad_out_buffered pad_out_b3 (.pad(b_out[3]), .out(b_out_pad[3]));
    pad_out_buffered pad_out_b4 (.pad(b_out[4]), .out(b_out_pad[4]));
    pad_out_buffered pad_out_b5 (.pad(b_out[5]), .out(b_out_pad[5]));
    pad_out_buffered pad_out_b6 (.pad(b_out[6]), .out(b_out_pad[6]));
    pad_out_buffered pad_out_b7 (.pad(b_out[7]), .out(b_out_pad[7]));

    // h_sync
    pad_out_buffered pad_out_hsync (.pad(h_sync), .out(h_sync_pad));

    // v_sync
    pad_out_buffered pad_out_vsync (.pad(v_sync), .out(v_sync_pad));

    // vdd and gnd pads
    pad_vdd pad_vdd0 ();
    pad_gnd pad_gnd0 ();

    // corner pads
    pad_corner corner0 ();
    pad_corner corner1 ();
    pad_corner corner2 ();
    pad_corner corner3 ();

    // post synthesis verilog file
    Tetris tetris_mapped (
        .clk(clk_pad),
        .hard_reset(hard_reset_pad),
        .nes_in(nes_in_pad),
        .r_out(r_out_pad),
        .g_out(g_out_pad),
        .b_out(b_out_pad),
        .h_sync(h_sync_pad),
        .v_sync(v_sync_pad)
    );
endmodule
