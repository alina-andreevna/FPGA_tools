----------------------------------------------------------------------------------
-- MOD.DATE: 20200423
--------------------------------------------------
-- Project :		
-- Author :			Alina Galichina
-- Creation date : 	2019-09-08
-- File : 			strobe_gen.vhd
-- TestBench : 		strobe_gen_tb.v
-- Software : 		ISE 14.7 / Vivado 2018
-- Primitives : 		No
-- Cores : 			No
-- Submodules : 		No
--------------------------------------------------
-- Description : 	Module for generate single pulse with user's start and duration 
-- 					after start clk. For generate new pulse use async reset_in input.

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity strobe_gen is
	generic
	(	
		Inverted			: boolean := true; 	-- true: pulse = 1, no_pulse = 0; false: pulse = 0, no pulse = 1
		Tiks_to_begin		: integer := 20; 		-- counts of clk period for rising edge
		Impulse_length		: integer := 1			-- strobe duration
	);
	port
	(
		reset_in				: in std_logic;		-- async
		clk_in					: in std_logic;
		strobe_out				: out std_logic
	);
end entity strobe_gen;


--=ARCHITECTURE=---------------------------------
architecture behavioral of strobe_gen is
	
	----=SIGNALS,CONSTANTS,ETC=------------------
	
	signal one_time_RST_counter : integer range 0 to 1000 := 0;
	signal strobe_s				: std_logic;

begin
	----=CONTINUOUS ASSIGNMENTS=-----------------
	strobe_out <= strobe_s;
	
	----=END CONTINUOUS ASSIGNMENTS=-----------------

	strobe : process (clk_in, reset_in)
	begin
		if (reset_in = '1') then
			one_time_RST_counter <= 0;
		elsif rising_edge(clk_in) then
			if (one_time_RST_counter <= Tiks_to_begin + Impulse_length) then
				if (Inverted) then
					if (one_time_RST_counter < Tiks_to_begin) then
						strobe_s <= '1';
					elsif (one_time_RST_counter >= Tiks_to_begin) 
						  and (one_time_RST_counter < Tiks_to_begin + Impulse_length) then
						strobe_s <= '0';
					elsif (one_time_RST_counter >= Tiks_to_begin + Impulse_length) then
						strobe_s <= '1';
					else
						strobe_s <= '1';
					end if;
				else
					if (one_time_RST_counter < Tiks_to_begin) then
						strobe_s <= '0';
					elsif (one_time_RST_counter >= Tiks_to_begin) 
						   and (one_time_RST_counter < Tiks_to_begin + Impulse_length) then
						strobe_s <= '1';
					elsif (one_time_RST_counter >= Tiks_to_begin + Impulse_length) then
						strobe_s <= '0';
					else
						strobe_s <= '0';
					end if;
				end if;
				one_time_RST_counter <= one_time_RST_counter + 1;
			else
				if (Inverted) then
					strobe_s <= '1';
				else
					strobe_s <= '0';
				end if;
			end if;
		end if;
		
	end process strobe;
end behavioral;