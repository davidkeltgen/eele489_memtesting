-- ----------------------------------------------------------------
-- avs_ram_interface.vhd
--
-- 3/30/2011 D. W. Hawkins (dwh@ovro.caltech.edu)
--
-- Altera Avalon-MM Slave FPGA on-chip RAM interface.
--
-- The RAM interface implements the Avalon slave interface
-- with pipelined reads.
--
-- This component implements the Avalon interface only. This
-- allows this interface to be connected to a single-port RAM,
-- dual-port RAM, or a component containing a dual-port RAM,
-- where the other port is used for another function.
--
-- ----------------------------------------------------------------
-- Notes:
-- ------
--
-- 1. Address/data width examples.
--
--    Stratix II FPGAs have three RAM types;
--     * M512       576-bits  eg.,  32 x 16-bit or  32 x 18-bit
--     * M4K      4,608-bits  eg., 256 x 16-bit or 128 x 32-bit
--     * M-RAM  589,824-bits  eg., 16k x 32-bit
--
-- 2. Avalon interface signals; readdatavalid and waitrequest
--
--    These interface signals are included so that Avalon-MM
--    master and slave connections can be made without using
--    an SOPC fabric. The SOPC builder component definition
--    file avs_ram_hw.tcl contains additional notes.
--
-- ----------------------------------------------------------------
-- References:
-- -----------
--
-- [1] Altera, "SOPC Builder User Guide", version 1.0, Dec 2010.
--     (ug_sopc_builder.pdf for use with Quartus 10.1)
--
--     The 'Hardware Tcl Command Reference' on p7-12 describes
--     the procedures used in this script.
--
-- [2] Altera, "Avalon Interface Specifications", version 3.1,
--     Aug. 2010. (mnl_avalon_spec.pdf)
--
-- ----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------

entity avs_ram_interface is
	generic (
		ADDR_WIDTH   : integer := 5;  -- 2 x M512
		BYTEEN_WIDTH : integer := 4;
		DATA_WIDTH   : integer := 32
	);
	port (
		-- Reset and clock
		rstN        : in  std_logic;
		clk         : in  std_logic;

		-- Avalon Slave Interface
		avs_read    : in  std_logic;
		avs_write   : in  std_logic;
		avs_addr    : in  std_logic_vector(  ADDR_WIDTH-1 downto 0);
		avs_byteen  : in  std_logic_vector(BYTEEN_WIDTH-1 downto 0);
		avs_wrdata  : in  std_logic_vector(  DATA_WIDTH-1 downto 0);
		avs_rddata  : out std_logic_vector(  DATA_WIDTH-1 downto 0);
	    avs_rdvalid : out std_logic;
	    avs_wait    : out std_logic;

	    -- RAM interface
		ram_wren    : out std_logic;
		ram_addr    : out std_logic_vector(  ADDR_WIDTH-1 downto 0);
		ram_byteen  : out std_logic_vector(BYTEEN_WIDTH-1 downto 0);
		ram_wrdata  : out std_logic_vector(  DATA_WIDTH-1 downto 0);
		ram_rddata  : in  std_logic_vector(  DATA_WIDTH-1 downto 0)
	);
end entity;

-- ----------------------------------------------------------------

architecture slave of avs_ram_interface is

	-- Read valid pipeline
	signal rdvalid : std_logic_vector(2 downto 1);

begin

	-- ------------------------------------------------------------
	-- Wait-request handshake
	-- ------------------------------------------------------------
	--
	process(clk, rstN)
	begin
		if (rstN = '0') then
			-- High during reset per Avalon verification suite
			avs_wait <= '1';
		elsif rising_edge(clk) then
			avs_wait <= '0';
		end if;
	end process;

	-- ------------------------------------------------------------
	-- Read data valid pipeline
	-- ------------------------------------------------------------
	--
	process(clk, rstN)
	begin
		if (rstN = '0') then
			rdvalid <= (others => '0');
		elsif rising_edge(clk) then
			rdvalid(1) <= avs_read;
			rdvalid(2) <= rdvalid(1);
		end if;
	end process;
	avs_rdvalid <= rdvalid(2);

    -- ------------------------------------------------------------
    -- RAM interface (pass-through connections)
    -- ------------------------------------------------------------
	--
	ram_wren    <= avs_write;
	ram_addr    <= avs_addr;
	ram_byteen  <= avs_byteen;
	ram_wrdata  <= avs_wrdata;
	avs_rddata  <= ram_rddata;

end architecture;

