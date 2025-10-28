-- filepath: d:\assignments\vhdl\arch_labs\lab4\testbench.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity system_tb is
end entity;

architecture tb of system_tb is

    signal clk         : std_logic := '0';
    signal reset       : std_logic := '0';
    signal reset_btns  : std_logic := '0';
    signal buttonsIn   : std_logic_vector(9 downto 0) := (others => '0');
    signal floor       : unsigned(3 downto 0);
    signal door_open   : std_logic;
    signal moving_up   : std_logic;
    signal moving_down : std_logic;

    constant clk_period : time := 20 ns; -- 50MHz

begin

    uut: entity work.top_elevator
        port map (
            clk         => clk,
            reset       => reset,
            reset_btns  => reset_btns,
            buttonsIn   => buttonsIn,
            floor       => floor,
            door_open   => door_open,
            moving_up   => moving_up,
            moving_down => moving_down
        );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        -- Reset system
        reset <= '1';
        reset_btns <= '1';
        wait for clk_period * 5;
        reset <= '0';
        reset_btns <= '0';
        wait for clk_period * 5;

        -- Test 1: Request ground floor (already there, should open door)
        buttonsIn <= "0000000001";
        wait for clk_period * 5;
        buttonsIn <= (others => '0');
        wait for 3 sec;

        -- Test 2: Request top floor (9)
        buttonsIn <= "1000000000";
        wait for clk_period * 5;
        buttonsIn <= (others => '0');
        wait for 25 sec;

        -- Test 3: Request middle floor (5) while at floor 9 (should go down)
        buttonsIn <= "0000100000";
        wait for clk_period * 5;
        buttonsIn <= (others => '0');
        wait for 15 sec;

        -- Test 4: Multiple requests up (2, 4, 7) from ground floor
        reset <= '1'; wait for clk_period * 5; reset <= '0'; wait for clk_period * 5;
        buttonsIn <= "0100100100";
        wait for clk_period * 5;
        buttonsIn <= (others => '0');
        wait for 30 sec;

        -- Test 5: Multiple requests down (3, 1) from floor 7
        buttonsIn <= "0000001000";
        wait for clk_period * 5;
        buttonsIn <= "0000000010";
        wait for clk_period * 5;
        buttonsIn <= (others => '0');
        wait for 20 sec;

        -- Test 6: Request change direction (up then down)
        reset <= '1'; wait for clk_period * 5; reset <= '0'; wait for clk_period * 5;
        buttonsIn <= "0000001000";
        wait for clk_period * 5;
        buttonsIn <= "0000100000";
        wait for clk_period * 5;
        buttonsIn <= (others => '0');
        wait for 20 sec;

        -- Test 7: Simultaneous requests (0 and 9)
        reset <= '1'; wait for clk_period * 5; reset <= '0'; wait for clk_period * 5;
        buttonsIn <= "1000000001";
        wait for clk_period * 5;
        buttonsIn <= (others => '0');
        wait for 30 sec;

        -- Test 8: Door timing (should stay open for at least 2 sec)
        buttonsIn <= "0000000001";
        wait for clk_period * 5;
        buttonsIn <= (others => '0');
        wait for 5 sec;

        wait;
    end process;

end architecture;