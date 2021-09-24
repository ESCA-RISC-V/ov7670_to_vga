//////////////////////////////////////////////////////////////////////////////////
// Company: Embedded Computing Lab, Korea University
// Engineer: Kwon Guyun
//           1216kg@naver.com
// 
// Create Date: 2021/07/01 11:04:31
// Design Name: ov7670_capture
// Module Name: ov7670_capture
// Project Name: project_ov7670
// Target Devices: zedboard
// Tool Versions: Vivado 2019.1
// Description: make image from ov7670 input and store it to fb1
// 
// Dependencies: 
// 
// Revision 1.00 - first well-activate version
// Additional Comments: sw can controll write image or not
//////////////////////////////////////////////////////////////////////////////////
module ov7670_capture 	(
						input       		pclk,
						input        		vsync,
						input       		href,
						input               sw,
						input  [7:0]	din,
						input               rst_n,
						output logic[18:0]	addr,
						output logic[7:0]	dout,
						output logic[1:0]	we
						);
						
    typedef enum {IDLE, RG, BX} data_state;
	data_state state;
    logic we_go;
    logic[18:0]	addr_t;

	always_ff @(posedge pclk or negedge rst_n) begin : proc_addr
		if(~rst_n) begin
			addr <= '0;
			addr_t <= '0;
		end else begin
			if (vsync == 1'b1) begin
				addr_t <= '0;
			end else if (state == BX) begin
				addr_t <= addr_t + 1;
			end
            addr <= addr_t;
		end
	end

	always_ff @(posedge pclk or negedge rst_n) begin : proc_dout
		if(~rst_n) begin
			dout <= '0;
		end else begin
            dout <= din;
		end
	end

	always_ff @(posedge pclk or negedge rst_n) begin : proc_we
		if(~rst_n) begin
			we <= '0;
		end else begin
			if (vsync == 1'b1) begin
				we <= '0;
			end else if (state == BX) begin
			    we[1] <= 0;
			    we[0] <= ~we_go;
			end else if (href &&(state == RG || state == IDLE)) begin
			    we[1] <= ~we_go;
			    we[0] <= 0;
			end else begin
			    we <= '0;
			end
		end
	end

	always_ff @(posedge pclk or negedge rst_n) begin : proc_state
		if(~rst_n) begin
			state <= IDLE;
		end else begin
			if (vsync == 1'b1) begin
				state <= IDLE;
			end else if (href == 1'b1) begin
				case (state)
				    IDLE:       state <= BX;
				    RG:         state <= BX;
				    BX:         state <= RG;
				    default:    state <= IDLE;
				endcase
			end else begin
				state <= IDLE;
			end
		end
	end

	always_ff @(posedge pclk or negedge rst_n) begin : proc_we_go
		if(~rst_n) begin
			we_go <= sw;
		end else begin
			if (vsync == 1'b1) begin
				we_go <= sw;
			end
		end
	end

endmodule : ov7670_capture