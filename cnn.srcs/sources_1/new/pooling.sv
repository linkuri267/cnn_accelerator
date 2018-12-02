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

typedef enum {
    INITIAL,
    RECV,
    POOL,
    DONE
} pooling_state;

module pooling #(
    type      T             =  shortreal,
    parameter data_width    =  $size(T),
    parameter dest_height   = `DESTINATION_SIZE,
    parameter dest_width    = `DESTINATION_SIZE,
    parameter kernel_size   = `KERNEL_SIZE,
    parameter pool_factor   = `POOLING_FACTOR,
    parameter buffer_size   = (2 * $size(T)) + 5,
    localparam pooled_height = (dest_height / pool_factor) + ((dest_height % pool_factor) != 0).
    localparam pooled_width  = (dest_width  / pool_factor) + ((dest_width  % pool_factor) != 0)
) (
    input clk,
    input reset,
    input [buffer_size:0] data_in,
    output T final_image [pooled_height][pooled_width]
);

    localparam  row_bits = $size(dest_height),
                col_bits = $size(dest_width);
    
    T filtered_image [dest_height - 1:0][dest_width - 1:0];
    T pooled_image [pooled_height - 1:0][pooled_width - 1:0];

    reg row_idx [row_bits - 1:0];
    reg col_idx [col_bits - 1:0];
    
    assign final_image = pooled_image;
    
    //state variables and declarations
    pooling_state state;
    logic done;

    assign T upper_flit_received = data_in[(2 * data_width) - 1:data_width];
    assign T lower_flit_received = data_in[data_width:0];
    assign logic flit_is_valid = data_in[buffer_size - 1];
    assign logic at_last_flit  = data_in[buffer_size - 2];
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= INITIAL;
            reset_pooling_layer();
        end
        else begin
            case (state)
                INITIAL:    do_initial_state();
                RECV:       do_recv_state();
                POOL:       do_pool_state();
                DONE:       do_done_state();
            endcase
        end
    end
    
    task reset_pooling_layer();
        begin
            set_done(1'b0);
            initialize_offsets();
            clear_pooled_image();
        end
    endtask

    task do_initial_state();
        begin
            reset_pooling_layer();
            
            if (flit_is_valid) begin 
                process_received_activations();
                state <= RECV;
            end
        end
    endtask

    task do_recv_state();
        begin 
            if (flit_is_valid) begin 
                process_received_activations();
                update_activation_offsets();
                if (at_last_flit) begin
                    initialize_offsets();
                    state <= POOL;
                end
            end
        end
    endtask

    task do_pool_state():
        begin
            pool_local_activations();
            update_pool_offsets();
            if (at_last_flit) begin
                state <= DONE;
            end
        end
    endtask

    task do_done_state();
    begin
        set_done(1'b1);
    end
    endtask
    
    task clear_pooled_image();
        begin 
            for (genvar i = 0; i < pooled_height; i++) begin
                for (genvar j = 0; j < pooled_width; j++) begin
                    pooled_image[i][j] <= 0;
                end
            end
        end
    endtask

    task set_done (input logic is_done);
        done <= is_done;
    endtask

    task initialize_offsets();
        begin
            row_idx <= 0;
            col_idx <= 0;
        end
    endtask

    task update_activation_offsets();
        begin
            if (col_idx < dest_width - 2) begin 
                col_idx <= col_idx + 2;
            end else begin
                col_idx <= 0;
                row_idx <= row_idx + 1;
            end
        end
    endtask

    task process_received_activations();
        begin
            filtered_image[row_idx][col_idx] <= lower_flit_received;
            if (col_idx < dest_width - 2) begin 
                filtered_image[row_idx][col_idx + 1] <= upper_flit_received;
            end
        end
    endtask

    task update_pool_offsets();
        begin
            if (col_idx < pooled_width - 1) begin
                col_idx <= col_idx + 1;
            end else begin 
                col_idx <= 0;
                row_idx <= row_idx + 1;
            end
        end
    endtask

    task pool_local_activations();
        int activation_row = row_idx * pool_factor;
        int activation_col = col_idx * pool_factor;
        int max_row = min(dest_height, activation_row + pool_factor);
        int max_col = min(dest_width,  activation_col + pool_factor);
        begin
            T max_val = filtered_image[activation_row][activation_col];
            for ( ; activation_row < max_row; ++activation_row) begin 
                for ( ; activation_col < max_col; ++activation_col) begin
                    max_val = max(max_val, filtered_image[activation_row][activation_col]);
                end
            end
            pooled_image[row_idx][col_idx] <= max_val;
        end
    endtask

endmodule
