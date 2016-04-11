library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ssdCtrl is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           DIN : in  STD_LOGIC_VECTOR (9 downto 0);
           AN : out  STD_LOGIC_VECTOR (3 downto 0);
           SEG : out  STD_LOGIC_VECTOR (6 downto 0));
end ssdCtrl;

architecture Behavioral of ssdCtrl is
		component Binary_To_BCD
			 Port ( CLK : in  STD_LOGIC;
					  RST : in  STD_LOGIC;
					  START : in STD_LOGIC;
					  BIN : in  STD_LOGIC_VECTOR(9 downto 0);
					  BCDOUT : inout STD_LOGIC_VECTOR(15 downto 0)
			 );
		end component;

		constant cntEndVal : STD_LOGIC_VECTOR(15 downto 0) := X"C350";
		signal clkCount : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
		signal DCLK : STD_LOGIC := '0';
		-- 2 Bit Counter
		signal CNT : STD_LOGIC_VECTOR(1 downto 0) := "00";
		-- Binary to BCD
		signal bcdData : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
		-- Output Data Mux
		signal muxData : STD_LOGIC_VECTOR(3 downto 0);

begin

			BtoBCD : Binary_To_BCD port map(
					CLK=>CLK,
					RST=>RST,
					START=>DCLK,
					BIN=>DIN,
					BCDOUT=>bcdData
			);
			
			--					 Output Data Mux
			process(CNT(1), CNT(0), bcdData, RST) begin
					if(RST = '1') then
							muxData <= "0000";
					else
							case (CNT) is
									when "00" => muxData <= bcdData(3 downto 0);
									when "01" => muxData <= bcdData(7 downto 4);
									when "10" => muxData <= bcdData(11 downto 8);
									when "11" => muxData <= bcdData(15 downto 12);
									when others => muxData <= "0000";
							end case;
					end if;
			end process;

			--		   Segment Decoder
			process(DCLK, RST) begin
					if(RST = '1') then
							SEG <= "1000000";
					elsif rising_edge(DCLK) then
							case (muxData) is

									when X"0" => SEG <= "1000000";  -- 0
									when X"1" => SEG <= "1111001";  -- 1
									when X"2" => SEG <= "0100100";  -- 2
									when X"3" => SEG <= "0110000";  -- 3
									when X"4" => SEG <= "0011001";  -- 4
									when X"5" => SEG <= "0010010";  -- 5
									when X"6" => SEG <= "0000010";  -- 6
									when X"7" => SEG <= "1111000";  -- 7
									when X"8" => SEG <= "0000000";  -- 8
									when X"9" => SEG <= "0010000";  -- 9
									when others => SEG <= "1000000";
									
							end case;
					end if;
			end process;

			--	  		  Anode Decoder
			process(DCLK, RST) begin
					if(RST = '1') then
							AN <= "0000";
					elsif rising_edge(DCLK) then
							case (CNT) is

									when "00" => AN <= "1110";  -- 0
									when "01" => AN <= "1101";  -- 1
									when "10" => AN <= "1011";  -- 2
									when "11" => AN <= "0111";  -- 3
									when others => AN <= "1111";
									
							end case;
					end if;
			end process;
			
			--			2 Bit Counter
			process(DCLK) begin

					if rising_edge(DCLK) then
							CNT <= CNT + 1;
					end if;
					
			end process;

			--			1khz Clock Divider
			process(CLK) begin

					if rising_edge(CLK) then
							if(clkCount = cntEndVal) then
									DCLK <= '1';
									clkCount <= X"0000";
							else
									DCLK <= '0';
									clkCount <= clkCount + 1;
							end if;
					end if;
					
			end process;

end Behavioral;

