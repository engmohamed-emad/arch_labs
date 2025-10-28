library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity elevator_ctrl_tb_fast is
end entity;

architecture tb of elevator_ctrl_tb_fast is
  constant N : integer := 10;

  -- testbench signals
  signal clk : std_logic := '0';
  signal reset : std_logic := '1';
  signal floor_buttons : std_logic_vector(N-1 downto 0) := (others => '0');

  -- outputs from DUT
  signal current_floor_leds : std_logic_vector(3 downto 0);
  signal seg_out : std_logic_vector(6 downto 0);
  signal door_led, moving_led, dir_up : std_logic;
begin
  ----------------------------------------------------------------------------
  -- DUT
  -- override CLOCK_FREQ generic so the internal 1-second divider is FAST in sim.
  -- In hardware keep CLOCK_FREQ = 50_000_000 for actual FPGA synthesis.
  ----------------------------------------------------------------------------
  dut: entity work.elevator_ctrl
    generic map (
      N_FLOORS => N,
      CLOCK_FREQ => 1000    -- <<<< small value for fast simulation
    )
    port map (
      clk => clk,
      reset => reset,
      floor_buttons => floor_buttons,
      current_floor_leds => current_floor_leds,
      seg_out => seg_out,
      door_led => door_led,
      moving_led => moving_led,
      dir_led_up => dir_up
    );

  ----------------------------------------------------------------------------
  -- 50 MHz clock generator (testbench)
  ----------------------------------------------------------------------------
  clk_proc: process
  begin
    while true loop
      clk <= '0'; wait for 10 ns;
      clk <= '1'; wait for 10 ns;
    end loop;
  end process;

  ----------------------------------------------------------------------------
  -- Stimulus process
  -- NOTE: use simulated 'sec' waits in this TB. Because CLOCK_FREQ is small,
  -- those simulated seconds happen quickly in ModelSim.
  ----------------------------------------------------------------------------
  stim_proc: process
  begin
    -- release reset after a short time
    wait for 100 ns;
    reset <= '0';

    -- Test 1: request floor 3 from initial floor 0
    floor_buttons <= (others => '0');
    floor_buttons(3) <= '1';
    -- keep request asserted for a brief time (simulated)
    wait for 1 sec;   -- with CLOCK_FREQ=1000 this will run quickly
    floor_buttons(3) <= '0';

    -- Wait enough simulated time for elevator to move and doors to open
    -- (movement is 2 simulated seconds per floor in the design spec)
    wait for 6 sec;

    -- Quick check: door should be open at some point after arrival.
    -- (assert may fire if design doesn't match expectation)
    assert door_led = '1'
      report "Test1: door_led not '1' after arrival to floor 3" severity warning;

    -- Test 2: multiple simultaneous requests
    floor_buttons <= (others => '0');
    floor_buttons(7) <= '1';
    floor_buttons(2) <= '1';
    floor_buttons(4) <= '1';

    -- allow time for servicing the queue (tune as necessary)
    wait for 40 sec;

    -- end simulation
    wait;
  end process;

end architecture;
