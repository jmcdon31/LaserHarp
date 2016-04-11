library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ClkDiv_5Hz is
    Port ( CLK : in  STD_LOGIC;				-- 100MHz onboard clock
           RST : in  STD_LOGIC;				-- Reset
           CLKOUT : inout  STD_LOGIC);		-- New clock output
end ClkDiv_5Hz;

architecture Behavioral of ClkDiv_5Hz is
			-- Current count value
			signal clkCount : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
			-- Value to toggle output clock at
			constant cntEndVal : STD_LOGIC_VECTOR(23 downto 0) := X"989680";

begin

			--	5Hz Clock Divider Generates Send/Receive signal
			process(CLK, RST) begin

					-- Reset clock
					if(RST = '1')  then
							CLKOUT <= '0';
							clkCount <= X"000000";
					elsif rising_edge(CLK) then
							if(clkCount = cntEndVal) then
									CLKOUT <= NOT CLKOUT;
									clkCount <= X"000000";
							else
									clkCount <= clkCount + '1';
							end if;
					end if;

			end process;

end Behavioral;

