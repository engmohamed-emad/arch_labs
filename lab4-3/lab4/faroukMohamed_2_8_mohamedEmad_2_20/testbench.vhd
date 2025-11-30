LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY elevator_ctrl_tb IS
END ENTITY;

ARCHITECTURE tb OF elevator_ctrl_tb IS
    CONSTANT NUM_FLOORS : INTEGER := 10;
    CONSTANT CLK_FREQ : INTEGER := 5000000;
    CONSTANT CLK_PERIOD : TIME := 1 sec / CLK_FREQ;

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '1';
    SIGNAL req : STD_LOGIC_VECTOR(NUM_FLOORS-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL floor : UNSIGNED(3 DOWNTO 0);
    SIGNAL door_open : STD_LOGIC;
    SIGNAL moving_up : STD_LOGIC;
    SIGNAL moving_down : STD_LOGIC;

    SIGNAL target_floor : UNSIGNED(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL state : INTEGER RANGE 0 TO 10 := 0;

    COMPONENT elevator IS
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            req : IN STD_LOGIC_VECTOR(NUM_FLOORS-1 DOWNTO 0);
            floor : OUT UNSIGNED(3 DOWNTO 0);
            door_open : OUT STD_LOGIC;
            moving_up : OUT STD_LOGIC;
            moving_down : OUT STD_LOGIC
        );
    END COMPONENT;

BEGIN
    UUT: elevator
        PORT MAP (
            clk => clk,
            reset => reset,
            req => req,
            floor => floor,
            door_open => door_open,
            moving_up => moving_up,
            moving_down => moving_down
        );

    clk_process: PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR CLK_PERIOD/2;
        clk <= '1';
        WAIT FOR CLK_PERIOD/2;
    END PROCESS;

    stimulus: PROCESS

        PROCEDURE request_floor(f : INTEGER) IS
        BEGIN
            req(f) <= '1';
            REPORT ">>> Request made for floor " & INTEGER'IMAGE(f);
            WAIT FOR 0.2 sec;
            req(f) <= '0';
        END PROCEDURE;

    BEGIN
        reset <= '1';
        WAIT FOR 100 ms;
        reset <= '0';
        REPORT "System reset complete.";
        WAIT FOR 200 ms;

        REPORT "=== TEST 1: Single request to floor 3 ===";
        request_floor(3);
        WAIT FOR 3 sec;

        REPORT "=== TEST 2: Multiple simultaneous requests (1, 5, 7) ===";
        req <= "0010100010";
        WAIT FOR 6 sec;
        req <= (OTHERS => '0');

        REPORT "=== TEST 3: Request while moving ===";
        request_floor(2);
        WAIT FOR 1 sec;
        request_floor(8);
        WAIT FOR 5 sec;

        REPORT "=== TEST 4: Downward sequence 4, 2, 0 ===";
        req <= "0000010101";
        WAIT FOR 8 sec;
        req <= (OTHERS => '0');

        REPORT "=== TEST 5: Request current floor ===";
        request_floor(to_integer(floor));
        WAIT FOR 2 sec;

        REPORT "=== TEST 6: Complex mixed requests ===";
        req <= "0101000010";
        WAIT FOR 10 sec;
        req <= (OTHERS => '0');

        REPORT "=== ALL TESTS COMPLETED ===";
        WAIT;
    END PROCESS;

    monitor: PROCESS
        VARIABLE last_floor : INTEGER := -1;
    BEGIN
        WAIT UNTIL rising_edge(clk);
        IF to_integer(floor) /= last_floor THEN
            REPORT ">> Floor changed to " & INTEGER'IMAGE(to_integer(floor)) &
                   " at " & TIME'IMAGE(NOW);
            last_floor := to_integer(floor);
        END IF;

        IF door_open = '1' THEN
            REPORT ">> Door OPEN at floor " & INTEGER'IMAGE(to_integer(floor))
                & " @ " & TIME'IMAGE(NOW);
        END IF;

        IF moving_up = '1' THEN
            REPORT ">> Moving UP @ " & TIME'IMAGE(NOW);
        ELSIF moving_down = '1' THEN
            REPORT ">> Moving DOWN @ " & TIME'IMAGE(NOW);
        END IF;
    END PROCESS;

END ARCHITECTURE;
