----------------------------------------------------------------------------------
--
-- Author:           Dr. Ross Snider
--           	     Electrical and Computer Engineering Department
--           	     Montana State University
--                   Bozeman, MT  59717
-- Modified by:      David Keltgen
-- 					 	Matthew Handley
--
-- Create Date:      09/23/2010
-- Design Name:      DE2_Board
-- Module Name:      DE2_Board 
-- Target Board:     Altera DE2 Evaluation Board
-- Target FPGA:      Cyclone II EP2C35F672C6
-- Tool versions:    Quartus II 10.0
-- Description:      Top Level VHDL Template File for the Altera DE2 Board
--                   This file contains the VHDL Entity for all the physical signals
--                   on the board that can be connected to by the Cyclone II FPGA
--                   Created for use in the EE475 course 
--                   HARDWARE AND SOFTWARE ENGINEERING FOR EMBEDDED SYSTEMS
--
-- Dependencies:     None
-- Revision:         1.01
-- Revision 1.00 -   File Created
--          1.01 -   Updated for Quartus II 10.0 (09/10/2010)
-- 
--
-- Note 1:           Use: Save this file as DE2_Board_top_level.vhd
--                   and import into your design
--                   Remove the statments driving the default output signals in the
--                   architecture that you will use in your design to avoid contention
--                   These statements are found below line ~251.
--
-- Note 2:           The DE2 Board pin assigments can be assigned by importing the file
--                   DE2_Board_pin_assignments.csv into Quartus by
--                   Assigments->Import Assigments...
--                   Verify by using the Pin Planner and making sure they have been loaded 
--                   (Assignments->Pin Planner)
--                   
-- Note 3:           FPGA Unused Pins:
--                   If you set the unused pins as "inputs tri-stated", 
--                   you should connect the pins on the board level to VCC or GND 
--                   or some signal for better noise immunity. If you set the 
--                   unused pins as "inputs tri-stated with weak pull up", you do 
--                   not have to connect the pin on the board.
--                   Do this under Assigments->Device:
--                   	1.  Click "Device and Pin options" Button
--                   	2.  Select the Unused Pins Catagory
--                   	3.  Select the option: "As inputs tri-stated with weak pull up"
--                      4.  Click OK
--
-- Note 4:           Dual Use Pins:
--                   See Note 3, but go to the Dual-Purpose Pins Catagory
--                   	1. Set nCEO by double clicking on the value setting and 
--                         selecting "Use as regular I/O" in the pull down menu.
--                         (this pin is also used by IRDA_TXD)
--                      2. Click OK
--
-- Note 5:           The instructions for inserting a Nios II Processor can be found 
--                   at the lines starting at both the line numbers ~220 and ~232
--
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DE2_Board_top_level is
	port
	(		
		-- Clocks
		CLOCK_27  : in std_logic;  -- 27 MHz clock input
		CLOCK_50  : in std_logic;  -- 50 MHz clock input
		EXT_CLOCK : in std_logic;  -- External (SMA) clock input
		
		-- Pushbuttons : 4 pushbuttons debounced via Schmitt Trigger
		KEY : in std_logic_vector(3 downto 0);  -- '1' when NOT PRESSED, '0' when DEPRESSED (active low) 
		
		-- Switches : 17 Slider Switches
		SW	: in  std_logic_vector(17 downto 0);  -- '1' when switch is UP, '0' when switch is DOWN (closest to edge of board)
		
		-- LEDs
		LEDR : out  std_logic_vector(17 downto 0);  -- 18 Red LEDs  '1' = ON,  '0' = OFF
		LEDG : out  std_logic_vector(8 downto 0);   -- 9 Green LEDs '1' = ON,  '0' = OFF
		
		-- 7-segment Displays (dot in displays cannot be used)
		HEX0 : out  std_logic_vector(6 downto 0);   -- '0' turns segment ON, '1' turns segment OFF
		HEX1 : out  std_logic_vector(6 downto 0);   -- '0' turns segment ON, '1' turns segment OFF
		HEX2 : out  std_logic_vector(6 downto 0);   -- '0' turns segment ON, '1' turns segment OFF
		HEX3 : out  std_logic_vector(6 downto 0);   -- '0' turns segment ON, '1' turns segment OFF
		HEX4 : out  std_logic_vector(6 downto 0);   -- '0' turns segment ON, '1' turns segment OFF
		HEX5 : out  std_logic_vector(6 downto 0);   -- '0' turns segment ON, '1' turns segment OFF
		HEX6 : out  std_logic_vector(6 downto 0);   -- '0' turns segment ON, '1' turns segment OFF
		HEX7 : out  std_logic_vector(6 downto 0);   -- '0' turns segment ON, '1' turns segment OFF
		
		-- LCD Module
		LCD_DATA : inout std_logic_vector(7 DOWNTO 0);
		LCD_RW   : out   std_logic;  -- '0' = Write, '1' = Read
		LCD_EN   : out   std_logic;  -- Enable
		LCD_RS   : out   std_logic;  -- Command/Data Select '0' = Command, '1' = Data
		LCD_ON   : out   std_logic;  -- LCD Power ON/OFF
		LCD_BLON : out   std_logic;  -- LCD Back Light ON/OFF
		 
		-- Expansion Header
		GPIO_0 : inout std_logic_vector(35 downto 0);  -- JP1
		GPIO_1 : inout std_logic_vector(35 downto 0);  -- JP2
		
		-- VGA video DAC (ADV7123)
		VGA_R     : out std_logic_vector(9 DOWNTO 0);  -- red data
		VGA_G     : out std_logic_vector(9 DOWNTO 0);  -- green data
		VGA_B     : out std_logic_vector(9 DOWNTO 0);  -- blue data
		VGA_CLK   : out std_logic;  -- VGA Clock
		VGA_BLANK : out std_logic;  -- VGA Blank
		VGA_HS    : out std_logic;  -- VGA H_Sync
		VGA_VS    : out std_logic;  -- VGA V_Sync
		VGA_SYNC  : out std_logic;  -- VGA Sync
		
		-- Audio CODEC (WM8731)
		------------------------------------------------------------
		-- NOTE: WM8731 is controlled by the I2C bus
		--       I2C ADDRESS READ  is 0x34
		--       I2C ADDRESS WRITE is 0x35
		------------------------------------------------------------
		AUD_XCK     : out   std_logic;  -- Audio CODEC Chip Clock
		AUD_BCLK    : out   std_logic;  -- Audio CODEC Bit-Stream Clock
		AUD_DACDAT  : out   std_logic;  -- Audio CODEC DAC Data
		AUD_DACLRCK : out   std_logic;  -- Audio CODEC DAC LR Clock
		AUD_ADCDAT  : in    std_logic;  -- Audio CODEC ADC Data
		AUD_ADCLRCL : out   std_logic;  -- Audio CODEC ADC LR Clock
		
		
		-- RS-232 Serial Port
		UART_RXD : in  std_logic;  -- UART Receiver
		UART_TXD : out std_logic;  -- UART Transmitter
		
		-- PS/2 Serial Port
		PS2_CLK : out   std_logic;  -- PS/2 Clock
		PS2_DAT : inout std_logic;  -- PS/2 Data
		
		-- I2C Serial Bus
		I2C_SCLK    : out   std_logic;  -- I2C Clock
		I2C_SDAT    : inout std_logic;  -- I2C Data
		
		-- Fast Ethernet Network Controller
		ENET_DATA  : inout std_logic_vector(15 DOWNTO 0);  	-- DM9000A Data
		ENET_CLK   : out   std_logic;  						-- DM9000A Clock 25 MHz
		ENET_CMD   : out   std_logic;  						-- DM9000A Command/Data Select, 0=Command, 1=Data
		ENET_CS_N  : out   std_logic;  						-- DM9000A Chip Select
		ENET_INT   : in    std_logic;  						-- DM9000A Interrupt
		ENET_RD_N  : out   std_logic;  						-- DM9000A Read
		ENET_WR_N  : out   std_logic;  						-- DM9000A Write
		ENET_RST_N : out   std_logic;  						-- DM9000A Reset
		
		-- TV Decoder (ADV7181)
		------------------------------------------------------------
		-- NOTE: ADV7181 is controlled by the I2C bus
		--       I2C ADDRESS READ  is 0x40
		--       I2C ADDRESS WRITE is 0x41
		------------------------------------------------------------
		TD_DATA  : in  std_logic_vector(7 DOWNTO 0);  	-- TV Decoder Data
		TD_HS    : in  std_logic;  						-- TV Decoder H_Sync
		TD_VS    : in  std_logic;  						-- TV Decoder V_Sync
		TD_CLK27 : in  std_logic;  						-- TV Decoder Clock Input
		TD_RESET : out std_logic;  						-- TV Decoder Reset
		
		-- USB Controller (Philips ISP1362)
		OTG_ADDR    : out   std_logic_vector(1 DOWNTO 0);  		-- ISP1362 Address
		OTG_DATA    : inout std_logic_vector(15 DOWNTO 0);  	-- ISP1362 Data
		OTG_CS_N    : out   std_logic;							-- ISP1362 Chip Select
		OTG_RD_N    : out   std_logic;							-- ISP1362 Read
		OTG_WR_N    : out   std_logic;							-- ISP1362 Write
		OTG_RST_N   : out   std_logic;							-- ISP1362 Reset
		OTG_INT0    : in    std_logic;							-- ISP1362 Interrupt 0
		OTG_INT1    : in    std_logic;							-- ISP1362 Interrupt 1
		OTG_DREQ0   : in    std_logic;							-- ISP1362 DMA Request 0
		OTG_DREQ1   : in    std_logic;							-- ISP1362 DMA Request 1
		OTG_DACK0_N : out   std_logic;							-- ISP1362 DMA Acknowledge 0
		OTG_DACK1_N : out   std_logic;							-- ISP1362 DMA Acknowledge 1
		OTG_FSPEED  : inout std_logic;							-- USB Full Speed, 0=Enable, Z=Disable
		OTG_LSPEED  : inout std_logic;							-- USB Low  Speed, 0=Enable, Z=Disable
		
		-- Infrared Transceiver (Agilent HSDL-3201)
		IRDA_TXD : out std_logic;  -- IRDA Transmitter		
		IRDA_RXD : in  std_logic;  -- IRDA Receiver		
			
		-- DRAM (8-Mbyte SDRAM)
		DRAM_ADDR  : out   std_logic_vector(11 DOWNTO 0);  -- SDRAM Address
		DRAM_DQ    : inout std_logic_vector(15 DOWNTO 0);  -- SDRAM Data
		DRAM_BA_0  : out   std_logic;                      -- SDRAM Bank Address 0
		DRAM_BA_1  : out   std_logic;                      -- SDRAM Bank Address 1
		DRAM_LDQM  : out   std_logic;                      -- SDRAM Low-byte  Data Mask
		DRAM_UDQM  : out   std_logic;                      -- SDRAM High-byte Data Mask
		DRAM_RAS_N : out   std_logic;                      -- SDRAM Row    Address Strobe
		DRAM_CAS_N : out   std_logic;                      -- SDRAM Column Address Strobe
		DRAM_CKE   : out   std_logic;                      -- SDRAM Clock Enable
		DRAM_CLK   : out   std_logic;                      -- SDRAM Clock 
		DRAM_WE_N  : out   std_logic;                      -- SDRAM Write Enable
		DRAM_CS_N  : out   std_logic;                      -- SDRAM Chip Select
		
		-- SRAM (512-Kbyte SRAM)
		SRAM_ADDR  : out   std_logic_vector(17 DOWNTO 0);  -- SRAM Address
		SRAM_DQ    : inout std_logic_vector(15 DOWNTO 0);  -- SRAM Data
		SRAM_WE_N  : out   std_logic;                      -- SRAM Write  Enable
		SRAM_OE_N  : out   std_logic;                      -- SRAM Output Enable
		SRAM_UB_N  : out   std_logic;                      -- SRAM High-byte Data Mask
		SRAM_LB_N  : out   std_logic;                      -- SRAM Low-byte  Data Mask
		SRAM_CE_N  : out   std_logic;                      -- SRAM Chip Enable
		
		-- Flash (4-Mbyte Flash)
		FL_ADDR  : out   std_logic_vector(21 DOWNTO 0);  -- Flash Address
		FL_DQ    : inout std_logic_vector(7 DOWNTO 0);   -- Flash Data
		FL_CE_N  : out   std_logic;                      -- Flash Chip Enable
		FL_OE_N  : out   std_logic;                      -- Flash Output Enable
		FL_RST_N : out   std_logic;                      -- Flash Reset
		FL_WE_N  : out   std_logic;                      -- Flash Write Enable
		
		-- SD Card Socket
		SD_DAT   : inout std_logic;
		SD_DAT3  : out   std_logic;
		SD_CMD   : out   std_logic;
		SD_CLK   : out   std_logic
				
	);
