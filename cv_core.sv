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
			parameter hMaxCount = 640 + 16 + 96 + 48,
			parameter vMaxCount = 480 + 10 + 2 + 33,
            
            localparam c_frame = hMaxCount * vMaxCount - 1
            )
            (
			input                         clk24,
			input        [7:0]	          din,
			input                         rst_n,
			
			output       [18:0]	          addr_mem0,
			output       [18:0]	          addr_mem1,
			output logic [3:0]	          dout,
			output logic                  we,
			
			output logic                  core_end
			);
	
	
	logic[18:0]	counter;
	logic[10:0] hor, ver;
	logic[18:0]	address_mem0;
	logic[18:0] address_mem1;
    logic we_t;
    
    assign addr_mem0 = address_mem0;
    assign addr_mem1 = address_mem1;
    assign core_end = counter == c_frame;
    
// counter - count per pixel - used for checking one frame processing ends.
    always_ff @(posedge clk24 or negedge rst_n) begin : proc_counter                                        
        if(~rst_n) begin
            counter <= '0;
        end 
        else begin
            if (counter == c_frame) begin
                counter <= '0;
            end 
            else begin
                counter <= counter + 1;
            end
        end
    end

// address_mem0 - address of pixel of input data

    assign address_mem0 = hor < 720 && ver < 480 ? hor + ver * width : 0;
    
    always_ff @(posedge clk24 or negedge rst_n) begin : proc_hor_ver                                   
        if(~rst_n) begin
            hor <= 0;
            ver <= 0;
        end 
        else begin
            if (counter == c_frame) begin
                hor <= 0;
                ver <= 0;
            end 
            else begin
                if (hor == hMaxCount - 1) begin
                    hor <= 0;
                    ver <= ver + 1;
                end 
                else begin
                    hor <= hor + 1;
                end
            end
        end
    end    

// address for ouput image's pixel - this will be shown on the monitor
    always_ff @(posedge clk24 or negedge rst_n) begin : proc_address_mem1                                   
        if(~rst_n) begin
            address_mem1 <= 0;
        end 
        else begin
            address_mem1 <= address_mem0;
        end
    end
    
// vga output pixel data
    always_ff @(posedge clk24 or negedge rst_n) begin : proc_dout                                            
        if(~rst_n) begin
            dout <= '0;
        end 
        else begin
            if (counter == c_frame) begin
                dout <= '0;
            end 
            else begin
                dout <= din[7:4];
            end
        end
    end

// write enable of vga output pixel
    always_ff @(posedge clk24 or negedge rst_n) begin : proc_we                                             
        if(~rst_n) begin
            we <= 0;
            we_t <= 0;
        end 
        else begin
            we <= we_t;
            if (hor < width && ver < height) begin
                we_t <= 1'b1;
            end 
            else begin
                we_t <= 1'b0;
            end
        end
    end

    
endmodule // core