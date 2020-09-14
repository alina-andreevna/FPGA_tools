----------------------------------------------------------------------------------
-- MOD.DATE: 
--------------------------------------------------
-- Project :		-
-- Author :			Alina Galichina
-- Creation date : 	12.09.2020
-- File : 			window_analysis.vhd
-- TestBench : 		..\sim\window_analysis_tb.vhd
-- Software : 		ISE 14.7, Vivado 2018
-- Primitives : 	FIFO_SYNC_MACRO
-- Cores : 			No
-- Submodules : 	No
--------------------------------------------------
-- Description : 	Система обработки данных для вычисления постоянной составляющей сигнала, максимальной амплитуды и номера отсчёта максимальной амплитуды.
--					Входные данные поступают в формате Offset binary: 
--					Decimal  |	Offset binary,K = 3
--					--------------------------------
--				  		3 	 |      111 	
--				  		2 	 |      110 	
--				  		1 	 |      101 	
--				  		0 	 |      100/000 	
--				  		−1 	 |      011 	
--				  		−2 	 |      010 	
--				  		−3 	 |      011 
--				 	-------------------------------
--					Постоянная составляющая расчитывается как сумма всех значение делённая на размер фрейма обработки. 
-- 					Результаты обработки сохраняются в буфер, реализованный на базе FIFO.
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package for_window_analysis is

	type bramParamType is record
		BRAM_SIZE : string(1 to 4);
		COUNTER_WIDTH : integer;			
	end record;

	constant DEVICE : string := "7SERIES";

	-- Логарифм по основанию 2 для оптимальной разрядности счётчиков
	function LOG2(a : integer) return integer;

	-- Максимум двух чисел 
	function MAX(a : integer; b : integer) return integer;

	-- Расчёт оптимальных параметров LIFO для максимальных разрядности данных и длины последовательности.
	function SET_BRAM_PARAM(readWidth : integer; writeWidth : integer; depth : integer) return bramParamType;

end package;

PACKAGE BODY for_window_analysis IS

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

	function MAX(a : integer; b : integer) return integer is
	begin
		if a > b then return a; else return b; end if;
	end function;
   
      -----------------------------------------------------------------
   -- DATA_WIDTH | FIFO_SIZE | FIFO Depth | RDCOUNT/WRCOUNT Width --
   -- ===========|===========|============|=======================--
   --   37-72    |  "36Kb"   |     512    |         9-bit         --
   --   19-36    |  "36Kb"   |    1024    |        10-bit         --
   --   19-36    |  "18Kb"   |     512    |         9-bit         --
   --   10-18    |  "36Kb"   |    2048    |        11-bit         --
   --   10-18    |  "18Kb"   |    1024    |        10-bit         -- <---- we use this config
   --    5-9     |  "36Kb"   |    4096    |        12-bit         --
   --    5-9     |  "18Kb"   |    2048    |        11-bit         --
   --    1-4     |  "36Kb"   |    8192    |        13-bit         --
   --    1-4     |  "18Kb"   |    4096    |        12-bit         --
   -----------------------------------------------------------------

	function SET_BRAM_PARAM(readWidth : integer; writeWidth : integer; depth : integer) return bramParamType is
	variable width : integer := MAX(readWidth, writeWidth);
	variable result : bramParamType;
	begin
	if (width >= 37 and width <= 72) and depth <= 512 then
		result := ("36Kb", 9);
		elsif (width >= 19 and width <= 36) and depth <= 1024 then
		result := ("36Kb", 10);
		elsif (width >= 19 and width <= 36) and depth <= 512 then
		result := ("18Kb", 9);
		elsif (width >= 10 and width <= 18) and depth <= 2048 then
		result := ("36Kb", 11);
		elsif (width >= 10 and width <= 18) and depth <= 1024 then
		result := ("18Kb", 10);
		elsif (width >= 5 and width <= 9) and depth <= 4096 then
		result := ("36Kb", 12);
		elsif (width >= 5 and width <= 9) and depth <= 2048 then
		result := ("18Kb", 11);
		elsif (width >= 1 and width <= 4) and depth <= 8192 then
		result := ("36Kb", 13);
		elsif (width >= 1 and width <= 4) and depth <= 4096 then
		result := ("18Kb", 12);
	end if;
	return result;
end function;

end for_window_analysis;

