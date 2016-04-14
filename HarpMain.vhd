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

    component SPIModule is
        port (
            clock : in Std_logic;
				set 	: in std_logic;
            SS    : out Std_logic; -- slave select bring low to enable sending data
            sclk  : out Std_logic; -- serial clock
            MISO  : in  Std_logic; -- master in
				osig	: out std_logic;
            light : out Std_logic_vector(7 downto 0)
            );
        end component;

    component sevenseg is
  port (
    clock : in std_logic;
    bnum : in std_logic_vector(3 downto 0);
    segment : out std_logic_vector(0 to 6)
  ) ;
end component;


signal tempos : bit_vector(6 downto 0);
signal clock50 : std_logic:= '0';
signal lightLevel : Std_logic_vector(7 downto 0);
signal counter : integer range 1 to 25000 := 1;
signal slowclk : std_logic := '0';
signal act_dis_cnt : std_logic_vector(1 downto 0):= "00"; -- counter to iterate through hex display
signal seg_out1, seg_out2: std_logic_vector(6 downto 0); -- the output from each segment display

begin
     hex1 :  sevenseg
    port map ( clock => clock50,
            bnum => lightLevel(3 downto 0),
            segment  => seg_out1
     ) ;

    hex2 :  sevenseg
    port map ( clock => clock50,
            bnum => lightLevel(7 downto 4),
            segment  => seg_out2
     ) ;


    LSense : SPIModule
    port map (
        clock => clock,
        set=> set,
        SS => ss,
        sclk => sclk,
        miso => miso,
        light => lightLevel,
        osig => light_on
        );

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

clockdiv : process( clock )
begin
  if rising_edge(clock) then
    clock50 <= not clock50;
  end if ;
end process ; -- clockdiv

    clockdiv50 : process( clock50 )
    begin
        if (rising_edge(clock50)) then
            counter <= counter +1;
            if (counter = 25000) then
                counter <= 1;
                slowclk <= not slowclk;
            end if ;
        end if ;
    end process ; -- clockdiv

activedisplay : process( slowclk )
begin
    if (rising_edge(slowclk)) then
        act_dis_cnt <= act_dis_cnt +1;
        case act_dis_cnt is
        when "00" => an <= "1110"; seg <= seg_out1;
        when "01" => an <= "1101"; seg <= seg_out2;
        --when "10" => an <= "1011"; seg <= seg_out1;
        --when "11" => an <= "0111"; seg <= seg_out4;
        when others => an <= "1111";
        end case;
    end if ;

end process ; -- activedisplay

ledout <= tempos;

end architecture ; -- arch