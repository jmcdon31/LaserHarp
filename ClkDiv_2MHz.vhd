--////////////////////////////////////////////////////////////////////////////////
-- Company: Digilent Inc.
-- Engineer: Josh Sackos
-- 
-- Create Date:    07/26/2012
-- Module Name:    ClkDiv_2Hz
-- Project Name: 	 
-- Target Devices: 
-- Tool versions:  ISE 14.1
-- Description: Converts input 50MHz clock signal to a 2MHz clock signal.
--
-- Revision History: 
-- 						Revision 0.01 - File Created (Josh Sackos)
--////////////////////////////////////////////////////////////////////////////////
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- ====================================================================================
-- 										  Define Module
-- ====================================================================================
entity ClkDiv_2MHz is
    Port ( CLK : in  STD_LOGIC;				-- 50MHz onboard clock
           RST : in  STD_LOGIC;				-- Reset
           CLKOUT : inout  STD_LOGIC);		-- New clock output
end ClkDiv_2MHz;

architecture Behavioral of ClkDiv_2MHz is

-- ====================================================================================
-- 							       Signals and Constants
-- ====================================================================================

			-- Current count value
			signal clkCount : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
			-- Value to toggle output clock at
			constant cntEndVal : STD_LOGIC_VECTOR(23 downto 0) := X"000019";

--  ===================================================================================
-- 							  				Implementation
--  ===================================================================================
begin

			-------------------------------------------------
			--	2Hz Clock Divider Generates Send/Receive signal
			-------------------------------------------------
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

