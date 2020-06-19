`timescale 1ns/100ps

module strobe_gen_tb ();
	// inputs
	reg reset_in;
	reg clk_in;

	// outputs
	wire strobe_out;
	
	strobe_gen uut  (.*);
	// (	
		// reset_in,
		// clk_in,
	
		// strobe_out
	// );
	
	
	initial begin
		clk_in = 0; 	repeat(100) #1 clk_in = ~clk_in;
	end

	
	initial begin
		reset_in = 0;	
	end

endmodule