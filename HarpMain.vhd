library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.std_logic_signed.all;

entity HarpMain is
	  port (
	  clock         : in std_logic;
	  reset			 : in STD_LOGIC;

	  --Motor Control Ports
	  turnon        : in std_logic; -- toggle on switch --
	  enable        : out std_logic; -- must be high for the motor to move. --
	  direction     : out std_logic; -- clockwise or counter clockwise. --
	  turn          : out std_logic;  -- toggle to turn in the current direction. --
	  controlSignal : out std_logic; -- used as a reference for the motor driver --
												-- digital inputs. --

	  --Laser Ports
	  olight        : out std_logic;  -- laser beam --

	  --Audio Output Ports
	  i2s_mclk      : out STD_LOGIC;
	  i2s_lrclk     : out STD_LOGIC;
	  i2s_sclk      : out STD_LOGIC;
	  i2s_data      : out STD_LOGIC;
	  swts			 : in bit_vector(3 downto 0);

	  --Light Sensor Ports
	  set				: in STD_LOGIC;
	  miso 			: in STD_LOGIC;
	  ss				: out STD_LOGIC;
	  sclk			: out STD_LOGIC;
	  an				: out STD_LOGIC_VECTOR(3 downto 0);
	  seg 			: out STD_LOGIC_VECTOR(6 downto 0);


    --position to leds
    ledout : out bit_vector(6 downto 0)
  ) ;
end entity ; -- HarpMain

architecture arch of HarpMain is

	constant NUM_STRS : integer := 3;
	--signal temp  : STD_LOGIC;
	--signal temp2 : STD_LOGIC_VECTOR(2 downto 0);

	signal light_on : STD_LOGIC;

	component audioOut
	  port (clk     : in  STD_LOGIC;
        reset     : in std_logic;
			  motor   : in  bit_vector(6 downto 0);
			  light   : in  STD_LOGIC; --enable signal
			  iopins    : out STD_LOGIC_VECTOR(3 downto 0)); --
	end component;

	component motorControl is
	  port (
	  clock         : in std_logic;
	  turnon        : in std_logic;
    reset         : in std_logic;
	  controlSignal : out std_logic;
	  enable        : out std_logic;
	  direction     : out std_logic;
	  turn          : out std_logic;
	  position      : out bit_vector( 6 downto 0 )
	  ) ;
  end component;

	component lightControl is
	  port (
		 --clk : in std_logic;
	  position : in bit_vector( 6 downto 0);
	  light : out std_logic
	  ) ;
  end component;

  component PmodALS_Demo is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           MISO : in  STD_LOGIC;
           SW : in  STD_LOGIC_VECTOR (2 downto 0);
			  SET : in STD_LOGIC;
           SS : out  STD_LOGIC;
           MOSI : out  STD_LOGIC;
           SCLK : out  STD_LOGIC;
			  OSIG : out STD_LOGIC;
           LED : out  STD_LOGIC_VECTOR (2 downto 0);
           AN : out  STD_LOGIC_VECTOR (3 downto 0);
           SEG : out  STD_LOGIC_VECTOR (6 downto 0));
	end component;

	signal tempos : bit_vector(6 downto 0);
  signal clock50 : std_logic:= '0';

begin
	MC : motorControl
	port map (
	  clock => clock,
	  turnon => turnon,
    reset => reset,
	  controlSignal => controlSignal,
	  enable => enable,
	  direction => direction,
	  turn => turn,
	  position => tempos
	  );

	lg : lightControl
	port map (
	  --clk => clock,
	  position => tempos,
	  light => olight
	  );

	i2s_int : audioOut port map
        (clk=>clock50,
          reset=> reset,
         motor => tempos,
         light=>light_on,
         iopins(0)=>i2s_mclk,
         iopins(1)=>i2s_lrclk,
         iopins(2)=>i2s_sclk,
         iopins(3)=>i2s_data);

--	fakecon(0) <= swts(3);
--	fakecon(3) <= swts(2);
--	fakecon(6) <= swts(1);

	als_int : PmodALS_Demo port map
				(CLK=>clock,
				 RST=>reset,
				 MISO=>miso,
				 SW=>"000",
				 SET=>set,
				 SS=>ss,
				 --MOSI=>temp,
				 SCLK=>sclk,
				 OSIG=>light_on,
				 --LED=>temp2,
				 AN=>an,
				 SEG=>seg);

clockdiv : process( clock )
begin
  if rising_edge(clock) then
    clock50 <= not clock50;
  end if ;
end process ; -- clockdiv

ledout <= tempos;

end architecture ; -- arch