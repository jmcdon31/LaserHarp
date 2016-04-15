library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity sevenseg is
  port (
    clock : in std_logic;
    bnum : in std_logic_vector(3 downto 0);
    segment : out std_logic_vector(0 to 6)
  ) ;
end entity ; -- sevenseg

architecture arch of sevenseg is
begin


    process(clock, bnum) begin
        if (rising_edge(clock)) then
            case bnum is
                when "0000"=> segment <="0000001";
                when "0001"=> segment <="1001111";
                when "0010"=> segment <="0010010";
                when "0011"=> segment <="0000110";
                when "0100"=> segment <="1001100";
                when "0101"=> segment <="0100100";
                when "0110"=> segment <="0100000";
                when "0111"=> segment <="0001111";
                when "1000"=> segment <="0000000";
                when "1001"=> segment <="0000100";
                when "1010"=> segment <="0001000";
                when "1011"=> segment <="1100000";
                when "1100"=> segment <="0110001";
                when "1101"=> segment <="1000010";
                when "1110"=> segment <="0110000";
                when "1111"=> segment <="0111000";
                when others => segment <="0000001";
            end case;
        end if;
    end process;

end architecture ; -- arch