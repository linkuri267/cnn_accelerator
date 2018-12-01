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
    output signed [`DATA_WIDTH - 1:0] destination [`DESTINATION_SIZE - 1:0][`DESTINATION_SIZE - 1:0],
    output [68:0] send_data,
    output send_data_en
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
    
    //NOC registers
    reg counter;
    reg [68:0] flit_buffer;
    reg send_data_en_reg;
    
    assign send_data = flit_buffer;
    assign send_data_en = send_data_en_reg;
    
    
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
                
            for(int i_k = 0; i_k < `KERNEL_SIZE; i_k = i_k + 1) begin
                for(int j_k = 0; j_k < `KERNEL_SIZE; j_k = j_k + 1) begin
                    kernel_local [`KERNEL_SIZE - i_k - 1][`KERNEL_SIZE - j_k - 1] <= j_k + i_k*`KERNEL_SIZE;
                end
            end
            for(int i = 0; i < `DESTINATION_SIZE; i ++) begin
                for(int j = 0; j < `DESTINATION_SIZE; j++) begin
                    destination_local[i][j] <= 32'd0;
                end
            end
            
            v_offset <= 7'b0;
            h_offset <= 7'b0;
            
            done <= 1'b0;
            
            //NOC registers
            counter <= 1'b0;
            flit_buffer <= 69'd0;
            send_data_en_reg <= 1'b0;
            
            //set initial state
            state <= INITIAL;
            
            
        end
        else begin
            case(state) 
                INITIAL: begin
                    //load inputs into local register
                    for(int i = 0; i < `DESTINATION_SIZE; i ++) begin
                        for(int j = 0; j < `DESTINATION_SIZE; j++) begin
                            destination_local[i][j] <= 8'd0;
                        end
                    end
                    
                    
                    flit_buffer[68] <= 1'b1; //set valid to 1
                    flit_buffer[66:65] <= 2'd0; //destination is R0 (reLU layer)
                    flit_buffer[64] <= 1'b0;
                    
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
                            if((`DESTINATION_SIZE % 2) == 0) begin
                                flit_buffer[63:32] <= destination_local[v_offset][h_offset];
                            end
                            else begin
                                flit_buffer[31:0] <= destination_local[v_offset][h_offset];
                            end
                            flit_buffer[67] <= 1'b1; //last flit, set tail to 1
                            
                        end
                        else begin
                            h_offset <= 4'b0;
                            v_offset <= v_offset + 1;
                        end
                      end
                      else begin
                        h_offset <= h_offset + 1;
                      end
                      
                      if(counter == 1'b1) begin
                        counter <= 1'b0;
                        send_data_en_reg <= 1'b1;
                        flit_buffer[63:32] <= destination_local[v_offset][h_offset];
                        flit_buffer[67] <= 1'b0; //not last flit, set tail to 0
                      end
                      else begin
                        flit_buffer[31:0] <= destination_local[v_offset][h_offset];
                        counter <= counter + 1;
                        send_data_en_reg <= 1'b0;
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
                   send_data_en_reg <= 1'b0;
                   
                   if(start) begin
                    state <= INITIAL;
                   end  
                end
                  
            endcase
        end 
    end
    
     
    
    
endmodule
