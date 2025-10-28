library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity elevator_ctrl is
  generic (N_FLOORS : integer := 10; CLOCK_FREQ : integer := 100);
  port (
    clk   : in std_logic;
    reset : in std_logic;
    floor_buttons : in std_logic_vector(N_FLOORS-1 downto 0);
    -- outputs to LED and 7-seg
    current_floor_leds : out std_logic_vector(3 downto 0);
    seg_out : out std_logic_vector(6 downto 0);
    door_led : out std_logic;
    moving_led : out std_logic;
    dir_led_up : out std_logic
  );
end entity;

architecture top of elevator_ctrl is
  signal sec_tick : std_logic;
  signal current_floor : integer range 0 to N_FLOORS-1 := 0;
  signal req_vector : std_logic_vector(N_FLOORS-1 downto 0);
begin
  -- instantiate clock divider
  clkdiv: entity work.clock_div
    generic map (CLOCK_FREQ => CLOCK_FREQ)
    port map (clk => clk, reset => reset, sec_tick => sec_tick);

  -- combine floor buttons into request vector (simple OR for inside + hall calls)
  req_vector <= floor_buttons; -- expand if you have other call buttons

  unit: entity work.unit_control
    generic map (N_FLOORS => N_FLOORS)
    port map (
      clk => clk, reset => reset, sec_tick => sec_tick,
      req_vector => req_vector,
      current_floor_out => current_floor,
      door_open => door_led,
      moving => moving_led,
      dir_up => dir_led_up
    );

  -- connect floor to SSD (convert integer to binary then to seg)
  -- assume binary_to_ssd component exists
  -- convert integer to unsigned 4-bit
  current_floor_leds <= std_logic_vector(to_unsigned(current_floor,4));
  -- binary_to_ssd instantiation here to set seg_out (not shown)
end architecture;
