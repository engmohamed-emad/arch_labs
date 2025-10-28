library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unit_control is
  generic (N_FLOORS : integer := 10);
  port (
    clk         : in std_logic;
    reset       : in std_logic;
    sec_tick    : in std_logic; -- 1 sec tick
    req_vector  : in std_logic_vector(N_FLOORS-1 downto 0);
    current_floor_out : out integer range 0 to N_FLOORS-1;
    door_open   : out std_logic;
    moving      : out std_logic;
    dir_up      : out std_logic
  );
end entity;

architecture fsm of unit_control is
  type state_t is (IDLE, START_MOVE, MOVING_STATE, ARRIVE, DOOR_OPEN_STATE);
  signal state : state_t := IDLE;
  signal floor_reg : integer range 0 to N_FLOORS-1 := 0;
  signal move_timer : integer := 0; -- counts sec_tick pulses (need 2 per floor)
  signal door_timer : integer := 0;
  -- signal to hold next target from a resolver (you can instantiate request_resolver)
  signal next_floor : integer range 0 to N_FLOORS-1 := 0;
  signal has_req : std_logic := '0';
  signal dir_up_sig : std_logic := '1';
begin
  current_floor_out <= floor_reg;
  moving <= '0';
  door_open <= '0';
  dir_up <= dir_up_sig;

  -- Example: instantiate resolver (not shown here) or do simple selection inline
  -- For brevity, suppose we compute next_floor & has_req externally

  process(clk, reset)
  begin
    if reset = '1' then
      state <= IDLE;
      floor_reg <= 0;
      move_timer <= 0;
      door_timer <= 0;
      dir_up_sig <= '1';
    elsif rising_edge(clk) then
      -- sample sec_tick & implement state machine
      case state is
        when IDLE =>
          if has_req = '1' and next_floor /= floor_reg then
            if next_floor > floor_reg then dir_up_sig <= '1'; else dir_up_sig <= '0'; end if;
            move_timer <= 0;
            state <= START_MOVE;
          elsif has_req = '1' and next_floor = floor_reg then
            -- immediate open door
            door_timer <= 0;
            state <= DOOR_OPEN_STATE;
          end if;
        when START_MOVE =>
          moving <= '1';
          if sec_tick = '1' then
            move_timer <= move_timer + 1;
            if move_timer = 1 then  -- second tick (0->1 -> after next sec_tick it will be 2)
              -- complete movement of one floor after 2 ticks -> update floor
              if dir_up_sig = '1' then
                floor_reg <= floor_reg + 1;
              else
                floor_reg <= floor_reg - 1;
              end if;
              move_timer <= 0;
              -- check arrival
              if floor_reg = next_floor then
                moving <= '0';
                door_timer <= 0;
                state <= DOOR_OPEN_STATE;
              else
                -- continue moving
                state <= MOVING_STATE;
              end if;
            end if;
          end if;
        when MOVING_STATE =>
          moving <= '1';
          if sec_tick = '1' then
            move_timer <= move_timer + 1;
            if move_timer = 2-1 then -- after two ticks
              if dir_up_sig = '1' then
                floor_reg <= floor_reg + 1;
              else
                floor_reg <= floor_reg - 1;
              end if;
              move_timer <= 0;
              if floor_reg = next_floor then
                moving <= '0';
                door_timer <= 0;
                state <= DOOR_OPEN_STATE;
              end if;
            end if;
          end if;
        when DOOR_OPEN_STATE =>
          door_open <= '1';
          if sec_tick = '1' then
            door_timer <= door_timer + 1;
            if door_timer >= 2 then
              -- after 2 seconds, clear serviced request for this floor and decide next
              -- (you need to update req_vector externally or here)
              state <= IDLE; -- or decide next move if requests exist
            end if;
          end if;
        when others =>
          state <= IDLE;
      end case;
    end if;
  end process;
end architecture;
