LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY elevator IS
    PORT (
        clk           : IN  STD_LOGIC;
        reset         : IN  STD_LOGIC;
        submitRequest : IN  STD_LOGIC;
        request       : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        isDoorOpen    : OUT STD_LOGIC;
        isMoving      : OUT STD_LOGIC;
        curFloor      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        curFloor7seg  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END ENTITY elevator;

ARCHITECTURE behavior OF elevator IS

    -- states
    TYPE state_type IS (ST_IDLE, ST_MOVING_UP, ST_MOVING_DOWN, ST_DOOR_OPEN);
    SIGNAL cur_state  : state_type := ST_IDLE;
    SIGNAL next_state : state_type := ST_IDLE;

    -- requests bitmap: bit 9 = floor 9 ... bit 0 = floor 0
    SIGNAL requests : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');

    -- target floor (4 bits) "1111" means none
    SIGNAL targetFloor : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";

    -- floor register
    SIGNAL floor_reg : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";

    -- tick generator (produces sec_tick = '1' every SEC_TICKS clock cycles)
    CONSTANT SEC_TICKS : INTEGER := 10; -- adjust for simulation / real clock
    SIGNAL sec_cnt : INTEGER RANGE 0 TO SEC_TICKS := 0;
    SIGNAL sec_tick : STD_LOGIC := '0';

    -- door timer (counts sec_ticks while door open)
    CONSTANT DOOR_TICKS : INTEGER := 2; -- how many sec_ticks door stays open
    SIGNAL door_cnt : INTEGER RANGE 0 TO DOOR_TICKS := 0;

    -- helper signals
    SIGNAL hasRequest : STD_LOGIC := '0';
    SIGNAL moving_dir : STD_LOGIC := '1'; -- '1' = up, '0' = down (last direction)

    -- simple 7-seg placeholder (not a full driver)
    FUNCTION seven_seg(n : INTEGER) RETURN STD_LOGIC_VECTOR IS
        VARIABLE seg : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '1');
    BEGIN
        CASE n IS
            WHEN 0 => seg := "0000001"; -- not real mapping; placeholder
            WHEN 1 => seg := "1001111";
            WHEN 2 => seg := "0010010";
            WHEN 3 => seg := "0000110";
            WHEN 4 => seg := "1001100";
            WHEN 5 => seg := "0100100";
            WHEN 6 => seg := "0100000";
            WHEN 7 => seg := "0001111";
            WHEN 8 => seg := "0000000";
            WHEN 9 => seg := "0000100";
            WHEN OTHERS => seg := (OTHERS => '1');
        END CASE;
        RETURN seg;
    END FUNCTION;

    -- helper functions to find next targets
    FUNCTION find_next_up(cur : INTEGER; reqs : STD_LOGIC_VECTOR) RETURN INTEGER IS
        VARIABLE i : INTEGER;
    BEGIN
        FOR i IN cur+1 TO 9 LOOP
            IF reqs(i) = '1' THEN
                RETURN i;
            END IF;
        END LOOP;
        RETURN -1;
    END FUNCTION;

    FUNCTION find_next_down(cur : INTEGER; reqs : STD_LOGIC_VECTOR) RETURN INTEGER IS
        VARIABLE i : INTEGER;
    BEGIN
        FOR i IN cur-1 DOWNTO 0 LOOP
            IF reqs(i) = '1' THEN
                RETURN i;
            END IF;
        END LOOP;
        RETURN -1;
    END FUNCTION;

