cnn_accelerator
================
Verilog based convolutional neural network accelerator.

------------


Directory Structure
-------------------
- /software_test
	- **C++ code for software-hardware verification**
	- source.mem
		-**Source bit file used for hardware simulation. conv.v reads this file and stores in register**
	- software_output.txt
		-**Software generated convolutional layer output**
- /cnn.sim/sim1/behav/xsim/hardware_output.txt
	- **Hardware generated convolutional layer output**
- /mesh
	- **Hex files used by mknetwork.v for routing**
- /cnn.srcs
	- /sources_1
		- imports/build/
			- **NOC library**
			-  testbench_sample.v
				- **Testbench for testing NOC**
		- /new
			- cnn_parameters.v
				- **Verilog headers containing data width, image width, etc**
			- conv_layer.sv
				- **Convolutional layer (not NOC ready)**
			- relu.v
				 - **ReLU layer (NOC ready)**
			- source_rom.sv
				 - **Not currently used**
	- /sim_1
		- conv_layer_tb.v
		 	- **Testbench for testing convolutional layer** 
