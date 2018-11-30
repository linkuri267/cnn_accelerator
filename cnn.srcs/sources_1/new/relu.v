`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2018 04:10:48 PM
// Design Name: 
// Module Name: relu
// Project Name: cnn
// Target Devices: 
// Tool Versions: 
// Description: 
// receives 2 data points, performs ReLU then sends output
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module relu(
    input clk,
    input reset,
    input [68:0] data_in,
    output [68:0] send_data,
    output send_data_en
    );
    
    reg send_data_en_reg;
    reg [68:0] send_data_reg;
    wire signed [31:0] data_in1_signed;
    wire signed [31:0] data_in2_signed;
    
    //1 bit isValid + 1 bit isTail + 2 bit destination + 1 bit VC + 64 bit data = 69 bit packet = 68:0
    
    assign send_data = send_data_reg;
    assign send_data_en = send_data_en_reg;
    
    assign data_in1_signed = data_in[31:0];
    assign data_in2_signed = data_in[63:32];
    
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            send_data_en_reg <= 1'b0;
            send_data_reg <= 69'd0;
        end
        else begin
            //if valid
            if(data_in[68] == 1'b1) begin
                //if not last piece of data
                //in 99x99, last piece of data will only contain 1 number (data_in[31:0])
                if(data_in[67] == 1'b0) begin
                   //if data1 is < 0, set output1 to 0
                   if(data_in1_signed < 0) begin
                    send_data_reg[31:0] <= 32'd0;
                   end 
                   else begin
                    send_data_reg[31:0] <= data_in1_signed;
                   end
                   //if data2 is < 0, set output2 to 0
                   if(data_in2_signed < 0) begin
                    send_data_reg[63:32] <= 32'd0;
                   end
                   else begin
                    send_data_reg[63:32] <= data_in2_signed;
                   end
                   //set tail to 0
                   send_data_reg[67] <= 1'b0;
                end
                else begin
                    if(data_in1_signed < 0) begin
                        send_data_reg[31:0] <= 32'd0;
                    end
                    else begin
                        send_data_reg[31:0] <= data_in1_signed;
                    end
                    send_data_reg[63:32] <= 32'd0;
                    //set tail to 1
                    send_data_reg[67] <= 1'b1;
                end
                //set valid to 1
                send_data_reg[68] <= 1'b1;
                //set destination to R1 (pooling layer)
                send_data_reg[66:65] <= 2'd1;
                //set virtual channel to 0
                send_data_reg[64] <= 1'b0;
                //set en reg to 1, will send on next clock
                send_data_en_reg <= 1'b1;
            end
            else begin
                send_data_en_reg <= 1'b0;
            end
        end 
    end
    
    
    
endmodule
