----------------------------------------------------------------------------------
-- MOD.DATE: 25062020
--------------------------------------------------
-- Project :		
-- Author :			Alina Galichina
-- Creation date : 	2020-06-25
-- File : 			debouncer.vhd
-- TestBench : 		..\debouncer_tb.vhd
-- Software : 		ISE 14.7, Vivado 2018
-- Primitives : 	No
-- Cores : 			No
-- Submodules : 	No
--------------------------------------------------
-- Description : 	Module to debouncing circuit that forwards only
-- 					signals that have been stable for preset counts of ticks:
--							if d(signal_in) > wait_ticks then signal_out <= signal_in
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
	generic(
		wait_ticks : integer := 3);     --preset stable duration

	port(
		signal_in  : in  std_logic;
		signal_out : out std_logic;
		clk        : in  std_logic);
end entity debouncer;

architecture behaivorial of debouncer is

	------------------=FUNCTIONS=------------------

	function LOG2(a : integer) return integer is
		variable b : integer := 0;
	begin
		assert a > 0 report "Operand cannot be less than 1" severity FAILURE;
		for i in 0 to integer'high loop
			b := i;
			exit when 2 ** i >= a;
		end loop;
		return b;
	end function;

	------------------=END FUNCTIONS=------------------

	------------------=CONSTANTS,SIGNALS,VARIABLES=------------------

	type state_t is (idle, work);
	signal state : state_t := idle;

	signal counter : unsigned(LOG2(wait_ticks) - 1 downto 0) := (others => '0');

	signal signal_out_r : std_logic := '0';
	signal signal_in_r  : std_logic := '0';
	
------------------=END CONSTANTS,SIGNALS,VARIABLES=------------------


begin
	----=ASSERTIONS=----

	assert false report "wait_tiks = " & integer'image(wait_ticks) severity NOTE;

	----=END ASSERTIONS=----

	signal_out <= signal_out_r;

	process(clk) is
	begin
		if rising_edge(clk) then
			case state is
				when idle =>
					if signal_out_r /= signal_in then
						signal_in_r <= signal_in;
						counter     <= to_unsigned(wait_ticks - 1, counter'length);

						state <= work;
					end if;

				when work =>
					if counter = 0 then
						if signal_in = signal_in_r then
							signal_out_r <= signal_in;
						end if;

						state <= idle;

					else
						if signal_in /= signal_in_r then
							state <= idle;
						end if;

						counter <= counter - 1;

					end if;

			end case;
		end if;
	end process;

end architecture behaivorial;