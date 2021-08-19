//////////////////////////////////////////////////////////////////////////////////
// Company: Embedded Computing Lab, Korea University
// Engineer: Kwon Guyun
//           1216kg@naver.com
// 
// Create Date: 2021/07/01 11:04:31
// Design Name: vga
// Module Name: vga
// Project Name: project_ov7670
// Target Devices: zedboard
// Tool Versions: Vivado 2019.1
// Description: get a image like data send it by using vga port
//               
//
// Dependencies: 
// 
// Revision 1.00 - first well-activate version
// Additional Comments: reference design: http://www.nazim.ru/2512
//                                        can show lenet output at top left corner
//                                      
//////////////////////////////////////////////////////////////////////////////////
module vga	 
			#(
			parameter hRez = 640,
			parameter hStartSync = 640 + 16,
			parameter hEndSync = 640 + 16 + 96,
			parameter hMaxCount = 800,

			parameter vRez = 480,
			parameter vStartSync = 480 + 10,
			parameter vEndSync = 480 + 10 + 2,
			parameter vMaxCount = 480 + 10 + 2 + 33,

			parameter hsync_active = 1'b0,
			parameter vsync_active = 1'b0
			)
			(
			input                clk25,
			input        [3:0]   frame_pixel,
			input                rst_n,
			output       [18:0]	 frame_addr,
			output logic [3:0]	 vga_red,
			output logic [3:0]	 vga_green,
			output logic [3:0]	 vga_blue,
			output logic 		 vga_hsync,
			output logic		 vga_vsync
			);



	logic [9:0]	   hCounter;
	logic [9:0]	   vCounter;
	logic [18:0]   address;
	logic 		   blank;
	
	assign frame_addr = address;

	always_ff @(posedge clk25 or negedge rst_n) begin : proc_hCounter                  // horizontal counter of vga output
		if(~rst_n) begin
			hCounter <= '0;
		end else begin
			if (hCounter == hMaxCount - 1) begin
				hCounter <= 10'b0;
			end else begin
				hCounter <= hCounter + 1;
			end
		end
	end

	always_ff @(posedge clk25 or negedge rst_n) begin : proc_vCounter                  // vertical counter of vga output
		if(~rst_n) begin
			vCounter <= '0;
		end else begin
			if (hCounter == hMaxCount - 1) begin
				if (vCounter == vMaxCount - 1) begin
					vCounter <= 10'b0;
				end else begin
					vCounter <= vCounter + 1;
				end
			end
		end
	end

	always_ff @(posedge clk25 or negedge rst_n) begin : proc_address                   // address of vga output pixel
		if(~rst_n) begin
			address <= 0;
		end else begin
			if (vCounter >= vRez) begin
				address <= 19'b0;
			end else begin
				if (hCounter < hRez) begin
					address <= address + 1;
				end
			end
		end
	end

	always_ff @(posedge clk25 or negedge rst_n) begin : proc_blank                     // whether send pixel value or not
		if(~rst_n) begin
			blank <= 1'b1;
		end else begin
			if (vCounter >= vRez) begin
				blank <= 1'b1;
			end else begin
				if (hCounter < hRez) begin
					blank <= 1'b0;
				end else begin
					blank <= 1'b1;
				end
			end
		end
	end

	always_ff @(posedge clk25 or negedge rst_n) begin : proc_vga_rgb                   // vga_rgb value
		if(~rst_n) begin
			{vga_red, vga_green, vga_blue} <= '0;
		end else begin
			if (blank == 1'b0) begin
                vga_red <= frame_pixel;
                vga_green <= frame_pixel;
                vga_blue <= frame_pixel;
			end else begin
                vga_red <= 4'b0;
                vga_green <= 4'b0;
                vga_blue <= 4'b0;
			end
		end
	end

	always_ff @(posedge clk25 or negedge rst_n) begin : proc_vga_hsync                 // vga horizontal sync
		if(~rst_n) begin
			vga_hsync <= ~hsync_active;
		end else begin
			if (hCounter > hStartSync && hCounter <= hEndSync) begin
				vga_hsync <= hsync_active;
			end else begin
				vga_hsync <= ~hsync_active;
			end
		end
	end

	always_ff @(posedge clk25 or negedge rst_n) begin : proc_vga_vsync                 // vga vertical sync
		if(~rst_n) begin
			vga_vsync <= ~vsync_active;
		end else begin
			if (vCounter >= vStartSync && vCounter < vEndSync) begin
				vga_vsync <= vsync_active;
			end else begin
				vga_vsync <= ~vsync_active;
			end
		end
	end

endmodule // vga