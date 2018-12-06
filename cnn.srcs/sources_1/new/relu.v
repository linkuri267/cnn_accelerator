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


module relu#(
    type T                  = shortreal,
    parameter data_width    = $size(T),
    parameter src_height    = `SOURCE_SIZE,
    parameter src_width     = `SOURCE_SIZE,
    parameter dest_height   = `DESTINATION_SIZE
    parameter dest_width    = `DESTINATION_SIZE,
    paramter kernel_size    = `KERNEL_SIZE,
    paramter buffer_size    = (2 * $size(T)) + 5
)(
    input clk,
    input reset,
    input [buffer_size-1:0] data_in,
    output [buffer_size-1:0] send_data,
    output reg send_data_en
);
    reg [buffer_size-1:0] output_flit_buffer;
    
    //1 bit isValid + 1 bit isTail + 2 bit destination + 1 bit VC + 64 bit data = 69 bit packet = 68:0
    
    assign send_data = output_flit_buffer;
    
    assign T lower_flit_received = data_in[data_width-1:0];
    assign T upper_flit_received = data_in[(2*data_width)-1: data_width];

    assign logic flit_is_valid = data_in[buffer_size - 1];
    assign logic at_last_flit  = data_in[buffer_size - 2];
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            do_reset();
        end
        else begin
            perform_relu();  
        end 
    end

    task do_reset();
    begin 
        set_enable_send(1'b0);
        clear_flit_buffer();
    end
    endtask

    task perform_relu();
    begin
        if (flit_is_valid) begin
            set_last_flit(at_last_flit);
            propagate_appropriate_flits();
        end
        set_enable_send(flit_is_valid);
    end
    endtask

    task propagate_appropriate_flits();
        localparam R1_pooling_layer = 2'd1;
        begin
            propagate_lower_flit();
            if (!at_odd_flit) begin
                propagate_upper_flit();
            end
            else begin
                clear_upper_flit();
            end
            set_valid(1'b1);
            set_destination(R1_pooling_layer);
            set_virtual_channel(1'b0);
        end
    endtask

    task propagate_upper_flit();
        output_flit_buffer[(2 * data_width) - 1:data_width]
            <= max(32'd0, upper_flit_received);
    endtask

    task propagate_lower_flit();
        output_flit_buffer[data_width - 1:0]
            <= max(32'd0, lower_flit_received);
    endtask

    task set_done (input logic is_done);
        done <= is_done;
    endtask

    task set_valid (input logic is_valid);
        output_flit_buffer[buffer_size - 1] <= is_valid;
    endtask

    task set_last_flit(input logic is_last);
        output_flit_buffer[buffer_size - 2] <= is_last;
    endtask

    task set_destination(input logic dest[1:0]);
        flit_buffer[buffer_size - 3:buffer_size - 4] <= dest;
    endtask

    task set_virtual_channel(input logic bit_val);
        output_flit_buffer[buffer_size - 5] <= bit_val;
    endtask

    task set_enable_send(input logic should_enable);
        send_data_en <= should_enable;
    endtask

    task clear_flit_buffer();
        output_flit_buffer <= {buffer_size {1'd0}};
    endtask

    task clear_upper_flit();
        output_flit_buffer[(2 * data_width) - 1:data_width] <= {data_width {1'd0}};
    endtask

endmodule
