library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;

entity lightControl is
  port (
  clk : in std_logic;
  position : in bit_vector( 6 downto 0);
  light : out std_logic
  ) ;
end entity ; -- lightControl

architecture arch of lightControl is
begin

with position select
   light <= '1' when "0001000" | "1000000" | "0000001", --| "0001000" | "0000001",
   '0' when others;

end architecture ; -- arch