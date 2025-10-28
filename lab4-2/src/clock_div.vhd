library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_div is
  generic (
    CLOCK_FREQ : integer := 50000000  -- 50 MHz
  );
  port (
    clk      : in  std_logic;
    reset    : in  std_logic;
    sec_tick : out std_logic  -- pulses high for 1 cycle when 1 second elapsed
  );
end entity;

architecture rtl of clock_div is
  signal cnt : unsigned(31 downto 0) := (others => '0');
  constant MAXCNT : unsigned(31 downto 0) := to_unsigned(CLOCK_FREQ-1, 32);
begin
  process(clk, reset)
  begin
    if reset = '1' then
      cnt <= (others => '0');
      sec_tick <= '0';
    elsif rising_edge(clk) then
      if cnt = MAXCNT then
        cnt <= (others => '0');
        sec_tick <= '1';
      else
        cnt <= cnt + 1;
        sec_tick <= '0';
      end if;
    end if;
  end process;
end architecture;
