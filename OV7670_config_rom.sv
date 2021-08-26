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
            0:  dout <= 16'h12_80; //reset
            1:  dout <= 16'hFF_F0; //delay
            2:  dout <= 16'h12_00; 
            3:  dout <= 16'h11_00; 
            4:  dout <= 16'h0C_00; 
            5:  dout <= 16'h3E_00; 
            6:  dout <= 16'h8C_00; 
            7:  dout <= 16'h04_00; 
            8:  dout <= 16'h40_10; 
            9:  dout <= 16'h3A_14; 
            10: dout <= 16'h14_38; 
            //11: dout <= 16'h58_9E; 
            //12: dout <= 16'h3D_88; 
            //13: dout <= 16'h11_00; 
            //14: dout <= 16'h17_11; 
            //15: dout <= 16'h18_61; 
            //16: dout <= 16'h32_A4; 
            //17: dout <= 16'h19_03; 
            //18: dout <= 16'h1A_7B; 
            //19: dout <= 16'h03_0A;
            default: dout <= 16'hFF_FF;         //mark end of ROM
            endcase
        end
    end
endmodule
