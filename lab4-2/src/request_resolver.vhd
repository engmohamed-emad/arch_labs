library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity request_resolver is
  generic (N_FLOORS : integer := 10);
  port (
    clk          : in std_logic;
    reset        : in std_logic;
    req_vector   : in std_logic_vector(N_FLOORS-1 downto 0); -- OR of all requests
    current_floor: in integer range 0 to N_FLOORS-1;
    direction_up : in std_logic; -- '1' = up, '0' = down or idle
    has_request  : out std_logic;
    next_floor   : out integer range 0 to N_FLOORS-1
  );
end entity;

architecture behavioral of request_resolver is

  -- Function to check if any bit is '1'
  function any_request(vec : std_logic_vector) return boolean is
  begin
    for i in vec'range loop
      if vec(i) = '1' then
        return true;
      end if;
    end loop;
    return false;
  end function;

begin
  process(req_vector, current_floor, direction_up)
    variable found : boolean;
    variable i : integer;
  begin
    has_request <= '0';
    next_floor <= current_floor; -- default
    -- quick check for any request
    if any_request(req_vector) then
      has_request <= '1';
      if direction_up = '1' then
        -- search for lowest request above current
        found := false;
        for i in current_floor+1 to N_FLOORS-1 loop
          if req_vector(i) = '1' then
            next_floor <= i;
            found := true;
            exit;
          end if;
        end loop;
        if not found then
          -- pick highest below
          for i in current_floor-1 downto 0 loop
            if req_vector(i) = '1' then
              next_floor <= i;
              exit;
            end if;
          end loop;
        end if;
      else
        -- direction down or idle: search for highest request below current
        found := false;
        for i in current_floor-1 downto 0 loop
          if req_vector(i) = '1' then
            next_floor <= i;
            found := true;
            exit;
          end if;
        end loop;
        if not found then
          -- pick lowest above
          for i in current_floor+1 to N_FLOORS-1 loop
            if req_vector(i) = '1' then
              next_floor <= i;
              exit;
            end if;
          end loop;
        end if;
      end if;
    end if;
  end process;
end architecture;
