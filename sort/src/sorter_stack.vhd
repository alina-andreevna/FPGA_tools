----------------------------------------------------------------------------------
-- MOD.DATE: 20/08/2020
--------------------------------------------------
-- Project :		-
-- Author :			Alina Galichina
-- Creation date : 	17.08.2020
-- File : 			sorter_stack.vhd
-- TestBench : 		..\sim\sorter_stack_tb.v
-- Software : 		ISE 14.7, Vivado 2018
-- Primitives : 	BRAM_SDP_MACRO
-- Cores : 			No
-- Submodules : 	comparator.vhd
--------------------------------------------------
-- Description : 	Модуль сортировки входных значений по возрастанию и перевод отсортированных данных из одного клокового домена в другой.
--					Для реализаации задачи использует сортировку по убыванию и память типа LIFO.
--
--					Сортировка реализована путём создания каскада сортировочных ячеек и сравнение двух последовательно приходящих чисел.
--					Сортировочная ячейка реализует хранение и сравнение двух чисел. В зависимости от режима работы на выход ячейки поступает 
-- 					большее или меньшее число. Второе число сохраняется в памяти для сравнения с новым числом, поступившего на вход. 
-- 					После прихода последнего значения последовательности каждая ячейка содержит два значения, причём значения в ячейках
--					отсортированы по убыванию. Далее происходит их последовательное считывание из ячеек.
--
--					Для перехода в другой клоковый домен используется двухклоковая память с чтением и записью по адресу. Память также реализует
--					конвертацию сортировки по убыванию в сортировку по возрастанию. 
--
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package for_sorter_stack is

	type bramParamType is record
		BRAM_SIZE : string(1 to 4);
		ADDR_WIDTH : integer;
		WE_WIDTH : integer;				
	end record;

	constant DEVICE : string := "7SERIES";

	-- Логарифм по основанию 2 для оптимальной разрядности счётчиков
	function LOG2(a : integer) return integer;

	-- Максимум двух чисел 
	function MAX(a : integer; b : integer) return integer;

	-- Расчёт оптимальных параметров LIFO для максимальных разрядности данных и длины последовательности.
	function SET_BRAM_PARAM(readWidth : integer; writeWidth : integer; depth : integer) return bramParamType;

end package;

PACKAGE BODY for_sorter_stack IS

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

   -----------------------------------------------------------------------
	    ---- Reference information from Xilinx Language templates ----
   -----------------------------------------------------------------------
   --  READ_WIDTH | BRAM_SIZE | READ Depth  | RDADDR Width |            --
   -- WRITE_WIDTH |           | WRITE Depth | WRADDR Width |  WE Width  --
   -- ============|===========|=============|==============|============--
   --    37-72    |  "36Kb"   |      512    |     9-bit    |    8-bit   --
   --    19-36    |  "36Kb"   |     1024    |    10-bit    |    4-bit   --
   --    19-36    |  "18Kb"   |      512    |     9-bit    |    4-bit   --
   --    10-18    |  "36Kb"   |     2048    |    11-bit    |    2-bit   --
   --    10-18    |  "18Kb"   |     1024    |    10-bit    |    2-bit   --
   --     5-9     |  "36Kb"   |     4096    |    12-bit    |    1-bit   --
   --     5-9     |  "18Kb"   |     2048    |    11-bit    |    1-bit   --
   --     3-4     |  "36Kb"   |     8192    |    13-bit    |    1-bit   --
   --     3-4     |  "18Kb"   |     4096    |    12-bit    |    1-bit   --
   --       2     |  "36Kb"   |    16384    |    14-bit    |    1-bit   --
   --       2     |  "18Kb"   |     8192    |    13-bit    |    1-bit   --
   --       1     |  "36Kb"   |    32768    |    15-bit    |    1-bit   --
   --       1     |  "18Kb"   |    16384    |    14-bit    |    1-bit   --
   -----------------------------------------------------------------------

	function SET_BRAM_PARAM(readWidth : integer; writeWidth : integer; depth : integer) return bramParamType is
	variable width : integer := MAX(readWidth, writeWidth);
	variable result : bramParamType;
	begin
	if (width >= 37 and width <= 72) and depth <= 512 then
		result := ("36Kb", 9, 8);
		elsif (width >= 19 and width <= 36) and depth <= 1024 then
		result := ("36Kb", 10, 4);
		elsif (width >= 19 and width <= 36) and depth <= 512 then
		result := ("18Kb", 9, 4);
		elsif (width >= 10 and width <= 18) and depth <= 2048 then
		result := ("36Kb", 11, 2);
		elsif (width >= 10 and width <= 18) and depth <= 1024 then
		result := ("18Kb", 10, 2);
		elsif (width >= 5 and width <= 9) and depth <= 4096 then
		result := ("36Kb", 12, 1);
		elsif (width >= 5 and width <= 9) and depth <= 2048 then
		result := ("18Kb", 11, 1);
		elsif (width >= 3 and width <= 4) and depth <= 8192 then
		result := ("36Kb", 13, 1);
		elsif (width >= 3 and width <= 4) and depth <= 4096 then
		result := ("18Kb", 12, 1);
		elsif (width = 2) and depth <= 16384 then
		result := ("36Kb", 14, 1);
		elsif (width = 2) and depth <= 8192 then
		result := ("18Kb", 13, 1);
		elsif (width = 1) and depth <= 32768 then
		result := ("36Kb", 15, 1);
		elsif (width = 1) and depth <= 16384 then
		result := ("18Kb", 14, 1);
		else
		result := ("22Kb", 14, 1);
	end if;
	return result;
