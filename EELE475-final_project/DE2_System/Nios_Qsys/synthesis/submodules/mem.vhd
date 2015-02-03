LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY mem IS
 PORT(
		  clk 			    : in std_logic;
		  reset_n 		    : in std_logic;
		  avs_s1_read		 : in std_logic;
		  avs_s1_write 	 : in std_logic;
		  avs_s1_address 	 : in std_logic_vector(7 downto 0);
		  avs_s1_readdata	 : out std_logic_vector(31 downto 0);
		  avs_s1_writedata : in std_logic_vector(31 downto 0);
		  led_signal 			    : out std_logic_vector(8 downto 0)
        );
END mem;

ARCHITECTURE rtl OF mem IS

			component twoptram IS
			PORT
			(
				clock		: IN STD_LOGIC  := '1';
				data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
				rdaddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
				wraddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
				wren		: IN STD_LOGIC  := '0';
				q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
			);
		END component twoptram;
		
	component clk_div IS
	PORT
	(
		clock_48Mhz				: IN	STD_LOGIC;
		clock_1MHz				: OUT	STD_LOGIC;
		clock_100KHz			: OUT	STD_LOGIC;
		clock_10KHz				: OUT	STD_LOGIC;
		clock_1KHz				: OUT	STD_LOGIC;
		clock_100Hz				: OUT	STD_LOGIC;
		clock_10Hz				: OUT	STD_LOGIC;
		clock_1Hz				: OUT	STD_LOGIC
		);
	
END component clk_div;

	signal dram_ba : std_logic_vector(1 downto 0); 
	signal dram_dqm : std_logic_vector(1 downto 0); 
	signal clk_nios : std_logic;
	signal ram_wren 		: std_logic;
	signal rdaddress_sig : std_logic_vector(7 downto 0);
	signal wraddress_sig : std_logic_vector(7 downto 0);
	signal data_sig 		: std_logic_vector(31 downto 0);
	signal q_sig			: std_logic_vector(31 downto 0);
	signal rstate			: std_logic_vector(1 downto 0) := "00";
	signal wrstate			: std_logic_vector(1 downto 0) := "00";
	signal counter 		: integer := 0;
	signal readdata      : std_logic_vector(31 downto 0);
	
	signal wre  : std_logic;
	signal re   : std_logic;
	signal addr : std_logic_vector(7 downto 0);
	--signal data_in : std_logic_vector(31 downto 0);
	
	
begin
	--led_signal(8) <= '1';

	--wre  <= avs_s1_write;
	--re   <= avs_s1_read;
	--addr <= avs_s1_address;
	--led_signal(7 downto 1) <= "1111111";
	--led_signal(0) <= wre;
	--led_signal <= q_sig;
	avs_s1_readdata <= readdata;
	led_signal(7 downto 0) <= readdata(7 downto 0);
	
	--led_signal(8) <= '1';
	--led_signal(7) <= avs_s1_write;
	--led_signal(4 downto 0) <= avs_s1_address(4 downto 0);
	--led_signal(6 downto 5)<= readdata(1 downto 0);

--process (clk)
--		variable readdata : std_logic_vector(7 downto 0);
--	begin
--				ram_wren <= '1';
--				--wraddress_sig <= addr; -- for testing purposes, addr should be zero (i will check that next
--				wraddress_sig <= "00000";
--				--avs_s1_writedata <= "10101010";
--	end process;
--	
--	process (clk)
--		--variable readdata : std_logic_vector(7 downto 0);
--	begin
--				--rdaddress_sig <= addr;
--			data_in <= "10101010";
--	end process;
	


--	twoptram_inst : twoptram PORT MAP (
--		clock	 => clk,
--		--data	 => avs_s1_writedata,
--		data	 => data_in,
--		rdaddress	 => rdaddress_sig,
--		wraddress	 => wraddress_sig,
--		wren	 => ram_wren,
--		q	 => q_sig
--	);

	twoptram_inst : twoptram PORT MAP (
		clock	 => clk,
		data	 => avs_s1_writedata,
		rdaddress	 => avs_s1_address,
		wraddress	 => avs_s1_address,
		wren	 => avs_s1_write,
		--wren => '1',
		q	 => readdata
	);
	
end architecture;
	