`timescale 1ns/100ps

module  front_detector_tb ();

// inputs
	reg	clk_in, pulse_in;	

//outputs
	wire pulse_out;
	
	front_detector uut (.*);
		
	initial begin
		clk_in = 0; 	repeat(1000) #10 clk_in = ~clk_in;
	end

	initial begin 
		pulse_in = 0;
	#100
		pulse_in = 1;
	#20
		pulse_in = 0;
	#125
		pulse_in = 1;
	#50
		pulse_in = 0;
	#50
		pulse_in = 1;
	#16
		pulse_in = 0;
	#325
		pulse_in = 1;
	#20
		pulse_in = 0;
	#200
		pulse_in = 1;
	#25
		pulse_in = 0;
	#100
		pulse_in = 1;
	#20
		pulse_in = 0;
	#75
		pulse_in = 1;
	#70
		pulse_in = 0;
	#275
		pulse_in = 1;
	#35
		pulse_in = 0;
	#100
		pulse_in = 1;
	#23
		pulse_in = 0;
	end
	
endmodule		
