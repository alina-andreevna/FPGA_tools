`timescale 1ns/100ps

module  complex_multiplier_tb ();

// params
	parameter width_A = 13;
	parameter width_B = 13;
	parameter width_PR = 15;

// inputs
	reg	clk, reset_in, ce_in;	
	
	reg [width_A-1:0] ar_in, ai_in;
	reg [width_B-1:0] br_in, bi_in;

//outputs
	wire [width_PR-1:0] pr_out, pi_out;
	
	complex_multiplier uut (.*);
		
	initial begin
		$display("Running testbench");  
		ce_in = 1;
		clk = 0; 	repeat(1000) #10 clk = ~clk;
	end

	initial begin
		reset_in = 1;	#10 reset_in = 0;
	end

	initial begin 
	#5
		ar_in = 2;
		br_in = 2;
		ai_in = 0;
		bi_in = 0;
	#20
		ar_in = 10;
		br_in = 20;
		ai_in = 30;
		bi_in = 40;
	#20
		ar_in = 10;
		br_in = 30;
		ai_in = -20;
		bi_in = -50;
	#20
		ar_in = 10;
		br_in = -50;
		ai_in = 10;
		bi_in = 30;
	#20
		ar_in = -10;
		br_in = -20;
		ai_in = 30;
		bi_in = -40;
	#20
		ar_in = 0;
		br_in = 0;
		ai_in = 20;
		bi_in = 30;
	#20
		ar_in = 10;
		br_in = 0;
		ai_in = 0;
		bi_in = 20;
	#20
		ar_in = 0;
		br_in = 20;
		ai_in = 50;
		bi_in = 0;
		
	$display("Finished");  

	end
	
endmodule		
