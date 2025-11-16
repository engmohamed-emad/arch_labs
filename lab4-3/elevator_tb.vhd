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

    clk <= NOT clk AFTER clk_period/2;

    stim_proc : PROCESS
    BEGIN

        reset <= '1';
        WAIT FOR 100 ns;
        reset <= '0';
        WAIT FOR 50 ns;

        submit_floor(5, request, submitRequest);
        WAIT FOR 6000 ns;
        ASSERT curFloor = "0101" SEVERITY ERROR;

        submit_floor(2, request, submitRequest);
        WAIT FOR 5000 ns;
        ASSERT curFloor = "0010" SEVERITY ERROR;

        submit_floor(2, request, submitRequest);
        WAIT FOR 500 ns;
        ASSERT isDoorOpen = '1' SEVERITY ERROR;
        WAIT FOR 2500 ns;

        submit_floor(7, request, submitRequest);
        submit_floor(4, request, submitRequest);
        WAIT FOR 3000 ns;
        ASSERT curFloor = "0100" SEVERITY ERROR;
        WAIT FOR 5000 ns;
        ASSERT curFloor = "0111" SEVERITY ERROR;

        submit_floor(3, request, submitRequest);
        submit_floor(5, request, submitRequest);
        WAIT FOR 3000 ns;
        ASSERT curFloor = "0101" SEVERITY ERROR;
        WAIT FOR 4000 ns;
        ASSERT curFloor = "0011" SEVERITY ERROR;

        submit_floor(6, request, submitRequest);
        submit_floor(1, request, submitRequest);
        WAIT FOR 5000 ns;
        ASSERT curFloor = "0110" SEVERITY ERROR;
        WAIT FOR 7000 ns;
        ASSERT curFloor = "0001" SEVERITY ERROR;

        submit_floor(8, request, submitRequest);
        WAIT FOR 2000 ns;
        submit_floor(5, request, submitRequest);
        WAIT FOR 6000 ns;
        ASSERT curFloor = "0101" SEVERITY ERROR;
        WAIT FOR 5000 ns;
        ASSERT curFloor = "1000" SEVERITY ERROR;

        submit_floor(3, request, submitRequest);
        submit_floor(6, request, submitRequest);
        submit_floor(9, request, submitRequest);
        WAIT FOR 7000 ns;
        ASSERT curFloor = "0011" SEVERITY ERROR;
        WAIT FOR 5000 ns;
        ASSERT curFloor = "0110" SEVERITY ERROR;
        WAIT FOR 5000 ns;
        ASSERT curFloor = "1001" SEVERITY ERROR;

        submit_floor(0, request, submitRequest);
        WAIT FOR 11000 ns;
        ASSERT curFloor = "0000" SEVERITY ERROR;
        submit_floor(9, request, submitRequest);
        WAIT FOR 11000 ns;
        ASSERT curFloor = "1001" SEVERITY ERROR;

        submit_floor(5, request, submitRequest);
        WAIT FOR 6000 ns;
        submit_floor(2, request, submitRequest);
        submit_floor(4, request, submitRequest);
        submit_floor(7, request, submitRequest);
        submit_floor(8, request, submitRequest);
        WAIT FOR 15000 ns;

        submit_floor(3, request, submitRequest);
        WAIT FOR 3000 ns;
        submit_floor(6, request, submitRequest);
        submit_floor(6, request, submitRequest);
        submit_floor(6, request, submitRequest);
        WAIT FOR 5000 ns;
        ASSERT curFloor = "0110" SEVERITY ERROR;

        submit_floor(0, request, submitRequest);
        WAIT FOR 8000 ns;
        FOR i IN 1 TO 9 LOOP
            submit_floor(i, request, submitRequest);
        END LOOP;
        WAIT FOR 25000 ns;

        submit_floor(5, request, submitRequest);
        WAIT FOR 6000 ns;
        WAIT FOR 100 ns;
        submit_floor(3, request, submitRequest);
        WAIT FOR 5000 ns;

        FOR i IN 0 TO 20 LOOP
            submit_floor((i*7) MOD 10, request, submitRequest);
            WAIT FOR 200 ns;
        END LOOP;
        WAIT FOR 30000 ns;

        submit_floor(9, request, submitRequest);
        WAIT FOR 2000 ns;
        reset <= '1';
        WAIT FOR 100 ns;
        reset <= '0';
        WAIT FOR 50 ns;
        ASSERT curFloor = "0000" SEVERITY ERROR;
        ASSERT isDoorOpen = '0' SEVERITY ERROR;

        WAIT;
    END PROCESS;

END ARCHITECTURE test;
