//////////////////////////////////////////////////////////////////////////////////
// Company: Embedded Computing Lab, Korea University
// Engineer: Kwon Guyun
//           1216kg@naver.com
// 
// Create Date: 2021/07/01 11:04:31
// Design Name: ov7670_top
// Module Name: ov7670_top
// Project Name: project_ov7670
// Target Devices: zedboard
// Tool Versions: Vivado 2019.1
// Description: top module of ov7670 to VGA and doing lenet inference
// 
// Dependencies: 
// 
// Revision 1.00 - first well-activate version
// Additional Comments: reference design - ov7670 to vga: http://www.nazim.ru/2512
//                      reference design - lenet: https://github.com/lulinchen/cnn_open
//                      up button - reset ov7670
//                      switch 4 - show cnn output
//                      switch 5 - show resolution change image
//                      switch 6 - pause image
//                      switch 7 - change resolution and start lenet inference
//////////////////////////////////////////////////////////////////////////////////


module ov7670_top	#(
                    parameter screenwidth = 640,
                    parameter screenheight = 480,
                    parameter hMaxCount = 800,
                    parameter vMaxCount = 525
                    )(
					input 	     		  clk100_zed,
					output      			OV7670_SIOC,  // similar with I2C's SCL
					inout 	     			OV7670_SIOD,  // similar with I2C's SDA
					output      			OV7670_RESET, // ov7670 reset
					output      			OV7670_PWDN,  // ov7670 power down
					input 	     			OV7670_VSYNC, // ov7670 vertical sync
					input 	     			OV7670_HREF,  // ov7670 horizontal reference
					input 	     			OV7670_PCLK,  // ov7670 pclock
					output      			OV7670_XCLK,  // ov7670 xclock
					input 	       [7:0] 	OV7670_D,     // ov7670 data
		
					output         [7:0]    LED,          // zedboard_LED
		
					output         [3:0]	vga_red,      // vga red output
					output	       [3:0]	vga_green,    // vga green output
					output	       [3:0]	vga_blue,     // vga blue output
					output	                vga_hsync,    // vga horizontal sync
					output	                vga_vsync,    // vga vertical sync

					input                   PAD_RESET,
					input 	       [7:0]	SW            // zedboard SW (switch )
					);
        
	// clocks
	logic			clk48;
	logic			clk48_180shift;
	logic 			clk24;
	logic			clk24_180shift;
	// capture to mem_blk_0
	logic [18:0]	capture_addr;
	logic [7:0] 	capture_data;
	logic [0:0]		capture_we;
	// mem_blk_0 -> core -> mem_blk_1
	logic [7:0]		data_to_core;
	logic [3:0]		data_from_core;
	logic [18:0]	addr_core_to_mem0;
	logic [18:0]	addr_core_to_mem1;
	logic [0:0]		we_core_to_mem1;
	// mem_blk_1 to vga
	logic [18:0]	frame_addr;
	logic [3:0]		frame_pixel;
	// controller to LED
	logic 			config_finished;
	logic [7:0]     read;
	logic           capture_end, core_end;
	
	
    wire rst_n = ~PAD_RESET;
	
// show some informations with LED
    assign LED = {SW[7:1], config_finished};

// clock generator
		clk_wiz_0 clkwiz(
			.clk_in_wiz(clk100_zed),
			.clk_48wiz(clk48),
			.clk_48wiz_180shift(clk48_180shift),
			.clk_24wiz(clk24),
			.clk_24wiz_180shift(clk24_180shift),
			.resetn(rst_n)
			);                                  
			                     
// gets datas from ov7670 and stores them to captured_data
		ov7670_capture icapture(
			.pclk(OV7670_PCLK),
			.vsync(OV7670_VSYNC),
			.href(OV7670_HREF),
			.sw(SW[7]),
			.rst_n(rst_n),
			.din(OV7670_D),
			.addr(capture_addr),
			.dout(capture_data),
			.we(capture_we[0]),
			.capture_end(capture_end)
			);

// stores captured data
    	blk_mem_gen_0 captured_data(
			.clka(OV7670_PCLK),
			.wea(capture_we),
			.addra(capture_addr),
			.dina(capture_data),

			.clkb(clk24_180shift), // you can replace clk24 with 50 phase shift with !clk24
			.addrb(addr_core_to_mem0),
			.doutb(data_to_core)
			);

// loads data from captured_data and processes it, 
// stores processed data to processed_data_for_vga, 
// you can modify this module to change vga output or anything else
		core #(
		    .width(screenwidth),
		    .height(screenheight),
		    .hMaxCount(hMaxCount),
		    .vMaxCount(vMaxCount)
		    )icore(                                                   
			.clk24(clk24),
			.din(data_to_core),
			.rst_n(rst_n),
			.addr_mem0(addr_core_to_mem0),
			.addr_mem1(addr_core_to_mem1),
			.dout(data_from_core),
			.we(we_core_to_mem1[0]),
			.core_end(core_end)
			);

// stores processed data, connected with vga module
		blk_mem_gen_1 processed_data_for_vga(                                            
			.clka(clk24),
			.wea(we_core_to_mem1),
			.addra(addr_core_to_mem1),
			.dina(data_from_core),

			.clkb(clk24_180shift),
			.addrb(frame_addr),
			.doutb(frame_pixel)
			);

// loads data from fb and sends it to vga output
		vga #(
		     .hRez(640),
		     .hStartSync(640 + 16),
		     .hEndSync(640 + 16 + 96),
		     .hMaxCount(hMaxCount),
		     .vRez(480),
		     .vStartSync(480 + 10),
		     .vEndSync(480 + 10 + 2),
		     .vMaxCount(vMaxCount),
		     .hsync_active(1'b0),
		     .vsync_active(1'b0)
		     )ivga(                                                     
			.clk24(clk24),
			.rst_n(rst_n),
			.frame_addr(frame_addr),
			.frame_pixel(frame_pixel),
			.vga_red(vga_red),
			.vga_green(vga_green),
			.vga_blue(vga_blue),
			.vga_hsync(vga_hsync),
			.vga_vsync(vga_vsync)
			);

// SCCB comunication with OV7670
        camera_configure #(
          .CLK_FREQ(25000000)
            )configure(
		  .clk(clk24),
		  .sclk(clk48),
		  .clk_en(1'b1),
		  .rst_n(rst_n),
		  .sioc(OV7670_SIOC),
          .siod(OV7670_SIOD),
          .done(config_finished),
          .pwdn(OV7670_PWDN),
          .reset(OV7670_RESET),
          .xclk(OV7670_XCLK),
          .read(read),
          .capture_end(capture_end),
          .core_end(core_end)
		  );

endmodule // ov7670_top