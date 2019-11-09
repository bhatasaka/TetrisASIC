// ============================
// UART transmitter module - transmits one byte at a time.
//
// TO use:
// On first use, Reset and wait one clock cycle after reset is set low again.
//
// From here, data may be loaded to the Data_Bus,
// After data is loaded, set Load_XMT_datareg high for 1 clock cycle.
// Anytime after this clock cycle, Byte_ready can be set high for 1 clock cycle
// to indicate that the byte has been loaded.
// Anytime after this clock cycle, T_byte may be set high for 1 clock cycle to start the transmission.
// Exactly 1 clock cycle after T_byte has been set high, the transmission will begin.
// A new bit will appear on Serial_out every clock cycle.
// After the UART start bit has been sent, the LSBs of the data byte will be sent,
// one after anoter until all 8 bits are sent. Then the UART stop bit will be sent and 
// more data may be loaded to transmit again.
//
// This module follows a similar/the same block diagram as was given in the Homework 2 assignment
// 
// Author: Bryan Hatasaka
// 
// ============================
module Grid_To (
	input [7:0] Data_Bus, 
    input Byte_ready,
    input Load_XMT_datareg,
    input T_byte,
    input Clk,
    input Reset,
    input px_clk,
	output reg Serial_out
);

    reg [4:0] state;
    reg [4:0] next_state;
    reg [7:0] data_reg;
    reg [7:0] shift_reg;
    reg [3:0] status_reg;

    parameter IDLE = 4'd0;
    parameter LOAD_SHIFT = 4'd1;
    parameter WAITING = 4'd2;
    parameter START = 4'd3;
    parameter SEND = 4'd4;
    parameter SHIFT = 4'd5;
    parameter CLEAR = 4'd6;

    reg[7:0] current_px_rgb;
    reg[7:0] next_px_rgb;
    reg[7:0] current_grid_addr;
    reg[15:0] current_vga_addr;
    

    always @ (clk)
    begin
        if() // start next block
        begin
            // Find the pixel in memory that we are looking for
            case:
                //green
                current_vga_addr = green addr;
            
        end

    end

    always @ (px_clk)
    begin
        current_px_rgb = next_px_rgb;
    end

    // Combinational logic to determine next state
    always @ (state, Byte_ready, T_byte, status_reg)
    begin
        case(state)
            // Idle
            IDLE: 
            begin
                if(Byte_ready)
                    next_state <= LOAD_SHIFT;
            end
	    // After shift register is loaded, if the T_byte is high,
	    // go straight to sending, otherwise, wait until T_byte goes high
            LOAD_SHIFT:
            begin
		if(T_byte)
		    next_state <= START;
		else
                    next_state <= WAITING;
            end
            WAITING:
            begin
                if(T_byte)
		begin
                    next_state <= START;
		end
            end
            START: 
            begin
                next_state <= SEND;
            end
            SEND: 
            begin
                if(status_reg == 9) // 9 bits will be sent until the stop bit needs to be sent
                    next_state <= CLEAR;
            end
            CLEAR: 
            begin
                next_state <= IDLE;
            end
            // By default, the next_state is just set to itself
            default: 
            begin
                next_state <= IDLE;
            end

        endcase
    end

    // Output logic
    always @(posedge Clk, Load_XMT_datareg)
    begin
        if(Load_XMT_datareg) // If the data bus has received data, shift it in
        begin
            data_reg <= Data_Bus;
        end

        case(state)
            // In the IDLE state, the output is high -
            // the output doesn't go low until the start bit
            IDLE:
            begin
                Serial_out <= 1'b1;
                status_reg <= 4'b0; // Reset the status register
            end
            LOAD_SHIFT:
            begin
                // Shift in the data from the data register
                // (if, during this evaluation, Load_XMT_datareg is high,
                // the data loaded into the shift_reg will not be the same
                // as the current Data_bus value)
                shift_reg <= data_reg;
                Serial_out <= 1'b1; // Haven't started yet
            end
            WAITING:
            begin
                Serial_out <= 1'b1; // Haven't started yet
            end
            START:
            begin
                Serial_out <= 1'b0; // Start bit to transmission
                status_reg <= status_reg + 1; // Increment the bit count
            end

            // For the send state, the data out will equal the LSB of the shift reg,
            // the shift reg will be shifted,
            // and the status register will be incremented
            SEND:
            begin
                Serial_out <= shift_reg[0];
                shift_reg <= shift_reg >> 1;
                status_reg <= status_reg + 1; // Increment the bit count
            end
            CLEAR:
            begin
                Serial_out <= 1'b1; // Stop bit
            end
            default:
            begin
                Serial_out <= 1'b1; // Equivalent to just not transmitting
            end
        endcase
    end
    // State always block
    always @ (posedge Clk, Reset)
    begin
        // Asychronous reset to keep everything in sync
        if(Reset)
        begin
            state <= IDLE;
        end
        else
            state <= next_state;
    end

endmodule