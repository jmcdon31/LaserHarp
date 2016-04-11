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
  olight        : out std_logic;  -- laser beam --

  swts      : in  STD_LOGIC_VECTOR(7 downto 0);
  btn     : in STD_LOGIC;
  i2s_mclk    : out STD_LOGIC;
  i2s_lrclk : out STD_LOGIC;
  i2s_sclk    : out STD_LOGIC;
  i2s_data    : out STD_LOGIC
  ) ;
end entity ; -- HarpMain

architecture arch of HarpMain is

constant NUM_STRS : integer := 3;

component i2s_top
  port (clk   : in  STD_LOGIC;
      numStr  : in  integer;
      motor   : in  STD_LOGIC_VECTOR(7 downto 0);
      light   : in  STD_LOGIC;
      JA    : out STD_LOGIC_VECTOR(3 downto 0));
end component;

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

i2s_int : i2s_top port map
        (clk=>clock,
         numStr=>NUM_STRS,
         motor(0)=>swts(0),
         motor(1)=>swts(1),
         motor(2)=>swts(2),
         motor(3)=>swts(3),
         motor(4)=>swts(4),
         motor(5)=>swts(5),
         motor(6)=>swts(6),
         motor(7)=>swts(7),
         light=>btn,
         JA(0)=>i2s_mclk,
         JA(1)=>i2s_lrclk,
         JA(2)=>i2s_sclk,
         JA(3)=>i2s_data);


end architecture ; -- arch