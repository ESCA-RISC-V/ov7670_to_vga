`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26/08/2021 11:27:03 AM
// Design Name: 
// Module Name: camera_configure
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


module camera_configure
    #(
    parameter CLK_FREQ=25000000
    )
    (
    input clk,
    input clk_en,
    input rst_n,
    output sioc,
    output siod,
    output done,
    output reset,
    output pwdn,
    output xclk
    );
    
    logic sys_clk;
    logic start;

    assign reset = 1'b1;
    assign pwdn = 1'b0;
    assign xclk = sys_clk;

    always_ff @(posedge clk or negedge rst_n) begin : proc_sys_clk
        if(~rst_n) begin
            sys_clk <= 0;
        end else if(clk_en && done) begin
            sys_clk <= ~sys_clk;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin : proc_start
        if(~rst_n) begin
            start <= 1;
        end else if(clk_en) begin
            start <= 0;
        end
    end

    wire [7:0] rom_addr;
    wire [15:0] rom_dout;
    wire [7:0] SCCB_addr;
    wire [7:0] SCCB_data;
    wire SCCB_start;
    wire SCCB_ready;
    wire SCCB_SIOC_oe;
    wire SCCB_SIOD_oe;
    
    assign sioc = SCCB_SIOC_oe ? 1'b0 : 1'b1;
    assign siod = SCCB_SIOD_oe ? 1'b0 : 1'b1;

    OV7670_config_rom rom1(
        .clk(clk),
        .clk_en(clk_en),
        .rst_n(rst_n),              
        .addr(rom_addr),        
        .dout(rom_dout)
        );
        
    OV7670_config #(.CLK_FREQ(CLK_FREQ)) config_1(
        .clk(clk),
        .clk_en(clk_en),
        .rst_n(rst_n),
        .SCCB_interface_ready(SCCB_ready),
        .rom_data(rom_dout),
        .start(start),
        .rom_addr(rom_addr),
        .done(done),
        .SCCB_interface_addr(SCCB_addr),
        .SCCB_interface_data(SCCB_data),
        .SCCB_interface_start(SCCB_start)
        );
    
    SCCB_interface #( .CLK_FREQ(CLK_FREQ)) SCCB1(
        .clk(clk),
        .clk_en(clk_en),
        .rst_n(rst_n),
        .start(SCCB_start),
        .address(SCCB_addr),
        .data(SCCB_data),
        .ready(SCCB_ready),
        .SIOC_oe(SCCB_SIOC_oe),
        .SIOD_oe(SCCB_SIOD_oe)
        );
    
endmodule