end DE2_Board_top_level;


architecture behavioral of DE2_Board_top_level is

    ---------------------------------------------------------------
   -- ADD NIOS component below this comment block
   -- This can done as follows (assumming nios_system is the SOPC name)
   -- Open the file: nios_system.vhd
   -- Search for the following string "entity nios_system is"
   -- Cut and paste the entity below
   -- change the word entity to to the word component, delete the word "is"
   -- change end entity to end component
   ---------------------------------------------------------------
	
	 component Nios_Qsys is
        port (
            clk_clk                             : in    std_logic                     := 'X';             -- clk
            switches_external_connection_export : in    std_logic_vector(17 downto 0) := (others => 'X'); -- export
            leds_external_connection_export     : out   std_logic_vector(17 downto 0);                    -- export
            reset_reset_n                       : in    std_logic                     := 'X';             -- reset_n
            sdram_addr                          : out   std_logic_vector(11 downto 0);                    -- addr
            sdram_ba                            : out   std_logic_vector(1 downto 0);                     -- ba
            sdram_cas_n                         : out   std_logic;                                        -- cas_n
            sdram_cke                           : out   std_logic;                                        -- cke
            sdram_cs_n                          : out   std_logic;                                        -- cs_n
            sdram_dq                            : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
            sdram_dqm                           : out   std_logic_vector(1 downto 0);                     -- dqm
            sdram_ras_n                         : out   std_logic;                                        -- ras_n
            sdram_we_n                          : out   std_logic;                                        -- we_n
            lcd_RS                              : out   std_logic;                                        -- RS
            lcd_RW                              : out   std_logic;                                        -- RW
            lcd_data                            : inout std_logic_vector(7 downto 0)  := (others => 'X'); -- data
            lcd_E                               : out   std_logic;                                        -- E
            buttons_pio_external_connection_export : in    std_logic_vector(2 downto 0)  := (others => 'X')  -- export	
        );
    end component Nios_Qsys;
	
	--Copyright (C) 1991-2013 Altera Corporation
	--Your use of Altera Corporation's design tools, logic functions 
	--and other software and tools, and its AMPP partner logic 
	--functions, and any output files from any of the foregoing 
	--(including device programming or simulation files), and any 
	--associated documentation or information are expressly subject 
	--to the terms and conditions of the Altera Program License 
	--Subscription Agreement, Altera MegaCore Function License 
	--Agreement, or other applicable license agreement, including, 
	--without limitation, that your use is for the sole purpose of 
	--programming logic devices manufactured by Altera and sold by 
	--Altera or its authorized distributors.  Please refer to the 
	--applicable agreement for further details.
	component clockPLL
		PORT
		(
			inclk0		: IN STD_LOGIC  := '0';
			c0				: OUT STD_LOGIC ;
			c1				: OUT STD_LOGIC 
		);
	end component;

	signal dram_ba : std_logic_vector(1 downto 0); 
	signal dram_dqm : std_logic_vector(1 downto 0); 
	signal clk_nios : std_logic;
	


