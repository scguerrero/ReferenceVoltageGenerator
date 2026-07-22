-- Finite state machine for I2C protocol
-- Sasha C. Guerrero
-- 2026 July 1

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY fsm_i2c_writing IS
	PORT(
		-- FSM inputs
		clk : in std_logic; -- fpga clock
		str : in std_logic; -- start
		rst : in std_logic; -- reset registers
		
		-- Mode 'inout' for SDA pins caused a compilation error for i2c_protocol because
		-- "multiple drivers to the SDA pin." One of those drivers being the tristate buffer
		
		Done_SCL_Ctr : in std_logic; -- count SCL pulses
		Done_Bit_Ctr : in std_logic; -- count bits received
		
		-- FSM outputs
		L : out std_logic; -- load
		SH : out std_logic; -- shift
		SCL : out std_logic; -- serial clock line
		EN_Buffer : out std_logic;
		EN_SCL_Ctr : out std_logic;
		Rst_SCL_Ctr : out std_logic;
		EN_Bit_Ctr : out std_logic;
		Rst_Bit_Ctr : out std_logic;
		Sel : out std_logic;-- "Select" is a reserved keyword
		CE : out std_logic; -- clock enable
		Done : out std_logic;
		rdy : out std_logic
	);
END ENTITY;

ARCHITECTURE behave OF fsm_i2c_writing IS

-- Internal connections
SIGNAL currentState, nextState : std_logic_vector(4 downto 0);

BEGIN

