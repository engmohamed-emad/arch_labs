library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_elevator is
end tb_elevator;

architecture behavior of tb_elevator is
    signal clk            : std_logic := '0';
    signal reset          : std_logic := '0';
    signal submitRequest  : std_logic := '0';
    signal request        : std_logic_vector(3 downto 0) := (others => '0');
    signal isDoorOpen     : std_logic;
    signal isMoving       : std_logic;
    signal curFloor       : std_logic_vector(3 downto 0);
    signal curFloor7seg   : std_logic_vector(6 downto 0);

    constant clk_period : time := 10 ns;
begin

    -- Clock
    clk_process: process
    begin
        loop
            clk <= '0'; wait for clk_period/2;
            clk <= '1'; wait for clk_period/2;
        end loop;
    end process;

    -- Instantiate DUT
    uut: entity work.elevator
        port map(
            clk => clk,
            reset => reset,
            submitRequest => submitRequest,
            request => request,
            isDoorOpen => isDoorOpen,
            isMoving => isMoving,
            curFloor => curFloor,
            curFloor7seg => curFloor7seg
        );

    -- Stimulus
    stim_proc: process
    begin
        -- Reset
        reset <= '1'; wait for 50 ns;
        reset <= '0'; wait for 50 ns;

        -- Test requests
        request <= "0011"; submitRequest <= '1'; wait for 20 ns;
        submitRequest <= '0'; wait for 200 ns;

        request <= "0101"; submitRequest <= '1'; wait for 20 ns;
        submitRequest <= '0'; wait for 200 ns;

        request <= "0010"; submitRequest <= '1'; wait for 20 ns;
        submitRequest <= '0'; wait for 200 ns;

        request <= "1000"; submitRequest <= '1'; wait for 20 ns;
        submitRequest <= '0'; wait for 200 ns;

        -- Finish simulation
        assert false report "Simulation finished" severity failure;
    end process;

end behavior;
