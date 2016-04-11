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

with position select
   light <= '1' when "100000" | "000100",
   '0' when others;

end architecture ; -- arch