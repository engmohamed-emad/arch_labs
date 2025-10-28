-- filepath: d:\assignments\vhdl\arch_labs\lab4\elevator.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity elevator is
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        req         : in  std_logic_vector(9 downto 0);
        floor       : out std_logic_vector(3 downto 0);
        door_open   : out std_logic;
        moving_up   : out std_logic;
        moving_down : out std_logic
    );
end entity;

architecture rtl of elevator is

    -- Rename state_type literals to avoid name clash with output signals
    type state_type is (ST_IDLE, ST_MOVING_UP, ST_MOVING_DOWN, ST_DOOR_OPEN);
    signal state, next_state : state_type;

    signal current_floor : std_logic_vector(3 downto 0) := (others => '0');
    signal target_floor  : std_logic_vector(3 downto 0) := (others => '0');
    signal timer         : std_logic_vector(1 downto 0) := (others => '0'); -- counts seconds (0..3)
    signal clk_1s_en     : std_logic := '0'; -- 1 sec enable

    signal req_latched   : std_logic_vector(9 downto 0) := (others => '0');
    signal next_req_up   : std_logic_vector(3 downto 0);
    signal next_req_down : std_logic_vector(3 downto 0);
    signal req_pending   : std_logic;

begin

    -- 1 sec clock enable generator (assuming 50MHz clk)
    process(clk, reset)
        variable cnt : integer range 0 to 49999999 := 0;
    begin
        if reset = '1' then
            cnt := 0;
            clk_1s_en <= '0';
        elsif rising_edge(clk) then
            if cnt = 49999999 then
                clk_1s_en <= '1';
                cnt := 0;
            else
                clk_1s_en <= '0';
                cnt := cnt + 1;
            end if;
        end if;
    end process;

    -- Latch requests
    process(clk, reset)
    begin
        if reset = '1' then
            req_latched <= (others => '0');
        elsif rising_edge(clk) then
            req_latched <= req_latched or req;
        end if;
    end process;

    -- Request resolver: find next requested floor above/below current
    process(req_latched, current_floor)
    begin
        next_req_up   <= current_floor;
        next_req_down <= current_floor;
        req_pending   <= '0';
        -- Up direction
        for i in to_integer(current_floor)+1 to 9 loop
            if req_latched(i) = '1' then
                next_req_up <= std_logic_vector(to_unsigned(i, 4));
                req_pending <= '1';
                exit;
            end if;
        end loop;
        -- Down direction
        for i in to_integer(current_floor)-1 downto 0 loop
            if req_latched(i) = '1' then
                next_req_down <= std_logic_vector(to_unsigned(i, 4));
                req_pending <= '1';
                exit;
            end if;
        end loop;
    end process;

    -- FSM: Elevator control
    process(clk, reset)
    begin
        if reset = '1' then
            state        <= ST_IDLE;
            current_floor<= (others => '0');
            timer        <= (others => '0');
            target_floor <= (others => '0');
        elsif rising_edge(clk) then
            if clk_1s_en = '1' then
                state <= next_state;
                -- Movement and timer logic
                case state is
                    when ST_MOVING_UP =>
                        if current_floor < target_floor then
                            if timer = "10" then -- 2 seconds
                                current_floor <= current_floor + 1;
                                timer <= (others => '0');
                            else
                                timer <= timer + 1;
                            end if;
                        end if;
                    when ST_MOVING_DOWN =>
                        if current_floor > target_floor then
                            if timer = "10" then -- 2 seconds
                                current_floor <= current_floor - 1;
                                timer <= (others => '0');
                            else
                                timer <= timer + 1;
                            end if;
                        end if;
                    when ST_DOOR_OPEN =>
                        if timer < "10" then
                            timer <= timer + 1;
                        else
                            timer <= (others => '0');
                        end if;
                    when others =>
                        timer <= (others => '0');
                end case;
            end if;
        end if;
    end process;

    -- Next state logic
    process(state, req_pending, current_floor, next_req_up, next_req_down, target_floor, timer, req_latched)
        variable v_next_state   : state_type;
        variable v_target_floor : unsigned(3 downto 0);
    begin
        v_next_state   := state;
        v_target_floor := current_floor;
        case state is
            when ST_IDLE =>
                if req_pending = '1' then
                    if next_req_up > current_floor then
                        v_next_state   := ST_MOVING_UP;
                        v_target_floor := next_req_up;
                    elsif next_req_down < current_floor then
                        v_next_state   := ST_MOVING_DOWN;
                        v_target_floor := next_req_down;
                    elsif req_latched(to_integer(current_floor)) = '1' then
                        v_next_state := ST_DOOR_OPEN;
                    end if;
                end if;
            when ST_MOVING_UP =>
                if current_floor = target_floor then
                    v_next_state := ST_DOOR_OPEN;
                end if;
            when ST_MOVING_DOWN =>
                if current_floor = target_floor then
                    v_next_state := ST_DOOR_OPEN;
                end if;
            when ST_DOOR_OPEN =>
                if timer = "10" then -- 2 seconds
                    v_next_state := ST_IDLE;
                end if;
            when others =>
                v_next_state := ST_IDLE;
        end case;
        next_state   <= v_next_state;
        target_floor <= v_target_floor;
    end process;

    -- Clear request for current floor after door opens
    process(clk, reset)
    begin
        if reset = '1' then
            req_latched <= (others => '0');
        elsif rising_edge(clk) then
            if state = ST_DOOR_OPEN and timer = "10" then
                req_latched(to_integer(current_floor)) <= '0';
            end if;
        end if;
    end process;

    -- Output logic
    floor      <= current_floor;
    door_open  <= '1' when state = ST_DOOR_OPEN else '0';
    moving_up  <= '1' when state = ST_MOVING_UP else '0';
    moving_down<= '1' when state = ST_MOVING_DOWN else '0';

end architecture;