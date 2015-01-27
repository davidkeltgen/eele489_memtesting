------------------------------------------------------------------------------------------------------------
-- File name   : crc_TB.vhd
--
-- Project     : VHDL CRC calculator
--
-- Description : VHDL testbench
--
-- Author(s)   : David Keltgen
--				 Matthew Handley
--               Montana State University
--               
--
-- Date        : December 9, 2014
--
------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all; 

entity crc_TB is
end entity;

architecture crc_TB_arch of crc_TB is
        
  constant t_clk_per : time := 20 ns;  -- Period of a 50MHZ Clock

-- Component Declaration

  component crc_control
	 Port (  	clk            	: in  STD_LOGIC;  		-- PWM timing is based on the number of clock cycles from clk
				reset          	: in  STD_LOGIC;  		-- reset 
				
				-- control register bits
				enable			: in 	STD_LOGIC;		-- enable module
				start			: in 	STD_LOGIC;		-- start calculation
				fifo_empty		: out STD_LOGIC;		-- FIFO empty status flag
				fifo_full		: out STD_LOGIC;		-- FIFO full status flag
				complete		: out STD_LOGIC;		-- calculation complete
				reset_shift    	: in  STD_LOGIC;		-- clears shift register
				shift_change   	: in  STD_LOGIC;  	   -- goes high when shift register changes
				
				vword   		: out STD_LOGIC_VECTOR (15 downto 0); 	-- Read only, Indicates the number of valid words in the shift register
				dwidth  		: in STD_LOGIC_VECTOR ( 7 downto 0); 	-- Width of a data word
				plen  			: in STD_LOGIC_VECTOR ( 7 downto 0); 	-- Polynomial width
				poly 			: in STD_LOGIC_VECTOR (31 downto 0); 	-- Polynomial coefficients

				--FIFO 			: in STD_LOGIC_VECTOR (31 downto 0); 	-- Writes data to the FIFO
				SHIFT 			: in STD_LOGIC_VECTOR (31 downto 0); 	-- Writes to the CRC shift register
				RESULT 			: out STD_LOGIC_VECTOR (31 downto 0); 	-- The CRC calculation result.
				
				DEBUG 			: out STD_LOGIC_VECTOR (31 downto 0) 	-- reserved for debugging.
				);
  end component;

 -- Signal Declaration
 
	--
 
    signal  clock_TB      	 	: std_logic;
    signal  reset_TB       		: std_logic;
	signal  enable_TB    		: std_logic;
	signal  start_TB       		: std_logic;
	signal  fifo_empty_TB       : std_logic;
	signal  fifo_full_TB       	: std_logic;
	signal  complete_TB       	: std_logic;
	signal  reset_shift_TB      : std_logic;
	signal  shift_change_TB     : std_logic;
	
	signal  vword_TB  				: std_logic_vector(15 downto 0);
	signal  dwidth_TB  				: std_logic_vector(7 downto 0);
	signal  plen_TB  				: STD_LOGIC_VECTOR ( 7 downto 0); 	-- Polynomial width
	signal  poly_TB 				: STD_LOGIC_VECTOR (31 downto 0); 	-- Polynomial coefficients
	signal  SHIFT_TB  				: STD_LOGIC_VECTOR (31 downto 0); 	-- Writes to the CRC shift register
	signal  RESULT_TB  				: STD_LOGIC_VECTOR (31 downto 0); 	-- The CRC calculation result.
	signal  DEBUG_TB  				: STD_LOGIC_VECTOR (31 downto 0); 	-- reserved for debugging.


  begin
      DUT1 : crc_control
         port map  (clk        	=> clock_TB,
                    reset      	=> reset_TB,
					enable		=> enable_TB,
					start    	=> start_TB,
					fifo_empty  => fifo_empty_TB,
					fifo_full	=> fifo_full_TB,
					complete	=> complete_TB,
					reset_shift	=> reset_shift_TB,
					shift_change =>	shift_change_TB,
					vword 		=> vword_TB,
					dwidth 		=> dwidth_TB,
					plen 		=> plen_TB,
					poly 		=> poly_TB,
					SHIFT 		=> SHIFT_TB,
					RESULT 		=> RESULT_TB,
					DEBUG 		=> DEBUG_TB);
					
					
					


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
			
			shift_change_TB <= '0';
			start_TB <= '0';
			reset_shift_TB <= '0';
			
			reset_TB <= '1'; wait for 10 ns;
			reset_shift_TB <= '1';
		  
			reset_TB <= '0'; wait for 100 ns;
			reset_shift_TB <= '0';
		  
			enable_TB <= '1';
		  
		  
		  
		  
			dwidth_TB <= x"04";
			plen_TB 	<=  x"04";
			poly_TB   <= x"0000000B";
			--wait for 100 ns;
		  
		  
			SHIFT_TB <= x"00000003"; 
			shift_change_TB <= '1';
			wait for 100 ns;
		 
			SHIFT_TB <= x"00000004"; 
			shift_change_TB <= '0';
			wait for 100 ns;
		  
			SHIFT_TB <= x"0000000E";  
			shift_change_TB <= '1';	wait for 100 ns;	   
          
			SHIFT_TB <= x"0000000C"; 
			shift_change_TB <= '0'; wait for 100 ns;		  
      		  
			start_TB <= '1';

		  wait;
       end process;


end architecture;
