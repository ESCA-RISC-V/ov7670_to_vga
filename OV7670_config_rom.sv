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
        end 
        else if(clk_en) begin
            case(addr) 
                0:  dout <= 16'h12_80; // Reset registers
    //          1:  dout <= 16'h12_01; // Set to RGB mode
    //          2:  dout <= 16'h3A_06; // Change UYUV to YUYV
    //          3:  dout <= 16'hFE_1A; // COM7      reading - work in progress (dout[15:8] == FE means reading register at dout[7:0])
    
                default: dout <= 16'hFF_FF;         //mark end of ROM
            endcase
        end
    end
endmodule