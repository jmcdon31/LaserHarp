library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;

entity lightControl is
  port (
  clk : in std_logic;
  position : in bit_vector( 5 downto 0);
  light : out std_logic
  ) ;
end entity ; -- lightControl

architecture arch of lightControl is
signal tmplight : std_logic:= '0';
begin
--  lightturn : process( clk )
--  begin
--    if (rising_edge(clk)) then
--      if (position = "100000" or position = "000100" ) then
--        tmplight <= '1';
--      else
--        tmplight <= '0';
--      end if ;
--    end if ;
--    --if (falling_edge(clk)) then
--    --  tmplight <= '0';
--    --end if ;
--  end process ; -- lightturn
--light <= tmplight; -- when clk = '1' else '0'; --
--light <= '1';
with position select
   light <= '1' when "100000" | "000100",
   '0' when others;

end architecture ; -- arch