--------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library UNISIM;
use UNISIM.vcomponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;

Library work;
use work.for_window_analysis.all;

--------------------------------------------------

entity window_analysis is

	generic( 
			fifo_size : natural := 100;
			fifo_state_size : natural := 4;
			sample_data_size : natural := 10;
			window_delay_size : natural := 10;
			window_pow_size : natural := 10;
			cycle_number_size : natural := 10
			);    

	port( clk         : in  std_logic;
		  nrst_in     : in std_logic;

		  cycle_start_in		: in std_logic;
		  sample_data_in		: in std_logic_vector(sample_data_size - 1 downto 0);
		  window_delay_in		: in std_logic_vector(window_delay_size - 1 downto 0);
		  window_pow_in			: in std_logic_vector(window_pow_size - 1 downto 0);
		  read_enable_in		: in std_logic;

		  
		  read_data_out			: out std_logic_vector(cycle_number_size + 2*sample_data_size + LOG2(window_pow_size) + window_pow_size - 1 - 1 downto 0);
		  fifo_state_out		: out std_logic_vector(fifo_state_size - 1 downto 0)
		  );

end entity window_analysis;

--------------------------------------------------

architecture behavior of window_analysis is

	------------------=FUNCTIONS=------------------
	
-- NO FUNCTIONS --

	------------------=END FUNCTIONS=------------------


	------------------=CONSTANTS,SIGNALS,VARIABLES=------------------

-- Целевые параметры: постонное смещение, максимум, индекс максимума, номер цикла
signal zero_offset 	: signed(sample_data_size + LOG2(window_pow_size) - 1 - 1 downto 0) := (others => '0');
signal max_ampl 	: signed(sample_data_size - 1 downto 0) := (others => '0');
signal max_time 	: unsigned(window_pow_size - 1 downto 0) := (others => '0');
signal cycle_number : unsigned(cycle_number_size - 1 downto 0) := (others => '0');

-- Счётики задержки и длительность фрейма
signal time_counter	: unsigned(window_pow_size - 1 downto 0) := (others => '0');
signal delay_counter : unsigned(window_delay_size - 1 downto 0) := (others => '0');

-- Синхронизатор для асинхронного запуска cycle_start_in
signal cycle_start_sync : std_logic_vector(1 downto 0) := "00";
signal cycle_start : std_logic := '0';

-- Конечный автомат
type state_t is (idle, 
				 waiting_delay, 
				 calculate_params, 
				 ready_data);
signal state_r, next_state : state_t;

-- Регистры задержки и длительности фрейма 
signal window_delay : unsigned(window_delay_size - 1 downto 0) := (others => '0'); 
signal window_pow 	: unsigned(window_pow_size - 1 downto 0) := (others => '0'); 

-- Вспомогательные сигналы для расчёта постоянного смещения
signal sample_data 		: signed(sample_data_size - 1 downto 0) := (others => '0'); 
signal sum_sample_data 	: signed(sample_data_size + LOG2(window_pow_size) + 1 - 1 downto 0) := (others => '0'); 

-- Управление памятью
signal write_data, read_data : std_logic_vector(cycle_number_size + 2*sample_data_size + LOG2(window_pow_size) - 1 + window_pow_size - 1 downto 0) := (others => '0');

constant BRAM_PARAM : bramParamType := SET_BRAM_PARAM(read_data'length, write_data'length, fifo_size); -- оптимальные параметры LIFO

signal wr_en, rd_en, reset_mem : std_logic := '0';
signal full, empty, almost_full, almost_empty : std_logic := '0';
signal rd_count, wr_count : std_logic_vector(BRAM_PARAM.COUNTER_WIDTH - 1 downto 0) := (others => '0');

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

	assert False 
		report "MEMORY DATA WIDTH = " & integer'image(cycle_number_size + 2*sample_data_size + window_pow_size) & 
			   ", MEMORY SIZE = " & BRAM_PARAM.BRAM_SIZE
		severity NOTE;

	----=END ASSERTIONS=----


	----=CONTINIOUS ASSIGNMENTS=----
	
-- Выходные данные --
read_data_out <= read_data;
fifo_state_out <= full & empty & almost_full & almost_empty;

--------------------------------------

-- Синхронизированный импульс запуска обработки --
cycle_start <= cycle_start_sync(1);

--------------------------------------

