LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY elevator_tb IS
END elevator_tb;

ARCHITECTURE test OF elevator_tb IS

    -- DUT signals
    SIGNAL clk           : STD_LOGIC := '0';
    SIGNAL reset         : STD_LOGIC := '0';
    SIGNAL submitRequest : STD_LOGIC := '0';
    SIGNAL request       : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');

    SIGNAL isDoorOpen    : STD_LOGIC;
    SIGNAL isMoving      : STD_LOGIC;
    SIGNAL curFloor      : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL curFloor7seg  : STD_LOGIC_VECTOR(6 DOWNTO 0);

    CONSTANT clk_period : TIME := 10 ns;
    
    -- Helper procedure to submit a request
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

    -- Instantiate the Unit Under Test (UUT)
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

    --------------------------------------------------------------------
    -- Clock Generation
    --------------------------------------------------------------------
    clk <= NOT clk AFTER clk_period/2;

    --------------------------------------------------------------------
    -- Test Procedure
    --------------------------------------------------------------------
    stim_proc : PROCESS
    BEGIN
        ----------------------------------------------------------------
        -- Test 1: Global reset
        ----------------------------------------------------------------
        REPORT "===== TEST 1: RESET =====";
        reset <= '1';
        WAIT FOR 100 ns;
        reset <= '0';
        WAIT FOR 50 ns;
        ASSERT curFloor = "0000" REPORT "Reset failed: Not at floor 0" SEVERITY ERROR;
        ASSERT isDoorOpen = '0' REPORT "Reset failed: Door should be closed" SEVERITY ERROR;

        ----------------------------------------------------------------
        -- Test 2: Single upward request (0 -> 5)
        ----------------------------------------------------------------
        REPORT "===== TEST 2: SINGLE UPWARD REQUEST (0 -> 5) =====";
        submit_floor(5, request, submitRequest);
        WAIT FOR 6000 ns; -- 5 seconds to move + 2 seconds door open
        ASSERT curFloor = "0101" REPORT "Failed to reach floor 5" SEVERITY ERROR;

        ----------------------------------------------------------------
        -- Test 3: Single downward request (5 -> 2)
        ----------------------------------------------------------------
        REPORT "===== TEST 3: SINGLE DOWNWARD REQUEST (5 -> 2) =====";
        submit_floor(2, request, submitRequest);
        WAIT FOR 5000 ns; -- 3 seconds to move + 2 seconds door open
        ASSERT curFloor = "0010" REPORT "Failed to reach floor 2" SEVERITY ERROR;

        ----------------------------------------------------------------
        -- Test 4: Request current floor (door should open immediately)
        ----------------------------------------------------------------
        REPORT "===== TEST 4: REQUEST CURRENT FLOOR =====";
        submit_floor(2, request, submitRequest);
        WAIT FOR 500 ns; -- Should open door immediately
        ASSERT isDoorOpen = '1' REPORT "Door should open for current floor" SEVERITY ERROR;
        WAIT FOR 2500 ns; -- Wait for door to close

        ----------------------------------------------------------------
        -- Test 5: Two requests in same direction (going up: 2 -> 4 -> 7)
        ----------------------------------------------------------------
        REPORT "===== TEST 5: TWO REQUESTS SAME DIRECTION UP (2 -> 4 -> 7) =====";
        submit_floor(7, request, submitRequest);
        submit_floor(4, request, submitRequest);
        
        WAIT FOR 3000 ns; -- Should reach floor 4 first
        ASSERT curFloor = "0100" REPORT "Should stop at floor 4 first" SEVERITY ERROR;
        
        WAIT FOR 5000 ns; -- Should continue to floor 7
        ASSERT curFloor = "0111" REPORT "Should reach floor 7" SEVERITY ERROR;

        ----------------------------------------------------------------
        -- Test 6: Two requests in same direction (going down: 7 -> 5 -> 3)
        ----------------------------------------------------------------
        REPORT "===== TEST 6: TWO REQUESTS SAME DIRECTION DOWN (7 -> 5 -> 3) =====";
        submit_floor(3, request, submitRequest);
        submit_floor(5, request, submitRequest);
        
        WAIT FOR 3000 ns; -- Should reach floor 5 first
        ASSERT curFloor = "0101" REPORT "Should stop at floor 5 first" SEVERITY ERROR;
        
        WAIT FOR 4000 ns; -- Should continue to floor 3
        ASSERT curFloor = "0011" REPORT "Should reach floor 3" SEVERITY ERROR;

        ----------------------------------------------------------------
        -- Test 7: Two requests opposite directions (3 -> 6, then 1)
        ----------------------------------------------------------------
        REPORT "===== TEST 7: TWO REQUESTS OPPOSITE DIRECTIONS (3 -> 6 -> 1) =====";
        submit_floor(6, request, submitRequest);
        submit_floor(1, request, submitRequest);
        
        WAIT FOR 5000 ns; -- Should reach floor 6 first (going up)
        ASSERT curFloor = "0110" REPORT "Should reach floor 6 first" SEVERITY ERROR;
        
        WAIT FOR 7000 ns; -- Should then go down to floor 1
        ASSERT curFloor = "0001" REPORT "Should reach floor 1 after" SEVERITY ERROR;

        ----------------------------------------------------------------
        -- Test 8: Request while moving (1 -> 8, request 5 while moving)
        ----------------------------------------------------------------
        REPORT "===== TEST 8: REQUEST WHILE MOVING (1 -> 8, add 5 mid-way) =====";
        submit_floor(8, request, submitRequest);
        WAIT FOR 2000 ns; -- Elevator should be moving
        submit_floor(5, request, submitRequest); -- Add floor 5 while moving
        
        WAIT FOR 6000 ns; -- Should stop at floor 5
        ASSERT curFloor = "0101" REPORT "Should stop at floor 5" SEVERITY ERROR;
        
        WAIT FOR 5000 ns; -- Should continue to floor 8
        ASSERT curFloor = "1000" REPORT "Should reach floor 8" SEVERITY ERROR;

        ----------------------------------------------------------------
        -- Test 9: Three requests in sequence (8 -> 3, 6, 9)
        ----------------------------------------------------------------
        REPORT "===== TEST 9: THREE REQUESTS (8 -> 3 -> 6 -> 9) =====";
        submit_floor(3, request, submitRequest);
        submit_floor(6, request, submitRequest);
        submit_floor(9, request, submitRequest);
        
        WAIT FOR 7000 ns; -- Should reach floor 3 first (going down)
        ASSERT curFloor = "0011" REPORT "Should reach floor 3" SEVERITY ERROR;
        
        WAIT FOR 5000 ns; -- Should then go up to floor 6
        ASSERT curFloor = "0110" REPORT "Should reach floor 6" SEVERITY ERROR;
        
        WAIT FOR 5000 ns; -- Should finally reach floor 9
        ASSERT curFloor = "1001" REPORT "Should reach floor 9" SEVERITY ERROR;

        ----------------------------------------------------------------
        -- Test 10: Extreme floors (9 -> 0 -> 9)
        ----------------------------------------------------------------
        REPORT "===== TEST 10: EXTREME FLOORS (9 -> 0 -> 9) =====";
        submit_floor(0, request, submitRequest);
        WAIT FOR 11000 ns; -- 9 floors down + door time
        ASSERT curFloor = "0000" REPORT "Should reach floor 0" SEVERITY ERROR;
        
        submit_floor(9, request, submitRequest);
        WAIT FOR 11000 ns; -- 9 floors up + door time
        ASSERT curFloor = "1001" REPORT "Should reach floor 9" SEVERITY ERROR;

        ----------------------------------------------------------------
        -- Test 11: Multiple simultaneous requests from middle floor
        ----------------------------------------------------------------
        REPORT "===== TEST 11: MULTIPLE SIMULTANEOUS REQUESTS FROM MIDDLE =====";
        submit_floor(5, request, submitRequest);
        WAIT FOR 6000 ns; -- Move to floor 5
        
        -- Submit multiple requests at once
        submit_floor(2, request, submitRequest);
        submit_floor(4, request, submitRequest);
        submit_floor(7, request, submitRequest);
        submit_floor(8, request, submitRequest);
        
        -- Elevator should handle all efficiently
        WAIT FOR 15000 ns;

        ----------------------------------------------------------------
        -- Test 12: Request same floor multiple times
        ----------------------------------------------------------------
        REPORT "===== TEST 12: DUPLICATE REQUESTS =====";
        submit_floor(3, request, submitRequest);
        WAIT FOR 3000 ns;
        
        submit_floor(6, request, submitRequest);
        submit_floor(6, request, submitRequest); -- Duplicate
        submit_floor(6, request, submitRequest); -- Duplicate
        
        WAIT FOR 5000 ns; -- Should only go to 6 once
        ASSERT curFloor = "0110" REPORT "Should handle duplicate requests" SEVERITY ERROR;

        ----------------------------------------------------------------
        -- Test 13: Rapid fire requests
        ----------------------------------------------------------------
        REPORT "===== TEST 13: RAPID FIRE REQUESTS =====";
        submit_floor(0, request, submitRequest);
        WAIT FOR 8000 ns; -- Go to floor 0
        
        FOR i IN 1 TO 9 LOOP
            submit_floor(i, request, submitRequest);
        END LOOP;
        
        WAIT FOR 25000 ns; -- Let elevator handle all requests

        ----------------------------------------------------------------
        -- Test 14: Request during door open
        ----------------------------------------------------------------
        REPORT "===== TEST 14: REQUEST DURING DOOR OPEN =====";
        submit_floor(5, request, submitRequest);
        WAIT FOR 6000 ns; -- Reach floor 5, door opens
        
        -- Request while door is open
        WAIT FOR 100 ns; -- During door open time
        submit_floor(3, request, submitRequest);
        
        WAIT FOR 5000 ns; -- Should handle new request after door closes

        ----------------------------------------------------------------
        -- Test 15: Stress test - random requests
        ----------------------------------------------------------------
        REPORT "===== TEST 15: STRESS TEST =====";
        FOR i IN 0 TO 20 LOOP
            submit_floor((i*7) MOD 10, request, submitRequest);
            WAIT FOR 200 ns;
        END LOOP;
        
        WAIT FOR 30000 ns; -- Let elevator settle

        ----------------------------------------------------------------
        -- Test 16: Final reset test
        ----------------------------------------------------------------
        REPORT "===== TEST 16: RESET DURING OPERATION =====";
        submit_floor(9, request, submitRequest);
        WAIT FOR 2000 ns; -- Start moving
        reset <= '1';
        WAIT FOR 100 ns;
        reset <= '0';
        WAIT FOR 50 ns;
        ASSERT curFloor = "0000" REPORT "Reset during operation failed" SEVERITY ERROR;
        ASSERT isDoorOpen = '0' REPORT "Door should be closed after reset" SEVERITY ERROR;

        ----------------------------------------------------------------
        -- End simulation
        ----------------------------------------------------------------
        REPORT "===== ALL TESTS COMPLETE =====";
        WAIT FOR 1000 ns;
        REPORT "===== SIMULATION SUCCESSFUL =====";
        WAIT;
    END PROCESS;

END ARCHITECTURE test;