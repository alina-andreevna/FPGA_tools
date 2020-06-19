`timescale 1ns/100ps

module  cdc_pulse_tb ();

// inputs
	reg	clk_fast_in, clk_slow_in;	
	reg strobe_in;

//outputs
	wire strobe_out;
	
	cdc_pulse uut (.*);
		
	initial begin
		clk_fast_in = 0; 	repeat(1000) #10 clk_fast_in = ~clk_fast_in;
	end

	initial begin
		clk_slow_in = 0; 	repeat(1000) #25 clk_slow_in = ~clk_slow_in;
	end

	initial begin 
		strobe_in = 0;
	#125
		strobe_in = 1;
	#50
		strobe_in = 0;
	#125
		strobe_in = 1;
	#50
		strobe_in = 0;
	#75
		strobe_in = 1;
	#50
		strobe_in = 0;
	#325
		strobe_in = 1;
	#50
		strobe_in = 0;
	#225
		strobe_in = 1;
	#50
		strobe_in = 0;
	#75
		strobe_in = 1;
	#50
		strobe_in = 0;
	#75
		strobe_in = 1;
	#50
		strobe_in = 0;
	#275
		strobe_in = 1;
	#50
		strobe_in = 0;
	#125
		strobe_in = 1;
	#50
		strobe_in = 0;
	end
	
endmodule		
