`timescale 1ns/1ps

module  sorter_stack_tb ();
	
	parameter DATA_WIDTH = 16;
	parameter MAX_LENGTH = 30;
	
	parameter SRC_CLK = 3.76; // semi-period 133 MHz
	parameter SNK_CLK = 10;  // semi-period 50 MHz
	

	reg	snk_reset;	
	reg	snk_clock;	
	reg	snk_valid;	
	reg	snk_sop;	
	reg	snk_eop;	
	reg	[DATA_WIDTH-1:0] snk_data;	
	wire	snk_ready;	

	reg	src_reset;		
	reg	src_clock;	
	wire	src_valid;	
	wire	src_sop;	
	wire	src_eop;	
	wire	[DATA_WIDTH-1:0] src_data;	

	//----------------------------------------------------//
	
	sorter_stack #(DATA_WIDTH, MAX_LENGTH) uut (.*);

	//----------------------------------------------------//	
	
	initial begin
		snk_clock = 0; 	forever #SNK_CLK snk_clock = ~snk_clock;
	end
	
	initial begin
		src_clock = 0; 	forever #SRC_CLK src_clock = ~src_clock;
	end

	//----------------------------------------------------//

	initial begin
		src_reset = 1; 	#(10*SRC_CLK)   src_reset = 0;
	end

	initial begin
		snk_reset = 1; 	#(10*SNK_CLK)   snk_reset = 0;
	end

	//----------------------------------------------------//

integer seed;

integer i,j;
		
integer TEST_LENGTH;

integer error, current_number;

reg [DATA_WIDTH-1:0] data_now, data_prev;

initial begin

	//----------------------------------------------------//
	// Init variables
	//----------------------------------------------------//

	seed = $urandom();
	$display("SEED =  %d", seed);

	TEST_LENGTH = $random(seed)%MAX_LENGTH; 

	if (TEST_LENGTH < 0) TEST_LENGTH = - TEST_LENGTH;
	
	$display("TEST SEQUENCE LENGTH %d", TEST_LENGTH);

	snk_data = 0;
	snk_sop = 0;
	snk_eop = 0;
	snk_valid = 0; 
	
	data_prev = 0;
	data_now = 0;

	error = 0;

	i=0;
	j=0;
	current_number = 0;

	#(12*SNK_CLK)

	//----------------------------------------------------//
	// Generate input sequence
	//----------------------------------------------------//	

	for (i=0; i<TEST_LENGTH; i=i+1) begin
		#SNK_CLK;
		snk_valid = 1; 
		if (i==0) 
			snk_sop = 1; 
		else 
			snk_sop = 0;
			
		if (i == TEST_LENGTH - 1) 
			snk_eop = 1; 
		else 
			snk_eop = 0;
			
		snk_data = $random%2**(DATA_WIDTH-1);
		current_number = current_number + 1;

		$display("%d. CURRENT INPUT DATA %d", current_number, snk_data);
		
		#SNK_CLK;
	end

	#SNK_CLK;

	snk_eop = 0;
	snk_valid = 0; 

	current_number = 0;

	$display("END INPUT DATA\n==================\nSORT RESULTS:");

	//----------------------------------------------------//
	// Waitig output sequence
	//----------------------------------------------------//	
	wait (src_valid == 1);

	//----------------------------------------------------//
	// Check output sequence
	//----------------------------------------------------//	
	
	for (j=0; j<TEST_LENGTH; j=j+1) begin
		#SRC_CLK;
		
		data_now = data_prev;
		data_prev = src_data;
		
		current_number = current_number + 1;		

		if (src_valid ^ src_sop)
		begin
			if (data_prev < data_now)
				begin
					error = error + 1;
					$display("%d. ERROR! %d > %d. POSITION: %d. ERROR COUNT: %d", current_number, data_prev, data_now, i, error);
				end
			else $display("%d. CORRECT. %d =< %d", current_number, data_prev, data_now);
		end
		
		#SRC_CLK;
	end

	//----------------------------------------------------//
	// Results
	//----------------------------------------------------//
	
	$display("SIMULATE ENDED. TOTAL ERROR COUNT: %d", error);
	
end
		
endmodule		
