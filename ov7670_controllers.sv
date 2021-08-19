//////////////////////////////////////////////////////////////////////////////////
// Company: Embedded Computing Lab, Korea University
// Engineer: Kwon Guyun
//           1216kg@naver.com
// 
// Create Date: 2021/07/01 11:04:31
// Design Name: ov7670_controllers
// Module Name: ov7670_controllers
// Project Name: project_ov7670
// Target Devices: zedboard
// Tool Versions: Vivado 2019.1
// Description: set registers of ov7670
//               
//
// Dependencies: i2c_senders.sv
//               ov7670_registers.sv
// 
// Revision 1.00 - first well-activate version
// Additional Comments: reference design: http://www.nazim.ru/2512
//                                        
//                                      
//////////////////////////////////////////////////////////////////////////////////
module ov7670_controller	#(
							parameter camera_address = 8'h42
							)(
							input            clk,
							input            rst_n,
							output           config_finished,
							output           sioc,
							inout            siod,
							output           reset,
							output           pwdn,
							output           xclk
							);
	logic 			sys_clk;
	logic [15:0]	command;
	logic 			finished;
	logic 			taken;
	logic 			send;

	assign config_finished = finished;
 	assign send = ~finished;
    assign reset = 1'b1;
	assign pwdn = 1'b0;
	assign xclk = sys_clk;
	

	i2c_sender Inst_i2c_sender(
		.clk(clk),
		.taken(taken),
		.siod(siod),
		.sioc(sioc),
		.send(send),
		.id(camera_address),
		.regi(command[15:8]),
		.value(command[7:0]),
		.rst_n(rst_n)
		);

	ov7670_registers Inst_ov7670_registers(
		.clk(clk),
		.advance(taken),
		.command(command),
		.finished(finished),
		.rst_n(rst_n)
		);

	always_ff @(posedge clk or negedge rst_n) begin : proc_sys_clk
	    if(~rst_n) begin
            sys_clk <= '0;
	    end else begin
		    sys_clk <= ~sys_clk;
		end
	end
endmodule