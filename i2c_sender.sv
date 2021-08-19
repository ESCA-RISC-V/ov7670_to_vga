//////////////////////////////////////////////////////////////////////////////////
// Company: Embedded Computing Lab, Korea University
// Engineer: Kwon Guyun
//           1216kg@naver.com
// 
// Create Date: 2021/07/01 11:04:31
// Design Name: i2c_sender
// Module Name: i2c_sender
// Project Name: project_ov7670
// Target Devices: zedboard
// Tool Versions: Vivado 2019.1
// Description: send register setting signal using i2c(sccb)
//               
//
// Dependencies: 
// 
// Revision 1.00 - first well-activate version
// Additional Comments: reference design: http://www.nazim.ru/2512
//                                        
//                                      
//////////////////////////////////////////////////////////////////////////////////
module i2c_sender (
                    input               clk,
                    output  logic       siod,
                    output  logic       sioc,
                    output  logic       taken,
                    input               send,
                    input         [7:0] id,
                    input         [7:0] regi,
                    input         [7:0] value,
                    input               rst_n
                   );

    logic[7:0]  divider;
    logic[31:0] busy_sr;
    logic[31:0] data_sr;
    logic       clklow;
    logic       cntmax ='d64;   // constant
    logic[5:0]  counter;
    

    always_comb begin : proc_siod
        if (busy_sr[11:10] == 2'b10 || busy_sr[20:19] == 2'b10 || busy_sr[29:28] == 2'b10) begin
            siod = 1'b0;
        end else begin
            siod = data_sr[31];
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin : proc_clklow
        if(~rst_n) begin
            clklow <= '0;
        end else begin
            if (counter == cntmax - 1) begin
                clklow <= ~clklow;
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin : proc_counter
        if(~rst_n) begin
            counter <= '0;
        end else begin
            if (counter == cntmax - 1) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin : proc_divider
        if(~rst_n) begin
            divider <= 8'b1;
        end else begin
            if (busy_sr[31] == 1'b0) begin
                if ( send == 1'b1) begin
                    if ( divider != 8'b0) begin
                        divider <= divider + 1;
                    end
                end
            end else begin
                if (divider == 8'hFF) begin
                    divider <= '0;
                end else begin
                    divider <= divider + 1;
                end
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin : proc_busy_sr
        if(~rst_n) begin
            busy_sr <= 0;
        end else begin
            if (busy_sr[31] == 1'b0) begin
                if (send == 1'b1) begin
                    if (divider == 8'b0) begin
                        busy_sr <= 32'hFFFF;
                    end
                end
            end else begin
                if (divider == 8'hFF) begin
                    busy_sr <= {busy_sr[30:0], 1'b0};
                end
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin : proc_data_sr
        if(~rst_n) begin
            data_sr <= 0;
        end else begin
            if (busy_sr[31] == 1'b0) begin
                if (send == 1'b1) begin
                    if (divider == 8'b0) begin
                        data_sr <= {3'b100, id, 1'b0, regi, 1'b0, value, 1'b0, 2'b00};
                    end
                end
            end else begin
                if (divider == 8'hFF) begin
                    data_sr <= {data_sr[30:0], 1'b1};
                end
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin : proc_taken
        if(~rst_n) begin
            taken <= '0;
        end else begin
            if (busy_sr[31] == 1'b0) begin
                if (send == 1'b1) begin
                    if (divider == 8'b0) begin
                        taken <= 1'b1;
                    end
                end
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin : proc_sioc
        if(~rst_n) begin
            sioc <= 1'b1;
        end else begin
            if (busy_sr[31] == 1'b0) begin
                sioc <= 1'b1;
            end else begin
                case ({busy_sr[31:29], busy_sr[2:0]})
                    6'b111111:
                        case (divider[7:6])
                            2'b00   : sioc <= 1'b1;
                            2'b01   : sioc <= 1'b1;
                            2'b10   : sioc <= 1'b1;
                            default : sioc <= 1'b1;
                        endcase
                    6'b111110:
                        case (divider[7:6])
                            2'b00   : sioc <= 1'b1;
                            2'b01   : sioc <= 1'b1;
                            2'b10   : sioc <= 1'b1;
                            default : sioc <= 1'b1;
                        endcase
                    6'b111100:
                        case (divider[7:6])
                            2'b00   : sioc <= 1'b0;
                            2'b01   : sioc <= 1'b0;
                            2'b10   : sioc <= 1'b0;
                            default : sioc <= 1'b0;
                        endcase
                    6'b110000:
                        case (divider[7:6])
                            2'b00   : sioc <= 1'b0;
                            2'b01   : sioc <= 1'b1;
                            2'b10   : sioc <= 1'b1;
                            default : sioc <= 1'b1;
                        endcase
                    6'b100000:
                        case (divider[7:6])
                            2'b00   : sioc <= 1'b1;
                            2'b01   : sioc <= 1'b1;
                            2'b10   : sioc <= 1'b1;
                            default : sioc <= 1'b1;
                        endcase
                    6'b000000:
                        case (divider[7:6])
                            2'b00   : sioc <= 1'b1;
                            2'b01   : sioc <= 1'b1;
                            2'b10   : sioc <= 1'b1;
                            default : sioc <= 1'b1;
                        endcase
                    default : 
                        case (divider[7:6])
                            2'b00   : sioc <= 1'b0;
                            2'b01   : sioc <= 1'b1;
                            2'b10   : sioc <= 1'b1;
                            default : sioc <= 1'b0;
                        endcase
                endcase
            end
        end
    end

endmodule // i2c_sender