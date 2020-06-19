----------------------------------------------------------------------------------
-- MOD.DATE: 080320
--------------------------------------------------
-- Project :		
-- Author :			Alina Galichina
-- Creation date : 	2020-04-03
-- File : 			cdc_pulse.vhd
-- TestBench : 		cdc_pulse_tb.v
-- Software : 		ISE 14.7 / Vivado 2018
-- Primitives : 		No
-- Cores : 			No
-- Submodules : 		No
--------------------------------------------------
-- Description : 	Module to CDC single pulse with measured frequency of domains
--
-- 					SLOW TO FAST: reading the slow pulse with a fast frequency and 
--					finding the falling edge with the help of "and not".
--
-- 					FAST TO SLOW: stretching the pulse to a length of at least one 
--					and a half clock cycles of slow frequency and reading the stretched 
--					pulse at a slow frequency.

----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity cdc_pulse is
    Generic ( slow_freq : natural := 40000000;		-- freq in Hz
    		  fast_freq : natural := 100000000;		-- freq in Hz
    		  direction : string := "SLOW_TO_FAST"	-- direction
    	);
    Port ( clk_fast_in : in  STD_LOGIC;
           clk_slow_in : in  STD_LOGIC;
           strobe_in : in  STD_LOGIC;
           strobe_out : out  STD_LOGIC);
end cdc_pulse;

architecture Behavioral of cdc_pulse is

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

function FILL_BITS(a : std_logic_vector; b : integer) return std_logic_vector is
	variable ones  : std_logic_vector(b - 1 downto 0) := (others => '1');
	variable zeros : std_logic_vector(b - 1 downto 0) := (others => '0');
begin
	if a = "1" then
		return ones;
	else
		return zeros;
	end if;
end function;
------------------=END FUNCTIONS=------------------

----=CONSTANTS,SIGNALS,VARIABLES=----------
constant n : integer := LOG2(fast_freq/slow_freq) + 1; 
signal cnt : unsigned(n - 1 downto 0) := (others => '1');

signal pulse_in, pulse_out : std_logic := '0';
signal pulse_sync_fast, pulse_sync_fast_delayed : std_logic := '0';
signal pulse_sync_slow, pulse_sync_slow_delayed, pulse_sync_slow_delayed_delayed : std_logic := '0';

----=END_CONSTANTS,SIGNALS,VARIABLES=------

begin
----=ASSERTIONS=----
assert direction = "FAST_TO_SLOW" or direction = "SLOW_TO_FAST" report  "Unknown direction" severity FAILURE;
assert slow_freq < fast_freq report  "slow_freq should be less than fast_freq" severity FAILURE;
assert false report  "n=" & integer'image(n) severity NOTE;

----=END ASSERTIONS=----

----=SLOW TO FAST PART=----
InputRegSlow : if direction = "SLOW_TO_FAST" generate
	process(clk_slow_in) 
	begin
	  if rising_edge(clk_slow_in) then
	    pulse_in <= strobe_in;
	  end if;
	end process;
end generate InputRegSlow;

SlowToFastCDC : if direction = "SLOW_TO_FAST" generate
	process(clk_fast_in) 
	begin
	  if rising_edge(clk_fast_in) then
	    pulse_sync_fast <= pulse_in;
	    pulse_sync_fast_delayed <= pulse_sync_fast;
	  end if;
	end process;

	pulse_out <= pulse_sync_fast and not pulse_sync_fast_delayed;
end generate SlowToFastCDC;

OutputRegFast : if direction = "SLOW_TO_FAST" generate
	process(clk_fast_in) 
	begin
	  if rising_edge(clk_fast_in) then
	    strobe_out <= pulse_out;
	  end if;
	end process;
end generate OutputRegFast;

----=END SLOW TO FAST PART=----

----=FAST TO SLOW PART=----

InputRegFast : if direction = "FAST_TO_SLOW" generate
	process(clk_fast_in) 
	begin
	  if rising_edge(clk_fast_in) then
	    pulse_in <= strobe_in;
	  end if;
	end process;
end generate InputRegFast;

FastToSlowCDC : if direction = "FAST_TO_SLOW" generate
	process(clk_fast_in) 
	begin
	  if rising_edge(clk_fast_in) then
	    if pulse_in = '1' then
	    	cnt <= (others => '0');
	    	pulse_sync_slow <= '0';
	    elsif cnt < unsigned(FILL_BITS("1", cnt'length)) then
	    	cnt <= cnt+1;
	    	pulse_sync_slow <= '1';
	    else
	    	cnt <= (others => '1');
	    	pulse_sync_slow <= '0';
	    end if;

	  end if;
	end process;

	process(clk_slow_in) 
	begin
	if rising_edge(clk_slow_in) then
	 	pulse_sync_slow_delayed <= pulse_sync_slow;
	 	pulse_sync_slow_delayed_delayed <= pulse_sync_slow_delayed;
	end if;
	end process;
end generate FastToSlowCDC;

OutputRegSlow : if direction = "FAST_TO_SLOW" generate
	process(clk_slow_in) 
	begin
	  if rising_edge(clk_slow_in) then
	  	pulse_out <= pulse_sync_slow_delayed_delayed and not pulse_sync_slow_delayed;
	    strobe_out <= pulse_out;
	  end if;
	end process;
end generate OutputRegSlow;

----=END FAST TO SLOW PART=----


end Behavioral;

