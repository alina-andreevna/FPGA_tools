`timescale 1ns/100ps

module debouncer_tb ();

// inputs
	reg	clk;	
	reg signal_in ;

//outputs
	wire signal_out;
	
	debouncer uut (.*);
		
	initial begin
		clk = 0; 	repeat(1000) #10 clk = ~clk;
	end

	initial begin 
		signal_in = 0;
	#10
		signal_in = 1;
	#40
		signal_in = 0;
	#40
		signal_in = 1;
	#60
		signal_in = 0;
	#60
		signal_in = 1;
	#80
		signal_in = 0;
	#80
		signal_in = 1;
	#100
		signal_in = 0;
	#100
		signal_in = 1;
	#120
		signal_in = 0;
	#120
		signal_in = 1;
	#140
		signal_in = 0;
	#140
		signal_in = 1;
	#160
		signal_in = 0;
	#160
		signal_in = 1;
	#180
		signal_in = 0;
	end
	
endmodule