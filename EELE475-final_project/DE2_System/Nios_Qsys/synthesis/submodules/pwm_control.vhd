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

entity pwm_control is
    Port ( clk            : in  STD_LOGIC;  -- PWM timing is based on the number of clock cycles from clk
           reset          : in  STD_LOGIC;  -- reset 
           enable         : in  STD_LOGIC;  -- enable PWM (1 = pulse, 0 = no pulses)
           control        : in  STD_LOGIC_VECTOR (7 downto 0);  -- control word [-128:+127], signed char, controls pulse width
           pulse_period   : in  STD_LOGIC_VECTOR (23 downto 0); -- number of clock cycles between pulses
           pulse_neutral  : in  STD_LOGIC_VECTOR (23 downto 0); -- pulse width in clock cycles when control word is 0
           pulse_largest  : in  STD_LOGIC_VECTOR (23 downto 0); -- pulse width in clock cycles when control word is +127
           pulse_smallest : in  STD_LOGIC_VECTOR (23 downto 0); -- pulse width in clock cycles when control word is -128
           pwm_signal     : out  STD_LOGIC); -- the PWM signal
end pwm_control;

architecture Behavioral of pwm_control is
			
    type state_type is (state_high, state_low); 
    signal state, next_state : state_type; 

    signal pulse_go_low    : std_logic;
    signal pulse_go_high   : std_logic;
    signal pwm_signal_int  : std_logic;
	 
	 signal pulse_high_count : STD_LOGIC_VECTOR (23 downto 0);
	 signal pulse_low_count  : STD_LOGIC_VECTOR (23 downto 0);
	 signal pulse_width        : STD_LOGIC_VECTOR (23 downto 0);
	 signal pulse_result       : STD_LOGIC_VECTOR (23 downto 0);
	 signal pulse_width_high   : STD_LOGIC_VECTOR (23 downto 0);
	 signal pulse_width_low    : STD_LOGIC_VECTOR (23 downto 0);
	 
	 signal difference_high_side  : STD_LOGIC_VECTOR (23 downto 0);
	 signal difference_low_side   : STD_LOGIC_VECTOR (23 downto 0);
	 signal sign_bit              : STD_LOGIC;
	 signal control_step          : STD_LOGIC_VECTOR (16 downto 0);
	 signal quotient              : STD_LOGIC_VECTOR (23 downto 0);
	 signal ctrl_word             : STD_LOGIC_VECTOR (7 downto 0);
	 signal ctrl_product          : STD_LOGIC_VECTOR (24 downto 0);

	 signal pulse_high_count_reload  : STD_LOGIC;
	 signal pulse_low_count_reload   : STD_LOGIC;
	 signal pulse_high_count_enable  : STD_LOGIC;
	 signal pulse_low_count_enable   : STD_LOGIC;

