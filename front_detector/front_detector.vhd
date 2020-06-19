----------------------------------------------------------------------------------
-- MOD.DATE: 12032019
--------------------------------------------------
-- Project :		
-- Author :			Alina Galichina
-- Creation date : 	2019-12-02
-- File : 			front_detector.vhd
-- TestBench : 		front_detector_tb.v
-- Software : 		ISE 14.7 / Vivado 2018
-- Primitives : 		No
-- Cores : 			No
-- Submodules : 		No
--------------------------------------------------
-- Description : 	Module generate pulse to changed edge type (RISING/FALLING/ALL_EDGES)

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
----------------------------------------------------------------------------------

entity front_detector is
	generic
	(
		edge_type : string := "ALL_EDGES"	-- RISING/FALLING/ALL_EDGES
	);
	port
	(
		clk_in		: in std_logic;
		pulse_in	: in std_logic;
		pulse_out	: out std_logic
	);	
end entity front_detector;


architecture behavioral of front_detector is
	signal prev_signal : std_logic;
	
begin 

	process(clk_in)
	begin
		if (rising_edge(clk_in)) then
			prev_signal <= pulse_in;
		end if;
	end process;
	
	RisingEdge:		if (edge_type = "RISING") generate
		pulse_out <= ( not prev_signal ) and pulse_in;
	end generate;
	--
	FallingEdge:	if (edge_type = "FALLING") generate
		pulse_out <= prev_signal and ( not pulse_in );
	end generate;
	--
	BothEdges :		if (edge_type = "ALL_EDGES") generate
		pulse_out <= prev_signal xor pulse_in;
	end generate;
	
end behavioral;