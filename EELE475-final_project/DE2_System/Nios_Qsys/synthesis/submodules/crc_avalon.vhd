----------------------------------------------------------------------------------
-- Company:          Montana State University
-- Author/Engineer:	Matthew Handley
--							David Keltgen
-- 
-- Create Date:    	2014-11-25
-- Design Name: 
-- Module Name:    crc - Behavioral 
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


entity crc_avalon is
	port (
		clk 			    		 : in std_logic;
		reset_n 		    		 : in std_logic;
		avs_s1_write 		    : in std_logic;
		avs_s1_read 		    : in std_logic;
		avs_s1_address 	    : in std_logic_vector(7 downto 0);
		avs_s1_writedata 	    : in std_logic_vector(31 downto 0);
		avs_s1_readdata 	    : out std_logic_vector(31 downto 0)
	);
end crc_avalon;

architecture behavior of crc_avalon is

	component crc_control 
		Port ( 	clk            : in  STD_LOGIC;  	-- PWM timing is based on the number of clock cycles from clk
					reset          : in  STD_LOGIC;  	-- reset 
					
					-- control register bits
					enable			: in 	STD_LOGIC;		-- enable module
					start				: in 	STD_LOGIC;		-- start calculation
					fifo_empty		: out STD_LOGIC;		-- FIFO empty status flag
					fifo_full		: out STD_LOGIC;		-- FIFO full status flag
					complete			: out STD_LOGIC;		-- calculation complete
					reset_shift    : in  STD_LOGIC;		-- clears shift register
					shift_change   : in  STD_LOGIC;     -- goes high when shift register changes
					
					vword   			: out STD_LOGIC_VECTOR (15 downto 0); 	-- Read only, Indicates the number of valid words in the FIFO
					dwidth  			: in STD_LOGIC_VECTOR ( 5 downto 0); 	-- Width of a data word
					plen  			: in STD_LOGIC_VECTOR ( 5 downto 0); 	-- Polynomial width
					poly 				: in STD_LOGIC_VECTOR (31 downto 0); 	-- Polynomial coefficients

					--FIFO 				: in STD_LOGIC_VECTOR (31 downto 0); 	-- Writes data to the FIFO
					SHIFT 			: in STD_LOGIC_VECTOR (31 downto 0); 	-- Writes to the CRC shift register
					RESULT 			: out STD_LOGIC_VECTOR (31 downto 0); 	-- The CRC calculation result.
					DEBUG 			: out STD_LOGIC_VECTOR (31 downto 0) 	-- reserved for debugging.
		);
	end component;

	signal wre  : std_logic;
	signal re   : std_logic;
	signal addr : std_logic_vector(7 downto 0);
	signal reset_shift    : STD_LOGIC;		-- clears shift register
	signal shift_change   : STD_LOGIC;     -- goes high when shift register changes
	
	-- control register
	signal enable				: STD_LOGIC;
	signal start				: STD_LOGIC;
	signal fifo_empty			: STD_LOGIC;
	signal fifo_full			: STD_LOGIC;
	signal complete			: STD_LOGIC;
	
	signal vword   			: STD_LOGIC_VECTOR (15 downto 0); 	-- Read only, Indicates the number of valid words in the FIFO
	signal dwidth  			: STD_LOGIC_VECTOR ( 5 downto 0); 	-- Width of a data word
	signal plen  				: STD_LOGIC_VECTOR ( 5 downto 0); 	-- Polynomial width
	signal poly 				: STD_LOGIC_VECTOR (31 downto 0); 	-- Polynomial coefficients
	
	--signal FIFO 				: STD_LOGIC_VECTOR (31 downto 0); 	-- Writes data to the FIFO
	signal SHIFT 				: STD_LOGIC_VECTOR (31 downto 0); 	-- Writes to the CRC shift register
	signal RESULT 				: STD_LOGIC_VECTOR (31 downto 0); 	-- The CRC calculation result.
	signal DEBUG 				: STD_LOGIC_VECTOR (31 downto 0); 	-- reserved for debugging.

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
						enable 		<= avs_s1_writedata(0);
						start 		<= avs_s1_writedata(1);
						reset_shift <= avs_s1_writedata(2);
					elsif wre='0' and re='1' then
						readdata(0) 				:= enable;
						readdata(1) 				:= start;
						readdata(2) 				:= reset_shift;
						readdata(3) 				:= '0';
						readdata(4) 				:= fifo_empty;
						readdata(5) 				:= fifo_full;
						readdata(7 downto 6) 	:= (others => '0');
						readdata(8) 				:= complete;
						readdata(31 downto 9) 	:= (others => '0');
					end if;
					
				-- Latch vword (address 1)
				WHEN x"01" =>
					if wre='1' and re='0' then
						-- writes ignored
					elsif wre='0' and re='1' then
						readdata(15 downto 0) := vword;
						readdata(31 downto 16) := (others => '0');
					end if;
					
				-- Latch dwidth (address 2)
				WHEN x"02" =>
					if wre='1' and re='0' then
						dwidth <= avs_s1_writedata(5 downto 0);
					elsif wre='0' and re='1' then
						readdata(5 downto 0) := dwidth;
						readdata(31 downto 6) := (others => '0');
					end if;
					
				-- Latch plen (address 3)
				WHEN x"03" =>
					if wre='1' and re='0' then
						plen <= avs_s1_writedata(5 downto 0);
					elsif wre='0' and re='1' then
						readdata(5 downto 0) := plen;		
						readdata(31 downto 6) := (others => '0');
					end if;
					
				-- Latch poly (address 4)
				WHEN x"04" =>
					if wre='1' and re='0' then
						poly <= avs_s1_writedata(31 downto 0);
					elsif wre='0' and re='1' then
						readdata(31 downto 0) := poly;		
					end if;
					
					
			
			------------------------
			-- Block 2 (32 bytes) --
			------------------------
			
				-- Latch FIFO word (address 0)
				WHEN x"20" =>
					if wre='1' and re='0' then
						--FIFO <= avs_s1_writedata(31 downto 0);
					elsif wre='0' and re='1' then
						readdata(31 downto 0) := x"00000000";		
					end if;
			
				-- Latch SHIFT word (address 1)
				WHEN x"21" =>
					if wre='1' and re='0' then
						SHIFT <= avs_s1_writedata(31 downto 0);
						
						-- toggle shift_change
						if(shift_change = '0') then
							shift_change <= '1';
						else
							shift_change <= '0';
						end if;
						
					elsif wre='0' and re='1' then
						readdata(31 downto 0) := SHIFT;		
					end if;
			
				-- Latch RESULT word (address 2)
				WHEN x"22" =>
					if wre='1' and re='0' then
						-- Writes ignored
					elsif wre='0' and re='1' then
						readdata(31 downto 0) := RESULT;		
					end if;
			
				-- Latch DEBUG word (address 3)
				WHEN x"23" =>
					if wre='1' and re='0' then
						-- Writes ignored
					elsif wre='0' and re='1' then
						readdata(31 downto 0) := DEBUG;		
					end if;
					
				WHEN OTHERS =>  readdata := x"F000000F"; -- TODO: chanche back to 0x00...
				
			end CASE;
			
			-- update output
			avs_s1_readdata <= readdata;
			
		end IF;
	end process;

	---------------------------------------------------
	-- instantiate pwm controller block
	---------------------------------------------------
	crc1 : crc_control Port Map ( 
			   clk            => clk,
			   reset          => not reset_n,

				-- control register bits
				enable			=> enable,
				start				=> start,
				fifo_empty		=> fifo_empty,
				fifo_full		=> fifo_full,
				complete			=> complete,
				reset_shift 	=> reset_shift, 
				shift_change   => shift_change,

				vword   			=> vword,
				dwidth  			=> dwidth,
				plen  			=> plen,
				poly 				=> poly,

				--FIFO 				=> FIFO,
				SHIFT 			=> SHIFT,
				RESULT 			=> RESULT,
				DEBUG 			=> DEBUG
	);

end behavior;



