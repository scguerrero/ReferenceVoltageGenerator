-- Generic Counter
-- hdricoaniles
-- 2023 06 20
LIBRARY IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
ENTITY counter_w_EN IS
	generic (n :integer :=10); -- n= the number of bits
	port(
		rst 		: in std_logic;
		clk 		: in std_logic;
		EN	 		: in std_logic;
		cnt 		: out std_logic_vector(n-1 downto 0)
		
	);
END ENTITY;
ARCHITECTURE behave OF counter_w_EN IS
signal current_count, next_count : std_logic_vector(n-1 downto 0);
BEGIN
	cnt <= current_count;
	--adder
	process(EN,current_count)
	begin 
		if (EN='1') then
			next_count <= current_count +1;	
		else
			next_count <= current_count;
		end if;
	end process;
	--register
	process(rst,clk)
	begin
		if (rst = '1') then
			current_count <= (others=>'0');
		elsif (rising_edge(clk)) then
			current_count <= next_count;
		end if;
	end process;
END ARCHITECTURE;