end function;

end for_sorter_stack;

--------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library UNISIM;
use UNISIM.vcomponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;

Library work;
use work.for_sorter_stack.all;

entity sorter_stack is

	generic(
	DATA_WIDTH : integer := 10;
	MAX_LENGTH : integer := 10
		);    

	port( snk_reset  : in  std_logic;
		  snk_clock  : in std_logic;
		  snk_valid  : in std_logic;
		  snk_sop    : in std_logic;
		  snk_eop    : in std_logic;
		  snk_data	 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
		  snk_ready	 : out std_logic;

		  src_reset  : in  std_logic;
		  src_clock  : in std_logic;
		  src_valid  : out std_logic;
		  src_sop    : out std_logic;
		  src_eop 	 : out std_logic;
		  src_data	 : out std_logic_vector(DATA_WIDTH - 1 downto 0)
		);

end entity sorter_stack;

--------------------------------------------------

architecture mixed of sorter_stack is

	------------------=FUNCTIONS=------------------


	------------------=END FUNCTIONS=------------------


	------------------=CONSTANTS,SIGNALS,VARIABLES=------------------

	-- Максимальное количество ячеек сортировки
	constant MAX_LENGTH_INTERNAL : integer := (MAX_LENGTH + 1)/2;

	-- Сигналы ячеек сортировки
	signal data_in, data_out : std_logic_vector(DATA_WIDTH - 1 downto 0)  := (others => '0');

	type output_prev_next_t is array (MAX_LENGTH_INTERNAL - 1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal prev_w, next_w, output_w : output_prev_next_t := (others => (others => '0'));

	-- Счётчики для подсчёта длины каждой последовательности
	signal counter_data_r: unsigned(LOG2(MAX_LENGTH) - 1 downto 0) := (others => '0');
	signal counter_data_out_r : unsigned(LOG2(MAX_LENGTH) - 1 downto 0) := (others => '1');


	-- Флаги отсортированной последовательности
	signal valid, eop : std_logic := '0';	
	signal sop : std_logic_vector(1 downto 0) := "00";	


	-- Управление памятью
	signal data_for_mem, data_from_mem : std_logic_vector(DATA_WIDTH + 3 - 1 downto 0)  := (others => '0'); -- данные + три флага по 1 биту

	constant BRAM_PARAM : bramParamType := SET_BRAM_PARAM(data_for_mem'length,data_from_mem'length, MAX_LENGTH); -- оптимальные параметры LIFO

	signal rd, we: std_logic := '0';
	signal write_enable : std_logic_vector(BRAM_PARAM.WE_WIDTH - 1 downto 0) := (others => '1'); 
	signal reset_mem: std_logic := '0';
	signal rd_address, we_address : unsigned(BRAM_PARAM.ADDR_WIDTH- 1 downto 0) := (others => '0'); 

	signal we_last, stop_write, start_read, start_read_lifo, start_read_last : std_logic := '0'; -- служебные флаги
	signal we_rd : std_logic_vector (1 downto 0) := "00"; -- перевод флага между клоковыми доменами

	-- Выходной регистр готовности принять новую последовательность
	signal snk_ready_r : std_logic := '1';

	-- Регистры выходного интерфейса
	signal src_data_out_r : std_logic_vector(DATA_WIDTH - 1 downto 0)  := (others => '0');
	signal src_sop_r, src_eop_r, src_valid_r : std_logic := '0';

		------------------=END CONSTANTS,SIGNALS,VARIABLES=------------------


		-----------------=COMPONENTS=------------------

	-- Сортировочная ячейка --

	component comparator is
		generic(
		DATA_WIDTH : integer := DATA_WIDTH
			);    

		port( clk_in   : in  std_logic;
			  reset_in : in std_logic;

			-- входной интерфейс
			  is_input_in   : in std_logic;
			  prev_in		: in std_logic_vector(DATA_WIDTH - 1 downto 0);
			  next_in		: in std_logic_vector(DATA_WIDTH - 1 downto 0);

			  -- выходной интерфейс
			  data_out		: out std_logic_vector(DATA_WIDTH - 1 downto 0)	
			 );
	end component;

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
		report "DATA_WIDTH = " & integer'image(DATA_WIDTH) & 
			   ", MAX_LENGTH = " & integer'image(MAX_LENGTH) & 
			   ", MAX COMPARATOR'S COUNT = " & integer'image(MAX_LENGTH_INTERNAL)
		severity NOTE;

		----=END ASSERTIONS=----


		----=CONTINIOUS ASSIGNMENTS=----

	-- Входной интерфейс --

	data_in <= snk_data;

	snk_ready <= snk_ready_r;

	--------------------------------------

	-- Выходной интерфейс --

	src_sop <= src_sop_r;
	src_eop <= src_eop_r;
	src_valid <= src_valid_r;
	src_data <= src_data_out_r;

	--------------------------------------

	-- Каскадирование сортировочных ячеек --

	prev_next_statements : for i in 0 to MAX_LENGTH_INTERNAL - 2 generate
		prev_w(i+1) <= output_w(i);
		next_w(i) <= output_w(i+1);
	end generate prev_next_statements;

	prev_w(0) <= data_in;
	data_out <= output_w(0);

	next_w(MAX_LENGTH_INTERNAL-1) <= (others => '0');

	--------------------------------------

	-- Служебные флаги для управления памятью --

	stop_write <= we_last and not we;

	start_read_lifo <= start_read and not start_read_last;

	--------------------------------------

	reset_mem <= snk_reset or src_reset;


		----=END CONTINIOUS ASSIGNMENTS=----


		----=INSTANCES=---

	-- Каскад сортировочных ячеек --
	comparator_instances : for i in 0 to MAX_LENGTH_INTERNAL - 1 generate
		inst_comparator : comparator
		
		PORT MAP(
		clk_in => snk_clock,
		reset_in => snk_reset,
		is_input_in => snk_valid,
		prev_in => prev_w(i),
		next_in => next_w(i),
		data_out => output_w(i)
		);
	end generate comparator_instances;

	-- LIFO память --
	lifo_cdc_memory_instance : BRAM_SDP_MACRO
	   generic map (
	      BRAM_SIZE => BRAM_PARAM.BRAM_SIZE,  -- размер 18/36 кБ
	      DEVICE => DEVICE,					  -- целевое устройство

	      WRITE_WIDTH => data_for_mem'length, -- размерность данных чтения/записи
	      READ_WIDTH => data_from_mem'length, -- формат данных: sop & eop & valid & data_out

	      WRITE_MODE => "READ_FIRST", 		  -- при одновременном флаге чтения и записи на выходе данные из памяти
	      
		  DO_REG => 1 						  -- регистровый выход
		  )

	   port map (
	      -- потоки данных
	      DO => data_from_mem, 
	      DI => data_for_mem,      

	      --интерфейс чтения
	      RDADDR => std_logic_vector(rd_address),
	      RDCLK => src_clock,
	      RDEN => rd,     
	      REGCE => '1',  

	      -- сброс
	      RST => reset_mem,     

	      -- интерфейс записи
	      WE => write_enable,        
	      WRADDR => std_logic_vector(we_address), 
	      WRCLK => snk_clock,   
	      WREN => we      
	   );

		----=END INSTANCES=----


		----=PROCESSES ETC.=----

	-- устанавливаем регистр sop отсортированной последовательности	
	sop_reg : process(snk_clock, snk_reset)
	begin
		if snk_reset = '1' then
			sop(0) <= '0';
			sop(1) <= '0';
		elsif rising_edge(snk_clock) then
			sop(0) <= snk_eop;
			sop(1) <= sop(0);
		end if;
	end process sop_reg;

	-- устанавливаем регистр valid отсортированной последовательности	
	valid_reg : process(snk_clock, snk_reset)
	begin
		if snk_reset = '1' then
			valid <= '0';
		elsif rising_edge(snk_clock) then
			if sop(0) = '1' then
				valid <= '1';
			elsif eop = '1' then
				valid <= '0';
			end if;
		end if;
	end process valid_reg;

	-- устанавливаем регистр eop отсортированной последовательности	
	eop_reg : process(snk_clock, snk_reset)
	begin
		if snk_reset = '1' then
			eop <= '0';
		elsif rising_edge(snk_clock) then
			if counter_data_out_r = counter_data_r - 2 and valid = '1' then
				eop <= '1';
			else 
				eop <= '0';
			end if;
		end if;
	end process eop_reg;

	-- расчёт реальной длины последовательности
	counters : process(snk_clock, snk_reset)
	begin
		if snk_reset = '1' then
				counter_data_r <= (others => '0');
				counter_data_out_r <= (others => '0');
		
		elsif rising_edge(snk_clock) then
			
			if snk_valid = '1' then
				counter_data_r <= counter_data_r + 1;
			end if;
			
			if sop(0) = '1' then
				counter_data_out_r <= (others => '0');
			elsif counter_data_out_r <= counter_data_r then
				counter_data_out_r <= counter_data_out_r + 1;
			end if;

		end if;
	end process counters;

	-- управление интерфейсом записи в память
	process(snk_clock, snk_reset)
	begin
		if snk_reset = '1' then
			we  <=  '0';
			we_last <= '0';

			data_for_mem <= (others => '0');

			we_address <= (others => '0');

		elsif rising_edge(snk_clock) then
			we <= valid;
			we_last <= we;

			data_for_mem <= sop(1) & eop & valid & data_out;

			if sop(1) = '1'or we = '1' then
				we_address <= we_address + 1;
			end if;

		end if;
	end process;

	-- устанавливаем флаг ready готовности приёма новых данных
	ready_reg : process(snk_clock, snk_reset)
	begin
		if rising_edge(snk_clock) then
			if snk_sop = '1' then 
				snk_ready_r <= '0';
			elsif (stop_write = '1') then
				snk_ready_r <= '1';
			end if;	
		end if;
	end process ready_reg;

	--------------------------------------------------

	-- выходные регистры
	output_data_reg : process(src_clock, src_reset)
	begin
		if src_reset = '1' then
			src_eop_r <= '0';
			src_sop_r <= '0';
			src_valid_r <= '0';
			src_data_out_r <= (others => '0');
		elsif rising_edge(src_clock) then
			src_eop_r <= data_from_mem(DATA_WIDTH + 2);
			src_sop_r <= data_from_mem(DATA_WIDTH + 1);
			src_valid_r <= data_from_mem(DATA_WIDTH);
			src_data_out_r <= data_from_mem(DATA_WIDTH - 1 downto 0);
		end if;
	end process output_data_reg;

	-- управление интерфейсом чтения
	memory_settings : process(src_clock, src_reset)
	begin
		if src_reset = '1' then
			we_rd(0)  <= '0';
			we_rd(1)  <= '0';
			start_read <= '0';

			start_read_last <= '0';

			rd <= '0';
			rd_address <= (others => '0');

		elsif rising_edge(src_clock) then
			
			we_rd(0)  <= stop_write;
			we_rd(1)  <= we_rd(0);
			start_read <= we_rd(1);

			start_read_last <= start_read;

			if start_read_lifo = '1' then
				rd <= '1';
				rd_address <= we_address - 1;
			elsif rd_address > 0 then
				rd_address <= rd_address - 1;
				rd <= '1';
			else
				rd_address <= (others => '0');
				rd <= '0';
			end if;
		end if;
	end process memory_settings;

		----=END PROCESSES ETC.=----


		----=DEBUG ZONE=----

	-- NO DEBUG ZONE --

		----=END DEBUG ZONE=----

end architecture mixed;
