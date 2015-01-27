
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
use IEEE.numeric_std.all;

entity crc_control is
	 Port ( 		clk            : in  STD_LOGIC;  	-- PWM timing is based on the number of clock cycles from clk
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
end entity;

architecture Behavioral of crc_control is

	constant shift_reg_size : integer := 128;	-- 16 bytes
	
	signal data 					: unsigned (shift_reg_size downto 0);		
	signal vword_int 				: integer range 0 to 65535;
	signal pointer					: integer range 0 to shift_reg_size;     			-- keep track of location in data 
	signal plen_int				: integer range 0 to shift_reg_size;     			-- 
	signal dwidth_int 			: integer range 0 to shift_reg_size;               --
	signal data_mask  			: STD_LOGIC_VECTOR (31 downto 0);        --
	signal shift_change_last 	: STD_LOGIC;
	signal complete_local 		: STD_LOGIC;
	signal poly_uns 			: unsigned (shift_reg_size downto 0);	
	
	signal shift_uns 			: unsigned (shift_reg_size downto 0);	
	
	-- state machine
	type state_type is ( 
		S_RESET_WAIT,
		S_RESET,
		S_DATA_INPUT,
		S_DATA_INPUT_WAIT,
		S_START_CALC,
		S_SHIFTING,
		S_SHIFTING_WAIT,
		S_DIVIDING, 
		S_DONE
	);	
	signal current_state		: state_type;
	signal next_state			: state_type;


begin

	shift_uns(31 downto 0) <= unsigned(SHIFT and data_mask);
	shift_uns(shift_reg_size downto 32) <= (others => '0');
	
	poly_uns(31 downto 0)	<= unsigned(poly);
	poly_uns(shift_reg_size downto 32) 	<= (others => '0');
	
	plen_int <= to_integer(unsigned(plen));	
	dwidth_int <= to_integer(unsigned(dwidth));
	vword  		<= STD_LOGIC_VECTOR(to_unsigned(vword_int, 16));
	
	complete <= complete_local;
	
	RESULT <= STD_LOGIC_VECTOR(data(31 downto 0)) AND data_mask;
	
	DEBUG(0)		<= shift_change;
	DEBUG(1)		<= shift_change_last;
	DEBUG(2)		<= reset;
	
	with current_state select DEBUG(7 downto 4) <=
		x"1" when S_RESET,
		x"2" when S_DATA_INPUT,
		x"3" when S_START_CALC,
		x"4" when S_SHIFTING,
		x"5" when S_DIVIDING,
		x"6" when S_DONE,
		x"0" when others;
		
	with next_state select DEBUG(11 downto 8) <=
		x"1" when S_RESET,
		x"2" when S_DATA_INPUT,
		x"3" when S_START_CALC,
		x"4" when S_SHIFTING,
		x"5" when S_DIVIDING,
		x"6" when S_DONE,
		x"0" when others;
		
	DEBUG(15 downto 12) <= (others => '0');
	DEBUG(23 downto 16) <= STD_LOGIC_VECTOR(to_unsigned(pointer, 8));
	DEBUG(31 downto 24) <= (others => '0');
	

	with dwidth_int select data_mask <=
		x"00000000" when 0, 
		x"00000001" when 1,
		x"00000003" when 2,
		x"00000007" when 3,
		x"0000000F" when 4,
		x"0000001F" when 5,
		x"0000003F" when 6,
		x"0000007F" when 7,
		x"000000FF" when 8,
		x"000001FF" when 9,
		x"000003FF" when 10,
		x"000007FF" when 11,
		x"00000FFF" when 12,
		x"00001FFF" when 13,
		x"00003FFF" when 14,
		x"00007FFF" when 15,
		x"0000FFFF" when 16,
		x"0001FFFF" when 17,
		x"0003FFFF" when 18,
		x"0007FFFF" when 19,
		x"000FFFFF" when 20,
		x"001FFFFF" when 21,
		x"003FFFFF" when 22,
		x"007FFFFF" when 23,
		x"00FFFFFF" when 24,
		x"01FFFFFF" when 25,
		x"03FFFFFF" when 26,
		x"07FFFFFF" when 27,
		x"0FFFFFFF" when 28,
		x"1FFFFFFF" when 29,
		x"3FFFFFFF" when 30,
		x"7FFFFFFF" when 31,
		x"FFFFFFFF" when others;
	
	

	--------------------------------------------------
	-- STATE_MEMORY 
	--------------------------------------------------
	STATE_MEMORY : process(reset, reset_shift, clk, enable)
		begin
			if(reset = '1' or reset_shift = '1') then
				current_state 	<= S_RESET_WAIT;
				
			elsif((clk'event) and (clk='0') and (enable = '1')) then					
				current_state <= next_state;
			end if;
			
	end process;
	
	--------------------------------------------------
	-- NEXT_STATE_LOGIC 
	--------------------------------------------------
	NEXT_STATE_LOGIC : process(current_state, data, complete_local, pointer, dwidth_int, start)
		begin
			case(current_state) is 
			
				when S_RESET_WAIT =>
					next_state <= S_RESET;
			
				when S_RESET =>
					next_state <= S_DATA_INPUT;
			
				when S_DATA_INPUT =>
					if(start = '1') then
						next_state <= S_START_CALC;							
					else
						next_state <= S_DATA_INPUT_WAIT;							
					end if;
					
				when S_DATA_INPUT_WAIT =>
					next_state <= S_DATA_INPUT;	
					
					
				when S_START_CALC =>
					next_state <= S_SHIFTING;
			
				when S_SHIFTING =>
					if(pointer < dwidth_int) then
						next_state <= S_DONE;
					elsif(data(pointer) = '1') then
						next_state <= S_DIVIDING;							
					else
						next_state <= S_SHIFTING_WAIT;							
					end if;
					
				when S_SHIFTING_WAIT =>
					next_state <= S_SHIFTING;	
			
				when S_DIVIDING =>
					next_state <= S_SHIFTING;
				
				when S_DONE =>					
					next_state <= S_DONE;
					
				when others =>
					next_state <= S_DONE;
						
			end case;
				
	end process;	
	
	
	--------------------------------------------------
	-- OUTPUT_LOGIC 
	--------------------------------------------------
	OUTPUT_LOGIC : process(current_state)
	
		begin
			
			case(current_state) is 
			
				
				when S_RESET =>
					-- reset signals for a new calculation
					data 					<= (others => '0');
					pointer 				<= 0;
					vword_int 			<= 0;			
					complete_local 	<= '0';
					shift_change_last <= shift_change;
					
				when S_DATA_INPUT =>
				
					-- if shift register has been written to
					if((shift_change = '1' and  shift_change_last = '0') OR
						(shift_change = '0' and  shift_change_last = '1')) then
						
						-- update shift_change_last, pointer, and vword
						shift_change_last <= shift_change;
						
						pointer <= pointer + dwidth_int;				
						vword_int <= vword_int +1;
						
						-- shift the old data to the left and OR in the new data
						data <= shift_left(data, dwidth_int) OR shift_uns;					
					
					end if;
					
					complete_local <= '0';
					
				when S_START_CALC =>
					-- shift data, so that we have room for the remainder (RESULT)
					pointer <= pointer + dwidth_int;		
					data <= shift_left(data, dwidth_int);
					
					complete_local <= '0';
			
				when S_SHIFTING =>
					-- decrement pointer to 'shift' the polynomial to the right					
					pointer <= pointer -1;
					
					complete_local <= '0';
			
				when S_DIVIDING =>		
					-- XOR the polynomial with the data, aligning the MSB of the poly with data(pointer)
					data <= data XOR (shift_left(poly_uns, (pointer - plen_int +1)));
					
					complete_local <= '0';
				
				when S_DONE =>
					complete_local <= '1';
					
				when others => 
					complete_local <= '0';
						
			end case;
			
	end process;

end Behavioral;