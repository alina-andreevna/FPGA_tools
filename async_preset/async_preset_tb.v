`timescale 1ns/100ps

module async_preset_tb ();

// inputs
	reg	clk;	
	reg preset_in;

//outputs
	wire q_out;
	
	async_preset uut (.*);
		
	initial begin
		clk = 0; 	repeat(1000) #10 clk = ~clk;
	end

	initial begin 
		preset_in = 0;
	#15
		preset_in = 1;
	#1
		preset_in = 0;
	#49
		preset_in = 1;
	#1
		preset_in = 0;
	#43
		preset_in = 1;
	#2
		preset_in = 0;
	#48
		preset_in = 1;
	#2
		preset_in = 0;
	#48
		preset_in = 1;
	#1
		preset_in = 0;
	#40
		preset_in = 1;
	#1
		preset_in = 0;
	#45
		preset_in = 1;
	#1
		preset_in = 0;
	#39
		preset_in = 1;
	#40
		preset_in = 0;
	end
	
endmodule					