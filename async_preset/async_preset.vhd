----------------------------------------------------------------------------------
-- MOD.DATE: 280420
--------------------------------------------------
-- Project :		
-- Author :			Alina Galichina
-- Creation date : 	2020-21-04
-- File : 			async_preset.vhd
-- TestBench : 		async_preset_tb.v
-- Software : 		ISE 14.7 / Vivado 2018
-- Primitives : 		No
-- Cores : 			No
-- Submodules : 		No
--------------------------------------------------
-- Description : 	Asunchronious module to form strobe for one period clk
--                  after the appearance of an asynchronous signal at the
--                  input preset_in.
--                  __XXXXXX | ______________ input
--                  __ | - | ___ | - | ___ | - | ___ clk
--                  _________ | ------ | ______ output

--------------------------------------------------

library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
----------------------------------------------------------------------------------


entity async_preset is
	port
	(
		clk			: in  std_logic;	
		preset_in	: in std_logic;		-- async
		--
		q_out		: out std_logic		-- sync

	);
end entity async_preset;



architecture behavioral of async_preset is

	----=CONSTANTS,SIGNALS,VARIABLES=----------

	signal one_in_flag	: boolean := false;

	signal q_out_r		: std_logic := '0';
	--
	----=END_CONSTANTS,SIGNALS,VARIABLES=------

begin
		
	----=CONTINUOUS ASSIGNMENTS=---------------
	--
	q_out <= q_out_r;
	--
	----=END_CONTINUOUS ASSIGNMENTS=-----------
	
	----=PROCESSES, ETC=-----------------------
	--
	process (clk, preset_in) begin		
		--								
		if (preset_in = '1') then		
			--							
			one_in_flag <= true;		
										
		elsif rising_edge(clk) then		
			--							
			if one_in_flag then			
				--						
				one_in_flag <= false;	
				q_out_r <= '1';			
										
			else						
				--						
				q_out_r <= '0';			
										
			end if;						
			--							
		end if;							
		--								
	end process;						
	--
	----=END_PROCESSES, ETC=-------------------

end architecture;