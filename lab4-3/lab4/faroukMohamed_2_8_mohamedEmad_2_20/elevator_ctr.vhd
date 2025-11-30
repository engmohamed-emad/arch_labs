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

    -- FSM states
    TYPE state_type IS (ST_IDLE, ST_MOVING_UP, ST_MOVING_DOWN, ST_DOOR_OPEN);
    SIGNAL cur_state  : state_type := ST_IDLE;
    SIGNAL next_state : state_type := ST_IDLE;

    -- requests bitmap (bit 9 = floor 9 ... bit 0 = floor 0)
    SIGNAL requests : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');

    -- target floor (4 bits), "1111" = no target
    SIGNAL targetFloor      : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
    SIGNAL next_targetFloor : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";

    -- current floor
    SIGNAL floor_reg : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";

    -- tick generator (produces sec_tick)
    CONSTANT SEC_TICKS : INTEGER := 10;
    SIGNAL sec_cnt   : INTEGER RANGE 0 TO SEC_TICKS := 0;
    SIGNAL sec_tick  : STD_LOGIC := '0';

    -- door timer
    CONSTANT DOOR_TICKS : INTEGER := 2;
    SIGNAL door_cnt    : INTEGER RANGE 0 TO DOOR_TICKS := 0;

    -- helper signals
    SIGNAL hasRequest : STD_LOGIC := '0';
    SIGNAL moving_dir : STD_LOGIC := '1'; -- '1'=up, '0'=down
    SIGNAL next_moving_dir : STD_LOGIC := '1';

    -- simple 7-seg placeholder
    FUNCTION seven_seg(n : INTEGER) RETURN STD_LOGIC_VECTOR IS
        VARIABLE seg : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '1');
    BEGIN
        CASE n IS
            WHEN 0 => seg := "0000001";
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

    -- find nearest request above current floor
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

    -- find nearest request below current floor
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

    -------------------------------------------------------------------------
    -- Synchronous process: tick generator, request storage, floor updates
    -------------------------------------------------------------------------
    sync_proc : PROCESS(clk, reset)
    BEGIN
        IF reset = '1' THEN
            sec_cnt     <= 0;
            sec_tick    <= '0';
            requests    <= (OTHERS => '0');
            floor_reg   <= "0000";
            cur_state   <= ST_IDLE;
            targetFloor <= "1111";
            door_cnt    <= 0;
            hasRequest  <= '0';
            moving_dir  <= '1';
        ELSIF rising_edge(clk) THEN
            -- tick generator
            IF sec_cnt = SEC_TICKS - 1 THEN
                sec_cnt  <= 0;
                sec_tick <= '1';
            ELSE
                sec_cnt  <= sec_cnt + 1;
                sec_tick <= '0';
            END IF;

            -- store incoming request
            IF submitRequest = '1' THEN
                IF unsigned(request) <= 9 THEN
                    requests(to_integer(unsigned(request))) <= '1';
                END IF;
            END IF;

            -- movement and door timer on sec_tick
            IF sec_tick = '1' THEN
                CASE cur_state IS
                    WHEN ST_MOVING_UP =>
                        IF unsigned(floor_reg) < 9 THEN
                            floor_reg <= STD_LOGIC_VECTOR(unsigned(floor_reg) + 1);
                        END IF;
                        -- check if reached target after movement
                        IF STD_LOGIC_VECTOR(unsigned(floor_reg) + 1) = targetFloor THEN
                            requests(to_integer(unsigned(targetFloor))) <= '0';
                            door_cnt <= 0;
                            cur_state <= ST_DOOR_OPEN;
                        END IF;
                        
                    WHEN ST_MOVING_DOWN =>
                        IF unsigned(floor_reg) > 0 THEN
                            floor_reg <= STD_LOGIC_VECTOR(unsigned(floor_reg) - 1);
                        END IF;
                        -- check if reached target after movement
                        IF STD_LOGIC_VECTOR(unsigned(floor_reg) - 1) = targetFloor THEN
                            requests(to_integer(unsigned(targetFloor))) <= '0';
                            door_cnt <= 0;
                            cur_state <= ST_DOOR_OPEN;
                        END IF;
                        
                    WHEN ST_DOOR_OPEN =>
                        IF door_cnt < DOOR_TICKS THEN
                            door_cnt <= door_cnt + 1;
                        ELSE
                            -- door timer finished, update state from combinational logic
                            cur_state <= next_state;
                            targetFloor <= next_targetFloor;
                            moving_dir <= next_moving_dir;
                        END IF;
                        
                    WHEN ST_IDLE =>
                        -- update state from combinational logic
                        cur_state <= next_state;
                        targetFloor <= next_targetFloor;
                        moving_dir <= next_moving_dir;
                        
                    WHEN OTHERS =>
                        NULL;
                END CASE;
            ELSE
                -- when not on tick, still update state for IDLE and non-door states
                IF cur_state = ST_IDLE OR cur_state = ST_MOVING_UP OR cur_state = ST_MOVING_DOWN THEN
                    IF cur_state /= ST_MOVING_UP OR floor_reg /= targetFloor THEN
                        IF cur_state /= ST_MOVING_DOWN OR floor_reg /= targetFloor THEN
                            cur_state <= next_state;
                            targetFloor <= next_targetFloor;
                            moving_dir <= next_moving_dir;
                        END IF;
                    END IF;
                END IF;
            END IF;

            -- update hasRequest flag
            IF requests /= "0000000000" THEN
                hasRequest <= '1';
            ELSE
                hasRequest <= '0';
            END IF;
        END IF;
    END PROCESS sync_proc;

    -------------------------------------------------------------------------
    -- Combinational next-state and target selection
    -------------------------------------------------------------------------
    comb_next : PROCESS(cur_state, floor_reg, requests, hasRequest, door_cnt, moving_dir)
        VARIABLE cur_idx : INTEGER := 0;
        VARIABLE up_idx  : INTEGER := -1;
        VARIABLE down_idx: INTEGER := -1;
    BEGIN
        -- defaults
        next_state      <= cur_state;
        next_targetFloor <= targetFloor;
        next_moving_dir <= moving_dir;

        cur_idx := to_integer(unsigned(floor_reg));

        CASE cur_state IS
            WHEN ST_IDLE =>
                IF hasRequest = '1' THEN
                    up_idx := find_next_up(cur_idx, requests);
                    down_idx := find_next_down(cur_idx, requests);
                    
                    -- Check current floor first
                    IF requests(cur_idx) = '1' THEN
                        next_state <= ST_DOOR_OPEN;
                        next_targetFloor <= floor_reg;
                    ELSIF up_idx /= -1 THEN
                        next_state <= ST_MOVING_UP;
                        next_targetFloor <= STD_LOGIC_VECTOR(to_unsigned(up_idx,4));
                        next_moving_dir <= '1';
                    ELSIF down_idx /= -1 THEN
                        next_state <= ST_MOVING_DOWN;
                        next_targetFloor <= STD_LOGIC_VECTOR(to_unsigned(down_idx,4));
                        next_moving_dir <= '0';
                    END IF;
                END IF;

            WHEN ST_MOVING_UP =>
                -- Continue moving, target is already set
                next_state <= ST_MOVING_UP;

            WHEN ST_MOVING_DOWN =>
                -- Continue moving, target is already set
                next_state <= ST_MOVING_DOWN;

            WHEN ST_DOOR_OPEN =>
                IF door_cnt >= DOOR_TICKS THEN
                    -- Door timer finished, decide next direction
                    IF hasRequest = '1' THEN
                        up_idx := find_next_up(cur_idx, requests);
                        down_idx := find_next_down(cur_idx, requests);
                        
                        -- Continue in the same direction if possible
                        IF moving_dir = '1' THEN
                            -- Was going up, try to continue up first
                            IF up_idx /= -1 THEN
                                next_state <= ST_MOVING_UP;
                                next_targetFloor <= STD_LOGIC_VECTOR(to_unsigned(up_idx,4));
                                next_moving_dir <= '1';
                            ELSIF down_idx /= -1 THEN
                                -- No more up requests, go down
                                next_state <= ST_MOVING_DOWN;
                                next_targetFloor <= STD_LOGIC_VECTOR(to_unsigned(down_idx,4));
                                next_moving_dir <= '0';
                            ELSE
                                -- No more requests
                                next_state <= ST_IDLE;
                                next_targetFloor <= "1111";
                            END IF;
                        ELSE
                            -- Was going down, try to continue down first
                            IF down_idx /= -1 THEN
                                next_state <= ST_MOVING_DOWN;
                                next_targetFloor <= STD_LOGIC_VECTOR(to_unsigned(down_idx,4));
                                next_moving_dir <= '0';
                            ELSIF up_idx /= -1 THEN
                                -- No more down requests, go up
                                next_state <= ST_MOVING_UP;
                                next_targetFloor <= STD_LOGIC_VECTOR(to_unsigned(up_idx,4));
                                next_moving_dir <= '1';
                            ELSE
                                -- No more requests
                                next_state <= ST_IDLE;
                                next_targetFloor <= "1111";
                            END IF;
                        END IF;
                    ELSE
                        -- No more requests
                        next_state <= ST_IDLE;
                        next_targetFloor <= "1111";
                    END IF;
                ELSE
                    -- Door still open
                    next_state <= ST_DOOR_OPEN;
                END IF;

            WHEN OTHERS =>
                next_state <= ST_IDLE;
                next_targetFloor <= "1111";
        END CASE;
    END PROCESS comb_next;

    -------------------------------------------------------------------------
    -- Output assignments
    -------------------------------------------------------------------------
    curFloor    <= floor_reg;
    isMoving    <= '1' WHEN (cur_state = ST_MOVING_UP OR cur_state = ST_MOVING_DOWN) ELSE '0';
    isDoorOpen  <= '1' WHEN (cur_state = ST_DOOR_OPEN) ELSE '0';
    curFloor7seg<= seven_seg(to_integer(unsigned(floor_reg)));

END ARCHITECTURE behavior;