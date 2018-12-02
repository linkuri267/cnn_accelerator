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
 

typedef enum {
    INIT,
    CALC,
    DONE
} conv_layer_state;

module conv_layer#(
    type      T             =  shortreal,
    parameter data_width    =  $size(T),
    parameter src_height    = `SOURCE_SIZE,
    parameter src_width     = `SOURCE_SIZE,
    parameter dest_height   = `DESTINATION_SIZE,
    parameter dest_width    = `DESTINATION_SIZE,
    parameter kernel_size   = `KERNEL_SIZE,
    parameter buffer_size   = (2 * $size(T)) + 5
) (
    input clk,
    input reset,
    input start,
    output T destination [dest_height - 1:0][dest_width - 1:0],
    output [buffer_size:0] send_data,
    output logic send_data_en
);
    conv_layer_state state;
    
    reg T [data_width - 1:0] source_img [src_height - 1:0][src_width - 1:0];
    reg T [data_width - 1:0] kernel [kernel_size - 1:0][kernel_size - 1:0];
    reg T [data_width - 1:0] feature_map [dest_height - 1:0][dest_width - 1:0];
    
    localparam dh_bits = $bits(dest_height);
    localparam dw_bits = $bits(dest_width);
    localparam sh_bits = $bits(src_height);
    localparam sw_bits = $bits(src_width);
    // localparam buffer_size = (2 * data_width) + 5;

    reg [sh_bits:0] v_off;
    reg [sw_bits:0] h_off;
    
    logic done;
    
    //NOC registers
    logic parity;
    reg [buffer_size:0] flit_buffer;
    
    assign send_data = flit_buffer;
    assign destination = feature_map;
    
    initial begin : initialize_source
        integer fsource;
        fsource = $fopen("source.mem","r");
        for (genvar i = 0; i < src_height; i++) begin
            for (genvar j = 0; j < src_width; j++) begin
                $fscanf(fsource, "%hh", source_img[src_height - i - 1][src_width - j - 1]);
            end
        end
    end
    
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            reset_layer();
        end
        else begin
            case (state)
                INITIAL:    do_initial_state();
                CALC:       do_calc_state();
                DONE:       do_done_state();
            endcase
        end 
    end
    
    task reset_layer();
        begin
            initialize_kernel();
            clear_local_destination();

            v_off <= 0;
            h_off <= 0;

            set_done(1'b0);
            parity <= 1'b0;
            clear_flit_buffer();
            set_enable_send(1'b0);

            state <= INITIAL;
        end
    endtask

    task do_initial_state();
        begin
            clear_local_destination();

            set_valid(1'b1);
            set_destination(2'd0);
            set_fifth_highest_bit(1'b0);

            if (start) begin
                state <= CALC;
            end
        end
    endtask

    task do_calc_state();
    begin
        convolve_current_pixel();
        send_current_pixel();
    end
    endtask

    task do_done_state();
        begin
            set_done(1'b1);
            set_enable_send(1'b0);

            if (start) begin
                state <= INITIAL;
            end
        end
    endtask


    task clear_local_destination();
        for (genvar i = 0; i < dest_height; i ++) begin
            for (genvar j = 0; j < dest_width; j++) begin
                feature_map[i][j] <= 0;
            end
        end
    endtask

    task set_done (input logic is_done);
        done <= is_done;
    endtask

    task set_valid (input logic is_valid);
        flit_buffer[buffer_size - 1] <= is_valid;
    endtask

    task set_last_flit(input logic is_last);
        flit_buffer[buffer_size - 2] <= is_last;
    endtask

    task set_destination(input logic dest[1:0]);
        flit_buffer[buffer_size - 3:buffer_size - 4] <= dest;
    endtask

    task set_fifth_highest_bit(input logic bit_val);
        // what the fuck does this do
        flit_buffer[buffer_size - 5] <= 1'b0;
    endtask

    task set_enable_send(input logic should_enable);
        send_data_en <= should_enable;
    endtask

    task clear_flit_buffer();
        flit_buffer <= {$bits(flit_buffer) {1'0}};
    endtask


    task initialize_kernel();
        begin
            for (genvar i_k = 0; i_k < kernel_size; i_k = i_k + 1) begin
                for (genvar j_k = 0; j_k < kernel_size; j_k = j_k + 1) begin
                    kernel[kernel_size - i_k - 1][kernel_size - j_k - 1] <= j_k + (i_k * kernel_size);
                end
            end
        end
    endtask

    task set_buffer_flits(input logic is_upper_flit, input logic is_last_flit = 1'b0);
        begin
            if (is_upper_flit) begin
                flit_buffer[(2 * data_width) - 1:data_width] <= feature_map[v_off][h_off];
                set_last_flit(is_last_flit);
            end else begin
                flit_buffer[data_width - 1:0] <= feature_map[v_off][h_off];
            end
            set_enable_send(is_upper_flit || is_last_flit);
        end
    endtask

    task send_last_flit();
        logic is_upper_flit = is_even(dest_height) || is_even (dest_width);
        begin
            set_buffer_flits(is_upper_flit, 1'b1);
            state <= DONE;
        end
    endtask

    task convolve_current_pixel();
        for (genvar i = 0; i < kernel_size; i++) begin
            for (genvar j = 0; j < kernel_size; j++) begin
                feature_map[v_off][h_off] += kernel[i][j] * source_img[v_off + i][h_off + j];
            end
        end
    endtask

    task send_current_pixel();
        logic is_last_flit = 1'b0;
        begin
            if (h_off == dest_width - 1) begin
                if (v_off == dest_height - 1) begin
                    send_last_flit();
                    is_last_flit = 1'b1;
                end else begin
                    {h_off, v_off} <= {4'b0, v_off + 1};
                end
            end
            else begin
                h_off <= h_off + 1;
            end
            
            if (!is_last_flit) begin 
                set_buffer_flits(/* upper_bits = */ (parity != 0), /* last = */ 1'b0);
            end
            toggle_parity();
        end
    endtask

    task toggle_parity();
        parity ^= 1'b1;
    endtask

endmodule
