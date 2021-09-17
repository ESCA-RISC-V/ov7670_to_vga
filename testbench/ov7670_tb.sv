`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/06 14:25:31
// Design Name: 
// Module Name: ov7670_tb
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


module ov7670_tb(
    );
    parameter CLK_PERIOD = 10;
    
    logic clkgen;
    logic pclkgen;
    logic rst_n;
    logic [7:0] sw;
    logic [7:0] d;
    logic href;
    logic vsync;
    logic [31:0] counter;

    initial begin
        clkgen = 0;        
        #(CLK_PERIOD);
        forever clkgen = #(CLK_PERIOD/2) ~clkgen;
    end
   
    initial begin
        pclkgen = 0;        
        #(8);
        forever pclkgen = #(CLK_PERIOD/2) ~pclkgen;
    end
   
    initial begin
        rst_n = 0;
        #(10);
        rst_n = 1;
    end
    
    initial begin
        sw = 8'b00110000;
    end
    
    always_ff @(posedge !pclkgen or negedge rst_n) begin : proc_d
        if(~rst_n) begin
            d <= 0;
        end else begin
            if (href) begin
                if (counter % 2 == 0) begin
                    d <= d+16;
                end
            end
        end
    end

    always_ff @(posedge !pclkgen or negedge rst_n) begin : proc_counter
        if(~rst_n) begin
            counter <= 0;
        end else begin
            if (counter == 2 * 784 * 510 - 1) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

    always_ff @(posedge !pclkgen or negedge rst_n) begin : proc_vsync
        if(~rst_n) begin
            vsync <= 0;
        end else begin
            if (counter == 0) begin
                vsync <= 1;
            end else if (counter == 2 * 784 * 3) begin
                vsync <= 0;
            end
        end
    end

    always_ff @(posedge !pclkgen or negedge rst_n) begin : proc_href
        if(~rst_n) begin
            href <= 0;
        end else begin
            if (counter < 2 * 784 * 20 || counter >= 2 * 784 * 500) begin
                href <= 0;
            end else if (counter % (784*2) == 0) begin
                href <= 1;
            end else if (counter % (784*2) == 640 * 2) begin
                href <= 0;
            end
        end
    end


    ov7670_top #(
        )tb_top(
        .clk100_zed(clkgen),
        .OV7670_SIOC(),
        .OV7670_SIOD(),
        .OV7670_RESET(),
        .OV7670_PWDN(),
        .OV7670_VSYNC(vsync),
        .OV7670_HREF(href),
        .OV7670_PCLK(pclkgen),
        .OV7670_XCLK(),
        .OV7670_D(d),
        .LED(),
        .vga_red(),
        .vga_green(),
        .vga_blue(),
        .vga_hsync(),
        .vga_vsync(),
        .PAD_RESET(~rst_n),
        .SW(sw)
        );
    
endmodule
