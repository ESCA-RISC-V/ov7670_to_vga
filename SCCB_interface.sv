`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25/08/2021 17:19:21 AM
// Design Name: 
// Module Name: SCCB_interface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module SCCB_interface #(
	parameter CLK_FREQ = 25000000,
	parameter SCCB_FREQ = 100000
	)(
	input clk,    // Clock
	input clk_en, // Clock Enable
	input rst_n,  // Asynchronous reset active low
	input start,
	input [7:0] address,
	input [7:0] data,
	output logic ready,
	output logic SIOC_oe,
	output logic SIOD_oe
);

	typedef enum bit[3:0] {IDLE, START_SIGNAL, LOAD_BYTE, TX_BYTE_1, TX_BYTE_2, TX_BYTE_3, TX_BYTE_4, END_SIGNAL_1, END_SIGNAL_2, END_SIGNAL_3, END_SIGNAL_4, ALL_DONE, TIMER} FSM_STATE;

	localparam CAMERA_ADDR = 8'h42;

	FSM_STATE state;
	FSM_STATE return_state;
	logic [31:0] timer;
	logic [7:0] latched_address;
	logic [7:0] latched_data;
	logic [1:0] byte_counter;
	logic [7:0] tx_byte;
	logic [3:0] byte_index;

	always_ff @(posedge clk or negedge rst_n) begin : proc_state
		if(~rst_n) begin
			state <= IDLE;
		end else if(clk_en) begin
			case (state)
				IDLE: begin
					if (start) begin
						state <= START_SIGNAL;
					end
				end
				START_SIGNAL: begin
					state <= TIMER;
				end
				LOAD_BYTE: begin
					state <= (byte_counter == 3) ? END_SIGNAL_1 : TX_BYTE_1;
				end
				TX_BYTE_1: begin
					state <= TIMER;
				end
				TX_BYTE_2: begin
					state <= TIMER;
				end
				TX_BYTE_3: begin
					state <= TIMER;
				end
				TX_BYTE_4: begin
					state <= (byte_index == 8) ? LOAD_BYTE : TX_BYTE_1;
				end
				END_SIGNAL_1: begin
					state <= TIMER;
				end
				END_SIGNAL_2: begin
					state <= TIMER;
				end
				END_SIGNAL_3: begin
					state <= TIMER;
				end
				END_SIGNAL_4: begin
					state <= TIMER;
				end
				ALL_DONE: begin
					state <= TIMER;
				end
				TIMER: begin
					state <= (timer == 0) ? return_state : TIMER;
				end
				default : begin
					state <= IDLE;
				end
			endcase
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_return_state
		if(~rst_n) begin
			return_state <= IDLE;
		end else if(clk_en) begin
			case (state)
				IDLE: begin
					// do nothing
				end
				START_SIGNAL: begin
					return_state <= LOAD_BYTE;
				end
				LOAD_BYTE: begin
					// do nothing
				end
				TX_BYTE_1: begin
					return_state <= TX_BYTE_2;
				end
				TX_BYTE_2: begin
					return_state <= TX_BYTE_3;
				end
				TX_BYTE_3: begin
					return_state <= TX_BYTE_4;
				end
				TX_BYTE_4: begin
					// do nothing
				end
				END_SIGNAL_1: begin
					return_state <= END_SIGNAL_2;
				end
				END_SIGNAL_2: begin
					return_state <= END_SIGNAL_3;
				end
				END_SIGNAL_3: begin
					return_state <= END_SIGNAL_4;
				end
				END_SIGNAL_4: begin
					return_state <= ALL_DONE;
				end
				ALL_DONE: begin
					return_state <= IDLE;
				end
				TIMER: begin
					// do nothing
				end
				default : begin
					// do nothing
				end
			endcase
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_timer
		if(~rst_n) begin
			timer <= 0;
		end else if(clk_en) begin
			case (state)
				IDLE: begin
					// do nothing
				end
				START_SIGNAL: begin
					timer <= (CLK_FREQ / (4*SCCB_FREQ));
				end
				LOAD_BYTE: begin
					// do nothing
				end
				TX_BYTE_1: begin
					timer <= (CLK_FREQ / (4*SCCB_FREQ));
				end
				TX_BYTE_2: begin
					timer <= (CLK_FREQ / (4*SCCB_FREQ));
				end
				TX_BYTE_3: begin
					timer <= (CLK_FREQ / (4*SCCB_FREQ));
				end
				TX_BYTE_4: begin
					// do nothing
				end
				END_SIGNAL_1: begin
					timer <= (CLK_FREQ / (4*SCCB_FREQ));
				end
				END_SIGNAL_2: begin
					timer <= (CLK_FREQ / (4*SCCB_FREQ));
				end
				END_SIGNAL_3: begin
					timer <= (CLK_FREQ / (4*SCCB_FREQ));
				end
				END_SIGNAL_4: begin
					timer <= (CLK_FREQ / (4*SCCB_FREQ));
				end
				ALL_DONE: begin
					timer <= (CLK_FREQ / (4*SCCB_FREQ));
				end
				TIMER: begin
					timer <= (timer == 0) ? 0 : timer - 1;
				end
				default : begin
					// do nothing
				end
			endcase
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_latched_address
		if(~rst_n) begin
			latched_address <= 0;
		end else if(clk_en) begin
			case (state)
				IDLE: begin
					if (start) begin
						latched_address <= address;
					end
				end
				START_SIGNAL: begin
					// do nothing
				end
				LOAD_BYTE: begin
					// do nothing
				end
				TX_BYTE_1: begin
					// do nothing
				end
				TX_BYTE_2: begin
					// do nothing
				end
				TX_BYTE_3: begin
					// do nothing
				end
				TX_BYTE_4: begin
					// do nothing
				end
				END_SIGNAL_1: begin
					// do nothing
				end
				END_SIGNAL_2: begin
					// do nothing
				end
				END_SIGNAL_3: begin
					// do nothing
				end
				END_SIGNAL_4: begin
					// do nothing
				end
				ALL_DONE: begin
					// do nothing
				end
				TIMER: begin
					// do nothing
				end
				default : begin
					// do nothing
				end			
			endcase
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_latched_data
		if(~rst_n) begin
			latched_data <= 0;
		end else if(clk_en) begin
			case (state)
				IDLE: begin
					if (start) begin
						latched_data <= data;
					end
				end
				START_SIGNAL: begin
					// do nothing
				end
				LOAD_BYTE: begin
					// do nothing
				end
				TX_BYTE_1: begin
					// do nothing
				end
				TX_BYTE_2: begin
					// do nothing
				end
				TX_BYTE_3: begin
					// do nothing
				end
				TX_BYTE_4: begin
					// do nothing
				end
				END_SIGNAL_1: begin
					// do nothing
				end
				END_SIGNAL_2: begin
					// do nothing
				end
				END_SIGNAL_3: begin
					// do nothing
				end
				END_SIGNAL_4: begin
					// do nothing
				end
				ALL_DONE: begin
					// do nothing
				end
				TIMER: begin
					// do nothing
				end
				default : begin
					// do nothing
				end
			endcase
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_byte_counter
		if(~rst_n) begin
			byte_counter <= 0;
		end else if(clk_en) begin
			case (state)
				IDLE: begin
					byte_counter <= 0;
				end
				START_SIGNAL: begin
					// do nothing
				end
				LOAD_BYTE: begin
					byte_counter <= byte_counter + 1;
				end
				TX_BYTE_1: begin
					// do nothing
				end
				TX_BYTE_2: begin
					// do nothing
				end
				TX_BYTE_3: begin
					// do nothing
				end
				TX_BYTE_4: begin
					// do nothing
				end
				END_SIGNAL_1: begin
					// do nothing
				end
				END_SIGNAL_2: begin
					// do nothing
				end
				END_SIGNAL_3: begin
					// do nothing
				end
				END_SIGNAL_4: begin
					// do nothing
				end
				ALL_DONE: begin
					byte_counter <= 0;
				end
				TIMER: begin
					// do nothing
				end
				default : begin
					// do nothing
				end
			endcase
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_tx_byte
		if(~rst_n) begin
			tx_byte <= 0;
		end else if(clk_en) begin
			case (state)
				IDLE: begin
					// do nothing
				end
				START_SIGNAL: begin
					// do nothing
				end
				LOAD_BYTE: begin
					case (byte_counter)
						0:tx_byte <= CAMERA_ADDR;
						1:tx_byte <= latched_address;
						2:tx_byte <= latched_data;
						default : tx_byte <= latched_data;
					endcase
				end
				TX_BYTE_1: begin
					// do nothing 	
				end
				TX_BYTE_2: begin
					// do nothing 	
				end
				TX_BYTE_3: begin
					// do nothing 	
				end
				TX_BYTE_4: begin
					tx_byte <= tx_byte << 1;
				end
				END_SIGNAL_1: begin
					// do nothing 	
				end
				END_SIGNAL_2: begin
					// do nothing 	
				end
				END_SIGNAL_3: begin
					// do nothing 	
				end
				END_SIGNAL_4: begin
					// do nothing 	
				end
				ALL_DONE: begin
					// do nothing 	
				end
				TIMER: begin
					// do nothing 	
				end
				default : begin
					// do nothing 	
				end
			endcase
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_byte_index
		if(~rst_n) begin
			byte_index <= 0;
		end else if(clk_en) begin
			case (state)
				IDLE: begin
					byte_index <= 0;
				end
				START_SIGNAL: begin
					// do nothing 	
				end
				LOAD_BYTE: begin
					byte_index <= 0;
				end
				TX_BYTE_1: begin
					// do nothing 	
				end
				TX_BYTE_2: begin
					// do nothing 	
				end
				TX_BYTE_3: begin
					// do nothing 	
				end
				TX_BYTE_4: begin
					byte_index <= byte_index + 1;
				end
				END_SIGNAL_1: begin
					// do nothing 	
				end
				END_SIGNAL_2: begin
					// do nothing 	
				end
				END_SIGNAL_3: begin
					// do nothing 	
				end
				END_SIGNAL_4: begin
					// do nothing 	
				end
				ALL_DONE: begin
					// do nothing 	
				end
				TIMER: begin
					// do nothing 	
				end
				default : begin
					// do nothing 	
				end
			endcase
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_ready
		if(~rst_n) begin
			ready <= 1;
		end else if(clk_en) begin
			case (state)
				IDLE: begin
					if (start) begin
						ready <= 0;
					end else begin
						ready <= 1;
					end
				end
				START_SIGNAL: begin
					// do nothing 	
				end
				LOAD_BYTE: begin
					// do nothing 	
				end
				TX_BYTE_1: begin
					// do nothing 	
				end
				TX_BYTE_2: begin
					// do nothing 	
				end
				TX_BYTE_3: begin
					// do nothing 	
				end
				TX_BYTE_4: begin
					// do nothing 	
				end
				END_SIGNAL_1: begin
					// do nothing 	
				end
				END_SIGNAL_2: begin
					// do nothing 	
				end
				END_SIGNAL_3: begin
					// do nothing 	
				end
				END_SIGNAL_4: begin
					// do nothing 	
				end
				ALL_DONE: begin
					// do nothing 	
				end
				TIMER: begin
					// do nothing 	
				end
				default : begin
					// do nothing 	
				end
			endcase
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_SIOC_oe
		if(~rst_n) begin
			SIOC_oe <= 0;
		end else if(clk_en) begin
			case (state)
				IDLE: begin
					// do nothing
				end
				START_SIGNAL: begin
					SIOC_oe <= 0;
				end
				LOAD_BYTE: begin
					// do nothing
				end
				TX_BYTE_1: begin
					SIOC_oe <= 1;
				end
				TX_BYTE_2: begin
					// do nothing
				end
				TX_BYTE_3: begin
					SIOC_oe <= 0;
				end
				TX_BYTE_4: begin
					// do nothing
				end
				END_SIGNAL_1: begin
					SIOC_oe <= 1;
				end
				END_SIGNAL_2: begin
					// do nothing
				end
				END_SIGNAL_3: begin
					SIOC_oe <= 0;
				end
				END_SIGNAL_4: begin
					// do nothing
				end
				ALL_DONE: begin
					// do nothing
				end
				TIMER: begin
					// do nothing
				end
				default : begin
					// do nothing
				end
			endcase
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_SIOD_oe
		if(~rst_n) begin
			SIOD_oe <= 0;
		end else if(clk_en) begin
			case (state)
				IDLE: begin
					// do nothing	
				end
				START_SIGNAL: begin
					SIOD_oe <= 1;
				end
				LOAD_BYTE: begin
					// do nothing	
				end
				TX_BYTE_1: begin
					// do nothing	
				end
				TX_BYTE_2: begin
					SIOD_oe <= (byte_index == 8) ? 0 : ~tx_byte[7];
				end
				TX_BYTE_3: begin
					// do nothing	
				end
				TX_BYTE_4: begin
					// do nothing	
				end
				END_SIGNAL_1: begin
					// do nothing	
				end
				END_SIGNAL_2: begin
					SIOD_oe <= 1;
				end
				END_SIGNAL_3: begin
					// do nothing
				end
				END_SIGNAL_4: begin
					SIOD_oe <= 0;
				end
				ALL_DONE: begin
					// do nothing	
				end
				TIMER: begin
					// do nothing	
				end
				default : begin
					// do nothing	
				end
			endcase
		end
	end

endmodule : SCCB_interface

/*
			case (state)
				IDLE: begin
				end
				START_SIGNAL: begin
				end
				LOAD_BYTE: begin
				end
				TX_BYTE_1: begin
				end
				TX_BYTE_2: begin
				end
				TX_BYTE_3: begin
				end
				TX_BYTE_4: begin
				end
				END_SIGNAL_1: begin
				end
				END_SIGNAL_2: begin
				end
				END_SIGNAL_3: begin
				end
				END_SIGNAL_4: begin
				end
				ALL_DONE: begin
				end
				TIMER: begin
				end
				default : begin
				end
			endcase
*/