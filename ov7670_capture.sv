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
						output logic 		we
						);
						
    typedef enum logic[1:0] {IDLE, NY, Y} data_state;
	data_state state;
    logic we_go;
    logic [18:0] addr_t, addr_s;
    
    
    always_ff @(posedge pclk or negedge rst_n) begin : proc_addr
        if (~rst_n) begin
            addr <= 0;
            addr_s <= 0;
        end else begin
            addr <= addr_s;
            addr_s <= addr_t;
        end
    end

	always_ff @(posedge pclk or negedge rst_n) begin : proc_addr_t
		if(~rst_n) begin
			addr_t <= '0;
		end else begin
			if (vsync == 1'b1) begin
				addr_t <= '0;
			end else if (state == Y && href == 1'b1) begin
				addr_t <= addr_t + 1;
			end
		end
	end

	always_ff @(posedge pclk or negedge rst_n) begin : proc_dout
		if(~rst_n) begin
			dout <= '0;
		end else begin
			if (~(vsync == 1'b1) && ~(state == Y && href == 1'b1)) begin
				dout <= din;
			end
		end
	end

	always_ff @(posedge pclk or negedge rst_n) begin : proc_we
		if(~rst_n) begin
			we <= '0;
		end else begin
			if (state == NY && href == 1'b1) begin
				we <= ~we_go;
			end else begin
				we <= 0;
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
					IDLE: 	state <= NY;
					NY:		state <= Y;
					Y:		state <= NY;
					default : ;
				endcase
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