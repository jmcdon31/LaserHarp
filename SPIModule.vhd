library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity SPIModule is
  port (
    clock : in Std_logic;
    set:    in Std_logic;
    SS    : out Std_logic; -- slave select bring low to enable sending data
    sclk  : out Std_logic; -- serial clock
    MISO  : in  Std_logic; -- master in
    light : out Std_logic_vector(7 downto 0);
    OSIG : out Std_logic
  ) ;
end entity ; -- SPIModule

architecture arch of SPIModule is
signal lightStream : Std_logic_vector(7 downto 0);
signal clk4        : Std_logic := '0';
signal ccounter    : integer range 0 to 12:= 0;
signal streamCounter : integer range 0 to 14;
signal chipSel      : Std_logic := '1';
signal baseline     : Std_logic_vector(7 downto 0):="00000000";
signal tmplight 		: Std_logic_vector(7 downto 0):="00000000";
begin

sclk <= clk4;
SS <= chipSel;
clkDiv4Mhz : process( clock )
begin
    if (rising_edge(clock)) then
        ccounter <= ccounter +1;
        if (ccounter = 12) then
            clk4 <= not clk4;
            ccounter <= 0;
        end if;
    end if ;
end process ; -- clkDiv4Mhz


identifier : process( clk4 )
begin
    if (rising_edge(clk4)) then
        streamCounter <= streamCounter+1;
        if (streamCounter = 14) then
            chipSel <= '1';
            streamCounter <= 0;
            light <= lightStream;
				tmplight <= lightStream;
        elsif (streamCounter = 0) then
            chipSel <= '0';
        elsif (streamCounter >=3 and streamCounter <= 10) then
            lightStream <= lightStream(6 downto 0) & MISO;
        end if ;
    end if ;
end process ; -- identifier

            baseline <= tmplight when SET = '0'; -- else
                --baseline;

            OSIG <= '1' when SET = '1'
                        and (to_integer(signed(tmplight)) > to_integer(signed(baseline))) else
                    '0';


end architecture ; -- arch