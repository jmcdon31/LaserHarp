--////////////////////////////////////////////////////////////////////////////////
-- Company: Digilent Inc.
-- Engineer: Josh Sackos
-- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Binary_To_BCD is
    Port ( CLK : in  STD_LOGIC;										-- 100Mhz CLK
           RST : in  STD_LOGIC;										--	Reset
           START : in  STD_LOGIC;									--	Signal to initialize conversion
           BIN : in  STD_LOGIC_VECTOR (9 downto 0);			--	Binary value to be converted
           BCDOUT : inout  STD_LOGIC_VECTOR (15 downto 0));	--	4 digit binary coded decimal output
end Binary_To_BCD;

architecture Behavioral of Binary_To_BCD is
		-- Stores number of shifts executed
		signal shiftCount : STD_LOGIC_VECTOR(4 downto 0) := "00000";
		-- Temporary shift regsiter
		signal tmpSR : STD_LOGIC_VECTOR(27 downto 0) := (others=>'0');

		-- FSM States
		type state_type is (Idle, Init, Shift, Check, Done);

		-- Present state, Next State
		signal STATE, NSTATE : state_type;

begin

		--		   State Register
		STATE_REGISTER: process(CLK, RST) begin
				if (RST = '1') then
						STATE <= Idle;
				elsif rising_edge(CLK) then
						STATE <= NSTATE;
				end if;
		end process;

		--		Output Logic/Assignment
		OUTPUT_LOGIC: process (CLK, RST)
		begin
				if(RST = '1') then
						-- Reset/clear values
						BCDOUT <= X"0000";
						tmpSR <= X"0000000";
						
				elsif rising_edge(CLK) then

						case (STATE) is

								when Idle =>
										BCDOUT <= BCDOUT;								 	-- Output does not change
										tmpSR <= X"0000000";								-- Temp shift reg empty
								when Init =>
										BCDOUT <= BCDOUT;									-- Output does not change
										tmpSR <= "000000000000000000" & BIN;		-- Copy input to lower 10 bits
								when Shift =>
										BCDOUT <= BCDOUT;									-- Output does not change
										tmpSR <= tmpSR(26 downto 0) & '0';					-- Shift left 1 bit

										shiftCount <= shiftCount + '1';					-- Count the shift
								when Check =>
										BCDOUT <= BCDOUT;									-- Output does not change

										-- Not done converting
										if(shiftCount /= X"C") then

												-- Add 3 to thousands place
												if(tmpSR(27 downto 24) >= X"5") then
														tmpSR(27 downto 24) <= tmpSR(27 downto 24) + X"3";
												end if;

												-- Add 3 to hundreds place
												if(tmpSR(23 downto 20) >= X"5") then
														tmpSR(23 downto 20) <= tmpSR(23 downto 20) + X"3";
												end if;
												
												-- Add 3 to tens place
												if(tmpSR(19 downto 16) >= X"5") then
														tmpSR(19 downto 16) <= tmpSR(19 downto 16) + X"3";
												end if;
												
												-- Add 3 to ones place
												if(tmpSR(15 downto 12) >= X"5") then
														tmpSR(15 downto 12) <= tmpSR(15 downto 12) + X"3";
												end if;
										end if;
									
								when Done =>
										BCDOUT <= tmpSR(27 downto 12);				-- Assign output the new BCD values
										tmpSR <= X"0000000";								-- Clear temp shift register
										shiftCount <= "00000"; 							-- Clear shift count
						end case;
						
				end if;
		end process;

		--		  Next State Logic
		NEXT_STATE_LOGIC: process (START, shiftCount, STATE)
		begin
				-- Define default state to avoid latches
				NSTATE <= Idle;

				case (STATE) is
						when Idle =>
								if(START = '1') then
										NSTATE <= Init;
								else
										NSTATE <= Idle;
								end if;
						when Init =>
								NSTATE <= Shift;
						when Shift =>
								NSTATE <= Check;
						when Check =>
								if(shiftCount /= X"C") then
										NSTATE <= Shift;
								else
										NSTATE <= Done;
								end if;
						when Done =>
								NSTATE <= Idle;
						when others =>
								NSTATE <= Idle;
				end case;      
		end process;

end Behavioral;

