library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.std_logic_signed.all;

entity HarpMain is
  port (
  clock         : in std_logic;
  turnon        : in std_logic; -- toggle on switch --
  controlSignal : out std_logic; -- used as a reference for the motor driver --
                                 -- digital inputs. --
  enable        : out std_logic; -- must be high for the motor to move. --
  direction     : out std_logic; -- clockwise or counter clockwise. --
  turn          : out std_logic;  -- toggle to turn in the current direction. --
  olight        : out std_logic  -- laser beam --
  ) ;
end entity ; -- HarpMain

architecture arch of HarpMain is
component motorControl is
  port (
  clock         : in std_logic;
  turnon        : in std_logic;
  controlSignal : out std_logic;
  enable        : out std_logic;
  direction     : out std_logic;
  turn          : out std_logic;
  position      : out bit_vector( 5 downto 0 );
  stepclk       : out std_logic;
  ostepclk      : out std_logic
  ) ;
  end component;

component lightControl is
  port (
    clk : in std_logic;
  position : in bit_vector( 5 downto 0);
  light : out std_logic
  ) ;
  end component;

signal tempos : bit_vector(5 downto 0);
signal tempclk : std_logic;
signal clk200 : std_logic;
begin
MC : motorControl
port map (
  clock => clock,
  turnon => turnon,
  controlSignal => controlSignal,
  enable => enable,
  direction => direction,
  turn => turn,
  position => tempos,
  stepclk =>clk200,
  ostepclk => tempclk
  );

lg : lightControl
port map (
  clk => tempclk,
  position => tempos,
  light => olight
  );

end architecture ; -- arch