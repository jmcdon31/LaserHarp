library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity i2s_top is
   port (clk 	: in  STD_LOGIC;
		   numStr	: in  integer;
			motor		: in  STD_LOGIC_VECTOR(7 downto 0);
			light		: in  STD_LOGIC;
         JA 		: out STD_LOGIC_VECTOR(3 downto 0));
	end i2s_top;
 
architecture Behavioral of i2s_top is
    component i2s_output is
    Port ( clk       : in   STD_LOGIC;
           data_l    : in   STD_LOGIC_VECTOR (15 downto 0);
           data_r    : in   STD_LOGIC_VECTOR (15 downto 0);
           accepted  : out  STD_LOGIC;
           i2s_sd    : out  STD_LOGIC;
           i2s_lrclk : out  STD_LOGIC;
           i2s_sclk  : out  STD_LOGIC;
           i2s_mclk  : out  STD_LOGIC);
    end component;
    
    signal accepted : STD_LOGIC;
    signal data     : STD_LOGIC_VECTOR (15 downto 0) := x"c000";
	 signal pitch	  : integer := -1;
    signal count    : unsigned(7 downto 0) := (others => '0');
begin
    
	i_output: i2s_output  port map 
						(clk=>clk,
						 data_l=>data,
						 data_r=>data, 
						 accepted=>accepted,
						 i2s_mclk=>ja(0),
						 i2s_lrclk=>ja(1),
						 i2s_sclk=>ja(2),
						 i2s_sd=>ja(3));
   
	--Note order: CDEFGAB
	data_set : process(clk)
	 begin
		if rising_edge(clk) then
			if (motor = "00000000") then
				pitch <= -1;
			end if;
			--A3, 220Hz
			if (motor(7) = '1') then
				pitch <= 110;
			end if;
			--B3, 245Hz
			if (motor(6) = '1') then
				pitch <= 99;
			end if;
			--C4, 261Hz
			if (motor(5) = '1') then
				pitch <= 93;
			end if;
			--D4, 293Hz
			if (motor(4) = '1') then
				pitch <= 83;
			end if;
			--E4, 329Hz
			if (motor(3) = '1') then
				pitch <= 74;
			end if;
			--F4, 349Hz
			if (motor(2) = '1') then
				pitch <= 69;
			end if;
			--G4, 392Hz
			if (motor(1) = '1') then
				pitch <= 62;
			end if;
			--A4, 440Hz
			if (motor(0) = '1') then
				pitch <= 55;
			end if;
		end if;
	end process;

	p_clk: process(clk)
    begin
        if rising_edge(clk) then
            if accepted = '1' then 
                if count = pitch then
                    count <= (others => '0');
                    data(15) <= not data(15);
                else
                    count <= count + 1;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
