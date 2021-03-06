/*
 * These source files contain a hardware description of a network
 * automatically generated by CONNECT (CONfigurable NEtwork Creation Tool).
 *
 * This product includes a hardware design developed by Carnegie Mellon
 * University.
 *
 * Copyright (c) 2012 by Michael K. Papamichael, Carnegie Mellon University
 *
 * For more information, see the CONNECT project website at:
 *   http://www.ece.cmu.edu/~mpapamic/connect
 *
 * This design is provided for internal, non-commercial research use only, 
 * cannot be used for, or in support of, goods or services, and is not for
 * redistribution, with or without modifications.
 * 
 * You may not use the name "Carnegie Mellon University" or derivations
 * thereof to endorse or promote products derived from this software.
 *
 * THE SOFTWARE IS PROVIDED "AS-IS" WITHOUT ANY WARRANTY OF ANY KIND, EITHER
 * EXPRESS, IMPLIED OR STATUTORY, INCLUDING BUT NOT LIMITED TO ANY WARRANTY
 * THAT THE SOFTWARE WILL CONFORM TO SPECIFICATIONS OR BE ERROR-FREE AND ANY
 * IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 * TITLE, OR NON-INFRINGEMENT.  IN NO EVENT SHALL CARNEGIE MELLON UNIVERSITY
 * BE LIABLE FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO DIRECT, INDIRECT,
 * SPECIAL OR CONSEQUENTIAL DAMAGES, ARISING OUT OF, RESULTING FROM, OR IN
 * ANY WAY CONNECTED WITH THIS SOFTWARE (WHETHER OR NOT BASED UPON WARRANTY,
 * CONTRACT, TORT OR OTHERWISE).
 *
 */


/* =========================================================================
 * 
 * Filename:            testbench_sample.v
 * Date created:        05-28-2012
 * Last modified:       06-09-2012
 * Authors:		Michael Papamichael <papamixATcs.cmu.edu>
 *
 * Description:
 * Minimal testbench sample for CONNECT networks
 * 
 * =========================================================================
 */

`ifndef XST_SYNTH

`timescale 1ns / 1ps

`include "connect_parameters.v"
`include "cnn_parameters.v"