begin

   ---------------------------------------------------------------
   -- Instantiate the NIOS component below this comment block
   -- This can be done using Edit->Insert Template
   -- Expand Megafunctions
   -- Expand Instances
   -- click on nios_system_inst.vhd and click insert 
   -- (it will insert where the cursor is located)
   -- Add the appropriate signal names to the signal connections
   ---------------------------------------------------------------

    u0 : component Nios_Qsys
        port map (
            clk_clk                             => clk_nios,                           --                          clk.clk
            switches_external_connection_export => SW, 											-- switches_external_connection.export
            leds_external_connection_export     => LEDR,     									--     leds_external_connection.export
            reset_reset_n                       => KEY(0),                       		--                        reset.reset_n
            sdram_addr                          => DRAM_ADDR,                          --                        sdram.addr
            sdram_ba                            => dram_ba,                            --                             .ba
            sdram_cas_n                         => DRAM_CAS_N,                         --                             .cas_n
            sdram_cke                           => DRAM_CKE,                           --                             .cke
            sdram_cs_n                          => DRAM_CS_N,                          --                             .cs_n
            sdram_dq                            => DRAM_DQ,                            --                             .dq
            sdram_dqm                           => dram_dqm,                           --                             .dqm
            sdram_ras_n                         => DRAM_RAS_N,                         --                             .ras_n
            sdram_we_n                          => DRAM_WE_N,                           --                             .we_n
				lcd_RS                              => LCD_RS,                              --                          lcd.RS
            lcd_RW                              => LCD_RW,                              --                             .RW
            lcd_data                            => LCD_DATA,                            --                             .data
            lcd_E                               => LCD_EN,                               --                             .E
				buttons_pio_external_connection_export => KEY(3 downto 1)  -- buttons_pio_external_connection.export

        ); 
	  
  clockPLL_inst : clockPLL PORT MAP (
		inclk0	=> CLOCK_50,
		c0	 		=> clk_nios,
		c1	 		=> DRAM_CLK
	);



   -----------------------------------------
   -- Delete the signals below that you will
   -- be connecting to your NIOS components
   -- Note: in    signals are ignored
   --       out   signals are set to '0'
   --       inout signals are set to 'Z'
   -----------------------------------------
	-- LEDs
	--LEDR <= (others => '0');  -- 18 Red LEDs  '1' = ON,  '0' = OFF
	LEDG <= (others => '0');  -- 9 Green LEDs '1' = ON,  '0' = OFF
	
	-- 7-segment Displays (dot in displays cannot be used)
	HEX0 <= (others => '1');  -- '0' turns segment ON, '1' turns segment OFF
	HEX1 <= (others => '1');  -- '0' turns segment ON, '1' turns segment OFF
	HEX2 <= (others => '1');  -- '0' turns segment ON, '1' turns segment OFF
	HEX3 <= (others => '1');  -- '0' turns segment ON, '1' turns segment OFF
	HEX4 <= (others => '1');  -- '0' turns segment ON, '1' turns segment OFF
	HEX5 <= (others => '1');  -- '0' turns segment ON, '1' turns segment OFF
	HEX6 <= (others => '1');  -- '0' turns segment ON, '1' turns segment OFF
	HEX7 <= (others => '1');  -- '0' turns segment ON, '1' turns segment OFF
	
	-- LCD Module
	--LCD_DATA <= (others => 'Z');
	--LCD_RW   <= '1';  -- '0' = Write, '1' = Read
	--LCD_EN   <= '0';  -- Enable
	--LCD_RS   <= '1';  -- Command/Data Select '0' = Command, '1' = Data
	LCD_ON   <= '1';  -- LCD Power ON/OFF
	LCD_BLON <= '1';  -- LCD Back Light ON/OFF
	 
	-- Expansion Header
	GPIO_0 <= (others => '0');  -- JP1
	GPIO_1(35 downto 6) <= (others => '0');  -- JP2
	GPIO_1(2) <= '0';  -- JP2
	GPIO_1(4) <= '0';  -- JP2
	
	
	-- VGA video DAC (ADV7123)
	VGA_R     <= (others => '0');  -- red data
	VGA_G     <= (others => '0');  -- green data
	VGA_B     <= (others => '0');  -- blue data
	VGA_CLK   <= '0';  -- VGA Clock
	VGA_BLANK <= '0';  -- VGA Blank
	VGA_HS    <= '0';  -- VGA H_Sync
	VGA_VS    <= '0';  -- VGA V_Sync
	VGA_SYNC  <= '0';  -- VGA Sync
	
	-- Audio CODEC (WM8731)
	------------------------------------------------------------
	-- NOTE: WM8731 is controlled by the I2C bus
	--       I2C ADDRESS READ  is 0x34
	--       I2C ADDRESS WRITE is 0x35
	------------------------------------------------------------
	AUD_XCK     <= '0';  -- Audio CODEC Chip Clock
	AUD_BCLK    <= '0';  -- Audio CODEC Bit-Stream Clock
	AUD_DACDAT  <= '0';  -- Audio CODEC DAC Data
	AUD_DACLRCK <= '0';  -- Audio CODEC DAC LR Clock
	AUD_ADCLRCL <= '0';  -- Audio CODEC ADC LR Clock
	
	-- RS-232 Serial Port
