library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.std_logic_unsigned.all ;

entity motorControl is
  port (
  clock         : in std_logic; -- MUST take 50MHz clock input --
  turnon        : in std_logic; -- toggle on switch --
  controlSignal : out std_logic; -- used as a reference for the motor driver --
                                 -- digital inputs. --
  enable        : out std_logic; -- must be high for the motor to move. --
  direction     : out std_logic; -- clockwise or counter clockwise. --
  turn          : out std_logic;  -- toggle to turn in the current direction. --
  position      : out bit_vector( 5 downto 0 );
  stepclk       : out std_logic;
  ostepclk      : out std_logic
  ) ;
end entity ; -- motorControl


architecture arch of motorControl is
-- we need a clock rate of about 5ns. This corresponds to a frequency of 200 hz.
-- 50Mhz / 200 hz  = 250000. So we only want to TOGGLE for half that time --
signal clk200   : std_logic:='0';
signal oclk200   : std_logic:='1';
signal clockCount : integer range 1 to 125000:= 1;
signal motorpos : bit_vector( 5 downto 0 ) := "100000";
signal outdirection : std_logic := '0';
signal enstep : std_logic := '1';
signal right : boolean := true;
begin
  -- the following process divides the clock into 5ms steps --
  -- NOTE: The clock has a 50% duty cycle --
  divclock : process( clock )
  variable offsetclock : integer;
  begin
    offsetclock := clockCount + 62500;
    if (rising_edge(clock)) then
      if (clockCount = 125000) then
        clockCount <= 1;
        clk200 <= not clk200;
      else
        clockCount <= clockCount +1;
      end if ;
      if (offsetclock = 125000) then
        oclk200 <= not oclk200;
      end if ;
    end if ;
  end process ; -- divclock

  trackPos : process( clk200 )
  begin
    if (rising_edge(clk200)) then
      if ( motorpos = "000001") then
        outdirection <= not outdirection;
        right <= not right;
        if right = true then
          if (turnon = '0') then
            enstep <= '0';
          else
            enstep <='1';
          end if ;
        end if ;
      end if ;
      motorpos <= motorpos ror 1;
    end if ;
  end process ; -- trackPos


  direction <= outdirection ;
  controlSignal <= '1'; -- the control signal is a reference that is always HIGH. --
  enable <= enstep;
  position <= motorpos;
  turn <= clk200; --when rotateon = '1' else '0'; --
end architecture ; -- arch