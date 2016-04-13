library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PmodALS is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           sndRec : in  STD_LOGIC;
           DIN : in  STD_LOGIC_VECTOR (7 downto 0);
           MISO : in  STD_LOGIC;
           SS : out  STD_LOGIC;
           SCLK : out  STD_LOGIC;
           --MOSI : out  STD_LOGIC;
           DOUT : inout  STD_LOGIC_VECTOR (39 downto 0));
end PmodALS;

architecture Behavioral of PmodALS is
		component spiCtrl
			 Port ( CLK : in  STD_LOGIC;
					  RST : in  STD_LOGIC;
					  sndRec : in STD_LOGIC;
					  BUSY : in STD_LOGIC;
					  DIN : in  STD_LOGIC_VECTOR(7 downto 0);
					  RxData : in  STD_LOGIC_VECTOR(7 downto 0);
					  SS : out STD_LOGIC;
					  getByte : out STD_LOGIC;
					  sndData : inout STD_LOGIC_VECTOR(7 downto 0);
					  DOUT : inout STD_LOGIC_VECTOR(39 downto 0)
			 );
		end component;

		component spiMode0
			 Port ( CLK : in  STD_LOGIC;
					  RST : in  STD_LOGIC;
					  sndRec : in STD_LOGIC;
					  DIN : in  STD_LOGIC_VECTOR(7 downto 0);
					  MISO : in  STD_LOGIC;
					  --MOSI : out STD_LOGIC;
					  SCLK : out STD_LOGIC;
					  BUSY : out STD_LOGIC;
					  DOUT : out STD_LOGIC_VECTOR (7 downto 0)
			 );
		end component;

		component ClkDiv_2MHz
			 Port ( CLK : in  STD_LOGIC;
					  RST : in  STD_LOGIC;
					  CLKOUT : inout STD_LOGIC
			 );
		end component;

		signal getByte : STD_LOGIC;							-- Initiates a data byte transfer in SPI_Int
		signal sndData : STD_LOGIC_VECTOR(7 downto 0);	-- Data to be sent to Slave
		signal RxData : STD_LOGIC_VECTOR(7 downto 0);	-- Output data from SPI_Int
		signal BUSY : STD_LOGIC;								-- Handshake from SPI_Int to SPI_Ctrl

		signal iSCLK : STD_LOGIC;								-- Internal serial clock,
																		-- not directly output to slave,
																		-- controls state machine, etc.
begin
			SPI_Ctrl : spiCtrl port map(
					CLK=>iSCLK,
					RST=>RST,
					sndRec=>sndRec,
					BUSY=>BUSY,
					DIN=>DIN,
					RxData=>RxData,
					SS=>SS,
					getByte=>getByte,
					sndData=>sndData,
					DOUT=>DOUT
			);

			SPI_Int : spiMode0 port map(
					CLK=>iSCLK,
					RST=>RST,
					sndRec=>getByte,
					DIN=>sndData,
					MISO=>MISO,
					--MOSI=>MOSI,
					SCLK=>SCLK,
					BUSY=>BUSY,
					DOUT=>RxData
			);

			SerialClock : ClkDiv_2MHz port map(
					CLK=>CLK,
					RST=>RST,
					CLKOUT=>iSCLK
			);

end Behavioral;

