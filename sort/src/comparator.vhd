----------------------------------------------------------------------------------
-- MOD.DATE: 20/08/2020
--------------------------------------------------
-- Project :		-
-- Author :			Alina Galichina
-- Creation date : 	17.08.2020
-- File : 			comparator.vhd
-- TestBench : 		--
-- Software : 		ISE 14.7, Vivado 2018
-- Primitives : 	No
-- Cores : 			No
-- Submodules : 	No
--------------------------------------------------
-- Description : 	Ячейка сортировки предназначена для хранения и сравнения двух чисел.
--					Ячейка имеет режимы чтения и записи. В режиме записи ячейка сохраняет большее число внутри, а меньшее отдаёт на выход. 
-- 					Его место занимает новое число со входа.
--					В режиме чтения наоборот: большее число отдаётся на выход, меньшее сохраняется для последующего сравнения с новым входным 
-- 					числом.
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------

entity comparator is

	generic(
		DATA_WIDTH : integer := 10
	);

	port(clk_in      : in  std_logic;
		 reset_in    : in  std_logic;

		 -- входной интерфейс
		 is_input_in : in  std_logic; -- флаг чтения (high) или записи (low)
		 prev_in     : in  std_logic_vector(DATA_WIDTH - 1 downto 0); -- вход для режима записи
		 next_in     : in  std_logic_vector(DATA_WIDTH - 1 downto 0); -- вход для режима чтения

		 -- выходной интерфейс
		  data_out			: out std_logic_vector(DATA_WIDTH - 1 downto 0)	-- выходное значение
	);

end entity comparator;

--------------------------------------------------

architecture behaivorial of comparator is

	------------------=FUNCTIONS=------------------

-- NO FUCTIONS --

	------------------=END FUNCTIONS=------------------


	------------------=CONSTANTS,SIGNALS,VARIABLES=------------------

	signal higher, lower : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
	signal output : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
	signal cand_h : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');	
	signal cand_l : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');	

-- 	------------------=END CONSTANTS,SIGNALS,VARIABLES=------------------


	-----------------=COMPONENTS=------------------

-- NO COMPONENTS --

	------------------=END COMPONENTS=------------------


	-----------------=DEBUG ZONE=------------------

-- NO DEBUG ZONE --

	------------------=END DEBUG ZONE=------------------


	-----------------=ATTRIBUTES=------------------

-- NO ATTRIBUTES --

	------------------=END ATTRIBUTES=------------------

--------------------------------------------------

begin

	----=ASSERTIONS=----

-- NO ASSERTIONS --

	----=END ASSERTIONS=----


	----=CONTINIOUS ASSIGNMENTS=----

	data_out <= output;
	output <= lower when is_input_in = '1' else higher; -- выход ячейки в зависимости от режима работы


	-- числа для сравнения
	cand_h <= higher when is_input_in = '1' else lower; 
	cand_l <= prev_in when is_input_in = '1' else next_in; 


	----=END CONTINIOUS ASSIGNMENTS=----


	----=INSTANCES=---

-- NO INSTANCES --

	----=END INSTANCES=----


	----=PROCESSES ETC.=----

	-- сравнение двух чисел
	process(clk_in, reset_in)
	begin
		if reset_in = '1' then
			higher <= (others => '0');	
			lower <= (others => '0');	

		elsif rising_edge(clk_in) then
			if cand_h >= cand_l then
				higher <= cand_h;
				lower <= cand_l;
			else
				higher <= cand_l;
				lower <= cand_h;
			end if;
		end if;
	end process;

	----=END PROCESSES ETC.=----


	----=DEBUG ZONE=----

-- NO DEBUG ZONE --

	----=END DEBUG ZONE=----

end architecture behaivorial;