BEGIN

    ----------------------------------------------------------------------------
    -- Synchronous tick generator + request storage + state register
    ----------------------------------------------------------------------------
    sync_proc : PROCESS(clk, reset)
    BEGIN
        IF reset = '1' THEN
            sec_cnt    <= 0;
            sec_tick   <= '0';
            requests   <= (OTHERS => '0');
            floor_reg  <= "0000";
            cur_state  <= ST_IDLE;
            -- next_state <= ST_IDLE;
            targetFloor<= "1111";
            door_cnt   <= 0;
            hasRequest <= '0';
            moving_dir <= '1';
        ELSIF rising_edge(clk) THEN

            -- tick generator
            IF sec_cnt = SEC_TICKS - 1 THEN
                sec_cnt  <= 0;
                sec_tick <= '1';
            ELSE
                sec_cnt  <= sec_cnt + 1;
                sec_tick <= '0';
            END IF;

            -- store incoming request on submitRequest
            IF submitRequest = '1' THEN
                -- request input is 4-bit floor; validate range 0..9
                IF unsigned(request) <= 9 THEN
                    requests(to_integer(unsigned(request))) <= '1';
                END IF;
            END IF;

            -- update state register
            cur_state <= next_state;

            -- movement on sec_tick (one floor per sec_tick)
            IF sec_tick = '1' THEN
                IF next_state = ST_MOVING_UP THEN
                    -- increment with bounds check
                    IF unsigned(floor_reg) < 9 THEN
                        floor_reg <= STD_LOGIC_VECTOR(unsigned(floor_reg) + 1);
                    END IF;
                ELSIF next_state = ST_MOVING_DOWN THEN
                    IF unsigned(floor_reg) > 0 THEN
                        floor_reg <= STD_LOGIC_VECTOR(unsigned(floor_reg) - 1);
                    END IF;
                ELSIF next_state = ST_DOOR_OPEN THEN
                    -- door timer
                    IF door_cnt < DOOR_TICKS THEN
                        door_cnt <= door_cnt + 1;
                    END IF;
                END IF;
            END IF;

            -- when we reach target floor (synchronous check after movement tick)
            IF sec_tick = '1' THEN
                IF targetFloor /= "1111" AND floor_reg = targetFloor THEN
                    -- clear the served request bit
                    requests(to_integer(unsigned(floor_reg))) <= '0';
                    -- open door and reset door timer
                    door_cnt <= 0;
                    next_state <= ST_DOOR_OPEN;
                END IF;
            END IF;

            -- update hasRequest flag (synchronous)
            IF requests /=  "0000000000" THEN
                hasRequest <= '1';
            ELSE
                hasRequest <= '0';
            END IF;

        END IF;
    END PROCESS sync_proc;

    ----------------------------------------------------------------------------
    -- Combinational next-state and target selection logic
    ----------------------------------------------------------------------------
    comb_next : PROCESS(cur_state, floor_reg, requests, hasRequest)
        VARIABLE cur_idx : INTEGER := 0;
        VARIABLE up_idx  : INTEGER := -1;
        VARIABLE down_idx: INTEGER := -1;
    BEGIN
        -- defaults
        next_state <= cur_state;
        targetFloor <= "1111";

        cur_idx := to_integer(unsigned(floor_reg));

        IF hasRequest = '0' THEN
            -- no requests: idle
            next_state <= ST_IDLE;
            targetFloor <= "1111";
        ELSE
            -- find up and down nearest requests
            up_idx   := find_next_up(cur_idx, requests);
            down_idx := find_next_down(cur_idx, requests);

            CASE cur_state IS
                WHEN ST_IDLE =>
                    -- choose direction: prefer up if found, else down
                    IF up_idx /= -1 THEN
                        next_state <= ST_MOVING_UP;
                        targetFloor <= STD_LOGIC_VECTOR(to_unsigned(up_idx, 4));
                        moving_dir <= '1';
                    ELSIF down_idx /= -1 THEN
                        next_state <= ST_MOVING_DOWN;
                        targetFloor <= STD_LOGIC_VECTOR(to_unsigned(down_idx, 4));
                        moving_dir <= '0';
                    ELSE
                        next_state <= ST_IDLE;
                        targetFloor <= "1111";
                    END IF;

                WHEN ST_MOVING_UP =>
                    -- continue moving up while there is any higher request
                    IF up_idx /= -1 THEN
                        next_state <= ST_MOVING_UP;
                        targetFloor <= STD_LOGIC_VECTOR(to_unsigned(up_idx, 4));
                        moving_dir <= '1';
                    ELSIF down_idx /= -1 THEN
                        next_state <= ST_MOVING_DOWN;
                        targetFloor <= STD_LOGIC_VECTOR(to_unsigned(down_idx, 4));
                        moving_dir <= '0';
                    ELSE
                        next_state <= ST_IDLE;
                        targetFloor <= "1111";
                    END IF;

                WHEN ST_MOVING_DOWN =>
                    IF down_idx /= -1 THEN
                        next_state <= ST_MOVING_DOWN;
                        targetFloor <= STD_LOGIC_VECTOR(to_unsigned(down_idx, 4));
                        moving_dir <= '0';
                    ELSIF up_idx /= -1 THEN
                        next_state <= ST_MOVING_UP;
                        targetFloor <= STD_LOGIC_VECTOR(to_unsigned(up_idx, 4));
                        moving_dir <= '1';
                    ELSE
                        next_state <= ST_IDLE;
                        targetFloor <= "1111";
                    END IF;

                WHEN ST_DOOR_OPEN =>
                    -- wait until door timer is done, then pick next
                    IF door_cnt >= DOOR_TICKS THEN
                        -- choose next request (prefer same direction)
                        IF moving_dir = '1' THEN
                            up_idx := find_next_up(cur_idx, requests);
                            IF up_idx /= -1 THEN
                                next_state <= ST_MOVING_UP;
                                targetFloor <= STD_LOGIC_VECTOR(to_unsigned(up_idx,4));
                            ELSE
                                down_idx := find_next_down(cur_idx, requests);
                                IF down_idx /= -1 THEN
                                    next_state <= ST_MOVING_DOWN;
                                    targetFloor <= STD_LOGIC_VECTOR(to_unsigned(down_idx,4));
                                    moving_dir <= '0';
                                ELSE
                                    next_state <= ST_IDLE;
                                    targetFloor <= "1111";
                                END IF;
                            END IF;
                        ELSE
                            down_idx := find_next_down(cur_idx, requests);
                            IF down_idx /= -1 THEN
                                next_state <= ST_MOVING_DOWN;
                                targetFloor <= STD_LOGIC_VECTOR(to_unsigned(down_idx,4));
                            ELSE
                                up_idx := find_next_up(cur_idx, requests);
                                IF up_idx /= -1 THEN
                                    next_state <= ST_MOVING_UP;
                                    targetFloor <= STD_LOGIC_VECTOR(to_unsigned(up_idx,4));
                                    moving_dir <= '1';
                                ELSE
                                    next_state <= ST_IDLE;
                                    targetFloor <= "1111";
                                END IF;
                            END IF;
                        END IF;
                    ELSE
                        next_state <= ST_DOOR_OPEN;
                    END IF;

                WHEN OTHERS =>
                    next_state <= ST_IDLE;
            END CASE;
        END IF;
    END PROCESS comb_next;

    ----------------------------------------------------------------------------
    -- Output assignments
    ----------------------------------------------------------------------------
        curFloor <= floor_reg;
        isMoving <= '1' WHEN (cur_state = ST_MOVING_UP OR cur_state = ST_MOVING_DOWN) ELSE '0';
        isDoorOpen <= '1' WHEN (cur_state = ST_DOOR_OPEN) ELSE '0';

        -- map to 7seg (simple)
        curFloor7seg <= seven_seg(to_integer(unsigned(floor_reg)));
    -- END PROCESS outputs_proc;

END ARCHITECTURE behavior;
