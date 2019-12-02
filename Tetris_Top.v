`include "/research/ece/lnis-teaching/5710_6710/Lab_files/HDL/padlib_tsmc180_innovus.v"
`include "Tetris_Mapped.v"

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

pad_in pad_in_clk (.pad(clk), .DataIn(clk_pad));
pad_in pad_in_reset (.pad(hard_reset), .DataIn(hard_reset_pad));
pad_in pad_in_nes (.pad(nes_in), .DataIn(nes_in_pad));

pad_out_buffered pad_out0 (.pad(r_out[0]), .out(r_out[0]_pad));
pad_out_buffered pad_out0 (.pad(r_out[0]), .out(r_out[0]_pad));
pad_out_buffered pad_out0 (.pad(r_out[0]), .out(r_out[0]_pad));
pad_out_buffered pad_out0 (.pad(r_out[0]), .out(r_out[0]_pad));
pad_out_buffered pad_out0 (.pad(r_out[0]), .out(r_out[0]_pad));
pad_out_buffered pad_out0 (.pad(r_out[0]), .out(r_out[0]_pad));
pad_out_buffered pad_out0 (.pad(r_out[0]), .out(r_out[0]_pad));
pad_out_buffered pad_out0 (.pad(r_out[0]), .out(r_out[0]_pad));




pad_vdd pad_vdd0 ();
pad_gnd pad_gnd0 ();


pad_corner corner0 ();
pad_corner corner1 ();
pad_corner corner2 ();
pad_corner corner3 ();




