-- Limit logic
-- hdricoaniles
-- 2023-04-11

Library ieee;
use ieee.std_logic_1164.all;

ENTITY LimitLogic IS
	GENERIC(n : integer := 8); -- number of bits
	PORT(
		A : in std_logic_vector(n-1 downto 0);
		B : in std_logic_vector(n-1 downto 0);
		Zout: OUT std_logic
		);
END ENTITY;

ARCHITECTURE behave OF LimitLogic IS
BEGIN

Process(A,B)
Begin
	If A = B then
		Zout <= '1';
	else
		Zout <= '0';
	end if;
end process;

END ARCHITECTURE;