-- Преобразование формата Offset binary к signed
 sample_data <= signed(not(sample_data_in(sample_data_size - 1)) & sample_data_in(sample_data_size - 2 downto 0));

--------------------------------------

-- Управление памятью --
write_data <= std_logic_vector(cycle_number) & std_logic_vector(zero_offset) & std_logic_vector(max_ampl) & std_logic_vector(max_time);
reset_mem <= not(nrst_in);
rd_en <= read_enable_in;

	----=END CONTINIOUS ASSIGNMENTS=----


	----=INSTANCES=---
	
 -- Буфер FIFO --

   comp_buffer_fifo : FIFO_SYNC_MACRO
   generic map (
      DEVICE => DEVICE,              		  -- целевое устройство
      DATA_WIDTH => write_data'length,        -- размерность данных чтения/записи
      FIFO_SIZE => BRAM_PARAM.BRAM_SIZE)      -- размер 18/36 кБ
	  
   port map (
      ALMOSTEMPTY => almost_empty,              
      ALMOSTFULL => almost_full,     
	  EMPTY => empty,                 
      FULL => full,             
      
      CLK => clk,                 
	  DI => write_data,            	  
      DO => read_data,       

	  RDEN => rd_en,    
	  WREN => wr_en,     
      RDCOUNT => rd_count, 
      WRCOUNT => wr_count,     

      RST => reset_mem  
   );

	----=END INSTANCES=----


	----=PROCESSES ETC.=----


-- FINITE STATE MACHINE --

-- Схема автомата --

fsm_scheme : process(cycle_start, delay_counter, window_delay, time_counter, window_pow)
begin
	case state_r is
	
	when idle =>
		if cycle_start = '1' then
			next_state <= waiting_delay;
		end if;
		
	when waiting_delay =>
		if delay_counter = window_delay - 3 then
			next_state <= calculate_params;
		end if;
	
	when calculate_params =>
		if time_counter = window_pow - 1 then
			next_state <= ready_data;
		end if;
		
	when ready_data =>
		next_state <= idle;
		
	end case;
end process fsm_scheme;


-- Регистр автомата --	

fsm_reg : process(clk, nrst_in)
begin
	if nrst_in = '0' then
		state_r <= idle;
	elsif rising_edge(clk) then
		state_r <= next_state;
	end if;
end process fsm_reg;


-- Описание состояний --

fsm_states : process(clk)
begin
	if rising_edge(clk) then
	case state_r is
	
	when idle =>
		zero_offset <= (others => '0');
		max_ampl 	<= (others => '0');
		max_time 	<= (others => '0');
		
		sum_sample_data <= (others => '0');
		
		time_counter 	<= (others => '0');
		delay_counter 	<= (others => '0');
		
		wr_en <= '0';
		
		
	when waiting_delay =>
		delay_counter <= delay_counter + 1;
	
	when calculate_params =>
		time_counter <= time_counter + 1;
		
		if max_ampl <= sample_data then
			max_ampl <= sample_data;
			max_time <= time_counter;
		end if;
		
		sum_sample_data <= sum_sample_data + sample_data;
		
	when ready_data =>
		wr_en <= '1';
		
		zero_offset <= sum_sample_data(sum_sample_data'length - 1 downto LOG2(to_integer(unsigned(window_pow))));
		cycle_number <= cycle_number + 1;
		
	end case;
	end if;
end process fsm_states;

-- END FINITE STATE MACHINE --


-- Сохранение параметров фрейма --

frame_params : process(nrst_in, cycle_start_in)
begin
	if nrst_in = '0' then
		window_pow 		<= (others => '0');
		window_delay 	<= (others => '0');
	elsif cycle_start_in = '1' then
		window_pow 		<= unsigned(window_pow_in);
		window_delay 	<= unsigned(window_delay_in);
	end if;
end process frame_params;


-- Синхронизация импульса начала фрейма --

cycle_start_sync_reg : process(clk)
begin
	if nrst_in = '0' then
		cycle_start_sync <= "00";
	elsif rising_edge(clk) then
		cycle_start_sync(0) <= cycle_start_in;
		cycle_start_sync(1) <= cycle_start_sync(0);
	end if;
end process cycle_start_sync_reg;

	----=END PROCESSES ETC.=----


	----=DEBUG ZONE=----

-- NO DEBUG ZONE --

	----=END DEBUG ZONE=----

end architecture behavior;