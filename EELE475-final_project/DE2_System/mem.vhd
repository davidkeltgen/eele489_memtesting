LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY mem IS
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
END mem;

ARCHITECTURE rtl OF mem IS

			component twoptram IS
			PORT
			(
				clock		: IN STD_LOGIC  := '1';
				data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
				rdaddress		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
				wraddress		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
				wren		: IN STD_LOGIC  := '0';
				q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
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
	signal rdaddress_sig : std_logic_vector(4 downto 0);
	signal wraddress_sig : std_logic_vector(4 downto 0);
	signal data_sig 		: std_logic_vector(7 downto 0);
	signal q_sig			: std_logic_vector(7 downto 0);
	signal rstate			: std_logic_vector(1 downto 0) := "00";
	signal wrstate			: std_logic_vector(1 downto 0) := "00";
	signal counter 		: integer := 0;
	
	signal wre  : std_logic;
	signal re   : std_logic;
	signal addr : std_logic_vector(4 downto 0);
	
	
begin

	wre  <= avs_s1_write;
	re   <= avs_s1_read;
	addr <= avs_s1_address;
	led_signal(7 downto 1) <= "0000000";
	led_signal(0) <= wre;

process (clk)
		variable readdata : std_logic_vector(7 downto 0);
	begin
				ram_wren <= '1';
				wraddress_sig <= addr; -- for testing purposes, addr should be zero (i will check that next
	end process;
	
	process (clk)
		variable readdata : std_logic_vector(7 downto 0);
	begin
				rdaddress_sig <= addr;
	end process;

	--led_signal <= q_sig;
	avs_s1_readdata <= q_sig;

	twoptram_inst : twoptram PORT MAP (
		clock	 => clk,
		data	 => avs_s1_writedata,
		rdaddress	 => rdaddress_sig,
		wraddress	 => wraddress_sig,
		wren	 => ram_wren,
		q	 => q_sig
	);
	
end architecture;
	