library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PmodALS_Demo is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           MISO : in  STD_LOGIC;
           SW : in  STD_LOGIC_VECTOR (2 downto 0);
			  SET : in STD_LOGIC;
           SS : out  STD_LOGIC;
           --MOSI : out  STD_LOGIC;
           SCLK : out  STD_LOGIC;
			  OSIG : out STD_LOGIC;
           LED : out  STD_LOGIC_VECTOR (2 downto 0);
           AN : out  STD_LOGIC_VECTOR (3 downto 0);
           SEG : out  STD_LOGIC_VECTOR (6 downto 0));
end PmodALS_Demo;

architecture Behavioral of PmodALS_Demo is
		component PmodALS
			 Port ( CLK : in  STD_LOGIC;
					  RST : in  STD_LOGIC;
					  sndRec : in  STD_LOGIC;
					  DIN : in  STD_LOGIC_VECTOR (7 downto 0);
					  MISO : in  STD_LOGIC;
					  SS : out  STD_LOGIC;
					  SCLK : out  STD_LOGIC;
					  --MOSI : out  STD_LOGIC;
					  DOUT : inout  STD_LOGIC_VECTOR (39 downto 0)
			 );
		end component;

		component ssdCtrl
			 Port
					( CLK : in  STD_LOGIC;
					  RST : in  STD_LOGIC;
					  DIN : in  STD_LOGIC_VECTOR(9 downto 0);
					  AN  : out STD_LOGIC_VECTOR(3 downto 0);
					  SEG : out STD_LOGIC_VECTOR(6 downto 0)
			 );
		end component;

		component ClkDiv_5Hz
			 Port ( CLK : in  STD_LOGIC;
					  RST : in  STD_LOGIC;
					  CLKOUT : inout STD_LOGIC
			 );
		end component;

		signal baseline : STD_LOGIC_VECTOR(9 downto 0);

		signal sndData : STD_LOGIC_VECTOR(7 downto 0) := X"00";
		signal sndRec : STD_LOGIC;
		signal alsData : STD_LOGIC_VECTOR(39 downto 0) := (others => '0');
		signal posData : STD_LOGIC_VECTOR(9 downto 0);

begin
			PmodALS_Int : PmodALS port map(
					CLK=>CLK,
					RST=>RST,
					sndRec=>sndRec,
					DIN=>sndData,
					MISO=>MISO,
					SS=>SS,
					SCLK=>SCLK,
					--MOSI=>MOSI,
					DOUT=>alsData
			);

			DispCtrl : ssdCtrl port map(
					CLK=>CLK,
					RST=>RST,
					DIN=>posData,
					AN=>AN,
					SEG=>SEG
			);

			genSndRec : ClkDiv_5Hz port map(
					CLK=>CLK,
					RST=>RST,
					CLKOUT=>sndRec
			);

			--Binary output from ALS
			posData <= alsData(37 downto 28);
			baseline <= alsData(37 downto 28) when SET = '0' else
						baseline;

			OSIG <= '1' when SET = '1'
						and (to_integer(signed(posData)) > to_integer(signed(baseline))) else
					'0';

end Behavioral;

