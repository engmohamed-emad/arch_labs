LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY elevator_tb IS
END elevator_tb;

ARCHITECTURE test OF elevator_tb IS

    SIGNAL clk           : STD_LOGIC := '0';
    SIGNAL reset         : STD_LOGIC := '0';
    SIGNAL submitRequest : STD_LOGIC := '0';
    SIGNAL request       : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');

    SIGNAL isDoorOpen    : STD_LOGIC;
    SIGNAL isMoving      : STD_LOGIC;
    SIGNAL curFloor      : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL curFloor7seg  : STD_LOGIC_VECTOR(6 DOWNTO 0);

    CONSTANT clk_period : TIME := 10 ns;

    -- Procedure to submit floor to DUT
    PROCEDURE submit_floor(
        floor_num : IN INTEGER;
        SIGNAL req : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL submit : OUT STD_LOGIC
    ) IS
    BEGIN
        req <= STD_LOGIC_VECTOR(to_unsigned(floor_num, 4));
        submit <= '1';
        WAIT FOR clk_period;
        submit <= '0';
        WAIT FOR clk_period;
    END PROCEDURE;

BEGIN

    uut : ENTITY work.elevator
        PORT MAP(
            clk           => clk,
            reset         => reset,
            submitRequest => submitRequest,
            request       => request,
            isDoorOpen    => isDoorOpen,
            isMoving      => isMoving,
            curFloor      => curFloor,
            curFloor7seg  => curFloor7seg
        );

    clk <= NOT clk AFTER clk_period / 2;

    stim_proc : PROCESS
    BEGIN

        reset <= '0';
        WAIT FOR 100 ns;
        reset <= '1';
        WAIT FOR 50 ns;

        ------------------------------------------------------------
        -- VALID REQUEST: GO TO FLOOR 2
        ------------------------------------------------------------
        submit_floor(2, request, submitRequest);
        WAIT FOR 6000 ns;

        ASSERT curFloor = "0010"
            REPORT "ERROR: Elevator failed to reach floor 2"
            SEVERITY ERROR;

        ------------------------------------------------------------
        -- INVALID REQUEST: FLOOR 6 (OUT OF BOUNDS)
        ------------------------------------------------------------
        submit_floor(6, request, submitRequest);
        WAIT FOR 5000 ns;

        -- Elevator must NOT go to floor 6
        ASSERT curFloor /= "0110"
            REPORT "ERROR: Elevator INCORRECTLY went to INVALID floor 6!"
            SEVERITY ERROR;

        -- It must remain on floor 2
        ASSERT curFloor = "0010"
            REPORT "ERROR: Elevator moved after invalid request!"
            SEVERITY ERROR;

        WAIT;
    END PROCESS;

END ARCHITECTURE test;