--	UART_TXD <= '0';  -- UART Transmitter
	
	-- PS/2 Serial Port
	PS2_CLK <= '0';  -- PS/2 Clock
	PS2_DAT <= 'Z';  -- PS/2 Data
	
	-- I2C Serial Bus
	I2C_SCLK    <= '0';  -- I2C Clock
	I2C_SDAT    <= 'Z';  -- I2C Data
	
	-- Fast Ethernet Network Controller
	ENET_DATA  <= (others => 'Z');  	-- DM9000A Data
	ENET_CLK   <= '0';  						-- DM9000A Clock 25 MHz
	ENET_CMD   <= '0';  						-- DM9000A Command/Data Select, 0=Command, 1=Data
	ENET_CS_N  <= '0';  						-- DM9000A Chip Select
	ENET_RD_N  <= '0';  						-- DM9000A Read
	ENET_WR_N  <= '0';  						-- DM9000A Write
	ENET_RST_N <= '0';  						-- DM9000A Reset
	
	-- TV Decoder (ADV7181)
	------------------------------------------------------------
	-- NOTE: ADV7181 is controlled by the I2C bus
	--       I2C ADDRESS READ  is 0x40
	--       I2C ADDRESS WRITE is 0x41
	------------------------------------------------------------
	TD_RESET <= '0';  						-- TV Decoder Reset
	
	-- USB Controller (Philips ISP1362)
	OTG_ADDR    <= (others => '0');  	-- ISP1362 Address
	OTG_DATA    <= (others => 'Z');  	-- ISP1362 Data
	OTG_CS_N    <= '0';							-- ISP1362 Chip Select
	OTG_RD_N    <= '0';							-- ISP1362 Read
	OTG_WR_N    <= '0';							-- ISP1362 Write
	OTG_RST_N   <= '0';							-- ISP1362 Reset
	OTG_DACK0_N <= '0';							-- ISP1362 DMA Acknowledge 0
	OTG_DACK1_N <= '0';							-- ISP1362 DMA Acknowledge 1
	OTG_FSPEED  <= 'Z';							-- USB Full Speed, 0=Enable, Z=Disable
	OTG_LSPEED  <= 'Z';							-- USB Low  Speed, 0=Enable, Z=Disable
	
	-- Infrared Transceiver (Agilent HSDL-3201)
	IRDA_TXD <= '0';  -- IRDA Transmitter		
		
	-- DRAM (8-Mbyte SDRAM)
