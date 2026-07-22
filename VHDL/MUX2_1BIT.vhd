-- Mux2_1bit
-- hdricoaniles
-- 2023 24 01
-- 4 1bit inputs mux with 


LIBRARY IEEE;
use ieee.std_logic_1164.all;


ENTITY MUX2_1BIT IS
	
	port(
		sel 					: in std_logic;
		D0,D1	 		: in std_logic;
		Q	 					: out std_logic
		
	);
END ENTITY;

ARCHITECTURE behave OF MUX2_1BIT IS
BEGIN

	process(seL, D0,D1)
	begin 
		CASE sel IS
			WHEN '0' => Q <=D0;
			WHEN '1' => Q <=D1;
			WHEN OTHERS => Q <= D0;
		END CASE;
	end process;
END ARCHITECTURE;