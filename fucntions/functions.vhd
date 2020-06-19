----------------------------------------------------------------------------------
-- MOD.DATE: 02032020
--------------------------------------------------
-- Project :		
-- Author :			Alina Galichina
-- Creation date : 	2018-07-04
-- File : 			functions.vhd
-- TestBench : 		No
-- Software : 		ISE 14.7 / Vivado 2018
-- Primitives : 		No
-- Cores : 			No
-- Submodules : 		No
--------------------------------------------------
-- Description : 	Package with often used functions.

----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

package functions is

	function MAX(a : integer; b : integer) return integer;

	function LOG2(a : integer) return integer;

	function FILL_BITS(a : std_logic_vector; b : integer) return std_logic_vector;


	function REVERSE_BITS(a : std_logic_vector) return std_logic_vector;

	function CHANGE_SIGN(a : std_logic_vector) return std_logic_vector;




-- Служит для преобразования std_logiс в std_logic_vector. (Иногда полезно при работе с параметризованным кодом)
-- Ex: 
-- Signal a: std_logic_vector(0 downto 0);
-- Signal b: std_logic;
-- b <= scalarize(a);
	function SCALARIZE(v : in std_logic_vector) return std_logic;

-- Служит для преобразования std_logic_vector в std_logiс. (Иногда полезно при работе с параметризованным кодом)
-- Ex: 
-- Signal a: std_logic_vector(0 downto 0);
-- Signal b: std_logic;
-- a <= vectorize(b);
	function VECTORIZE(s : std_logic) return std_logic_vector;

end functions;

package body functions is

	function MAX(a : integer; b : integer) return integer is
	begin
		if a > b then
			return a;
		else
			return b;
		end if;
	end function;

	function REVERSE_BITS(a : std_logic_vector) return std_logic_vector is
		variable b : std_logic_vector(a'range) := (others => '0');
	begin
		for i in 0 to a'length - 1 loop
			b(i) := a(a'left - i);
		end loop;
		return b;
	end function;


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

	function CHANGE_SIGN(a : std_logic_vector) return std_logic_vector is
		variable zeros : std_logic_vector(a'range) := (others => '0');
	begin
		return std_logic_vector(unsigned(zeros) - unsigned(a));
	end function;


	function VECTORIZE(s : std_logic) return std_logic_vector is
		variable v : std_logic_vector(0 downto 0);
	begin
		v(0) := s;
		return v;
	end;

	function SCALARIZE(v : in std_logic_vector) return std_logic is
	begin
		assert v'length = 1
			report "scalarize: output port must be single bit!"
			severity FAILURE;
		return v(v'LEFT);
	end;

	function SET_FIFO_COUNTS_WIDTH(dataWidth : integer; fifoSize : string(1 to 4)) return integer is
	-----------------------------------------------------------------
	-- DATA_WIDTH | FIFO_SIZE | FIFO Depth | RDCOUNT/WRCOUNT Width --
	-- ===========|===========|============|=======================--
	--   37-72    |  "36Kb"   |     512    |         9-bit         --
	--   19-36    |  "36Kb"   |    1024    |        10-bit         --
	--   19-36    |  "18Kb"   |     512    |         9-bit         --
	--   10-18    |  "36Kb"   |    2048    |        11-bit         --
	--   10-18    |  "18Kb"   |    1024    |        10-bit         --
	--    5-9     |  "36Kb"   |    4096    |        12-bit         --
	--    5-9     |  "18Kb"   |    2048    |        11-bit         --
	--    1-4     |  "36Kb"   |    8192    |        13-bit         --
	--    1-4     |  "18Kb"   |    4096    |        12-bit         --
	-----------------------------------------------------------------
		variable result : integer;
		begin

		assert dataWidth < 72 report "set_fifo_counts_width: dataWidth must be less than 72"	severity FAILURE;
		assert fifoSize = "36Kb" or fifoSize = "18Kb" report "set_fifo_counts_width: fifoSize must be 18Kb or 36Kb"	severity FAILURE;	

		if (dataWidth >= 37 and dataWidth <= 72) and fifoSize = "36Kb" then
			result := 9;
			elsif (dataWidth >= 19 and dataWidth <= 36) and fifoSize = "36Kb" then
			result := 10;
			elsif (dataWidth >= 19 and dataWidth <= 36) and fifoSize = "18Kb" then
			result := 9;
			elsif (dataWidth >= 10 and dataWidth <= 18) and fifoSize = "36Kb" then
			result := 11;
			elsif (dataWidth >= 10 and dataWidth <= 18) and fifoSize = "18Kb" then
			result := 10;
			elsif (dataWidth >= 5 and dataWidth <= 9) and fifoSize = "36Kb" then
			result := 12;
			elsif (dataWidth >= 5 and dataWidth <= 9) and fifoSize = "18Kb" then
			result := 11;
			elsif (dataWidth >= 1 and dataWidth <= 4) and fifoSize = "36Kb" then
			result := 13;
			elsif (dataWidth >= 1 and dataWidth <= 4) and fifoSize = "18Kb" then
			result := 12;
			else
			result := 999;
		end if;
		return result;
	end;

	function SET_AXIS_WIDTH(target_width : integer) return integer is
	variable a : integer := 0;
	begin
		for i in 1 to integer'high loop
			a := i;
			exit when 8*i >= target_width;
		end loop;
		return 8*a*2;
	end;

end package body functions;


