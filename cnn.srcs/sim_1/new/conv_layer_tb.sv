`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2018 06:29:21 PM
// Design Name: 
// Module Name: conv_layer_tb
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


module conv_layer_tb;
    reg clk;
    reg reset;
    reg start;
    reg signed [`DATA_WIDTH - 1:0] kernel [`KERNEL_SIZE - 1:0][`KERNEL_SIZE - 1:0];
    reg signed [`DATA_WIDTH - 1:0] source [`SOURCE_SIZE - 1:0][`SOURCE_SIZE - 1:0];
    reg signed [`DATA_WIDTH - 1:0] destination [`DESTINATION_SIZE - 1:0][`DESTINATION_SIZE -1:0];
//    reg signed [`DATA_WIDTH - 1:0] test_source [`SOURCE_SIZE - 1:0][`SOURCE_SIZE - 1: 0];
    reg signed [`DATA_WIDTH - 1:0] test_kernel [`KERNEL_SIZE - 1:0][`KERNEL_SIZE - 1:0];
     
    parameter CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) clk = ~clk;
    
    conv_layer test_conv_layer(
    .clk(clk),
    .reset(reset),
    .start(start),
    .kernel(kernel),
    .destination(destination)
    );

    initial begin
        integer f;
//      integer fmem;
        f = $fopen("hardware_output.txt","w");
//        fmem = $fopen("test.mem","r");
//        for(int i = 0; i < `SOURCE_SIZE; i++) begin
//            for(int j = 0; j < `SOURCE_SIZE; j++) begin
//                $fscanf(fmem,"%hh",test_source[i][j]);
//            end
//        end

        clk = 1'b0;
        reset = 1'b1;
        start = 1'b0;
        #(CLK_PERIOD*5)
        reset = 1'b0;
//        #(CLK_PERIOD*2)
//        for(int i = 0; i < `SOURCE_SIZE; i ++) begin
//            for(int j = 0; j < `SOURCE_SIZE; j++) begin
//                source[`SOURCE_SIZE - i - 1][`SOURCE_SIZE - j - 1] <= test_source[i][j];
//            end
         
//        end
        #(CLK_PERIOD*2)        
        for(int i = 0; i < `KERNEL_SIZE; i ++) begin
            for(int j = 0; j < `KERNEL_SIZE; j++) begin
                kernel[`KERNEL_SIZE - i - 1][`KERNEL_SIZE - j - 1] <= j + i*`KERNEL_SIZE;
            end
        end
        #(CLK_PERIOD*2)
        $display(kernel);

        start = 1'b1;
        
        #(CLK_PERIOD*100000)
        $display(destination);
        $fwrite(f,"{");
        for(int i = 0; i < `DESTINATION_SIZE; i++) begin
            $fwrite(f,"{");
            for(int j = 0; j < `DESTINATION_SIZE; j++) begin
                $fwrite(f,"%0d,",destination[`DESTINATION_SIZE - i - 1][`DESTINATION_SIZE - j - 1]);    
            end
            $fwrite(f,"}\n");
        end
        $fwrite(f,"}");
        $fclose(f);

    end
    

endmodule
