`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: BUPT MITC 
// Engineer: Chien Gu
//
// Create Date:   10:11:40 06/05/2014
// Design Name:   fsm
// Module Name:   E:/fpga-projects/fsm_test/tb_fsm.v
// Project Name:  fsm_test
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: fsm
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_fsm;

	// Inputs
	reg clk;
	reg rst_n;
	reg jump;

	// Outputs
	wire dout_p;
	wire dout_q;

	// Instantiate the Unit Under Test (UUT)
	fsm uut (
		.clk(clk), 
		.rst_n(rst_n), 
		.jump(jump), 
		.dout_p(dout_p), 
		.dout_q(dout_q)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst_n = 0;
		jump = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		rst_n = 1;
		#100;
		jump = 1;
		#20;
		jump = 0;
	end

	always #5 clk = ~clk;
      
endmodule

