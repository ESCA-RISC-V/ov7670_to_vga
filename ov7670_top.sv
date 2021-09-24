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
                    parameter screenheight = 480
                    
                    )(
					input 	     		    clk100_zed,
					output      			OV7670_SIOC,                           // similar with I2C's SCL
					inout 	     			OV7670_SIOD,                           // similar with I2C's SDA
					output      			OV7670_RESET,                          // ov7670 reset
					output      			OV7670_PWDN,                           // ov7670 power down
					input 	     			OV7670_VSYNC,                          // ov7670 vertical sync
					input 	     			OV7670_HREF,                           // ov7670 horizontal reference
					input 	     			OV7670_PCLK,                           // ov7670 pclock
					output      			OV7670_XCLK,                           // ov7670 xclock
					input 	       [7:0] 	OV7670_D,                              // ov7670 data
		
					output         [7:0]    LED,                                   // zedboard_LED
		
					output         [3:0]	vga_red,                               // vga red output
					output	       [3:0]	vga_green,                             // vga green output
					output	       [3:0]	vga_blue,                              // vga blue output
					output	                vga_hsync,                             // vga horizontal sync
					output	                vga_vsync,                             // vga vertical sync

					input                   PAD_RESET,
					input 	       [7:0]	SW                                    // zedboard SW (switch )
					);
        
	// clocks
	logic			clk100;
	logic			clk75;
	logic			clk50;
	logic 			clk25;
	// capture to mem_blk_0
	logic [18:0]	capture_addr;
	logic [7:0] 	capture_data;
	logic [1:0]		capture_we;
	// mem_blk_1 to vga
	logic [18:0]	frame_addr;
	logic [11:0]    frame_pixel;
	
	// controller to LED
	logic 			config_finished;
	
    wire rst_n = ~PAD_RESET;

    assign LED = {SW[7:1], config_finished};             // show LED some informations
    
		clk_wiz_0 clkwiz(                                             // clock generator
			.clk_in_wiz(clk100_zed),
			.clk_100wiz(clk100),
			.clk_75wiz(clk75),
			.clk_50wiz(clk50),
			.clk_25wiz(clk25),
			.resetn(rst_n)
			);                                                       

		ov7670_capture icapture(                                      // gets datas from ov7670 and stores them to fb1
			.pclk(OV7670_PCLK),
			.vsync(OV7670_VSYNC),
			.href(OV7670_HREF),
			.sw(SW[7]),
			.rst_n(rst_n),
			.din(OV7670_D),
			.addr(capture_addr),
			.dout(capture_data),
			.we(capture_we)
			);

    	blk_mem_gen_0 red4green3(                                             // stores captured data
			.clka(OV7670_PCLK),
			.wea(capture_we[1]),
			.addra(capture_addr),
			.dina({capture_data[7:4], capture_data[2:0]}),

			.clkb(clk50),
			.addrb(frame_addr),
			.doutb(frame_pixel[11:5])
			);
			
        blk_mem_gen_1 green1blue4(                                             // stores captured data
			.clka(OV7670_PCLK),
			.wea(capture_we[0]),
			.addra(capture_addr),
			.dina({capture_data[7], capture_data[4:1]}),

			.clkb(clk50),
			.addrb(frame_addr),
			.doutb(frame_pixel[4:0])
			);
			
		vga #(
		     .hRez(640),
		     .hStartSync(640 + 16),
		     .hEndSync(640 + 16 + 96),
		     .hMaxCount(640 + 16 + 96 + 48),
		     .vRez(480),
		     .vStartSync(480 + 10),
		     .vEndSync(480 + 10 + 2),
		     .vMaxCount(480 + 10 + 2 + 33),
		     .hsync_active(1'b0),
		     .vsync_active(1'b0)
		     )ivga(                                                     // loads data from fb and sends it to vga output
			.clk25(clk25),
			.rst_n(rst_n),
			.frame_addr(frame_addr),
			.frame_pixel(frame_pixel),
			.vga_red(vga_red),
			.vga_green(vga_green),
			.vga_blue(vga_blue),
			.vga_hsync(vga_hsync),
			.vga_vsync(vga_vsync),
			.switches(SW[6:4])
			);

        camera_configure #(
          .CLK_FREQ(25000000)
            )configure(
		  .clk(clk25),
		  .sclk(clk100),
		  .clk_en(1'b1),
		  .rst_n(rst_n),
		  .sioc(OV7670_SIOC),
          .siod(OV7670_SIOD),
          .done(config_finished),
          .pwdn(OV7670_PWDN),
          .reset(OV7670_RESET),
          .xclk(OV7670_XCLK)
		  );

endmodule // ov7670_top