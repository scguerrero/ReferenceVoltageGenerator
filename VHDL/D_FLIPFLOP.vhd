-- D flip-flop
-- hdricoaniles
-- 2023 24 01


LIBRARY IEEE;
use ieee.std_logic_1164.all;


ENTITY D_FLIPFLOP IS
	port(
		rst 		: in std_logic;
		clk 		: in std_logic;
		D	 		: in std_logic;
		Q 		: out std_logic
		
	);
END ENTITY;

ARCHITECTURE behave OF D_FLIPFLOP IS

BEGIN

	--register
	process(rst,clk)
	begin
		if (rst = '1') then
			Q <= '0';
		elsif (rising_edge(clk)) then
			Q <= D;
		end if;
	end process;

END ARCHITECTURE;