----------------------------------------------------------------------------------
-- MOD.DATE: 16022019
--------------------------------------------------
-- Project :		
-- Author :			Alina Galichina
-- Creation date : 	2018-11-23
-- File : 			complex_multiplier.vhd
-- TestBench : 		complex_multiplier_tb.v
-- Software : 		ISE 14.7 / Vivado 2018
-- Primitives : 		No
-- Cores : 			No
-- Submodules : 		No
--------------------------------------------------
-- Description : 	Module for multiply two complex numers
-- 					Used formula: pr_out = k1 - k2, pi_out = k1 + k3
--									k1 = ar_in * (br_in + bi_in)
--									k2 = bi_in * (ar_in + ai_in)
--									k3 = br_in * (ai_in - ar_in)
-- 					Full pipelined

----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity complex_multiplier is
	generic(
		width_A        : natural := 13; 
		width_B        : natural := 13; 
		width_PR         : natural := 15; 
		show_pr_width : boolean := true; 
		useDSP48       : string  := "AUTO"
	);
	port(
		clk : in  STD_LOGIC;
		reset_in : in  STD_LOGIC;           
		ce_in  : in  STD_LOGIC;          
		ar_in  : in  STD_LOGIC_VECTOR(width_A - 1 downto 0); 
		ai_in  : in  STD_LOGIC_VECTOR(width_A - 1 downto 0); 
		br_in  : in  STD_LOGIC_VECTOR(width_B - 1 downto 0); 
		bi_in  : in  STD_LOGIC_VECTOR(width_B - 1 downto 0); 
		pr_out  : out STD_LOGIC_VECTOR(width_PR - 1 downto 0); 
		pi_out  : out STD_LOGIC_VECTOR(width_PR - 1 downto 0) 
	);
	attribute USE_DSP48 : string;
	attribute USE_DSP48 of complex_multiplier : entity is useDSP48;
end complex_multiplier;

architecture Behavioral of complex_multiplier is
	------------------=FUNCTIONS=------------------
	function MAX(a : integer; b : integer) return integer is
	begin
		if a > b then
			return a;
		else
			return b;
		end if;
	end function;
	------------------=END FUNCTIONS=------------------
	
	------------------=CONSTANTS,SIGNALS,VARIABLES=------------------

	signal ar_r, ar_rr                            : signed(width_A - 1 downto 0)                     := (others => '0');
	signal bi_r, bi_rr, br_r, br_rr               : signed(width_B - 1 downto 0)                     := (others => '0');
	signal br_p_bi, br_p_bi_r                     : signed(width_B downto 0)                         := (others => '0');
	signal ar_p_ai, ar_p_ai_r, ai_m_ar, ai_m_ar_r : signed(width_A downto 0)                         := (others => '0');
	signal arm, arm_r                             : signed(width_A + br_p_bi'length - 1 downto 0)    := (others => '0');
	signal bim, bim_r, brm, brm_r                 : signed(width_B + ar_p_ai'length - 1 downto 0)    := (others => '0');
	signal prInt, piInt                           : signed(MAX(arm'length, bim'length) - 1 downto 0) := (others => '0');
	
	------------------=END CONSTANTS,SIGNALS,VARIABLES=------------------

begin
----=ASSERTIONS=----

	assert not show_pr_width report "Calculated output width is " & integer'image(width_A + width_B) severity WARNING;
	
----=END ASSERTIONS=----

	Calculate: process(ce_in, clk)
	begin
		if ce_in = '1' then
			if rising_edge(clk) then
				if reset_in = '1' then
					br_p_bi   <= (others => '0');
					ar_p_ai   <= (others => '0');
					ai_m_ar   <= (others => '0');
					arm       <= (others => '0');
					bim       <= (others => '0');
					brm       <= (others => '0');
					prInt     <= (others => '0');
					piInt     <= (others => '0');
					ar_r      <= (others => '0');
					bi_r      <= (others => '0');
					br_r      <= (others => '0');
					ar_rr     <= (others => '0');
					bi_rr     <= (others => '0');
					br_rr     <= (others => '0');
					br_p_bi_r <= (others => '0');
					ar_p_ai_r <= (others => '0');
					ai_m_ar_r <= (others => '0');
				else
					br_p_bi   <= resize(signed(br_in), br_p_bi'length) + resize(signed(bi_in), br_p_bi'length);
					ar_p_ai   <= resize(signed(ar_in), ar_p_ai'length) + resize(signed(ai_in), ar_p_ai'length);
					ai_m_ar   <= resize(signed(ai_in), ai_m_ar'length) - resize(signed(ar_in), ai_m_ar'length);
					arm       <= signed(ar_rr) * signed(br_p_bi_r);
					bim       <= signed(bi_rr) * signed(ar_p_ai_r);
					brm       <= signed(br_rr) * signed(ai_m_ar_r);
					arm_r     <= arm;
					bim_r     <= bim;
					brm_r     <= brm;
					prInt     <= signed(arm_r) - signed(bim_r);
					piInt     <= signed(arm_r) + signed(brm_r);
					ar_r      <= signed(ar_in);
					bi_r      <= signed(bi_in);
					br_r      <= signed(br_in);
					ar_rr     <= ar_r;
					bi_rr     <= bi_r;
					br_rr     <= br_r;
					br_p_bi_r <= br_p_bi;
					ar_p_ai_r <= ar_p_ai;
					ai_m_ar_r <= ai_m_ar;
				end if;
			end if;
		end if;
	end process;

	OutputRegister: process(clk)
		begin
			if rising_edge(clk) then
				pr_out <= std_logic_vector(resize(prInt(prInt'left - 1 downto 0), width_PR));
				pi_out <= std_logic_vector(resize(piInt(prInt'left - 1 downto 0), width_PR));
			end if;
		end process;

end Behavioral;

