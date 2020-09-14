`timescale 1ns/100ps

module  window_analysis_tb ();

	parameter FIFO_SIZE = 10;
	parameter FIFO_STATE_SIZE = 4;
	parameter SAMPLE_DATA_SIZE = 4;
	parameter WINDOW_DELAY_SIZE = 4;
	parameter WINDOW_POW_SIZE = 5;
	parameter CYCLE_NUMBER_SIZE = 5;
	
	parameter READ_DATA_SIZE = WINDOW_POW_SIZE + 2*SAMPLE_DATA_SIZE + $clog2(WINDOW_POW_SIZE) - 1 + CYCLE_NUMBER_SIZE;
	
	parameter CLK_SEMI_PERIOD = 5;
	parameter CYCLE_SEMI_PERIOD = 500;
	
	parameter MAX_DELAY_SIZE = 2**WINDOW_DELAY_SIZE - 1;
	
	//----------------------------------------------------//
	
	reg	clk, nrst_in;	
	reg	cycle_start_in;	

	reg	[SAMPLE_DATA_SIZE-1:0] 	sample_data_in;	
	reg	[WINDOW_DELAY_SIZE-1:0] window_delay_in;	
	reg	[WINDOW_POW_SIZE-1:0] 	window_pow_in;
	reg read_enable_in;	

	
	wire [FIFO_STATE_SIZE-1:0] 	fifo_state_out;	
	wire [READ_DATA_SIZE-1:0] 	read_data_out;	
	
	//----------------------------------------------------//	
		
	window_analysis #(FIFO_SIZE, FIFO_STATE_SIZE, SAMPLE_DATA_SIZE, WINDOW_DELAY_SIZE, WINDOW_POW_SIZE, CYCLE_NUMBER_SIZE) uut (.*);
		
	//----------------------------------------------------//
	
	initial begin
		clk = 0; 			forever #CLK_SEMI_PERIOD clk = ~clk;
	end
	
	initial begin
		nrst_in = 0; 		#(CLK_SEMI_PERIOD*10) nrst_in =1;
	end
	
	//----------------------------------------------------//
		
	initial begin
		cycle_start_in = 0; 
		#(CLK_SEMI_PERIOD + 2) 
		forever 
		begin
			#CYCLE_SEMI_PERIOD #(CLK_SEMI_PERIOD) cycle_start_in = 1; 
			#CLK_SEMI_PERIOD #CLK_SEMI_PERIOD cycle_start_in = 0;
			#CLK_SEMI_PERIOD;
		end
	end
		
	//----------------------------------------------------//
	
	integer DELAY_SIZE, WIN_SIZE;
	integer WIN_SIZE_POW;

	
	initial begin

		DELAY_SIZE = $urandom%MAX_DELAY_SIZE;

		window_delay_in = 0;
		#(CLK_SEMI_PERIOD + 2) 
		forever 
		begin
			#CYCLE_SEMI_PERIOD #(CLK_SEMI_PERIOD) window_delay_in = DELAY_SIZE;
			#CLK_SEMI_PERIOD #CLK_SEMI_PERIOD  window_delay_in = 0;
			#CLK_SEMI_PERIOD;
		end
	end
	
	initial begin

		WIN_SIZE_POW = $urandom%WINDOW_POW_SIZE;
		WIN_SIZE = 2 ** WIN_SIZE_POW;

		window_pow_in = 0;
		#(CLK_SEMI_PERIOD + 2) 
		forever 
		begin
			#CYCLE_SEMI_PERIOD #(CLK_SEMI_PERIOD) window_pow_in = WIN_SIZE;
			#CLK_SEMI_PERIOD #CLK_SEMI_PERIOD  window_pow_in = 0;
			#CLK_SEMI_PERIOD;
		end
	end
		
	//----------------------------------------------------//
		
integer i;

integer sum_data, max_data, max_ind, current_index;
	
	//----------------------------------------------------//
	

initial begin

	//----------------------------------------------------//
	// Init variables
	//----------------------------------------------------//
	

	$display("WINDOW_SIZE = %d, DELAY_SIZE = %d, SUM DURATION = %d", WIN_SIZE, DELAY_SIZE, WIN_SIZE+DELAY_SIZE);

	//----------------------------------------------------//
	// Generate input sequence
	//----------------------------------------------------//		
	
	forever
	begin
		current_index = 0;

		sum_data = 0;
		max_data = 0;
		max_ind = 0;
		sample_data_in = 0;

		wait (cycle_start_in == 1);
		
		#(CLK_SEMI_PERIOD*2) #(DELAY_SIZE*CLK_SEMI_PERIOD*2 - 2*CLK_SEMI_PERIOD - 2)


		
		for (i=0; i<WIN_SIZE; i=i+1) begin

			#CLK_SEMI_PERIOD;
			
			sample_data_in = $random%2**(SAMPLE_DATA_SIZE-1);

			$display("%d. CURRENT INPUT DATA %d", current_index, $signed(sample_data_in));
			
			sum_data = $signed(sum_data) + $signed(sample_data_in);
			
			max_ind = ($signed(sample_data_in) > $signed(max_data) ? current_index : max_ind);
			max_data = ($signed(sample_data_in) > $signed(max_data) ? $signed(sample_data_in) : $signed(max_data));
			
			current_index = current_index + 1;	

			sample_data_in[SAMPLE_DATA_SIZE-1] = ~sample_data_in[SAMPLE_DATA_SIZE-1]; // Offset binary
			
			#CLK_SEMI_PERIOD;
		end
		
		#CLK_SEMI_PERIOD;

		$display("END INPUT DATA");
		$display("MEAN_VAL = %d, MAX_VAL = %d, INDEX = %d", $signed(sum_data/WIN_SIZE), $signed(max_data), max_ind);
		$display("===================");
	end
end

integer j;
integer cycle_number,zero_offset, max_amp, max_time;

initial begin

	//----------------------------------------------------//
	// Init variables
	//----------------------------------------------------//
	
	read_enable_in = 0;
	
	cycle_number = 0;
	zero_offset = 0;
	max_amp = 0;
	max_time = 0;

	//----------------------------------------------------//
	// Read data and states from fifo
	//----------------------------------------------------//		
	
	forever
	begin

		#(5*CYCLE_SEMI_PERIOD);
		
		for (j=0; j<5; j=j+1) begin
			#CLK_SEMI_PERIOD;
			
			read_enable_in = 1;
			
			#(2*CLK_SEMI_PERIOD);
			
			read_enable_in = 0;
			
			#(12*CLK_SEMI_PERIOD);

			cycle_number = read_data_out[READ_DATA_SIZE - 1 : READ_DATA_SIZE - 1 - CYCLE_NUMBER_SIZE + 1];
			zero_offset = read_data_out[READ_DATA_SIZE - 1 - CYCLE_NUMBER_SIZE : READ_DATA_SIZE - 1 - CYCLE_NUMBER_SIZE - SAMPLE_DATA_SIZE - $clog2(WINDOW_POW_SIZE) + 1];
			max_amp = read_data_out[READ_DATA_SIZE - 1 - CYCLE_NUMBER_SIZE - SAMPLE_DATA_SIZE - $clog2(WINDOW_POW_SIZE) : READ_DATA_SIZE - 1 - CYCLE_NUMBER_SIZE - SAMPLE_DATA_SIZE - $clog2(WINDOW_POW_SIZE) - SAMPLE_DATA_SIZE + 1];
			max_time = read_data_out[READ_DATA_SIZE - 1 - CYCLE_NUMBER_SIZE - SAMPLE_DATA_SIZE - $clog2(WINDOW_POW_SIZE) - SAMPLE_DATA_SIZE : 0];

			#(8*CLK_SEMI_PERIOD);

			$display("===================");
			$display("READ DATA FROM FIFO");
			$display("CYCLE_NUMBER = %d, MEAN_VAL = %d, MAX_VAL = %d, INDEX = %d", cycle_number, $signed(zero_offset), $signed(max_amp), max_time);
			$display("===================");
			$display("FIFO_FULL = %d, FIFO_EMPTY= %d", fifo_state_out[3], fifo_state_out[2]);
			$display("FIFO_ALMOST_FULL = %d, FIFO_ALMOST_EMPTY= %d", fifo_state_out[1], fifo_state_out[0]);
			$display("===================");
			
			#CLK_SEMI_PERIOD;
		end
		
	end
end
		
endmodule		
