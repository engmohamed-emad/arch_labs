LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
ENTITY elevator IS PORT (
    clk, reset, submitRequest : IN STD_LOGIC;
    request : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    isDoorOpen, isMoving : OUT STD_LOGIC;
    curFloor : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    curFloor7seg : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
);
END ENTITY elevator;

ARCHITECTURE behavior OF elevator IS
    TYPE state_type IS (ST_IDLE, ST_MOVING_UP, ST_MOVING_DOWN, ST_DOOR_OPEN);
    TYPE requestArray IS ARRAY(0 TO 9) OF STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL requests : requestArray := (OTHERS => "1111");
    SIGNAL curState : state_type := ST_IDLE;
    SIGNAL nextState : state_type := ST_IDLE;
    SIGNAL targetFloor : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
    SIGNAL sec1_en : STD_LOGIC;
    SIGNAL hasRequest : STD_LOGIC;
    SIGNAL second_count : STD_LOGIC;
    SIGNAL cur_floor : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
BEGIN
    seconds_generator : PROCESS (clk, reset)
        VARIABLE cnt : INTEGER RANGE 0 TO 10 := 0;
        VARIABLE lastState : state_type := ST_IDLE;
    BEGIN
        IF reset = '1' THEN
            cnt := 0;
            sec1_en <= '0';
            lastState := ST_IDLE;
        ELSIF rising_edge(clk) THEN
            IF nextState /= lastState THEN
                cnt := 0;
                sec1_en <= '0';
                lastState := nextState;
            ELSE
                IF cnt = 10 THEN
                    sec1_en <= '1';
                    cnt := 0;
                ELSE
                    sec1_en <= '0';
                    cnt := cnt + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS seconds_generator;
    store_requests : PROCESS (request)
        VARIABLE idx : INTEGER;
    BEGIN
        idx := to_integer(unsigned(request));
        IF submitRequest = '1' THEN
            requests(idx) <= request;
        END IF;
    END PROCESS store_requests;
    check_requests : PROCESS (requests)
        VARIABLE found : BOOLEAN := false;
    BEGIN
        found := false;
        FOR i IN 0 TO 9 LOOP
            IF requests(i) /= "1111" THEN
                found := true;
            END IF;
        END LOOP;
        IF found = true THEN
            hasRequest <= '1';
        ELSE
            hasRequest <= '0';
        END IF;
    END PROCESS check_requests;
    state_manager : PROCESS (targetFloor, cur_floor, reset)
        VARIABLE pastState : state_type;
    BEGIN
        IF reset = '1' THEN
            nextState <= ST_IDLE;
        END IF;
        IF targetFloor /= "1111" THEN
            IF cur_floor = targetFloor THEN
                nextState <= ST_DOOR_OPEN;
            ELSIF cur_floor < targetFloor THEN
                nextState <= ST_MOVING_UP;
            ELSIF cur_floor > targetFloor THEN
                nextState <= ST_MOVING_DOWN;
            ELSE
                nextState <= ST_IDLE;
            END IF;
        END IF;
    END PROCESS state_manager;
    main_logic : PROCESS (clk)
        VARIABLE cur_floor_idx : INTEGER;
        VARIABLE isup : BOOLEAN;
        VARIABLE isdown : BOOLEAN;
        VARIABLE TIME : INTEGER;
    BEGIN
        IF rising_edge(clk) THEN
            cur_floor_idx := to_integer(unsigned(cur_floor));
            IF reset = '1' THEN
                curState <= ST_IDLE;
                cur_floor <= "0000";
                targetFloor <= "1111";
            ELSIF curState = ST_IDLE AND hasRequest = '1' THEN
                FOR i IN 0 TO 9 LOOP
                    IF requests(i) /= "1111" THEN
                        targetFloor <= requests(i);
                        EXIT;
                    END IF;
                END LOOP;
                IF nextState = ST_MOVING_UP AND sec1_en = '1' THEN
                    cur_floor <= STD_LOGIC_VECTOR(unsigned(cur_floor) + 1);
                    curState <= nextState;
                END IF;
                IF nextState = ST_MOVING_DOWN AND sec1_en = '1' THEN
                    cur_floor <= STD_LOGIC_VECTOR(unsigned(cur_floor) - 1);
                    curState <= nextState;
                END IF;
            ELSIF curState = ST_MOVING_UP AND nextState = ST_DOOR_OPEN THEN
                isup := false;
                isdown := false;
                FOR i IN cur_floor_idx + 1 to 9 LOOP
                    IF requests(i) /= "1111" THEN
                        targetFloor <= requests(i);
                        isup := true;
                        EXIT;
                    END IF;
                END LOOP;
                IF NOT isup THEN
                    FOR i IN  cur_floor_idx - 1 downto 0 LOOP
                        IF requests(i) /= "1111" THEN
                            targetFloor <= requests(i);
                            isdown := true;
                            EXIT;
                        END IF;
                    END LOOP;
                END IF;
                IF NOT isdown THEN
                    targetFloor <= "1111";
                END IF;
                curState <= nextState;
            ELSIF curState = ST_MOVING_DOWN AND nextState = ST_DOOR_OPEN THEN
                isup := false;
                isdown := false;
               FOR i IN  cur_floor_idx - 1 DOWNTO 0 LOOP
                    IF requests(i) /= "1111" THEN
                        targetFloor <= requests(i);
                        isdown := true;
                        EXIT;
                    END IF;
                END LOOP;
                IF NOT isdown THEN
                    FOR i IN cur_floor_idx + 1 TO 9 LOOP
                        IF requests(i) /= "1111" THEN
                            targetFloor <= requests(i);
                            isup := true;
                            EXIT;
                        END IF;
                    END LOOP;
                END IF;
                IF NOT isup THEN
                    targetFloor <= "1111";
                END IF;
                curState <= nextState;
            ELSIF curState = ST_DOOR_OPEN THEN
                IF sec1_en = '1' THEN
                    requests(cur_floor_idx) <= "1111";
                    curState <= nextState;
                END IF;
            END IF;
        END IF;
        curFloor <= cur_floor;
    END PROCESS main_logic;
END behavior;