`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:09:23 07/06/2014
// Design Name:   test_signed
// Module Name:   E:/study/projects/ise-projects/ISE/test_for_statement/tb_test_signed.v
// Project Name:  test_for_statement
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: test_signed
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_test_signed;

	// Inputs
	reg clk;
	reg rst;
	reg str;

	// Outputs
	wire [3:0] dout;
	wire dout_flag;

	// Instantiate the Unit Under Test (UUT)
	test_signed uut (
		.clk(clk), 
		.rst(rst), 
		.str(str),
		.dout(dout), 
		.dout_flag(dout_flag)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		str = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		#100;
		rst = 1;
		#50;
		rst = 0;

	end

	always #5 clk = ~clk;
	always #100 str = ~str;
      
endmodule

