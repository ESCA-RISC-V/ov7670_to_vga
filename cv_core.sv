//////////////////////////////////////////////////////////////////////////////////
// Company: Embedded Computing Lab, Korea University
// Engineer: Kwon Guyun
//           1216kg@naver.com
// 
// Create Date: 2021/07/01 11:04:31
// Design Name: ov7670_core
// Module Name: ov7670_core
// Project Name: project_ov7670
// Target Devices: zedboard
// Tool Versions: Vivado 2019.1
// Description: get a image like data and process it before send it to vga and lenet
//              
// Dependencies: 
// 
// Revision 1.00 - first well-activate version
// Additional Comments: reference design: http://www.nazim.ru/2512
//                                        can change center image to lower resolution
// 
//////////////////////////////////////////////////////////////////////////////////
module core #(
            parameter width = 640,
            parameter height = 480,
            
            localparam c_frame = width * height + 1
            )
            (
			input                         clk25,
			input        [7:0]	          din,
			input                         lenet_signal,
			input                         rst_n,
			
			output       [18:0]	          addr_mem0,
			output       [18:0]	          addr_mem1,
			output logic [3:0]	          dout,
			output logic                  we
			);
	
	
	logic[18:0]	counter;
	logic[18:0]	address_mem0;
	logic[18:0] address_mem1;

    assign addr_mem0 = address_mem0;
    assign addr_mem1 = address_mem1 - 1;
    
// counter - count per pixel - used for checking one frame processing ends.
    always_ff @(posedge clk25 or negedge rst_n) begin : proc_counter                                        
        if(~rst_n) begin
            counter <= '0;
        end else begin
            if (counter == c_frame) begin
                counter <= '0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

// address_mem0 - address of pixel of input data
    always_ff @(posedge clk25 or negedge rst_n) begin : proc_address_mem0                                   
        if(~rst_n) begin
            address_mem0 <= '0;
        end else begin
            if (counter == c_frame) begin
                address_mem0 <= '0;
            end else begin
                address_mem0 <= address_mem0 + 1;
            end
        end
    end

// address for ouput image's pixel - this will be shown on the monitor
    always_ff @(posedge clk25 or negedge rst_n) begin : proc_address_mem1                                   
        if(~rst_n) begin
            address_mem1 <= 0;
        end else begin
            if (counter == c_frame) begin
                address_mem1 <= 0;
            end else begin
                address_mem1 <= address_mem1 + 1;
            end
        end
    end
    
// vga output pixel data
    always_ff @(posedge clk25 or negedge rst_n) begin : proc_dout                                            
        if(~rst_n) begin
            dout <= '0;
        end else begin
            if (counter == c_frame) begin
                dout <= '0;
            end else begin
                dout <= din[7:4];
            end
        end
    end

// write enable of vga output pixel
    always_ff @(posedge clk25 or negedge rst_n) begin : proc_we                                             
        if(~rst_n) begin
            we <= 0;
        end else begin
            if (counter == c_frame) begin
                we <= '0;
            end else begin
                if (counter >= 1'b1) begin
                    we <= 1'b1;
                end
            end
        end
    end

    
endmodule // core