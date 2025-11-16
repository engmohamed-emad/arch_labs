LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY elevator IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        submitRequest : IN STD_LOGIC;
        request : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        isDoorOpen : OUT STD_LOGIC;
        isMoving : OUT STD_LOGIC;
        curFloor : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        curFloor7seg : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END ENTITY elevator;

ARCHITECTURE behavior OF elevator IS

    COMPONENT seven_segment_decoder IS
        PORT (
            floor_number : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            segments : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT;

    TYPE state_type IS (ST_IDLE, ST_MOVING_UP, ST_MOVING_DOWN, ST_DOOR_OPEN);
    SIGNAL cur_state : state_type := ST_IDLE;
    SIGNAL next_state : state_type := ST_IDLE;

    SIGNAL requests : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');

    SIGNAL targetFloor : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
    SIGNAL next_targetFloor : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";

    SIGNAL floor_reg : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";

    CONSTANT SEC_TICKS : INTEGER := 10;
    SIGNAL sec_cnt : INTEGER RANGE 0 TO SEC_TICKS := 0;
    SIGNAL sec_tick : STD_LOGIC := '0';

    CONSTANT DOOR_TICKS : INTEGER := 2;
    SIGNAL door_cnt : INTEGER RANGE 0 TO DOOR_TICKS := 0;

    SIGNAL hasRequest : STD_LOGIC := '0';
    SIGNAL moving_dir : STD_LOGIC := '1';
    SIGNAL next_moving_dir : STD_LOGIC := '1';
BEGIN
    seven_seg_inst : seven_segment_decoder
    PORT MAP(
        floor_number => floor_reg,
        segments => curFloor7seg
    );
    sync_proc : PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            sec_cnt <= 0;
            sec_tick <= '0';
            requests <= (OTHERS => '0');
            floor_reg <= "0000";
            cur_state <= ST_IDLE;
            targetFloor <= "1111";
            door_cnt <= 0;
            hasRequest <= '0';
            moving_dir <= '1';
        ELSIF rising_edge(clk) THEN
            IF sec_cnt = SEC_TICKS - 1 THEN
                sec_cnt <= 0;
                sec_tick <= '1';
            ELSE
                sec_cnt <= sec_cnt + 1;
                sec_tick <= '0';
            END IF;

            IF submitRequest = '1' THEN
                IF unsigned(request) <= 9 THEN
                    requests(to_integer(unsigned(request))) <= '1';
                END IF;
            END IF;

            IF sec_tick = '1' THEN
                CASE cur_state IS
                    WHEN ST_MOVING_UP =>
                        IF unsigned(floor_reg) < 9 THEN
                            floor_reg <= STD_LOGIC_VECTOR(unsigned(floor_reg) + 1);
                        END IF;
                        IF STD_LOGIC_VECTOR(unsigned(floor_reg) + 1) = targetFloor THEN
                            requests(to_integer(unsigned(targetFloor))) <= '0';
                            door_cnt <= 0;
                            cur_state <= ST_DOOR_OPEN;
                        END IF;

                    WHEN ST_MOVING_DOWN =>
                        IF unsigned(floor_reg) > 0 THEN
                            floor_reg <= STD_LOGIC_VECTOR(unsigned(floor_reg) - 1);
                        END IF;
                        IF STD_LOGIC_VECTOR(unsigned(floor_reg) - 1) = targetFloor THEN
                            requests(to_integer(unsigned(targetFloor))) <= '0';
                            door_cnt <= 0;
                            cur_state <= ST_DOOR_OPEN;
                        END IF;

                    WHEN ST_DOOR_OPEN =>
                        IF door_cnt < DOOR_TICKS THEN
                            door_cnt <= door_cnt + 1;
                        ELSE
                            cur_state <= next_state;
                            targetFloor <= next_targetFloor;
                            moving_dir <= next_moving_dir;
                        END IF;

                    WHEN ST_IDLE =>
                        cur_state <= next_state;
                        targetFloor <= next_targetFloor;
                        moving_dir <= next_moving_dir;

                    WHEN OTHERS =>
                        NULL;
                END CASE;
            ELSE
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

            IF requests /= "0000000000" THEN
                hasRequest <= '1';
            ELSE
                hasRequest <= '0';
            END IF;
        END IF;
    END PROCESS sync_proc;
    comb_next : PROCESS (cur_state, floor_reg, requests, hasRequest, door_cnt, moving_dir, targetFloor)
        VARIABLE cur_idx : INTEGER;
        VARIABLE up_idx : INTEGER;
        VARIABLE down_idx : INTEGER;
    BEGIN
        next_state <= cur_state;
        next_targetFloor <= targetFloor;
        next_moving_dir <= moving_dir;

        cur_idx := to_integer(unsigned(floor_reg));
        up_idx := - 1;
        down_idx := - 1;

        CASE cur_state IS
            WHEN ST_IDLE =>
                IF hasRequest = '1' THEN
                    FOR i IN 0 TO 9 LOOP
                        IF i > cur_idx AND requests(i) = '1' AND up_idx =- 1 THEN
                            up_idx := i;
                        END IF;
                    END LOOP;

                    FOR i IN 9 DOWNTO 0 LOOP
                        IF i < cur_idx AND requests(i) = '1' AND down_idx =- 1 THEN
                            down_idx := i;
                        END IF;
                    END LOOP;

                    IF requests(cur_idx) = '1' THEN
                        next_state <= ST_DOOR_OPEN;
                        next_targetFloor <= floor_reg;
                    ELSIF up_idx /= - 1 THEN
                        next_state <= ST_MOVING_UP;
                        next_targetFloor <= STD_LOGIC_VECTOR(to_unsigned(up_idx, 4));
                        next_moving_dir <= '1';
                    ELSIF down_idx /= - 1 THEN
                        next_state <= ST_MOVING_DOWN;
                        next_targetFloor <= STD_LOGIC_VECTOR(to_unsigned(down_idx, 4));
                        next_moving_dir <= '0';
                    END IF;
                END IF;

            WHEN ST_MOVING_UP =>
                next_state <= ST_MOVING_UP;

            WHEN ST_MOVING_DOWN =>
                next_state <= ST_MOVING_DOWN;

            WHEN ST_DOOR_OPEN =>
                IF door_cnt >= DOOR_TICKS THEN
                    IF hasRequest = '1' THEN
                        FOR i IN 0 TO 9 LOOP
                            IF i > cur_idx AND requests(i) = '1' AND up_idx =- 1 THEN
                                up_idx := i;
                            END IF;
                        END LOOP;

                        FOR i IN 9 DOWNTO 0 LOOP
                            IF i < cur_idx AND requests(i) = '1' AND down_idx =- 1 THEN
                                down_idx := i;
                            END IF;
                        END LOOP;

                        IF moving_dir = '1' THEN
                            IF up_idx /= - 1 THEN
                                next_state <= ST_MOVING_UP;
                                next_targetFloor <= STD_LOGIC_VECTOR(to_unsigned(up_idx, 4));
                                next_moving_dir <= '1';
                            ELSIF down_idx /= - 1 THEN
                                next_state <= ST_MOVING_DOWN;
                                next_targetFloor <= STD_LOGIC_VECTOR(to_unsigned(down_idx, 4));
                                next_moving_dir <= '0';
                            ELSE
                                next_state <= ST_IDLE;
                                next_targetFloor <= "1111";
                            END IF;
                        ELSE
                            IF down_idx /= - 1 THEN
                                next_state <= ST_MOVING_DOWN;
                                next_targetFloor <= STD_LOGIC_VECTOR(to_unsigned(down_idx, 4));
                                next_moving_dir <= '0';
                            ELSIF up_idx /= - 1 THEN
                                next_state <= ST_MOVING_UP;
                                next_targetFloor <= STD_LOGIC_VECTOR(to_unsigned(up_idx, 4));
                                next_moving_dir <= '1';
                            ELSE
                                next_state <= ST_IDLE;
                                next_targetFloor <= "1111";
                            END IF;
                        END IF;
                    ELSE
                        next_state <= ST_IDLE;
                        next_targetFloor <= "1111";
                    END IF;
                ELSE
                    next_state <= ST_DOOR_OPEN;
                END IF;

            WHEN OTHERS =>
                next_state <= ST_IDLE;
                next_targetFloor <= "1111";
        END CASE;
    END PROCESS comb_next;
    curFloor <= floor_reg;
    isMoving <= '1' WHEN (cur_state = ST_MOVING_UP OR cur_state = ST_MOVING_DOWN) ELSE
        '0';
    isDoorOpen <= '1' WHEN (cur_state = ST_DOOR_OPEN) ELSE
        '0';

END ARCHITECTURE behavior;