begin
	---------------------------------------------------------
	-- Compute the pulse width from the control word
	---------------------------------------------------------
	sign_bit <= control(7);   -- get sign bit to determine if this is a positive or negative value
	
	process(clk, sign_bit)
    begin
		if clk'event and clk='1' then
		   if sign_bit = '0' then
			   ctrl_word <= control;  -- positive control value
		   else
			   ctrl_word <= not control + 1; -- negative control value so get absolute value of it, i.e. change sign
		   end if;
		end if;
    end process;

	process(clk, pulse_largest, pulse_neutral)
    begin
		if clk'event and clk='1' then
			difference_high_side <= pulse_largest - pulse_neutral;
		end if;
    end process;
	
	process(clk, pulse_neutral, pulse_smallest)
    begin
		if clk'event and clk='1' then
			difference_low_side  <= pulse_neutral - pulse_smallest;
		end if;
    end process;
	
	process(clk, sign_bit, difference_high_side, difference_low_side)
    begin
		if clk'event and clk='1' then
		   if sign_bit = '0' then
			   control_step <= difference_high_side(23 downto 7);
		   else
			   control_step <= difference_low_side(23 downto 7);
		   end if;
		end if;
	end process;
		   	
	process(clk, ctrl_word, control_step)
    begin
		if clk'event and clk='1' then
	        ctrl_product <= ctrl_word * control_step;
		end if;
	end process;

	process(clk, sign_bit)
    begin
		if clk'event and clk='1' then
		   if sign_bit = '0' then
			  pulse_width <= pulse_neutral + ctrl_product(23 downto 0);
		   else
			  pulse_width <= pulse_neutral - ctrl_product(23 downto 0);
		   end if;
		end if;
	end process;
	
	process(clk, pulse_width, pulse_smallest, pulse_largest)  -- make sure there are no out of line values
    begin
		if clk'event and clk='1' then
		   if pulse_width < pulse_smallest then
			  pulse_width_high <= pulse_smallest;
		   elsif pulse_width > pulse_largest then
			  pulse_width_high <= pulse_largest;
		   else 
			  pulse_width_high <= pulse_width;
		   end if;
		end if;
	end process;
   
	process(clk)
	begin
		if clk'event and clk ='1' then
	        pulse_width_low <= pulse_period - pulse_width_high;
	   end if;
	end process;
				 	
	---------------------------------------------------------
	-- PWM pulse High counter
	---------------------------------------------------------
	process (clk, reset, pulse_high_count_reload, pulse_high_count_enable)
	begin 
		if clk'event and clk='1' then
		    if pulse_high_count_reload = '1' then
			     pulse_high_count <= (others => '0');
			 elsif pulse_high_count_enable = '1' then     
			     pulse_high_count <= pulse_high_count + 1;
		     end if;
		end if;
	end process;
	
	---------------------------------------------------------
	-- PWM pulse High comparator
	---------------------------------------------------------
	process(clk)
	begin
		if clk'event and clk ='1' then
			if pulse_high_count >= pulse_width_high then
			    pulse_go_low <= '1';
			else
			    pulse_go_low <= '0';
			end if;
		end if;
	end process;

	---------------------------------------------------------
	-- PWM pulse Low counter
	---------------------------------------------------------
	process (clk, reset, pulse_low_count_reload, pulse_low_count_enable)
	begin 
		if clk'event and clk='1' then
		    if pulse_low_count_reload = '1' then
			     pulse_low_count <= (others => '0');
			 elsif pulse_low_count_enable = '1' then     
			     pulse_low_count <= pulse_low_count + 1;
		     end if;
		end if;
	end process;
	
	---------------------------------------------------------
	-- PWM pulse Low comparator
	---------------------------------------------------------
	process(clk)
	begin
		if clk'event and clk ='1' then
			if pulse_low_count >= pulse_width_low then
			    pulse_go_high <= '1';
			else
			    pulse_go_high <= '0';
			end if;
		end if;
	end process;
		
	---------------------------------------------------------
	-- PWM state machine: state transition
	---------------------------------------------------------
	process (clk)
	begin
		if clk'event and clk = '1' then
			state <= next_state;
		end if;
	end process;

	---------------------------------------------------------
	-- PWM state machine: Determine next state
	---------------------------------------------------------
	decode_next_state: process (state, pulse_go_high, pulse_go_low)
	begin
		next_state <= state;  --default is to stay in current state
		case (state) is
			when state_high =>
				if pulse_go_low = '1' then
					next_state <= state_low;
				end if;
			when state_low =>
				if pulse_go_high = '1' then
					next_state <= state_high;
				end if;
			when others =>
				next_state <= state_low;
		end case;
	end process;

	---------------------------------------------------------
	-- PWM state machine: Determine output based on state
	---------------------------------------------------------
	decode_output: process (state)
	begin
	   pulse_high_count_enable  <= '0';  -- default value 
	   pulse_low_count_enable   <= '0';  -- default value 
	   pulse_high_count_reload  <= '0';  -- default value 
	   pulse_low_count_reload   <= '0';  -- default value 
	   pwm_signal_int           <= '0';
	   case (state) is
		  when state_low =>
	          pulse_high_count_reload    <= '1';  
			  pulse_low_count_enable     <= '1';
		  when state_high =>
			  pwm_signal_int             <= '1';
	          pulse_low_count_reload     <= '1';  
			  pulse_high_count_enable    <= '1'; 
		  when others =>
	   end case;
	end process;
	
	---------------------------------------------------------
	-- PWM enable
	---------------------------------------------------------
	process (enable)
	begin
		if enable = '1' then
			pwm_signal <= pwm_signal_int;
		else
			pwm_signal <= '0';
		end if;
	end process;
	
	
	

end Behavioral;

