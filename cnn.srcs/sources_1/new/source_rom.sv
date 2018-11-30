`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2018 03:17:54 PM
// Design Name: 
// Module Name: source_rom
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

module source_rom(
    input [6:0] addressI,
    input [6:0] addressJ,
    output [7:0] data
    );
    
    reg [7:0] mem [`SOURCE_SIZE - 1:0][`SOURCE_SIZE -1:0];
    reg [7:0] data_out;
    
    initial begin
            integer fsource;
            fsource = $fopen("test.mem","r");
            for(int i = 0; i < `SOURCE_SIZE; i++) begin
                for(int j = 0; j < `SOURCE_SIZE; j++) begin
                    $fscanf(fsource,"%hh",mem[i][j]);
                end
            end
        
    end
    
    always @(addressI, addressJ) begin
        if(((addressI >= 0)&&(addressI < `SOURCE_SIZE))&&((addressJ >= 0)&&(addressJ < `SOURCE_SIZE))) begin
            data_out = mem[addressI][addressJ];
        end
        else begin
            data_out = 8'b0;
        end
    end
    

    
    
    
endmodule
