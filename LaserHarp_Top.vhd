library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LaserHarp_Top is
	port (clk			: in  STD_LOGIC;
			--seg			: out STD_LOGIC_VECTOR(6 downto 0);
			--an			: out STD_LOGIC_VECTOR(2 downto 0);
			swts			: in  STD_LOGIC_VECTOR(7 downto 0);
			btn			: in STD_LOGIC;
			i2s_mclk		: out STD_LOGIC;
			i2s_lrclk	: out STD_LOGIC;
			i2s_sclk		: out STD_LOGIC;
			i2s_data		: out STD_LOGIC
	);
end LaserHarp_Top;

architecture Behavioral of LaserHarp_Top is
	constant NUM_STRS : integer := 3;
	
	component i2s_top
		port (clk		: in  STD_LOGIC;
				numStr	: in  integer;
				motor		: in  STD_LOGIC_VECTOR(7 downto 0);
				light		: in  STD_LOGIC;
				JA 		: out STD_LOGIC_VECTOR(3 downto 0));
	end component;
	
begin
	i2s_int : i2s_top port map 
					(clk=>clk,
					 numStr=>NUM_STRS,
					 motor(0)=>swts(0),
					 motor(1)=>swts(1),
					 motor(2)=>swts(2),
					 motor(3)=>swts(3),
					 motor(4)=>swts(4),
					 motor(5)=>swts(5),
					 motor(6)=>swts(6),
					 motor(7)=>swts(7),
					 light=>btn,
					 JA(0)=>i2s_mclk,
					 JA(1)=>i2s_lrclk,
					 JA(2)=>i2s_sclk,
					 JA(3)=>i2s_data);

end Behavioral;

