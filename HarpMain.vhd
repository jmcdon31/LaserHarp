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

  btn           : in STD_LOGIC;
  i2s_mclk      : out STD_LOGIC;
  i2s_lrclk     : out STD_LOGIC;
  i2s_sclk      : out STD_LOGIC;
  i2s_data      : out STD_LOGIC
  ) ;
end entity ; -- HarpMain

architecture arch of HarpMain is

constant NUM_STRS : integer := 3;

component audioOut
  port (clk   : in  STD_LOGIC;
      motor   : in  bit_vector(6 downto 0);
      light   : in  STD_LOGIC; --enable signal
      iopins    : out STD_LOGIC_VECTOR(3 downto 0)); --
end component;

component motorControl is
  port (
  clock         : in std_logic;
  turnon        : in std_logic;
  controlSignal : out std_logic;
  enable        : out std_logic;
  direction     : out std_logic;
  turn          : out std_logic;
  position      : out bit_vector( 6 downto 0 )
  ) ;
  end component;

component lightControl is
  port (
    clk : in std_logic;
  position : in bit_vector( 6 downto 0);
  light : out std_logic
  ) ;
  end component;

signal tempos : bit_vector(6 downto 0);

begin
MC : motorControl
port map (
  clock => clock,
  turnon => turnon,
  controlSignal => controlSignal,
  enable => enable,
  direction => direction,
  turn => turn,
  position => tempos
  );

lg : lightControl
port map (
  clk => clock,
  position => tempos,
  light => olight
  );

i2s_int : audioOut port map
        (clk=>clock,
         motor => tempos,
         light=>btn,
         iopins(0)=>i2s_mclk,
         iopins(1)=>i2s_lrclk,
         iopins(2)=>i2s_sclk,
         iopins(3)=>i2s_data);


end architecture ; -- arch