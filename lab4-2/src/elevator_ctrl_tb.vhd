library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity elevator_ctrl_tb is
end entity;

architecture tb of elevator_ctrl_tb is
  constant N : integer := 10;
  signal clk : std_logic := '0';
  signal reset : std_logic := '1';
  signal floor_buttons : std_logic_vector(N-1 downto 0) := (others => '0');
  signal current_floor_leds : std_logic_vector(3 downto 0);
  signal seg_out : std_logic_vector(6 downto 0);
  signal door_led, moving_led, dir_up : std_logic;
begin
  -- DUT
  dut: entity work.elevator_ctrl
    generic map (N_FLOORS => N, CLOCK_FREQ => 100)
    port map (
      clk => clk, reset => reset, floor_buttons => floor_buttons,
      current_floor_leds => current_floor_leds, seg_out => seg_out,
      door_led => door_led, moving_led => moving_led, dir_led_up => dir_up
    );

  -- 50 MHz clock
  clk_proc: process
  begin
    while true loop
      clk <= '0'; wait for 10 ns;
      clk <= '1'; wait for 10 ns;
    end loop;
  end process;

  stim_proc: process
  begin
    -- release reset
    wait for 100 ns;
    reset <= '0';
    -- Test 1: request floor 3 from initial floor 0
    floor_buttons <= (others => '0');
    floor_buttons(3) <= '1';
    wait for 2 ms; -- small wait to let signals propagate
    -- now wait until door opens and assert arrival conditions using asserts
    wait for 15 sec; -- in simulation you might accelerate sec_tick; otherwise long
    -- check assertions: door_led asserted after arrival etc.
    assert door_led = '1' report "Door not open at arrival" severity error;

    -- Additional tests: multiple simultaneous requests
    floor_buttons <= (others => '0');
    floor_buttons(7) <= '1';
    floor_buttons(2) <= '1';
    floor_buttons(4) <= '1';
    wait for 200 sec; -- allow time for full service (or accelerate)
    -- check that all requests cleared (you need visibility of req_vector in DUT or add status outputs)
    wait;
  end process;
end architecture;


















