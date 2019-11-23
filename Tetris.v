module Tetris (

    input clk,
    input hard_reset,
    input nes_in
    //vga outputs

    );

    reg reset;
    wire nes_reset, grid_we;
    wire [7:0] button_data, grid_address, data_from_grid, data_to_grid;
    

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

    Input_Controller input_controller (
        .clk(clk), // 50Mhz clock
        .reset(reset),
        .button_data_in(nes_in),
        .nes_reset(nes_reset),
        .button_data_out(button_data)
    );

    Grid_Controller grid_controller (
        .clk(clk),
        .reset(reset),
        .controller_in(button_data),
        .tetris_grid_in(data_from_grid),
        .grid_address(grid_address),
        .tetris_grid_out(data_to_grid),
        .write_en(grid_we)
    );

    Grid_Mem grid_mem (
        .clk(clk),
        .data_a(data_to_grid),
        .addr_a(grid_address), 
        .addr_b(),
        .we_a(grid_we), 
        .q_a(data_from_grid), 
        .q_b()
    );

    VGA_Mem vga_mem (
        .clk(clk),
        .data_a(),
        .addr_a(), 
        .addr_b(),
        .we_a(), 
        .q_a(), 
        .q_b()
    );

    Grid_To_Video grid_to_video (

    );




endmodule