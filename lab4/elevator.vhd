-- filepath: d:\assignments\vhdl\arch_labs\lab4\elevator.vhd
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY elevator IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        req : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        floor : OUT unsigned(3 DOWNTO 0);
        door_open : OUT STD_LOGIC;
        moving_up : OUT STD_LOGIC;
        moving_down : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE rtl OF elevator IS

    -- Define state type with unique names (use ST_ prefixes used throughout the code)
    TYPE state_type IS (ST_IDLE, ST_MOVING_UP, ST_MOVING_DOWN, ST_DOOR_OPEN);
    SIGNAL state, next_state : state_type;

    SIGNAL current_floor : unsigned(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL target_floor : unsigned(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL timer : unsigned(1 DOWNTO 0) := (OTHERS => '0'); -- counts seconds (0..3)
    SIGNAL clk_1s_en : STD_LOGIC := '0'; -- 1 sec enable

    SIGNAL req_latched : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL next_req_up : unsigned(3 DOWNTO 0);
    SIGNAL next_req_down : unsigned(3 DOWNTO 0);
    SIGNAL req_pending : STD_LOGIC;

BEGIN

    -- 1 sec clock enable generator (assuming 50MHz clk)
    PROCESS (clk, reset)
        VARIABLE cnt : INTEGER RANGE 0 TO 49999999 := 0;
    BEGIN
        IF reset = '1' THEN
            cnt := 0;
            clk_1s_en <= '0';
        ELSIF rising_edge(clk) THEN
            IF cnt = 49999999 THEN
                clk_1s_en <= '1';
                cnt := 0;
            ELSE
                clk_1s_en <= '0';
                cnt := cnt + 1;
            END IF;
        END IF;
    END PROCESS;

    -- Latch requests
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            req_latched <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            req_latched <= req_latched OR req;
        END IF;
    END PROCESS;

    -- Request resolver: find next requested floor above/below current
    PROCESS (req_latched, current_floor)
    BEGIN
        next_req_up <= current_floor;
        next_req_down <= current_floor;
        req_pending <= '0';
        -- Up direction (guard against current_floor = 9)
        IF to_integer(current_floor) < 9 THEN
            FOR i IN to_integer(current_floor) + 1 TO 9 LOOP
                IF req_latched(i) = '1' THEN
                    next_req_up <= to_unsigned(i, 4);
                    req_pending <= '1';
                    EXIT;
                END IF;
            END LOOP;
        END IF;
            -- Down direction (guard against current_floor = 0)
            IF to_integer(current_floor) > 0 THEN
                FOR i IN to_integer(current_floor) - 1 DOWNTO 0 LOOP
                    IF req_latched(i) = '1' THEN
                        next_req_down <= to_unsigned(i, 4);
                        req_pending <= '1';
                        EXIT;
                    END IF;
                END LOOP;
            END IF;
            
        END PROCESS; -- End of the previous process
        -- FSM: Elevator control
        PROCESS (clk, reset)
        BEGIN
            IF reset = '1' THEN
                state <= ST_IDLE;
                current_floor <= (OTHERS => '0');
                timer <= (OTHERS => '0');
                target_floor <= (OTHERS => '0');
            ELSIF rising_edge(clk) THEN
                IF clk_1s_en = '1' THEN
                    state <= next_state;
                    -- Movement and timer logic
                    CASE state IS
                        WHEN ST_MOVING_UP =>
                            IF current_floor < target_floor THEN
                                IF timer = to_unsigned(2, 2) THEN -- 2 seconds
                                    current_floor <= current_floor + 1;
                                    timer <= (OTHERS => '0');
                                ELSE
                                    timer <= timer + 1;
                                END IF;
                            END IF;
                        WHEN ST_MOVING_DOWN =>
                            IF current_floor > target_floor THEN
                                IF timer = to_unsigned(2, 2) THEN -- 2 seconds
                                    current_floor <= current_floor - 1;
                                    timer <= (OTHERS => '0');
                                ELSE
                                    timer <= timer + 1;
                                END IF;
                            END IF;
                        WHEN ST_DOOR_OPEN =>
                            IF timer < to_unsigned(2, 2) THEN
                                timer <= timer + 1;
                            ELSE
                                timer <= (OTHERS => '0');
                            END IF;
                        WHEN OTHERS =>
                            timer <= (OTHERS => '0');
                    END CASE;
                END IF;
            END IF;
        END PROCESS;
        -- Next state logic
        PROCESS (state, req_pending, current_floor, next_req_up, next_req_down, target_floor, timer, req_latched)
            VARIABLE v_next_state : state_type;
            VARIABLE v_target_floor : unsigned(3 DOWNTO 0);
        BEGIN
            v_next_state := state;
            v_target_floor := current_floor;
            CASE state IS
                WHEN ST_IDLE =>
                    IF req_pending = '1' THEN
                        IF next_req_up > current_floor THEN
                            v_next_state := ST_MOVING_UP;
                            v_target_floor := next_req_up;
                        ELSIF next_req_down < current_floor THEN
                            v_next_state := ST_MOVING_DOWN;
                            v_target_floor := next_req_down;
                        ELSIF req_latched(to_integer(current_floor)) = '1' THEN
                            v_next_state := ST_DOOR_OPEN;
                        END IF;
                    END IF;
                WHEN ST_MOVING_UP =>
                    IF current_floor = target_floor THEN
                        v_next_state := ST_DOOR_OPEN;
                    END IF;
                WHEN ST_MOVING_DOWN =>
                    IF current_floor = target_floor THEN
                        v_next_state := ST_DOOR_OPEN;
                    END IF;
                WHEN ST_DOOR_OPEN =>
                    IF timer = to_unsigned(2, 2) THEN -- 2 seconds
                        v_next_state := ST_IDLE;
                    END IF;
                WHEN OTHERS =>
                    v_next_state := ST_IDLE;
            END CASE;
            next_state <= v_next_state;
            target_floor <= v_target_floor;
        END PROCESS;
        -- Clear request for current floor after door opens
        PROCESS (clk, reset)
        BEGIN
            IF reset = '1' THEN
                req_latched <= (OTHERS => '0');
            ELSIF rising_edge(clk) THEN
                IF state = ST_DOOR_OPEN AND timer = to_unsigned(2, 2) THEN
                    req_latched(to_integer(current_floor)) <= '0';
                END IF;
            END IF;
        END PROCESS;
        req_latched(to_integer(current_floor)) <= '0';
        -- Output logic
        floor <= unsigned(current_floor);
        door_open <= '1' WHEN state = ST_DOOR_OPEN ELSE
            '0';
        moving_up <= '1' WHEN state = ST_MOVING_UP ELSE
            '0';
        moving_down <= '1' WHEN state = ST_MOVING_DOWN ELSE
            '0';
        -- Removed duplicate assignments and undefined states

    END ARCHITECTURE rtl;