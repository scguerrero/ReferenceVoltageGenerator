-- RIGTH sHIFT REGISTER
-- hdricoaniles
-- 2023 24 01


LIBRARY IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY R_SHIFT_REG IS
	generic (n :integer :=8);
	port(
		rst 		: in std_logic;
		clk 		: in std_logic;
		SH			: in std_logic;
		L			: in std_logic;
		SI	 		: in std_logic;
		D	: in std_logic_vector(n-1 downto 0);
		Q	 		: out std_logic_vector(n-1 downto 0)
		
	);
END ENTITY;

ARCHITECTURE behave OF R_SHIFT_REG IS
signal current_Q, next_Q : std_logic_vector(n-1 downto 0);
BEGIN	
	Q <= current_Q;
	--adder
	process(SH, L, SI,current_Q,D)
	begin 
		if (SH = '1') then
			next_Q <= SI & current_Q(n-1 downto 1);
			
		elsif (L='1') then
			next_Q <= D;
			
		else
			next_Q <= current_Q;
			
		end if;
	end process;

	--register
	process(rst,clk)
	begin
		if (rst = '1') then
			current_Q <= (others=>'0');
		elsif (rising_edge(clk)) then
			current_Q <= next_Q;
		end if;
	end process;

END ARCHITECTURE;