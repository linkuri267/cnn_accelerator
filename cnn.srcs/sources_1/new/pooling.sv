`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2018 04:29:26 PM
// Design Name: 
// Module Name: pooling
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Max pooling
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "cnn_parameters.v"


module pooling(
    input clk,
    input reset,
    input [68:0] data_in,
    output signed [`DATA_WIDTH - 1:0] final_image [`POOLED_IMAGE_SIZE - 1:0][`POOLED_IMAGE_SIZE - 1:0]
    );
    
    reg signed [`DATA_WIDTH - 1:0] pooled_image [`POOLED_IMAGE_SIZE - 1:0][`POOLED_IMAGE_SIZE - 1:0];
    reg signed [`DATA_WIDTH - 1:0] filtered_image_local [`DESTINATION_SIZE - 1:0][`DESTINATION_SIZE - 1:0];
    reg [`ROW_COUNTER_SIZE - 1:0] row_counter; 
    
    assign final_image = pooled_image;
    
    //state variables and declarations
    reg [3:0] state;
    reg done;
    localparam
    INITIAL = 4'b0001, WAIT  = 4'b0010, CALC= 4'b0100, DONE = 4'b1000;
    
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= INITIAL;
            row_counter <= 0;
            done <= 1'b0;
            for(int i = 0; i < `POOLED_IMAGE_SIZE; i ++) begin
                for(int j = 0; j < `POOLED_IMAGE_SIZE; j++) begin
                    pooled_image[i][j] <= 32'd0;
                end
            end
        end
        else begin
            case(state)
                INITIAL: begin
                    row_counter <= 0;
                    done <= 1'b0;
                    for(int i = 0; i < `POOLED_IMAGE_SIZE; i ++) begin
                        for(int j = 0; j < `POOLED_IMAGE_SIZE; j++) begin
                            pooled_image[i][j] <= 32'd0;
                        end
                    end
                    
                    if(data_in[68] == 1'b1) begin
                        filtered_image_local[0][0] <= data_in[31:0];
                        filtered_image_local[0][1] <= data_in [63:32];
                        state <= WAIT;
                    end
                end
                    
                WAIT: begin
                    
                end
                
                CALC: begin
                
                end
                
                DONE: begin
                    done <= 1'b1;
                end
            endcase
        end
    end
    
    
    
endmodule
