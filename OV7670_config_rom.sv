`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27/08/2021 11:28:05 PM
// Design Name: 
// Module Name: OV7670_config_rom
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


module OV7670_config_rom(
    input clk,
    input clk_en,
    input rst_n,
    input [7:0] addr,
    output logic [15:0] dout
    );
    //FFFF is end of rom, FFF0 is delay

    always_ff @(posedge clk or negedge rst_n) begin : proc_dout
        if(~rst_n) begin
            dout <= 0;
        end else if(clk_en) begin
            case(addr) 
            0:  dout <= 16'h12_80; // Reset registers
//          1:  dout <= 16'h12_01; // Set to RGB mode
//          2:  dout <= 16'h3A_06; // Change UYUV to YUYV
//          3:  dout <= 16'hFE_1A; // COM7      reading - work in progress (dout[15:8] == FE means reading register at dout[7:0])
//          4:  dout <= 16'h40_D0; //
//          3:  dout <= 16'h3A_06; // 
//          4:  dout <= 16'h0C_00; // COM3      Lots of stuff, enable scaling, all others off
//          5:  dout <= 16'h3E_00; // COM14     PCLK scaling off

//          6:  dout <= 16'h8C_00; // RGB444    Set RGB format
//          7:  dout <= 16'h04_00; // COM1      no CCIR601
//          8:  dout <= 16'h40_10; // COM15     Full 0-255 output, RGB 565
//          9:  dout <= 16'h3A_14; // TSLB      Set UV ordering,  do not auto-reset window
//          10: dout <= 16'h14_38; // COM9      AGC Celling
//          11: dout <= 16'h58_9E; // MTXS      Matrix sign and auto contrast
//          12: dout <= 16'h3D_88; // COM13     Turn on GAMMA and UV Auto adjust
//          13: dout <= 16'h11_00; // CLKRC     Prescaler - Fin/(1+1)

//          14: dout <= 16'h17_11; // HSTART    HREF start (high 8 bits)
//          15: dout <= 16'h18_61; // HSTOP     HREF stop (high 8 bits)
//          16: dout <= 16'h32_A4; // HREF      Edge offset and low 3 bits of HSTART and HSTOP

//          17: dout <= 16'h19_03; // VSTART    VSYNC start (high 8 bits)
//          18: dout <= 16'h1A_7B; // VSTOP     VSYNC stop (high 8 bits) 
//          19: dout <= 16'h03_0A; // VREF      VSYNC low two bits

            default: dout <= 16'hFF_FF;         //mark end of ROM
            endcase
        end
    end
endmodule