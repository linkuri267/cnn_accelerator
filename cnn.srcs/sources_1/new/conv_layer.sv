`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2018 05:45:26 PM
// Design Name: 
// Module Name: conv_layer
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

`include "cnn_parameters.v"

 
module conv_layer(
    input clk,
    input reset,
    input start,
    input signed [`DATA_WIDTH - 1:0] kernel [`KERNEL_SIZE - 1:0][`KERNEL_SIZE - 1:0],
    output signed [`DATA_WIDTH - 1:0] destination [`DESTINATION_SIZE - 1:0][`DESTINATION_SIZE - 1:0]
    );
    
    //state reg and declarations
    reg [2:0] state;
    localparam 
    INITIAL = 3'b001, CALC = 3'b010, DONE = 3'b100;
    
    //local regs
    reg signed [`DATA_WIDTH - 1:0] source_local [`SOURCE_SIZE - 1:0][`SOURCE_SIZE - 1:0];
    reg signed [`DATA_WIDTH - 1:0] kernel_local [`KERNEL_SIZE - 1:0][`KERNEL_SIZE - 1:0];
    reg signed [`DATA_WIDTH - 1:0] destination_local [`DESTINATION_SIZE - 1:0][`DESTINATION_SIZE - 1:0];
    
    reg [6:0] v_offset;
    reg [6:0] h_offset;
//    reg [3:0] v_offset_local;
//    reg [3:0] h_offset_local;
    
    reg done;
    
    assign destination = destination_local;
    
    
    initial begin
            integer fsource;
            fsource = $fopen("source.mem","r");
            for(int i = 0; i < `SOURCE_SIZE; i++) begin
                for(int j = 0; j < `SOURCE_SIZE; j++) begin
                    $fscanf(fsource,"%hh",source_local[`SOURCE_SIZE - i - 1][`SOURCE_SIZE - j - 1]);
                end
            end
        
    end
    
    
    always @(posedge clk, posedge reset) begin
        if(reset) begin
                
            for(int i = 0; i < `KERNEL_SIZE; i ++) begin
                for(int j = 0; j < `KERNEL_SIZE; j++) begin
                    kernel_local[i][j] <= 8'd0;
                end
            end
            for(int i = 0; i < `DESTINATION_SIZE; i ++) begin
                for(int j = 0; j < `DESTINATION_SIZE; j++) begin
                    destination_local[i][j] <= 8'd0;
                end
            end
            
            v_offset <= 7'b0;
            h_offset <= 7'b0;
            
            done <= 1'b0;
            
            
            //set initial state
            state <= INITIAL;
            
            
        end
        else begin
            case(state) 
                INITIAL: begin
                    //load inputs into local register
                    kernel_local <= kernel;
                    for(int i = 0; i < `DESTINATION_SIZE; i ++) begin
                        for(int j = 0; j < `DESTINATION_SIZE; j++) begin
                            destination_local[i][j] <= 8'd0;
                        end
                    end
                    
                    if(start) begin
                        state <= CALC;
                    end
                end
                
                CALC: begin

                      for(int i = 0; i < `KERNEL_SIZE; i++) begin
                        for(int j = 0; j < `KERNEL_SIZE; j++) begin
                            destination_local[v_offset][h_offset] = destination_local[v_offset][h_offset] + (kernel_local[i][j]*source_local[v_offset+i][h_offset+j]);
                        end
                      end


                      
                      if(h_offset == `DESTINATION_SIZE - 1) begin
                        if(v_offset == `DESTINATION_SIZE -1) begin
                            state <= DONE;
                        end
                        else begin
                            h_offset <= 4'b0;
                            v_offset <= v_offset + 1;
                        end
                      end
                      else begin
                        h_offset <= h_offset + 1;
                      end
                      
                      //PURELY SEQUENTIAL METHOD COMMENTED OUT
                    
//                    destination_local[v_offset][h_offset] <= destination_local[v_offset][h_offset] + (kernel_local[v_offset_local][h_offset_local]*source_local[v_offset+v_offset_local][h_offset+h_offset_local]);

//                    //destination_local[v_offset][h_offset] <= 8'd120;
                    
//                   //if at last element and all done with convolution 
//                    if((v_offset == `DESTINATION_SIZE - 1)&&(h_offset == `DESTINATION_SIZE - 1)&&(v_offset_local == `KERNEL_SIZE - 1)&&(h_offset_local == `KERNEL_SIZE - 1)) begin
//                       state <= DONE; 
//                    end
                    
//                    //if at the end of row and all done with convolution
//                    else if((h_offset == `DESTINATION_SIZE - 1)&&(v_offset_local == `KERNEL_SIZE -1)&&(h_offset_local == `KERNEL_SIZE - 1)) begin
//                        v_offset <= v_offset + 1;
//                        h_offset <= 7'b0;
//                        v_offset_local <= 4'b0;
//                        h_offset_local <= 4'b0;
//                    end
                    
//                    //if all done with convolution
//                    else if((h_offset_local == `KERNEL_SIZE - 1)&&(v_offset_local == `KERNEL_SIZE -1)) begin
//                        h_offset <= h_offset + 1;
//                        v_offset_local <= 4'b0;
//                        h_offset_local <= 4'b0;
//                    end
                    
//                    //if at the end of row convolution
//                    else if(h_offset_local == `KERNEL_SIZE -1) begin
//                        v_offset_local <= v_offset_local + 1;
//                        h_offset_local <= 4'b0;
//                    end
//                    else begin
//                        h_offset_local <= h_offset_local + 1;
//                    end

                end
                
                DONE: begin
                   done <= 1'b1;
                end
                  
            endcase
        end 
    end
    
     
    
    
endmodule
