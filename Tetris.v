module Tetris (
    input clk,
    input hard_reset,
    input nes_in,
    output wire [7:0] r_out,
	output wire [7:0] g_out,
	output wire [7:0] b_out,
	output wire h_sync,
	output wire v_sync
);
    reg reset;
    wire nes_reset, grid_we, pixel_en, vga_we, ext_disable;
    wire [3:0] button_data;
    wire [7:0] grid_address_a, grid_address_b, data_from_grid, data_to_grid, 
               grid_to_converter, vga_to_converter, pixel_rgb, mem_init_data,
               dummy_output;
    wire [12:0] mem_init_addr, vga_address;

    always @(posedge clk)
    begin
        if (hard_reset|| nes_reset)
        begin
            reset <= 1'b1;
        end
        else
        begin
            reset <= 1'b0;
        end
    end

    assign mod_rst = reset | ext_disable;

    Input_Controller input_controller (
        .clk(clk), // 50Mhz clock
        .reset(mod_rst),
        .button_data_in(nes_in),
        .nes_reset(nes_reset),
        .button_data_out(button_data)
    );

    Grid_Controller grid_controller (
        .clk(clk),
        .reset(mod_rst),
        .controller_in(button_data),
        .tetris_grid_in(data_from_grid),
        .grid_address(grid_address_a),
        .grid_data_out(data_to_grid),
        .write_en(grid_we)
    );

    Grid_Mem grid_mem (
        .clk(clk),
        .data_a(data_to_grid),
        .addr_a(grid_address_a), 
        .addr_b(grid_address_b),
        .we_a(grid_we), 
        .q_a(data_from_grid), 
        .q_b(grid_to_converter)
    );

    VGA_Mem vga_mem (
        .clk(clk),
        .data_a(mem_init_data),
        .addr_a(mem_init_addr), 
        .addr_b(vga_address), 
        .we_a(vga_we), 
        .q_a(dummy_output),
        .q_b(vga_to_converter)
    );

    Sprite_Initializer sprite_init (
    		.clk(clk),
    		.rst(mod_rst),
    		.dis(ext_disable),
    		.addr(mem_init_addr),
    		.data(mem_init_data),
    		.we(vga_we)
    );

    Grid_To_Video grid_to_video (
        .clk(clk),
        .px_en(pixel_en),
        .reset(mod_rst),
        .grid_data(grid_to_converter),
        .vga_data(vga_to_converter),
        .grid_addr(grid_address_b),
        .pixel_rgb(pixel_rgb),
        .vga_addr(vga_address)
    );

    VGA_Controller vga_controller (
        .clk(clk),
        .rgb_8(pixel_rgb),
        .r_out(r_out),
        .g_out(g_out),
        .b_out(b_out),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .pixel_en(pixel_en)
    );
endmodule