module CONNECT_testbench_sample();
  parameter HalfClkPeriod = 5;
  localparam ClkPeriod = 2*HalfClkPeriod;

  // non-VC routers still reeserve 1 dummy bit for VC.
  localparam vc_bits = (`NUM_VCS > 1) ? $clog2(`NUM_VCS) : 1;
  localparam dest_bits = $clog2(`NUM_USER_RECV_PORTS);
  localparam flit_port_width = 2 /*valid and tail bits*/+ `FLIT_DATA_WIDTH + dest_bits + vc_bits;
  localparam credit_port_width = 1 + vc_bits; // 1 valid bit
  localparam test_cycles = 20;

  reg Clk;
  reg Rst_n;

  // input regs
  reg send_flit [0:`NUM_USER_SEND_PORTS-1]; // enable sending flits
  reg [flit_port_width-1:0] flit_in [0:`NUM_USER_SEND_PORTS-1]; // send port inputs

  reg send_credit [0:`NUM_USER_RECV_PORTS-1]; // enable sending credits
  reg [credit_port_width-1:0] credit_in [0:`NUM_USER_RECV_PORTS-1]; //recv port credits

  // output wires
  wire [credit_port_width-1:0] credit_out [0:`NUM_USER_SEND_PORTS-1];
  wire [flit_port_width-1:0] flit_out [0:`NUM_USER_RECV_PORTS-1];

  reg [31:0] cycle;
  integer i;

  // packet fields
  reg is_valid;
  reg is_tail;
  reg [dest_bits-1:0] dest;
  reg [vc_bits-1:0]   vc;
  reg [`FLIT_DATA_WIDTH-1:0] data;

  // Generate Clock
  initial Clk = 0;
  always #(HalfClkPeriod) Clk = ~Clk;
  
  //start signals conv layers
  reg start_conv0;
  reg start_conv1;

  integer i_k;
  integer j_k;

  // Run simulation 
  initial begin 
    cycle = 0;
    for(i = 0; i < `NUM_USER_SEND_PORTS; i = i + 1) begin flit_in[i] = 0; send_flit[i] = 0; end
    for(i = 0; i < `NUM_USER_RECV_PORTS; i = i + 1) begin credit_in[i] = 0; send_credit[i] = 0; end
    
    $display("---- Performing Reset ----");
    Rst_n = 0; // perform reset (active low) 
    #(5*ClkPeriod+HalfClkPeriod); 
    Rst_n = 1; 
    #(HalfClkPeriod);


    
    //RELU TEST
//    send_flit[1] = 1'b1;
//    dest = 0;
//    vc = 0;
//    data[31:0] = 32'hffffffff;
//    data[63:32] = 32'd10;
//    flit_in[1] = {1'b1 /*valid*/, 1'b0 /*tail*/, dest, vc, data};
//    $display("@%3d: Injecting flit %x into send port %0d", cycle, flit_in[1], 0);
//    #(ClkPeriod);
//    send_flit[1] = 1'b0;
    
	  start_conv0 = 1'b1;
	  
	  #(10*ClkPeriod);
	
    end
  
  //--------------------------------------------


  // Monitor arriving flits
  always @ (posedge Clk) begin
    cycle <= cycle + 1;
    for(i = 0; i < `NUM_USER_RECV_PORTS; i = i + 1) begin
      if(flit_out[i][flit_port_width-1]) begin // valid flit
        $display("@%3d: Ejecting flit %x at receive port %0d", cycle, flit_out[i], i);
      end
    end

    // terminate simulation
    if (cycle > test_cycles) begin
      $finish();
    end
  end

  // Add your code to handle flow control here (sending receiving credits)

wire send_flit_en0; //ReLU en
wire [68:0] send_flit_data0; //ReLU data out

wire send_flit_en2; //conv0 en
wire [68:0] send_flit_data2; //conv0 data

wire send_flit_en3; //conv1 en
wire [68:0] send_flit_data3; //conv1 data

  // Instantiate CONNECT network
  mkNetwork dut
  (.CLK(Clk)
   ,.RST_N(Rst_n)
 
 //SEND PORTS
   ,.send_ports_0_putFlit_flit_in(send_flit_data0)
   ,.EN_send_ports_0_putFlit(send_flit_en0)

   ,.EN_send_ports_0_getCredits(1'b1) // dra    in credits
   ,.send_ports_0_getCredits(credit_out[0])

   ,.send_ports_1_putFlit_flit_in(flit_in[1])
   ,.EN_send_ports_1_putFlit(send_flit[1])

   ,.EN_send_ports_1_getCredits(1'b1) // drain credits
   ,.send_ports_1_getCredits(credit_out[1])

   // step 1:  add rest of send ports here
   //
   
   ,.send_ports_2_putFlit_flit_in(send_flit_data2)
   ,.EN_send_ports_2_putFlit(send_flit_en2)

   ,.EN_send_ports_2_getCredits(1'b1) // drain credits
   ,.send_ports_2_getCredits(credit_out[2])
   
   ,.send_ports_3_putFlit_flit_in(flit_in[3])
   ,.EN_send_ports_3_putFlit(send_flit[3])

   ,.EN_send_ports_3_getCredits(1'b1) // drain credits
   ,.send_ports_3_getCredits(credit_out[3])

//RECEIVE PORTS

   ,.EN_recv_ports_0_getFlit(1'b1) // drain flits
   ,.recv_ports_0_getFlit(flit_out[0])

   ,.recv_ports_0_putCredits_cr_in(credit_in[0])
   ,.EN_recv_ports_0_putCredits(1'b1)

   ,.EN_recv_ports_1_getFlit(1'b1) // drain flits
   ,.recv_ports_1_getFlit(flit_out[1])

   ,.recv_ports_1_putCredits_cr_in(credit_in[1])
   ,.EN_recv_ports_1_putCredits(1'b1)

   // step 1: add rest of receive ports here
   // 
   
   ,.EN_recv_ports_2_getFlit(1'b1) // drain flits
   ,.recv_ports_2_getFlit(flit_out[2])

   ,.recv_ports_2_putCredits_cr_in(credit_in[2])
   ,.EN_recv_ports_2_putCredits(1'b1)
   
   
   ,.EN_recv_ports_3_getFlit(1'b1) // drain flits
   ,.recv_ports_3_getFlit(flit_out[3])

   ,.recv_ports_3_putCredits_cr_in(credit_in[3])
   ,.EN_recv_ports_3_putCredits(1'b1)
   

   );
   
   
   relu relu0(.clk(Clk),
              .reset(~Rst_n),
              .data_in(flit_out[0]),
              .send_data(send_flit_data0),
              .send_data_en(send_flit_en0));
              
   conv_layer conv0(.clk(Clk),
                    .reset(~Rst_n),
                    .start(start_conv0),
                    .send_data(send_flit_data2),
                    .send_data_en(send_flit_en2));


endmodule

`endif