--	DRAM_ADDR  <= (others => '0');  -- SDRAM Address
--	DRAM_DQ    <= (others => 'Z');  -- SDRAM Data
	DRAM_BA_0  <= dram_ba(0);                      -- SDRAM Bank Address 0
	DRAM_BA_1  <= dram_ba(1);                      -- SDRAM Bank Address 1
	DRAM_LDQM  <= dram_dqm(0);                      -- SDRAM Low-byte  Data Mask
	DRAM_UDQM  <= dram_dqm(1);                      -- SDRAM High-byte Data Mask
--	DRAM_RAS_N <= '0';                      -- SDRAM Row    Address Strobe
--	DRAM_CAS_N <= '0';                      -- SDRAM Column Address Strobe
--	DRAM_CKE   <= '0';                      -- SDRAM Clock Enable
--	DRAM_CLK   <= '0';                      -- SDRAM Clock 
--	DRAM_WE_N  <= '0';                      -- SDRAM Write Enable
--	DRAM_CS_N  <= '0';                      -- SDRAM Chip Select
	
	-- SRAM (512-Kbyte SRAM)
	SRAM_ADDR  <= (others => '0');  -- SRAM Address
	SRAM_DQ    <= (others => 'Z');  -- SRAM Data
	SRAM_WE_N  <= '0';                      -- SRAM Write  Enable
	SRAM_OE_N  <= '0';                      -- SRAM Output Enable
	SRAM_UB_N  <= '0';                      -- SRAM High-byte Data Mask
	SRAM_LB_N  <= '0';                      -- SRAM Low-byte  Data Mask
	SRAM_CE_N  <= '0';                      -- SRAM Chip Enable
	
	-- Flash (4-Mbyte Flash)
	FL_ADDR  <= (others => '0');  -- Flash Address
	FL_DQ    <= (others => 'Z');   -- Flash Data
	FL_CE_N  <= '0';                      -- Flash Chip Enable
	FL_OE_N  <= '0';                      -- Flash Output Enable
	FL_RST_N <= '0';                      -- Flash Reset
	FL_WE_N  <= '0';                      -- Flash Write Enable
	
	-- SD Card Socket
	SD_DAT   <= 'Z';
	SD_DAT3  <= '0';
	SD_CMD   <= '0';
	SD_CLK   <= '0';

end behavioral;


