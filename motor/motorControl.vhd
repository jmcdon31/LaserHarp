library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.std_logic_unsigned.all ;

entity motorControl is
  port (
  clock         : in std_logic;
  turnon        : in std_logic; -- toggle on switch --
  reset         : in std_logic;
  controlSignal : out std_logic; -- used as a reference for the motor driver --
                                 -- digital inputs. --
  enable        : out std_logic; -- must be high for the motor to move. --
  direction     : out std_logic; -- clockwise or counter clockwise. --
  turn          : out std_logic;  -- toggle to turn in the current direction. --
  position      : out bit_vector( 6 downto 0 )
  ) ;
end entity ; -- motorControl


architecture arch of motorControl is
-- we need a clock rate of about 5ms. This corresponds to a frequency of 200 hz.
-- 50Mhz / 200 hz  = 250000. So we only want to TOGGLE for half that time --
signal clk200   : std_logic:='0';
signal clk20    : std_logic:='0';
signal counter1 : integer range 1 to 1250000:= 1;
signal counter2 : integer range 1 to 125000:= 1;
signal motorpos : bit_vector( 6 downto 0 ) := "0000001";
signal outdirection : std_logic := '1'; -- left =1 / 0 = right
signal enstep : std_logic := '1';
signal delay : boolean := false;
begin
  -- the following process divides the clock into steps --
  -- NOTE: The clock has a 50% duty cycle --
  divclock : process( clock )
  begin
    if (rising_edge(clock)) then
      counter1 <= counter1 +1;
      counter2 <= counter2 +1;
      if (counter1 = 1250000) then
        counter1 <= 1;
        clk200 <= not clk200;
      end if ;
      if (counter2 = 125000) then
        counter2 <= 1;
        clk20 <= not clk20;
      end if ;
    end if ;
  end process ; -- divclock

  trackPos : process( clk200 )
  begin
    if (rising_edge(clk200)) then
      if (outdirection = '1') then
        motorpos <= motorpos rol 1;
      else
        motorpos <= motorpos ror 1;
      end if ;
    end if ;
  end process ; -- trackPos

  trackdirection : process( clk20 )
  begin
    if (rising_edge(clk20)) then
      if (motorpos = "1000000") then
        outdirection <= '0';
      elsif (motorpos = "0000001") then
        outdirection <= '1';
        if (turnon = '0') then
          enstep <= '0';
        elsif (turnon = '1' and clk200 = '0') then
          enstep <= '1';
          outdirection <= '1';
        end if ;
      end if ;
    end if ;
  end process ; -- trackdirection


  direction <= outdirection ;
  controlSignal <= '1'; -- the control signal is a reference that is always HIGH. --
  enable <= '1' and not reset;
  position <= motorpos;
  turn <= clk200 and enstep;
end architecture ; -- arch