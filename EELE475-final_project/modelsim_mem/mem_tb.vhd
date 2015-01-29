library IEEE;
use IEEE.std_logic_1164.all; 

entity mem_TB is
end entity;

architecture mem_TB_arch of mem_TB is

	constant t_clk_per : time := 20 ns;
	
	component mem IS
 PORT(
		  clk 			    : in std_logic;
		  reset_n 		    : in std_logic;
		  avs_s1_read		 : in std_logic;
		  avs_s1_write 	 : in std_logic;
		  avs_s1_address 	 : in std_logic_vector(4 downto 0);
		  avs_s1_readdata	 : out std_logic_vector(7 downto 0);
		  avs_s1_writedata : in std_logic_vector(7 downto 0);
		  led_signal 			    : out std_logic_vector(7 downto 0)
        );
END component;

signal clock_TB 		: std_logic;
signal reset_TB 		: std_logic;
signal avs_s1_read_TB 		: std_logic;
signal avs_s1_write_TB 		: std_logic;
signal avs_s1_address_TB 		: std_logic_vector(4 downto 0);
signal avs_s1_readdata_TB 	: std_logic_vector (7 downto 0);
signal avs_s1_writedata_TB : std_logic_vector (7 downto 0);
signal led_signal_TB 	: std_logic_vector( 7 downto 0);

begin
	DUT1: mem
		port map	(
		 clk 			    => clock_TB,
		  reset_n 		    => reset_TB,
		  avs_s1_read		 => avs_s1_read_TB,
		  avs_s1_write 	 => avs_s1_write_TB,
		  avs_s1_address 	 => avs_s1_address_TB,
		  avs_s1_readdata	 => avs_s1_readdata_TB,
		  avs_s1_writedata => avs_s1_writedata_TB,
		  led_signal 			=> led_signal_TB
);		  

-----------------------------------------------
      HEADER : process
        begin
            report "CRC System Test Bench Initiating..." severity NOTE;
            wait;
        end process;
-----------------------------------------------
      CLOCK_STIM : process
       begin
          clock_TB <= '0'; wait for 0.5*t_clk_per; 
          clock_TB <= '1'; wait for 0.5*t_clk_per; 
       end process;
-----------------------------------------------      
--      RESET_STIM : process
--       begin
--          reset_TB <= '0'; wait for 0.25*t_clk_per; 
--          reset_TB <= '1'; wait; 
--       end process;
-----------------------------------------------     

      PORT_STIM : process
       begin
			
		avs_s1_write_TB <= '1';
		avs_s1_address_TB <= "00000";
		avs_s1_writedata_TB <= "00010001";
		
		wait for 100 ns;
		
		end process;
		
end architecture;
		


