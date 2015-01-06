`timescale 1ns / 1ps
`include "global_define.vh"
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:21:13 09/24/2014
// Design Name:   TBCE
// Module Name:   E:/study/projects/ise-projects/ISE/OFDM/tb_tbce.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: TBCE
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_tbce;

	// Inputs
	reg clk_i;
	reg clk_o;
	reg rst;
	reg din;
	reg din_vld;
	reg [5:0] din_init;

	// Outputs
	wire dout;
	wire dout_vld;

	// Instantiate the Unit Under Test (UUT)
	TBCE uut (
		.clk_i(clk_i), 
		.clk_o(clk_o), 
		.rst(rst), 
		.din(din), 
		.din_vld(din_vld), 
		.din_init(din_init), 
		.dout(dout), 
		.dout_vld(dout_vld)
	);

	reg str;
	reg data [7:0]; // for test function
	reg [5:0] indx;

	initial begin
		// Initialize Inputs
		clk_i = 0;
		clk_o = 0;
		rst = 0;
		din = 0;
		din_vld = 0;
		din_init = 0;

		str = 0;
		indx = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		rst = 1;
		#(`CLK_CYCLE*2);
		$readmemb("signal_bits.txt", data);
		din_init[5] = 0;
		din_init[4] = 0;
		din_init[3] = 0;
		din_init[2] = 0;
		din_init[1] = 0;
		din_init[0] = 0;
		rst = 0;
		#(`CLK_CYCLE);
		str = 1;

	end

	always #(`CLK_CYCLE/2) clk_o = ~clk_o;
	always #(`CLK_CYCLE/2*3) clk_i = ~clk_i;

	always @(posedge clk_i) begin
		if (str) begin
			if (indx == 40) begin
				rst <= 1;
			end
			else begin
				rst <= 0;
			end
			if (indx == 50) begin
				indx <= 0;
			end
			else begin
				indx <= indx + 1;
			end
		end
		else begin
			indx <= 0;
		end
	end

	always @(posedge clk_i) begin
		if (rst) begin
			// reset
			din <= 0;
		end
		else begin
			if (str) begin
				din <= data[indx];
				/*din_init[5] <= data[31];
				din_init[4] <= data[30];
				din_init[3] <= data[29];
				din_init[2] <= data[28];
				din_init[1] <= data[27];
				din_init[0] <= data[26];*/
				din_init[5] <= data[7];
				din_init[4] <= data[6];
				din_init[3] <= data[5];
				din_init[2] <= data[4];
				din_init[1] <= data[3];
				din_init[0] <= data[2];
			end
			else begin
				din <= 0;
			end
		end
	end

	always @(posedge clk_i) begin
		if (rst) begin
			// reset
			din_vld <= 0;
		end
		else begin
			if (str && indx <= 7) begin
				din_vld <= 1;
			end
			else begin
				din_vld <= 0;
			end
		end
	end

	// display
	always @(posedge clk_o) begin
		if (dout_vld) begin
			$display("dout is : %d", dout);
		end
	end
      
endmodule