-- -------------------------------------------------
-- Next state logic
-- -------------------------------------------------
process(clk, str, rst, Done_SCL_Ctr, Done_Bit_Ctr, currentState)
begin
	
	CASE currentState IS
	
		WHEN "00000" => -- S0: Wait for Start signal
			EN_Buffer   <= '0';
			EN_SCL_Ctr  <= '0';
			Rst_SCL_Ctr <= '0';
			EN_Bit_ctr  <= '0';
			Rst_Bit_Ctr <= '0';
			Sel         <= '0';
			CE          <= '0';
			L           <= '0';
			SH          <= '0';
			
			SCL         <= '1'; -- SCL high until pulled down for I2C start signal
			done 		<= '0';
			rdy			<= '1';
			if str = '1' then -- If Start signal received
				nextState <= "00001";
			else
				nextState <= currentState;
			end if;
			
		WHEN "00001" => -- S1: Load data, pull down SDA, reset counters
			EN_Buffer   <= '1'; -- enable buffer so we can write to SDA
			EN_SCL_Ctr  <= '0';
			Rst_SCL_Ctr <= '1'; -- reset counter
			EN_Bit_ctr  <= '0';
			Rst_Bit_Ctr <= '1'; -- reset counter
			Sel         <= '0'; -- select D0 ('0') to pull down SDA using mux0
			CE          <= '0';
			L           <= '1'; -- load data
			SH          <= '0';
			
			SCL         <= '1'; -- trying to fix error: SCL unknown in simulation
			nextState   <= "00010";
			done 		<= '0';
			rdy			<= '0';
			
		WHEN "00010" => -- S2: Wait
			EN_Buffer   <= '0';
			EN_SCL_Ctr  <= '1';
			Rst_SCL_Ctr <= '0';
			EN_Bit_ctr  <= '0';
			Rst_Bit_Ctr <= '0';
			Sel         <= '0';
			CE          <= '0';
			L           <= '0';
			SH          <= '0';
			
			SCL         <= '1'; -- trying to fix error: SCL unknown in simulation
			done 		<= '0';
			rdy			<= '0';
			
			if Done_SCL_Ctr = '1' then -- Wait for one SCL pulse
				nextState <= "00011"; -- S3
			else
				nextState <= currentState;
			end if;
			
		WHEN "00011" => -- S3: Reset counters, pull down SCL
			EN_Buffer   <= '0';
			EN_SCL_Ctr  <= '0';
			Rst_SCL_Ctr <= '1'; -- reset counter
			EN_Bit_ctr  <= '0';
			Rst_Bit_Ctr <= '1'; -- reset counter
			Sel         <= '0';
			CE          <= '0';
			L           <= '0';
			SH          <= '0';
			
			SCL         <= '0'; -- pull down SCL
			done 		<= '0';
			rdy			<= '0';
			
			nextState   <= "00100"; -- Go directly to S4
			
			
		WHEN "00100" => -- S4: Wait
			EN_Buffer   <= '0';
			EN_SCL_Ctr  <= '1';
			Rst_SCL_Ctr <= '0';
			EN_Bit_ctr  <= '0';
			Rst_Bit_Ctr <= '0';
			Sel         <= '0';
			CE          <= '0';
			L           <= '0';
			SH          <= '0';
			
			SCL         <= '0'; -- trying to fix error: SCL unknown in simulation
			done 		<= '0';
			rdy			<= '0';
			
			if Done_SCL_Ctr = '1' then -- Wait for one SCL pulse
				nextState <= "00101"; -- S5
			else
				nextState <= currentState;
			end if;
		
		WHEN "00101" => -- S5: Enable Mux0
			EN_Buffer   <= '1'; -- Enable buffer to read Mux0 output
			EN_SCL_Ctr  <= '0';
			Rst_SCL_Ctr <= '1';
			EN_Bit_ctr  <= '0';
			Rst_Bit_Ctr <= '1';
			Sel         <= '1'; -- Enable Mux0
			CE          <= '0';
			L           <= '0';
			SH          <= '0';
			
			SCL         <= '0'; -- trying to fix error: SCL unknown in simulation
			done 		<= '0';
			rdy			<= '0';
			
			nextState <= "00110"; -- Go directly to S6
		
		WHEN "00110" => -- S6:  Wait
			EN_Buffer   <= '1';
			EN_SCL_Ctr  <= '1';
			Rst_SCL_Ctr <= '0';
			EN_Bit_ctr  <= '0';
			Rst_Bit_Ctr <= '0';
			Sel         <= '1';
			CE          <= '0';
			L           <= '0';
			SH          <= '0';
			
			SCL         <= '0'; -- trying to fix error: SCL unknown in simulation
			done 		<= '0';
			rdy			<= '0';
			
			if Done_SCL_Ctr = '1' then -- Wait for one SCL pulse
				nextState <= "00111"; -- S7
			else
				nextState <= currentState;
			end if;
		
		WHEN "00111" => -- S7: Pull up SCL, increment bit counter, reset SCL counter
			EN_Buffer   <= '1';
			EN_SCL_Ctr  <= '0';
			Rst_SCL_Ctr <= '1'; -- reset SCL counter
			EN_Bit_ctr  <= '1'; -- increment bit counter
			Rst_Bit_Ctr <= '0';
			Sel         <= '1';
			CE          <= '0';
			L           <= '0';
			SH          <= '0';
			
			SCL         <= '1'; -- pull up SCL 
			done 		<= '0';
			rdy			<= '0';
			
			nextState   <= "01000"; -- Go directly to S8
		
		WHEN "01000" => -- S8: Wait
			EN_Buffer   <= '1';
			EN_SCL_Ctr  <= '1';
			Rst_SCL_Ctr <= '0';
			EN_Bit_ctr  <= '0';
			Rst_Bit_Ctr <= '0';
			Sel         <= '1';
			CE          <= '0';
			L           <= '0';
			SH          <= '0';
			
			SCL         <= '1'; -- trying to fix error: SCL unknown in simulation
			done 		<= '0';
			rdy			<= '0';
			
			if Done_SCL_Ctr = '1' then -- Wait for one SCL pulse
				nextState <= "01001"; -- S9
			else
				nextState <= currentState;
			end if;
			
		WHEN "01001" => -- S9: Check if we're done counting bits
			EN_Buffer   <= '1';
			EN_SCL_Ctr  <= '0';
			Rst_SCL_Ctr <= '0';
			EN_Bit_ctr  <= '0';
			Rst_Bit_Ctr <= '0';
			Sel         <= '0';
			CE          <= '0';
			L           <= '0';
			SH          <= '0';
			
			SCL         <= '1'; -- trying to fix error: SCL unknown in simulation
			done 		<= '0';
			rdy			<= '0';
			
			if Done_Bit_Ctr = '1' then -- All 8 bits received
				nextState <= "01011"; -- S11 to wait for ACK
			else
				nextState <= "01010"; -- S10 to keep reading bits
			end if;
			
		WHEN "01010" => -- S10: Shift data, pull down SCL
			EN_Buffer   <= '1';
			EN_SCL_Ctr  <= '0';
			Rst_SCL_Ctr <= '1';
			EN_Bit_ctr  <= '0';
			Rst_Bit_Ctr <= '0';
			Sel         <= '1';
			CE          <= '0';
			L           <= '0';
			SH          <= '1'; -- shift data 1 bit
			
			SCL         <= '0'; -- pull down SCL
			done 		<= '0';
			rdy			<= '0';
			
			nextState   <= "00110"; -- Go directly to S6	
			
		WHEN "01011" => -- S11: pull down SCL, disable buffer
			EN_Buffer   <= '0'; -- disable buffer
			EN_SCL_Ctr  <= '0';
			Rst_SCL_Ctr <= '1';
			EN_Bit_ctr  <= '0';
			Rst_Bit_Ctr <= '0';
			Sel         <= '0';
			CE          <= '0';
			L           <= '0';
			SH          <= '0';
			
			SCL         <= '0'; -- pull down SCL
			done 		<= '0';
			rdy			<= '0';
			
			nextState <= "01100"; -- Go directly to S12
			
		WHEN "01100" => -- S12: Wait
			EN_Buffer   <= '0';
			EN_SCL_Ctr  <= '1';
			Rst_SCL_Ctr <= '0';
			EN_Bit_ctr  <= '0';
			Rst_Bit_Ctr <= '0';
			Sel         <= '0';
			CE          <= '0';
			L           <= '0';
			SH          <= '0';
			
			SCL         <= '0'; -- trying to fix error: SCL unknown in simulation
			done 		<= '0';
			rdy			<= '0';
			
			if Done_SCL_Ctr = '1' then -- Wait for one SCL pulse
				nextState <= "01101"; -- S13
			else
				nextState <= currentState;
			end if;
		
		WHEN "01101" => -- S13: Save ACK to flipflop
			EN_Buffer   <= '0';
			EN_SCL_Ctr  <= '0';
			Rst_SCL_Ctr <= '1';
			EN_Bit_ctr  <= '0';
			Rst_Bit_Ctr <= '0';
			Sel         <= '1';
			CE          <= '1';
			L           <= '0';
			SH          <= '0';
	
			SCL         <= '1'; -- trying to fix error: SCL unknown in simulation
			done 		<= '0';
			rdy			<= '0';
			
			nextState   <= "01110"; -- Go directly to S14
		
		WHEN "01110" => -- S14: Wait
			EN_Buffer   <= '0';
			EN_SCL_Ctr  <= '1';
			Rst_SCL_Ctr <= '0';
			EN_Bit_ctr  <= '0';
			Rst_Bit_Ctr <= '0';
			Sel         <= '0';
			CE          <= '0';
			L           <= '0';
			SH          <= '0';
			
			SCL         <= '1'; -- trying to fix error: SCL unknown in simulation
			done 		<= '0';
			rdy			<= '0';
			
			if Done_SCL_Ctr = '1' then -- Wait for one SCL pulse
				nextState <= "01111"; -- S15
			else
				nextState <= currentState;
			end if;
			
		WHEN "01111" => -- S15: Transition
			EN_Buffer   <= '0';
			EN_SCL_Ctr  <= '0';
			Rst_SCL_Ctr <= '1';
			EN_Bit_ctr  <= '0';
			Rst_Bit_Ctr <= '0';
			Sel         <= '0';
			CE          <= '0';
			L           <= '0';
			SH          <= '0';
			
			SCL         <= '0'; -- trying to fix error: SCL unknown in simulation
			done 		<= '0';
			rdy			<= '0';
			
			nextState <= "10000"; -- Go directly to S16
			
		WHEN "10000" => -- S16: Wait
			EN_Buffer   <= '0';
			EN_SCL_Ctr  <= '1';
			Rst_SCL_Ctr <= '0';
			EN_Bit_ctr  <= '0';
			Rst_Bit_Ctr <= '0';
			Sel         <= '0';
			CE          <= '0';
			L           <= '0';
			SH          <= '0';
			
			SCL         <= '0'; -- trying to fix error: SCL unknown in simulation
			done 		<= '0';
			rdy			<= '0';
			
			if Done_SCL_Ctr = '1' then -- Wait for one SCL pulse
				nextState <= "10001"; -- S17
			else
				nextState <= currentState;
			end if;
		
		WHEN "10001" => -- S17: Pull up SCL
			EN_Buffer   <= '0';
			EN_SCL_Ctr  <= '0';
			Rst_SCL_Ctr <= '1';
			EN_Bit_ctr  <= '0';
			Rst_Bit_Ctr <= '0';
			Sel         <= '0';
			CE          <= '0';
			L           <= '0';
			SH          <= '0';
			
			SCL         <= '1';
			done 		<= '0';
			rdy			<= '0';
			
			nextState   <= "10010"; -- Go directly to S18
		
		WHEN "10010" => -- S18: reset counters
			EN_Buffer   <= '0';
			EN_SCL_Ctr  <= '0';
			Rst_SCL_Ctr <= '1'; -- reset counter
			EN_Bit_ctr  <= '0';
			Rst_Bit_Ctr <= '1'; -- reset counter
			Sel         <= '0';
			CE          <= '0';
			L           <= '0';
			SH          <= '0';
			
			SCL         <= '1'; -- trying to fix error: SCL unknown in simulation
			done 		<= '1';
			rdy			<= '0';
			
			nextState <= "00000";
			
			
		WHEN OTHERS => -- fallback to S0
			EN_Buffer   <= '0';
			EN_SCL_Ctr  <= '0';
			Rst_SCL_Ctr <= '0';
			EN_Bit_ctr  <= '0';
			Rst_Bit_Ctr <= '0';
			Sel         <= '0';
			CE          <= '0';
			L           <= '0';
			SH          <= '0';
			done 		<= '0';
			rdy			<= '0';
			nextState   <= "00000";
		END CASE;
end process;

-- -------------------------------------------------
-- Current state flipflops
-- -------------------------------------------------
process(clk, nextState, rst)
begin
	if rst = '1' then
		currentState <= "00000";
	elsif rising_edge(clk) then
		currentState <= nextState;
	end if;
end process;

END ARCHITECTURE;