----------------------------------------------------------------------------------
-- Company:          Montana State University
-- Author/Engineer:	 Ross Snider 
-- 
-- Create Date:    14:17:04 10/06/2009 
-- Design Name: 
-- Module Name:    pwm - Behavioral 
-- Project Name: 
-- Target Devices: DE2 board
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity pwm_avalon is
	port (
		clk 			    		 : in std_logic;
		reset_n 		    		 : in std_logic;
		avs_s1_write 		    : in std_logic;
		avs_s1_read 		    : in std_logic;
		avs_s1_address 	    : in std_logic_vector(7 downto 0);
		avs_s1_writedata 	    : in std_logic_vector(31 downto 0);
		avs_s1_readdata 	    : out std_logic_vector(31 downto 0);
		pwm_signal 			    : out std_logic
	);
end pwm_avalon;

architecture behavior of pwm_avalon is

	component pwm_control 
		 Port ( clk            : in  STD_LOGIC;  -- PWM timing is based on the number of clock cycles from clk
				  reset          : in  STD_LOGIC;  -- reset 
				  enable         : in  STD_LOGIC;  -- enable PWM (1 = pulse, 0 = no pulses)
				  control        : in  STD_LOGIC_VECTOR (7 downto 0);  -- control word [-128:+127], signed char, controls pulse width
				  pulse_period   : in  STD_LOGIC_VECTOR (23 downto 0); -- number of clock cycles between pulses
				  pulse_neutral  : in  STD_LOGIC_VECTOR (23 downto 0); -- pulse width in clock cycles when control word is 0
				  pulse_largest  : in  STD_LOGIC_VECTOR (23 downto 0); -- pulse width in clock cycles when control word is +127
				  pulse_smallest : in  STD_LOGIC_VECTOR (23 downto 0); -- pulse width in clock cycles when control word is -128
				  pwm_signal     : out  STD_LOGIC); -- the PWM signal
	end component pwm_control;

	signal wre  : std_logic;
	signal re   : std_logic;
	signal addr : std_logic_vector(7 downto 0);
	
	
	signal control        : STD_LOGIC_VECTOR (7 downto 0);  -- control word [-100:+100], signed int, controls pulse width
	signal pulse_period   : STD_LOGIC_VECTOR (23 downto 0); -- number of clock cycles (100 MHz) between pulses
	signal pulse_neutral  : STD_LOGIC_VECTOR (23 downto 0); -- number of clock cycles when control word is 0
	signal pulse_largest  : STD_LOGIC_VECTOR (23 downto 0); -- number of clock cycles when control word is +100
	signal pulse_smallest : STD_LOGIC_VECTOR (23 downto 0); -- number of clock cycles when control word is -100
	signal pwm_enable     : STD_LOGIC;

begin
	wre  <= avs_s1_write;
	re   <= avs_s1_read;
	addr <= avs_s1_address;
	
	
	
	process (clk)
		variable readdata : std_logic_vector(31 downto 0);
	begin
		if clk'event and clk='0' then
		
			readdata(31 downto 0) := x"00000000";
		
			CASE addr IS
			
			------------------------
			-- Block 1 (32 bytes) --
			------------------------
			
				-- Latch control word (address 0)
				WHEN x"00" =>
					if wre='1' and re='0' then
						control <= avs_s1_writedata(7 downto 0);
					elsif wre='0' and re='1' then
						readdata(7 downto 0) := control;
						readdata(31 downto 8) := (others => readdata(7));
					end if;
					
				-- Latch pulse_period (address 1)
				WHEN x"01" =>
					if wre='1' and re='0' then
						pulse_period <= avs_s1_writedata(23 downto 0);
					elsif wre='0' and re='1' then
						readdata(23 downto 0) := pulse_period;
					end if;
					
				-- Latch pulse_neutral (address 2)
				WHEN x"02" =>
					if wre='1' and re='0' then
						pulse_neutral <= avs_s1_writedata(23 downto 0);
					elsif wre='0' and re='1' then
						readdata(23 downto 0) := pulse_neutral;
					end if;
					
				-- Latch pulse_largest (address 3)
				WHEN x"03" =>
					if wre='1' and re='0' then
						pulse_largest <= avs_s1_writedata(23 downto 0);
					elsif wre='0' and re='1' then
						readdata(23 downto 0) := pulse_largest;		
					end if;
					
				-- Latch pulse_smallest (address 4)
				WHEN x"04" =>
					if wre='1' and re='0' then
						pulse_smallest <= avs_s1_writedata(23 downto 0);
					elsif wre='0' and re='1' then
						readdata(23 downto 0) := pulse_smallest;		
					end if;
					
				-- Latch PWM enable (address 5)
				WHEN x"05" =>
					if wre='1' and re='0' then
						pwm_enable <= avs_s1_writedata(0);
					elsif wre='0' and re='1' then
						readdata(0) := pwm_enable;	
					end if;
					
					
			
			------------------------
			-- Block 2 (32 bytes) --
			------------------------
			
				-- Latch control word (address 0)
				WHEN x"20" =>
					if wre='0' and re='1' then
						readdata(7 downto 0) := control;
						readdata(31 downto 8) := (others => readdata(7));
					end if;
					
				-- Latch pulse_period (address 1)
				WHEN x"21" =>
					if wre='0' and re='1' then
						readdata(23 downto 0) := pulse_period;
					end if;
					
				-- Latch pulse_neutral (address 2)
				WHEN x"22" =>
					if wre='0' and re='1' then
						readdata(23 downto 0) := pulse_neutral;
					end if;
					
				-- Latch pulse_largest (address 3)
				WHEN x"23" =>
					if wre='0' and re='1' then
						readdata(23 downto 0) := pulse_largest;		
					end if;
					
				-- Latch pulse_smallest (address 4)
				WHEN x"24" =>
					if wre='0' and re='1' then
						readdata(23 downto 0) := pulse_smallest;		
					end if;
					
				-- Latch PWM enable (address 5)
				WHEN x"25" =>
					if wre='0' and re='1' then
						readdata(0) := pwm_enable;	
					end if;
					
				WHEN OTHERS =>  readdata := x"00000000";
				
			end CASE;
			
			-- update output
			avs_s1_readdata <= readdata;
			
		end IF;
	end process;

	---------------------------------------------------
	-- instantiate pwm controller block
	---------------------------------------------------
	pwmc1 : pwm_control Port Map ( 
			   clk            => clk,
			   reset          => not reset_n,
			   enable         => pwm_enable,
			   control        => control,
			   pulse_period   => pulse_period,
			   pulse_neutral  => pulse_neutral,
			   pulse_largest  => pulse_largest,
			   pulse_smallest => pulse_smallest,
			   pwm_signal     => pwm_signal
	);

end behavior;



